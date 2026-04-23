// lib/screens/smoke_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';

class SmokeScreen extends StatefulWidget {
  const SmokeScreen({super.key});

  @override
  State<SmokeScreen> createState() => _SmokeScreenState();
}

class _SmokeScreenState extends State<SmokeScreen> {
  final _limitCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _perPackCtrl = TextEditingController();

  @override
  void dispose() {
    _limitCtrl.dispose();
    _priceCtrl.dispose();
    _perPackCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, p, _) {
        final smoke = p.smoke;
        final pct = smoke.dailySmoked / smoke.dailyLimit;
        final color = pct > 0.8
            ? AppColors.smoke
            : pct > 0.5
                ? AppColors.warning
                : AppColors.success;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Main counter card
              AppCard(
                borderColor: AppColors.smoke,
                backgroundColor: const Color(0xFF1A0A0A),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BUGÜN İÇİLEN',
                              style: TextStyle(
                                color: AppColors.smoke,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${smoke.dailySmoked}',
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 56,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10, left: 6),
                                  child: Text(
                                    '/ ${smoke.dailyLimit}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white.withOpacity(0.4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        CircularProgressWidget(
                          value: pct,
                          color: color,
                          label: '${(pct * 100).round()}%',
                          sublabel: 'limit',
                          size: 90,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        IconBtn(
                          icon: Icons.remove,
                          color: Colors.white.withOpacity(0.08),
                          iconColor: Colors.white,
                          onTap: p.removeSmoke,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AccentButton(
                            label: '+ 1 Sigara İçtim',
                            color: AppColors.smoke,
                            fullWidth: true,
                            onTap: p.addSmoke,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: MiniCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TASARRUF',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.success,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(
                            '${smoke.moneySavedToday.toStringAsFixed(1)}₺',
                            style: GoogleFonts.spaceMono(
                                fontSize: 22, color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${smoke.dailyLimit - smoke.dailySmoked} sigara içilmedi',
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MiniCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('GÜNLÜK MALİYET',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.warning,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(
                            '${smoke.costToday.toStringAsFixed(1)}₺',
                            style: GoogleFonts.spaceMono(
                                fontSize: 22, color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'aylık ≈ ${smoke.monthlyCost.toStringAsFixed(0)}₺',
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Settings
              AppCard(
                borderColor: AppColors.warning,
                backgroundColor: const Color(0xFF0D0D1A),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('AYARLAR'),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _SettingField(
                          label: 'Günlük Limit',
                          initialValue: '${smoke.dailyLimit}',
                          controller: _limitCtrl,
                          onChanged: (v) {
                            final val = int.tryParse(v);
                            if (val != null && val > 0) p.updateSmokeSettings(limit: val);
                          },
                        ),
                        const SizedBox(width: 12),
                        _SettingField(
                          label: 'Paket Fiyatı (₺)',
                          initialValue: '${smoke.pricePerPack.toInt()}',
                          controller: _priceCtrl,
                          onChanged: (v) {
                            final val = double.tryParse(v);
                            if (val != null && val > 0) p.updateSmokeSettings(price: val);
                          },
                        ),
                        const SizedBox(width: 12),
                        _SettingField(
                          label: 'Pakette Adet',
                          initialValue: '${smoke.cigarettesPerPack}',
                          controller: _perPackCtrl,
                          onChanged: (v) {
                            final val = int.tryParse(v);
                            if (val != null && val > 0) p.updateSmokeSettings(perPack: val);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingField extends StatelessWidget {
  final String label;
  final String initialValue;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SettingField({
    required this.label,
    required this.initialValue,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.text.isEmpty) controller.text = initialValue;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  letterSpacing: 1)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            onChanged: onChanged,
            decoration: const InputDecoration(),
          ),
        ],
      ),
    );
  }
}
