// lib/screens/diet_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final _mealCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  
  // Vücut analizi için sabit controller'lar (rebuild'lerde focus kaybını önler)
  late TextEditingController _weightCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _ageCtrl;

  @override
  void initState() {
    super.initState();
    final diet = context.read<AppProvider>().diet;
    _weightCtrl = TextEditingController(text: diet.weight.toString());
    _heightCtrl = TextEditingController(text: diet.height.toString());
    _ageCtrl = TextEditingController(text: diet.age.toString());
  }

  @override
  void dispose() {
    _mealCtrl.dispose();
    _calCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _addMeal(AppProvider p) {
    final name = _mealCtrl.text.trim();
    final cal = int.tryParse(_calCtrl.text.trim());
    if (name.isEmpty || cal == null || cal <= 0) return;
    p.addMeal(name, cal);
    _mealCtrl.clear();
    _calCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, p, _) {
        final diet = p.diet;
        final maintenance = diet.maintenance;
        final deficit = diet.deficit;
        
        // Kümülatif hesaplama: Geçmiş veriler + Bugün
        double totalDeficit = 0;
        for (var entry in diet.history) {
          final hMaint = (entry['maintenance'] as num?)?.toDouble() ?? 0.0;
          final hCal = (entry['calories'] as num?)?.toDouble() ?? 0.0;
          totalDeficit += (hMaint - hCal);
        }
        totalDeficit += deficit; // Bugünkü anlık farkı ekle

        // 7700 kcal = 1 kg kuralına göre kümülatif değişim
        final totalWeightChange = totalDeficit / 7700;
        final isLosing = totalWeightChange >= 0;

        final pct = maintenance > 0 ? diet.calories / maintenance : 0.0;
        
        final color = pct > 1.0
            ? AppColors.smoke
            : pct > 0.8
                ? AppColors.warning
                : AppColors.diet;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // KÜMÜLATİF DEĞİŞİM WIDGETI
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: (isLosing ? AppColors.success : AppColors.smoke).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (isLosing ? AppColors.success : AppColors.smoke).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isLosing ? Icons.history : Icons.trending_up,
                      color: isLosing ? AppColors.success : AppColors.smoke,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KÜMÜLATİF KİLO DEĞİŞİMİ',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: isLosing ? AppColors.success : AppColors.smoke,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Başladığından beri toplam tahmini değişim: ${totalWeightChange.abs().toStringAsFixed(2)} kg ${isLosing ? 'kaybedildi' : 'alındı'}.',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Ana Kalori Kartı
              AppCard(
                borderColor: AppColors.diet,
                backgroundColor: const Color(0xFF000D1A),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ALINAN KALORİ',
                                  style: TextStyle(
                                      color: AppColors.diet,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 3)),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${diet.calories}',
                                    style: GoogleFonts.spaceMono(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6, left: 6),
                                    child: Text(
                                      '/ $maintenance',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.4)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        CircularProgressWidget(
                          value: pct,
                          color: color,
                          label: '${(pct * 100).round()}%',
                          sublabel: 'ihtiyaç',
                          size: 80,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Kalori Giriş Satırı
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _mealCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            onSubmitted: (_) => _addMeal(p),
                            decoration: const InputDecoration(hintText: 'Yemek adı'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _calCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            onSubmitted: (_) => _addMeal(p),
                            decoration: const InputDecoration(hintText: 'kcal'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconBtn(
                          icon: Icons.add,
                          color: AppColors.diet,
                          iconColor: Colors.white,
                          onTap: () => _addMeal(p),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // VÜCUT ANALİZİ VE İHTİYAÇ PANELİ
              AppCard(
                borderColor: AppColors.warning,
                backgroundColor: const Color(0xFF0D0D1A),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('VÜCUT ANALİZİ & İHTİYAÇ', 
                          style: TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: deficit >= 0 ? AppColors.success.withOpacity(0.15) : AppColors.smoke.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            deficit >= 0 ? '$deficit kcal açıkta' : '${deficit.abs()} kcal fazlada',
                            style: TextStyle(color: deficit >= 0 ? AppColors.success : AppColors.smoke, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _infoItem('İhtiyaç', '$maintenance', 'kcal'),
                        const SizedBox(width: 20),
                        _infoItem('Kilo', '${diet.weight}', 'kg'),
                        const SizedBox(width: 20),
                        _infoItem('Boy', '${diet.height}', 'cm'),
                        const SizedBox(width: 20),
                        _infoItem('Yaş', '${diet.age}', ''),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 32),
                    // Ayarlar Formu
                    Row(
                      children: [
                        _formField('Kilo', _weightCtrl, (v) => p.updateDietInfo(weight: double.tryParse(v))),
                        const SizedBox(width: 10),
                        _formField('Boy', _heightCtrl, (v) => p.updateDietInfo(height: int.tryParse(v))),
                        const SizedBox(width: 10),
                        _formField('Yaş', _ageCtrl, (v) => p.updateDietInfo(age: int.tryParse(v))),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => p.updateDietInfo(isMale: !diet.isMale),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(diet.isMale ? Icons.male : Icons.female, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Aktivite Seçimi
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _activityBtn(p, 'Az Hareketli', 1.2, diet.activityMultiplier),
                          _activityBtn(p, 'Orta', 1.375, diet.activityMultiplier),
                          _activityBtn(p, 'Aktif', 1.55, diet.activityMultiplier),
                          _activityBtn(p, 'Çok Aktif', 1.725, diet.activityMultiplier),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Water Section
              AppCard(
                borderColor: AppColors.water,
                backgroundColor: const Color(0xFF001A0D),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SU TÜKETİMİ',
                              style: TextStyle(fontSize: 10, color: AppColors.success, letterSpacing: 2, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: List.generate(diet.waterGoal, (i) {
                              final filled = i < diet.water;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 22,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: filled ? AppColors.water : Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: filled ? const Icon(Icons.water_drop, size: 14, color: Colors.white) : null,
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${diet.water}/${diet.waterGoal}',
                          style: GoogleFonts.spaceMono(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconBtn(icon: Icons.remove, color: Colors.white.withOpacity(0.08), iconColor: Colors.white, onTap: p.removeWater),
                            const SizedBox(width: 8),
                            AccentButton(label: '+ 1 Bardak', color: AppColors.water, textColor: const Color(0xFF001A0D), onTap: p.addWater),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Meals List
              if (diet.meals.isNotEmpty)
                AppCard(
                  borderColor: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('ÖĞÜNLER'),
                      const SizedBox(height: 12),
                      ...diet.meals.asMap().entries.map((e) {
                        final i = e.key;
                        final m = e.value;
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(m.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                                    Text(m.time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text('${m.calories} kcal', style: GoogleFonts.spaceMono(color: AppColors.diet, fontSize: 14, fontWeight: FontWeight.w700)),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => p.removeMeal(i),
                                      child: Icon(Icons.delete_outline, color: AppColors.smoke.withOpacity(0.6), size: 18),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (i < diet.meals.length - 1)
                              Divider(height: 20, color: Colors.white.withOpacity(0.05)),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoItem(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            if (unit.isNotEmpty) Text(' $unit', style: const TextStyle(color: AppColors.textSecondary, fontSize: 9)),
          ],
        ),
      ],
    );
  }

  Widget _formField(String label, TextEditingController controller, Function(String) onChanged) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 9)),
          TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            controller: controller,
            onChanged: onChanged,
            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
          ),
        ],
      ),
    );
  }

  Widget _activityBtn(AppProvider p, String label, double value, double current) {
    final isActive = value == current;
    return GestureDetector(
      onTap: () => p.updateDietInfo(activityMultiplier: value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.warning.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isActive ? AppColors.warning : Colors.transparent),
        ),
        child: Text(label, style: TextStyle(color: isActive ? AppColors.warning : AppColors.textSecondary, fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}