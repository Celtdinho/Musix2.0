class QuizResult {
  final int id;
  final DateTime dateTime;
  final int score;
  final int totalQuestions;
  final String feedback;
  final String improvementTip;

  QuizResult({
    required this.id,
    required this.dateTime,
    required this.score,
    required this.totalQuestions,
    required this.feedback,
    required this.improvementTip,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date_time': dateTime.toIso8601String(),
      'score': score,
      'total_questions': totalQuestions,
      'feedback': feedback,
      'improvement_tip': improvementTip,
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      id: map['id'],
      dateTime: DateTime.parse(map['date_time']),
      score: map['score'],
      totalQuestions: map['total_questions'],
      feedback: map['feedback'],
      improvementTip: map['improvement_tip'],
    );
  }
}