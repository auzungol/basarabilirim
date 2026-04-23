// lib/providers/app_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/smoke_model.dart';
import '../models/diet_model.dart';
import '../models/study_model.dart';
import '../models/project_model.dart';

class AppProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  SmokeData smoke = SmokeData();
  DietData diet = DietData();
  StudyData study = StudyData();
  ProjectsData projects = ProjectsData();

  bool _initialized = false;
  bool get initialized => _initialized;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _load();
    _checkDateAndReset();
    _initialized = true;
    notifyListeners();
  }

  void _load() {
    try {
      final s = _prefs.getString('smoke');
      if (s != null && s.isNotEmpty) smoke = SmokeData.fromJson(jsonDecode(s));
    } catch (e) { print("Smoke load error: $e"); }

    try {
      final d = _prefs.getString('diet');
      if (d != null && d.isNotEmpty) diet = DietData.fromJson(jsonDecode(d));
    } catch (e) { print("Diet load error: $e"); }

    try {
      final st = _prefs.getString('study');
      if (st != null && st.isNotEmpty) study = StudyData.fromJson(jsonDecode(st));
    } catch (e) { print("Study load error: $e"); }

    try {
      final p = _prefs.getString('projects');
      if (p != null && p.isNotEmpty) projects = ProjectsData.fromJson(jsonDecode(p));
    } catch (e) { print("Projects load error: $e"); }
  }

  void _checkDateAndReset() {
    final now = DateTime.now();
    final todayStr = "${now.day}.${now.month}.${now.year}";
    final lastSavedDate = _prefs.getString('last_date');

    if (lastSavedDate == null) {
      _prefs.setString('last_date', todayStr);
      return;
    }

    if (lastSavedDate != todayStr) {
      smoke.history.add({'date': lastSavedDate, 'smoked': smoke.dailySmoked, 'limit': smoke.dailyLimit});
      smoke.dailySmoked = 0;

      diet.history.add({
        'date': lastSavedDate,
        'calories': diet.calories,
        'goal': diet.goal,
        'maintenance': diet.maintenance,
        'water': diet.water,
        'meals': diet.meals.map((m) => m.toJson()).toList(),
      });
      diet.calories = 0;
      diet.water = 0;
      diet.meals = [];

      study.history.add({
        'date': lastSavedDate,
        'totalMinutes': study.totalTodayMinutes,
        'sessionCount': study.sessions.length,
        'sessions': study.sessions.map((s) => s.toJson()).toList(),
      });
      study.totalTodayMinutes = 0;
      study.sessions = [];

      _prefs.setString('last_date', todayStr);
      _saveAll();
      notifyListeners();
    }
  }

  void refresh() {
    _checkDateAndReset();
    notifyListeners();
  }

  void clearHistory(String type) {
    if (type == 'smoke') { smoke.history = []; _saveSmoke(); } 
    else if (type == 'diet') { diet.history = []; _saveDiet(); } 
    else if (type == 'study') { study.history = []; _saveStudy(); }
    notifyListeners();
  }

  void _saveAll() { _saveSmoke(); _saveDiet(); _saveStudy(); _saveProjects(); }
  void _saveSmoke() => _prefs.setString('smoke', jsonEncode(smoke.toJson()));
  void _saveDiet() => _prefs.setString('diet', jsonEncode(diet.toJson()));
  void _saveStudy() => _prefs.setString('study', jsonEncode(study.toJson()));
  void _saveProjects() => _prefs.setString('projects', jsonEncode(projects.toJson()));

  // ── Study Gelişmiş (RENK DESTEĞİ EKLENDİ) ──────────────────────────
  void addSubject(String name, int colorValue) {
    if (name.isEmpty) return;
    study.subjects.add(Subject(
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      name: name,
      colorValue: colorValue,
    ));
    _saveStudy();
    notifyListeners();
  }

  void deleteSubject(String id) {
    study.subjects.removeWhere((s) => s.id == id);
    _saveStudy();
    notifyListeners();
  }

  void startStudySession(String subject, String topic) {
    _checkDateAndReset();
    study.activeSubject = subject;
    study.activeTopic = topic;
    study.sessionStart = DateTime.now();
    study.isPaused = false;
    notifyListeners();
  }

  void togglePauseStudySession() {
    study.isPaused = !study.isPaused;
    notifyListeners();
  }

  void stopStudySession() {
    _checkDateAndReset();
    if (!study.isActive) return;
    
    // Not: Molalar düşülmüyor, sadece o andaki kronometre değeri üzerinden süre hesaplanıyor.
    // Ancak kullanıcı arayüzünde kronometre mola verildiğinde duracağı için bu yeterli olacaktır.
    // Eğer sessionStart baz alınırsa mola süreleri de dahil olur.
    // Bu yüzden kronometredeki süreyi (dakika cinsinden) almalıyız veya stop'ta geçen süreyi sessionStart'tan bağımsız hesaplamalıyız.
    // Şimdilik basitleştirmek için: sessionStart'tan bugüne geçen süre yerine, ekranda tutulan _elapsed süresini kullanalım.
    // Ancak Provider içinde _elapsed tutulmuyor. 
    // Bu yüzden stopStudySession'a dışarıdan dakika parametresi alalım.
  }

  void completeStudySession(int durationMinutes) {
    _checkDateAndReset();
    if (!study.isActive) return;

    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final dateStr = '${now.day}.${now.month}.${now.year}';

    study.sessions.add(StudySession(
      subject: study.activeSubject!,
      topic: study.activeTopic,
      durationMinutes: durationMinutes,
      time: timeStr,
    ));

    final subIdx = study.subjects.indexWhere((s) => s.name == study.activeSubject);
    if (subIdx != -1) {
      study.subjects[subIdx].totalMinutes += durationMinutes;
      study.subjects[subIdx].lastTopic = study.activeTopic;
      study.subjects[subIdx].lastDate = dateStr;
    }

    study.totalTodayMinutes += durationMinutes;
    study.activeSubject = null;
    study.activeTopic = null;
    study.sessionStart = null;
    study.isPaused = false;
    _saveStudy();
    notifyListeners();
  }

  // ... (Diğer metodlar aynı)
  void addSmoke() { _checkDateAndReset(); smoke.dailySmoked++; _saveSmoke(); notifyListeners(); }
  void removeSmoke() { _checkDateAndReset(); if (smoke.dailySmoked > 0) smoke.dailySmoked--; _saveSmoke(); notifyListeners(); }
  void updateSmokeSettings({int? limit, double? price, int? perPack}) { if (limit != null) smoke.dailyLimit = limit; if (price != null) smoke.pricePerPack = price; if (perPack != null) smoke.cigarettesPerPack = perPack; _saveSmoke(); notifyListeners(); }
  void addMeal(String name, int calories) { _checkDateAndReset(); final now = TimeOfDay.now(); final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}'; diet.meals.add(Meal(name: name, calories: calories, time: time)); diet.calories += calories; _saveDiet(); notifyListeners(); }
  void removeMeal(int index) { _checkDateAndReset(); final meal = diet.meals[index]; diet.calories -= meal.calories; diet.meals.removeAt(index); _saveDiet(); notifyListeners(); }
  void addWater() { _checkDateAndReset(); diet.water++; _saveDiet(); notifyListeners(); }
  void removeWater() { _checkDateAndReset(); if (diet.water > 0) { diet.water--; _saveDiet(); notifyListeners(); } }
  void updateDietInfo({int? age, double? weight, int? height, bool? isMale, double? activityMultiplier, int? goal}) { if (age != null) diet.age = age; if (weight != null) diet.weight = weight; if (height != null) diet.height = height; if (isMale != null) diet.isMale = isMale; if (activityMultiplier != null) diet.activityMultiplier = activityMultiplier; if (goal != null) diet.goal = goal; _saveDiet(); notifyListeners(); }
  void addProject(String name, String desc, Priority priority, String deadline) { final now = DateTime.now(); final dateStr = '${now.day}.${now.month}.${now.year}'; projects.list.add(Project(id: now.millisecondsSinceEpoch, name: name, desc: desc, priority: priority, deadline: deadline, created: dateStr)); _saveProjects(); notifyListeners(); }
  void updateProject(int id, {String? name, String? desc, Priority? priority, String? deadline}) { final index = projects.list.indexWhere((p) => p.id == id); if (index != -1) { projects.list[index] = projects.list[index].copyWith(name: name, desc: desc, priority: priority, deadline: deadline); _saveProjects(); notifyListeners(); } }
  void toggleProject(int id) { final index = projects.list.indexWhere((p) => p.id == id); if (index != -1) { projects.list[index] = projects.list[index].copyWith(done: !projects.list[index].done); _saveProjects(); notifyListeners(); } }
  void deleteProject(int id) { projects.list.removeWhere((p) => p.id == id); _saveProjects(); notifyListeners(); }
  void addTask(int projectId, String taskName) { if (taskName.isEmpty) return; final p = projects.list.firstWhere((p) => p.id == projectId); p.tasks.add(ProjectTask(name: taskName)); _saveProjects(); notifyListeners(); }
  void deleteTask(int projectId, int taskIndex) { final p = projects.list.firstWhere((p) => p.id == projectId); p.tasks.removeAt(taskIndex); _saveProjects(); notifyListeners(); }
  void toggleTask(int projectId, int taskIndex) { final p = projects.list.firstWhere((p) => p.id == projectId); p.tasks[taskIndex].done = !p.tasks[taskIndex].done; _saveProjects(); notifyListeners(); }
}