// lib/services/quiz_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/quiz_question.dart';
import '../models/song.dart';

class QuizService {
  /// Generate soal menggunakan Gemini AI (prioritas) dengan filter duplikat.
  /// Jika Gemini gagal atau API key tidak ada, gunakan fallback lokal.
  Future<List<QuizQuestion>> generateQuizQuestions(
      List<Song> songs, {
        int numberOfQuestions = 10,
      }) async {
    if (songs.isEmpty) return [];

    // Batasi jumlah soal agar tidak terlalu banyak dari jumlah lagu
    final maxQuestions = songs.length * 2;
    final targetCount = numberOfQuestions > maxQuestions ? maxQuestions : numberOfQuestions;

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      debugPrint('⚠️ GEMINI_API_KEY tidak ditemukan, pakai fallback lokal.');
      return _createFallbackQuestions(songs, targetCount);
    }

    final model = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.9,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
    );

    // Buat daftar lagu untuk prompt
    final songListText = songs.map((s) => 'ID:${s.id} - "${s.title}" oleh ${s.artist}').join('\n');

    final prompt = '''
Buat $targetCount soal pilihan ganda untuk kuis musik dari lagu-lagu berikut:

$songListText

**ATURAN KETAT (WAJIB DIPATUHI):**
- JANGAN PERNAH menggunakan lagu yang sama lebih dari SATU KALI dalam seluruh soal (berdasarkan songId).
- Jika jumlah lagu kurang dari $targetCount, buat soal hanya sebanyak jumlah lagu yang tersedia (jangan dipaksakan).
- Soal bisa tentang judul ("Apa judul lagu yang dinyanyikan oleh X?") atau artis ("Siapa penyanyi lagu Y?").
- Setiap soal harus memiliki 4 pilihan (A, B, C, D) dengan satu jawaban benar.
- Pilihan yang salah harus berasal dari lagu lain yang ada dalam daftar.
- Jangan buat soal yang sama persis (nilai, susunan pilihan, dll).

Format output: JSON array, contoh:
[
  {
    "questionText": "Apa judul lagu yang dinyanyikan oleh Ed Sheeran?",
    "options": ["Shape of You", "Thinking Out Loud", "Perfect", "Photograph"],
    "correctAnswer": "Shape of You",
    "songId": 1,
    "questionType": "title"
  }
]
''';

    try {
      debugPrint('📡 Memanggil Gemini...');
      final response = await model.generateContent([Content.text(prompt)]);
      final jsonString = response.text?.trim() ?? '';
      if (jsonString.isEmpty) throw Exception('Respons kosong dari Gemini');

      // Bersihkan markdown
      String cleanJson = jsonString;
      if (cleanJson.startsWith('```json')) cleanJson = cleanJson.substring(7);
      if (cleanJson.startsWith('```')) cleanJson = cleanJson.substring(3);
      if (cleanJson.endsWith('```')) cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      cleanJson = cleanJson.trim();

      final List<QuizQuestion> rawQuestions = await compute(_parseQuizQuestions, cleanJson);

      // Filter duplikat songId
      final Set<int> usedIds = {};
      final List<QuizQuestion> unique = [];
      for (var q in rawQuestions) {
        if (q.songId != null && !usedIds.contains(q.songId)) {
          usedIds.add(q.songId!);
          unique.add(q);
        } else if (q.songId == null) {
          unique.add(q); // aman
        }
      }

      if (unique.length < targetCount) {
        debugPrint('⚠️ Gemini hanya menghasilkan ${unique.length} soal unik, tambahkan fallback.');
        final fallback = _createFallbackQuestions(songs, targetCount - unique.length);
        unique.addAll(fallback);
      }

      return unique.take(targetCount).toList();
    } catch (e) {
      debugPrint('❌ Gemini gagal: $e, pakai fallback.');
      return _createFallbackQuestions(songs, targetCount);
    }
  }

  // Parser JSON (dijalankan di isolate)
  static List<QuizQuestion> _parseQuizQuestions(String jsonString) {
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded.map((item) {
      return QuizQuestion(
        id: DateTime.now().millisecondsSinceEpoch + ((item['songId'] as num?)?.toInt() ?? 0),
        questionText: item['questionText'] as String? ?? '',
        options: List<String>.from(item['options'] ?? []),
        correctAnswer: item['correctAnswer'] as String? ?? '',
        songId: (item['songId'] as num?)?.toInt(),
        questionType: item['questionType'] as String? ?? 'general',
        albumArt: null,
        previewUrl: null,
      );
    }).toList();
  }

  // Fallback lokal – setiap lagu maksimal 2 soal (judul + artis)
  List<QuizQuestion> _createFallbackQuestions(List<Song> songs, int targetCount) {
    if (songs.isEmpty) return [];
    final List<QuizQuestion> questions = [];
    final randomSeed = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < targetCount && i < songs.length * 2; i++) {
      final song = songs[i % songs.length];
      final isArtistQuestion = (i % 2 == 0);

      if (isArtistQuestion) {
        final allArtists = songs.map((s) => s.artist).toSet().toList();
        final wrongOptions = allArtists.where((a) => a != song.artist).toList();
        wrongOptions.shuffle();
        final options = [song.artist, ...wrongOptions.take(3)]..shuffle();
        questions.add(QuizQuestion(
          id: randomSeed + i,
          questionText: 'Siapa penyanyi lagu "${song.title}"?',
          options: options,
          correctAnswer: song.artist,
          songId: song.id,
          questionType: 'artist',
        ));
      } else {
        final allTitles = songs.map((s) => s.title).toSet().toList();
        final wrongOptions = allTitles.where((t) => t != song.title).toList();
        wrongOptions.shuffle();
        final options = [song.title, ...wrongOptions.take(3)]..shuffle();
        questions.add(QuizQuestion(
          id: randomSeed + i + 1000,
          questionText: 'Apa judul lagu ini? (Artist: ${song.artist})',
          options: options,
          correctAnswer: song.title,
          songId: song.id,
          questionType: 'title',
        ));
      }
    }
    questions.shuffle();
    return questions.take(targetCount).toList();
  }
}