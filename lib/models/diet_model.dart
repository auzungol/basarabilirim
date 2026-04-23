// lib/models/diet_model.dart

class Meal {
  final String name;
  final int calories;
  final String time;

  Meal({required this.name, required this.calories, required this.time});

  Map<String, dynamic> toJson() => {
        'name': name,
        'calories': calories,
        'time': time,
      };

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
        name: json['name']?.toString() ?? '',
        calories: int.tryParse(json['calories']?.toString() ?? '0') ?? 0,
        time: json['time']?.toString() ?? '',
      );
}

class DietData {
  int calories;
  int goal; // Hedef (manuel veya formdan gelen)
  
  // Fiziksel Veriler
  int age;
  double weight;
  int height;
  bool isMale;
  double activityMultiplier; // 1.2, 1.375, 1.55 vb.

  List<Meal> meals;
  int water;
  int waterGoal;
  List<Map<String, dynamic>> history;

  DietData({
    this.calories = 0,
    this.goal = 2000,
    this.age = 25,
    this.weight = 70.0,
    this.height = 175,
    this.isMale = true,
    this.activityMultiplier = 1.2,
    List<Meal>? meals,
    this.water = 0,
    this.waterGoal = 8,
    List<Map<String, dynamic>>? history,
  }) : meals = meals ?? [], history = history ?? [];

  // TDEE (Maintenance) Hesaplama: Mifflin-St Jeor Denklemi
  int get maintenance {
    double bmr;
    if (isMale) {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
    return (bmr * activityMultiplier).round();
  }

  int get remaining => goal - calories;
  int get deficit => maintenance - calories;

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'goal': goal,
        'age': age,
        'weight': weight,
        'height': height,
        'isMale': isMale,
        'activityMultiplier': activityMultiplier,
        'meals': meals.map((m) => m.toJson()).toList(),
        'water': water,
        'waterGoal': waterGoal,
        'history': history,
      };

  factory DietData.fromJson(Map<String, dynamic> json) => DietData(
        calories: int.tryParse(json['calories']?.toString() ?? '0') ?? 0,
        goal: int.tryParse(json['goal']?.toString() ?? '2000') ?? 2000,
        age: int.tryParse(json['age']?.toString() ?? '25') ?? 25,
        weight: double.tryParse(json['weight']?.toString() ?? '70.0') ?? 70.0,
        height: int.tryParse(json['height']?.toString() ?? '175') ?? 175,
        isMale: json['isMale'] ?? true,
        activityMultiplier: double.tryParse(json['activityMultiplier']?.toString() ?? '1.2') ?? 1.2,
        meals: (json['meals'] as List<dynamic>? ?? [])
            .map((m) => Meal.fromJson(Map<String, dynamic>.from(m)))
            .toList(),
        water: int.tryParse(json['water']?.toString() ?? '0') ?? 0,
        waterGoal: int.tryParse(json['waterGoal']?.toString() ?? '8') ?? 8,
        history: (json['history'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
      );
}
