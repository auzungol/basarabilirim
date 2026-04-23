// lib/models/study_model.dart

class StudySession {
  final String subject;
  final int durationMinutes;
  final String time;

  StudySession({
    required this.subject,
    required this.durationMinutes,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'durationMinutes': durationMinutes,
        'time': time,
      };

  factory StudySession.fromJson(Map<String, dynamic> json) => StudySession(
        subject: json['subject'] ?? '',
        durationMinutes: json['durationMinutes'] ?? 0,
        time: json['time'] ?? '',
      );
}

class StudyData {
  int totalTodayMinutes;
  String? activeSubject;
  DateTime? sessionStart;
  List<StudySession> sessions;
  List<Map<String, dynamic>> history; // Ders çalışma geçmişi

  StudyData({
    this.totalTodayMinutes = 0,
    this.activeSubject,
    this.sessionStart,
    List<StudySession>? sessions,
    List<Map<String, dynamic>>? history,
  }) : sessions = sessions ?? [], history = history ?? [];

  bool get isActive => activeSubject != null;

  Map<String, dynamic> toJson() => {
        'totalTodayMinutes': totalTodayMinutes,
        'sessions': sessions.map((s) => s.toJson()).toList(),
        'history': history,
      };

  factory StudyData.fromJson(Map<String, dynamic> json) => StudyData(
        totalTodayMinutes: json['totalTodayMinutes'] ?? 0,
        sessions: (json['sessions'] as List<dynamic>? ?? [])
            .map((s) => StudySession.fromJson(s))
            .toList(),
        history: List<Map<String, dynamic>>.from(json['history'] ?? []),
      );
}
