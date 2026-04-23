// lib/models/project_model.dart

enum Priority { high, mid, low }

extension PriorityExt on Priority {
  String get label {
    switch (this) {
      case Priority.high: return 'Yüksek';
      case Priority.mid: return 'Orta';
      case Priority.low: return 'Düşük';
    }
  }

  String get key {
    switch (this) {
      case Priority.high: return 'high';
      case Priority.mid: return 'mid';
      case Priority.low: return 'low';
    }
  }

  static Priority fromKey(String key) {
    switch (key) {
      case 'high': return Priority.high;
      case 'low': return Priority.low;
      default: return Priority.mid;
    }
  }
}

class ProjectTask {
  final String name;
  bool done;

  ProjectTask({required this.name, this.done = false});

  Map<String, dynamic> toJson() => {'name': name, 'done': done};

  factory ProjectTask.fromJson(Map<String, dynamic> json) =>
      ProjectTask(name: json['name'] ?? '', done: json['done'] ?? false);

  ProjectTask copyWith({String? name, bool? done}) =>
      ProjectTask(name: name ?? this.name, done: done ?? this.done);
}

class Project {
  final int id;
  final String name;
  final String desc;
  final Priority priority;
  final String deadline;
  final String created;
  List<ProjectTask> tasks;
  bool done;

  Project({
    required this.id,
    required this.name,
    this.desc = '',
    this.priority = Priority.mid,
    this.deadline = '',
    this.created = '',
    List<ProjectTask>? tasks,
    this.done = false,
  }) : tasks = tasks ?? [];

  int get completedTasks => tasks.where((t) => t.done).length;
  double get progress => tasks.isEmpty ? 0 : completedTasks / tasks.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'desc': desc,
        'priority': priority.key,
        'deadline': deadline,
        'created': created,
        'tasks': tasks.map((t) => t.toJson()).toList(),
        'done': done,
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        desc: json['desc'] ?? '',
        priority: PriorityExt.fromKey(json['priority'] ?? 'mid'),
        deadline: json['deadline'] ?? '',
        created: json['created'] ?? '',
        tasks: (json['tasks'] as List<dynamic>? ?? [])
            .map((t) => ProjectTask.fromJson(t))
            .toList(),
        done: json['done'] ?? false,
      );

  Project copyWith({
    String? name,
    String? desc,
    Priority? priority,
    String? deadline,
    List<ProjectTask>? tasks,
    bool? done,
  }) =>
      Project(
        id: id,
        name: name ?? this.name,
        desc: desc ?? this.desc,
        priority: priority ?? this.priority,
        deadline: deadline ?? this.deadline,
        created: created,
        tasks: tasks ?? this.tasks,
        done: done ?? this.done,
      );
}

class ProjectsData {
  List<Project> list;

  ProjectsData({List<Project>? list}) : list = list ?? [];

  List<Project> get active => list.where((p) => !p.done).toList();
  List<Project> get completed => list.where((p) => p.done).toList();

  Map<String, dynamic> toJson() => {
        'list': list.map((p) => p.toJson()).toList(),
      };

  factory ProjectsData.fromJson(Map<String, dynamic> json) => ProjectsData(
        list: (json['list'] as List<dynamic>? ?? [])
            .map((p) => Project.fromJson(p))
            .toList(),
      );
}
