import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ScoringService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<Map<String, dynamic>> calculateScoreWithAI(
    List<Map<String, dynamic>> userAnswers,
    int totalQuestions,
  ) async {
    if (_apiKey.isEmpty) {
      return _calculateManualScore(userAnswers, totalQuestions);
    }

    final prompt = '''
      Analyze this music quiz performance:
      User answers: ${jsonEncode(userAnswers)}
      Total questions: $totalQuestions
      
      Return JSON: {"score": (0-100 integer), "feedback": "short encouraging message", "improvement": "one-sentence tip"}
    ''';

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.5,
            'maxOutputTokens': 250,
          }
        }),
      ).timeout(
        const Duration(seconds: 10),
        // Use a generic Exception to avoid potential analyzer issues with TimeoutException
        onTimeout: () => throw Exception('API request timed out'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final generatedText = data['candidates'][0]['content']['parts'][0]['text'];
          return _parseScoreResponse(generatedText);
        }
      } else {
        if (kDebugMode) debugPrint('AI scoring error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('AI scoring error: $e');
    }
    return _calculateManualScore(userAnswers, totalQuestions);
  }

  Map<String, dynamic> _parseScoreResponse(String response) {
    try {
      String cleanJson = response.replaceAll(RegExp(r'```json\n?'), '').replaceAll(RegExp(r'\n?```'), '');
      final parsed = jsonDecode(cleanJson);

      return {
        'score': parsed['score'] ?? 0,
        'feedback': parsed['feedback'] ?? 'Great effort!',
        'improvement': parsed['improvement'] ?? 'Keep practicing!',
      };
    } catch (e) {
      if (kDebugMode) debugPrint('Error parsing score response: $e');
      return {
        'score': 0,
        'feedback': 'Great effort! Keep practicing!',
        'improvement': 'Listen to more music to improve.',
      };
    }
  }

  Map<String, dynamic> _calculateManualScore(
    List<Map<String, dynamic>> userAnswers,
    int totalQuestions,
  ) {
    int correct = userAnswers.where((a) => a['isCorrect'] == true).length;
    double score = totalQuestions > 0 ? (correct / totalQuestions) * 100 : 0;

    String feedback;
    if (score >= 80) {
      feedback = 'Excellent! You\'re a music master! 🎵';
    } else if (score >= 60) {
      feedback = 'Good job! Keep it up! 👍';
    } else if (score >= 40) {
      feedback = 'Not bad! Keep learning! 🎧';
    } else {
      feedback = 'Keep practicing! Music is infinite! 🌟';
    }

    return {
      'score': score.round(),
      'feedback': feedback,
      'improvement': 'Try listening to more songs from different eras.',
    };
  }
}