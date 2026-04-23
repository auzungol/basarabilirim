// lib/models/study_model.dart

class StudySession {
  final String subject;
  final String? topic;
  final int durationMinutes;
  final String time;

  StudySession({
    required this.subject,
    this.topic,
    required this.durationMinutes,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'topic': topic,
        'durationMinutes': durationMinutes,
        'time': time,
      };

  factory StudySession.fromJson(Map<String, dynamic> json) => StudySession(
        subject: json['subject'] ?? '',
        topic: json['topic'],
        durationMinutes: json['durationMinutes'] ?? 0,
        time: json['time'] ?? '',
      );
}

class Subject {
  final String id;
  String name;
  String? lastTopic;
  String? lastDate;
  int totalMinutes;
  int colorValue;

  Subject({
    required this.id,
    required this.name,
    this.lastTopic,
    this.lastDate,
    this.totalMinutes = 0,
    this.colorValue = 0xFF00FFC8,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lastTopic': lastTopic,
        'lastDate': lastDate,
        'totalMinutes': totalMinutes,
        'colorValue': colorValue,
      };

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        lastTopic: json['lastTopic']?.toString(),
        lastDate: json['lastDate']?.toString(),
        totalMinutes: int.tryParse(json['totalMinutes']?.toString() ?? '0') ?? 0,
        colorValue: int.tryParse(json['colorValue']?.toString() ?? '0xFF00FFC8') ?? 0xFF00FFC8,
      );
}

class StudyData {
  int totalTodayMinutes;
  String? activeSubject;
  String? activeTopic;
  DateTime? sessionStart;
  List<StudySession> sessions;
  List<Subject> subjects;
  List<Map<String, dynamic>> history;

  StudyData({
    this.totalTodayMinutes = 0,
    this.activeSubject,
    this.activeTopic,
    this.sessionStart,
    List<StudySession>? sessions,
    List<Subject>? subjects,
    List<Map<String, dynamic>>? history,
  }) : sessions = sessions ?? [], 
       subjects = subjects ?? [],
       history = history ?? [];

  bool get isActive => activeSubject != null;

  Map<String, dynamic> toJson() => {
        'totalTodayMinutes': totalTodayMinutes,
        'activeSubject': activeSubject,
        'activeTopic': activeTopic,
        'sessions': sessions.map((s) => s.toJson()).toList(),
        'subjects': subjects.map((s) => s.toJson()).toList(),
        'history': history,
      };

  factory StudyData.fromJson(Map<String, dynamic> json) => StudyData(
        totalTodayMinutes: int.tryParse(json['totalTodayMinutes']?.toString() ?? '0') ?? 0,
        activeSubject: json['activeSubject']?.toString(),
        activeTopic: json['activeTopic']?.toString(),
        sessions: (json['sessions'] as List<dynamic>? ?? [])
            .map((s) => StudySession.fromJson(Map<String, dynamic>.from(s)))
            .toList(),
        subjects: (json['subjects'] as List<dynamic>? ?? [])
            .map((p) => Subject.fromJson(Map<String, dynamic>.from(p)))
            .toList(),
        history: (json['history'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
      );
}