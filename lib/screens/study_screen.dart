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
      final study = context.read<AppProvider>().study;
      if (study.isActive && !study.isPaused) {
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
            _detailRow('Toplam Çalışma:', _fmtMin(sub.totalMinutes)),
            const SizedBox(height: 12),
            _detailRow('Son Çalışılan Konu:', sub.lastTopic ?? 'Henüz yok'),
            const SizedBox(height: 12),
            _detailRow('Son Çalışma Tarihi:', sub.lastDate ?? '-'),
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
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
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
          decoration: const InputDecoration(hintText: 'Hangi konuyu çalışacaksın?'),
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

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                        childAspectRatio: 0.85, 
                      ),
                      itemCount: study.subjects.length,
                      itemBuilder: (context, index) {
                        final sub = study.subjects[index];
                        final color = Color(sub.colorValue);
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: color.withOpacity(0.3)),
                          ),
                          child: Stack(
                            children: [
                              // Bilgi alanı için TÜM KARTI kaplayan Material/InkWell
                              Positioned.fill(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _showDetails(context, sub),
                                    onLongPress: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: AppColors.card,
                                          title: const Text('Dersi Sil'),
                                          content: Text('${sub.name} dersini ve tüm verilerini silmek istediğine emin misin?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('HAYIR')),
                                            TextButton(onPressed: () { p.deleteSubject(sub.id); Navigator.pop(context); }, child: const Text('SİL', style: TextStyle(color: Colors.red))),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sub.name, 
                                            maxLines: 2, 
                                            overflow: TextOverflow.ellipsis, 
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.1)
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _fmtMin(sub.totalMinutes), 
                                            style: TextStyle(fontSize: 10, color: color.withOpacity(0.8), fontWeight: FontWeight.bold)
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Sağ üstte küçük info ikonu (Tıklamayı engellememesi için IgnorePointer)
                              const Positioned(
                                top: 8,
                                right: 8,
                                child: IgnorePointer(
                                  child: Icon(Icons.info_outline, color: Colors.white10, size: 12),
                                ),
                              ),

                              // Alt kısımda sayaç başlatma butonu (InkWell'in üzerinde olduğu için kendi tıklamasını alır)
                              Positioned(
                                bottom: 10,
                                left: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: study.isActive ? null : () => _startWithSubject(context, p, sub),
                                  child: Opacity(
                                    opacity: study.isActive ? 0.3 : 1.0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: color.withOpacity(0.4)),
                                      ),
                                      child: Icon(Icons.play_arrow_rounded, color: color, size: 22),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                            Row(
                              children: [
                                Expanded(
                                  child: AccentButton(
                                    label: study.isPaused ? ' DEVAM ET ' : ' MOLA VER ',
                                    color: study.isPaused ? AppColors.study : AppColors.diet,
                                    onTap: () { p.togglePauseStudySession(); },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AccentButton(
                                    label: ' BİTİR ',
                                    color: AppColors.smoke,
                                    onTap: () { 
                                      p.completeStudySession(_elapsed ~/ 60); 
                                      setState(() => _elapsed = 0); 
                                    },
                                  ),
                                ),
                              ],
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

                        final String displayText = (s.topic != null && s.topic!.isNotEmpty) 
                            ? '${s.subject} - (${s.topic})' 
                            : s.subject;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: Icon(Icons.bookmark, color: sColor.withOpacity(0.7), size: 16),
                          title: Text(displayText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          trailing: Text(_fmtMin(s.durationMinutes), style: GoogleFonts.spaceMono(fontSize: 12, color: sColor)),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}