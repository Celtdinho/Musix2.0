// lib/models/quiz_question.dart

class QuizQuestion {
  final int id;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final int? songId;
  final String questionType;
  final String? albumArt;
  final String? previewUrl;

  QuizQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.songId,
    required this.questionType,
    this.albumArt,
    this.previewUrl,
  });

  /// Factory method untuk membuat objek dari JSON (digunakan oleh quiz_service)
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch,
      questionText: json['questionText'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      songId: json['songId'],
      questionType: json['questionType'] ?? 'general',
      albumArt: json['albumArt'],
      previewUrl: json['previewUrl'],
    );
  }

  /// Convert objek ke JSON (opsional, untuk debugging atau penyimpanan)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'options': options,
      'correctAnswer': correctAnswer,
      'songId': songId,
      'questionType': questionType,
      'albumArt': albumArt,
      'previewUrl': previewUrl,
    };
  }
}