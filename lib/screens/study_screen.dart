// lib/screens/study_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final _subjectCtrl = TextEditingController();
  Timer? _timer;
  int _elapsed = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final p = context.read<AppProvider>();
      if (p.study.isActive) setState(() => _elapsed++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subjectCtrl.dispose();
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

  void _start(AppProvider p) {
    final s = _subjectCtrl.text.trim();
    if (s.isEmpty) return;
    setState(() => _elapsed = 0);
    p.startStudySession(s);
  }

  void _stop(AppProvider p) {
    p.stopStudySession();
    _subjectCtrl.clear();
    setState(() => _elapsed = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, p, _) {
        final study = p.study;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Timer card
              AppCard(
                borderColor: AppColors.study,
                backgroundColor: const Color(0xFF000D0D),
                child: Column(
                  children: [
                    Text(
                      study.isActive ? '📚 ${study.activeSubject}' : 'ÇALIŞMA SAYACI',
                      style: TextStyle(
                        color: AppColors.study,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      study.isActive ? _fmt(_elapsed) : '00:00',
                      style: GoogleFonts.spaceMono(
                        fontSize: 64,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                              text: 'Bugün toplam: ',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13)),
                          TextSpan(
                              text: _fmtMin(study.totalTodayMinutes),
                              style: const TextStyle(
                                  color: AppColors.study,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!study.isActive) ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _subjectCtrl,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              onSubmitted: (_) => _start(p),
                              decoration:
                                  const InputDecoration(hintText: 'Ders / Konu adı'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconBtn(
                            icon: Icons.play_arrow,
                            color: AppColors.study,
                            iconColor: const Color(0xFF001A14),
                            onTap: () => _start(p),
                          ),
                        ],
                      ),
                    ] else ...[
                      AccentButton(
                        label: '⏹ Bitir ve Kaydet',
                        color: AppColors.smoke,
                        fullWidth: true,
                        onTap: () => _stop(p),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Sessions
              if (study.sessions.isNotEmpty)
                AppCard(
                  borderColor: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('BUGÜNKÜ SEANSLAR'),
                      const SizedBox(height: 12),
                      ...study.sessions.reversed.toList().asMap().entries.map((e) {
                        final i = e.key;
                        final s = e.value;
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.subject,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500)),
                                    Text(s.time,
                                        style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11)),
                                  ],
                                ),
                                Text(
                                  _fmtMin(s.durationMinutes),
                                  style: GoogleFonts.spaceMono(
                                      color: AppColors.study,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            if (i < study.sessions.length - 1)
                              Divider(
                                  height: 20,
                                  color: Colors.white.withOpacity(0.05)),
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
}
