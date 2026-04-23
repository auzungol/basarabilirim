// lib/screens/study_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/study_model.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  Timer? _timer;
  int _elapsed = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (context.read<AppProvider>().study.isActive) {
        setState(() => _elapsed++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _fmtMin(int min) {
    final h = min ~/ 60;
    final m = min % 60;
    return h > 0 ? '${h}s ${m}d' : '${m}d';
  }

  void _showAddSubject(BuildContext context, AppProvider p) {
    final ctrl = TextEditingController();
    int selectedColor = 0xFF00FFC8;
    
    final colors = [
      {'name': 'Yeşil', 'value': 0xFF00FFC8},
      {'name': 'Mavi', 'value': 0xFF1E90FF},
      {'name': 'Kırmızı', 'value': 0xFFFF4757},
      {'name': 'Turuncu', 'value': 0xFFFFA502},
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text('Yeni Ders Ekle', style: GoogleFonts.spaceMono(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'Ders adı'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: colors.map((c) => GestureDetector(
                  onTap: () => setDialogState(() => selectedColor = c['value'] as int),
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Color(c['value'] as int),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedColor == c['value'] ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İPTAL')),
            TextButton(
              onPressed: () {
                p.addSubject(ctrl.text.trim(), selectedColor);
                Navigator.pop(context);
              },
              child: const Text('EKLE', style: TextStyle(color: AppColors.study, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, Subject sub) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(sub.name, style: GoogleFonts.spaceMono(color: Color(sub.colorValue), fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Toplam:', _fmtMin(sub.totalMinutes)),
            const SizedBox(height: 10),
            _detailRow('Son Konu:', sub.lastTopic ?? 'Yok'),
            const SizedBox(height: 10),
            _detailRow('Son Tarih:', sub.lastDate ?? '-'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('KAPAT', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  void _startWithSubject(BuildContext context, AppProvider p, Subject sub) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(sub.name, style: TextStyle(color: Color(sub.colorValue))),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'Konu ne?'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İPTAL')),
          TextButton(
            onPressed: () {
              setState(() => _elapsed = 0);
              p.startStudySession(sub.name, ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('BAŞLA', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, p, _) {
        final study = p.study;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              // DERSLERİM GRID (ÜSTTE)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionLabel('DERSLERİM'),
                  IconButton(
                    onPressed: () => _showAddSubject(context, p),
                    icon: const Icon(Icons.add_circle, color: AppColors.study, size: 28),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemCount: study.subjects.length,
                itemBuilder: (context, index) {
                  final sub = study.subjects[index];
                  final color = Color(sub.colorValue);
                  return InkWell(
                    onTap: study.isActive ? null : () => _startWithSubject(context, p, sub),
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.card,
                          title: const Text('Sil'),
                          content: Text('${sub.name} silinsin mi?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('HAYIR')),
                            TextButton(onPressed: () { p.deleteSubject(sub.id); Navigator.pop(context); }, child: const Text('SİL', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.4)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(sub.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              GestureDetector(
                                onTap: () => _showDetails(context, sub),
                                child: Icon(Icons.info_outline, color: color.withOpacity(0.6), size: 14),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(_fmtMin(sub.totalMinutes), style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Icon(Icons.play_arrow, color: color, size: 18),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // SAYAÇ
              AppCard(
                borderColor: AppColors.study,
                backgroundColor: const Color(0xFF000D0D),
                child: Column(
                  children: [
                    Text(
                      study.isActive 
                        ? '${study.activeSubject} ${study.activeTopic != null && study.activeTopic!.isNotEmpty ? "- ${study.activeTopic}" : ""}' 
                        : 'ÇALIŞMA SAYACI',
                      style: const TextStyle(color: AppColors.study, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      study.isActive ? _fmt(_elapsed) : '00:00',
                      style: GoogleFonts.spaceMono(fontSize: 56, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text('Bugün toplam: ${_fmtMin(study.totalTodayMinutes)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    if (study.isActive) ...[
                      const SizedBox(height: 16),
                      AccentButton(
                        label: '⏹ ÇALIŞMAYI BİTİR',
                        color: AppColors.smoke,
                        fullWidth: true,
                        onTap: () { p.stopStudySession(); setState(() => _elapsed = 0); },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),
              
              if (study.sessions.isNotEmpty) ...[
                const SectionLabel('BUGÜNKÜ AKIŞ'),
                ...study.sessions.reversed.map((s) {
                  // Oturumun ait olduğu dersi bulup rengini alıyoruz
                  final sub = study.subjects.firstWhere(
                    (element) => element.name == s.subject,
                    orElse: () => Subject(id: '', name: '', colorValue: AppColors.study.value),
                  );
                  final sColor = Color(sub.colorValue);

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Icon(Icons.bookmark, color: sColor.withOpacity(0.7), size: 16),
                    title: Text(s.subject, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: s.topic != null && s.topic!.isNotEmpty ? Text(s.topic!, style: const TextStyle(fontSize: 11)) : null,
                    trailing: Text(_fmtMin(s.durationMinutes), style: GoogleFonts.spaceMono(fontSize: 12, color: sColor)),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}