// lib/models/smoke_model.dart
import 'dart:convert';

class SmokeData {
  int dailySmoked;
  int dailyLimit;
  double pricePerPack;
  int cigarettesPerPack;
  List<Map<String, dynamic>> history;

  SmokeData({
    this.dailySmoked = 0,
    this.dailyLimit = 20,
    this.pricePerPack = 80,
    this.cigarettesPerPack = 20,
    List<Map<String, dynamic>>? history,
  }) : history = history ?? [];

  double get moneySavedToday {
    final saved = dailyLimit - dailySmoked;
    return (saved / cigarettesPerPack) * pricePerPack;
  }

  double get costToday {
    return (dailySmoked / cigarettesPerPack) * pricePerPack;
  }

  double get monthlyCost => costToday * 30;

  Map<String, dynamic> toJson() => {
        'dailySmoked': dailySmoked,
        'dailyLimit': dailyLimit,
        'pricePerPack': pricePerPack,
        'cigarettesPerPack': cigarettesPerPack,
        'history': history,
      };

  factory SmokeData.fromJson(Map<String, dynamic> json) => SmokeData(
        dailySmoked: json['dailySmoked'] ?? 0,
        dailyLimit: json['dailyLimit'] ?? 20,
        pricePerPack: (json['pricePerPack'] ?? 80).toDouble(),
        cigarettesPerPack: json['cigarettesPerPack'] ?? 20,
        history: List<Map<String, dynamic>>.from(json['history'] ?? []),
      );

  SmokeData copyWith({
    int? dailySmoked,
    int? dailyLimit,
    double? pricePerPack,
    int? cigarettesPerPack,
    List<Map<String, dynamic>>? history,
  }) =>
      SmokeData(
        dailySmoked: dailySmoked ?? this.dailySmoked,
        dailyLimit: dailyLimit ?? this.dailyLimit,
        pricePerPack: pricePerPack ?? this.pricePerPack,
        cigarettesPerPack: cigarettesPerPack ?? this.cigarettesPerPack,
        history: history ?? this.history,
      );
}
