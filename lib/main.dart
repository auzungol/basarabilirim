// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'theme.dart';
import 'providers/app_provider.dart';
import 'screens/smoke_screen.dart';
import 'screens/diet_screen.dart';
import 'screens/study_screen.dart';
import 'screens/projects_screen.dart';
import 'screens/stats_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeDateFormatting('tr_TR', null);
    final provider = AppProvider();
    await provider.init();

    runApp(
      ChangeNotifierProvider.value(
        value: provider,
        child: const BasarabilirimApp(),
      ),
    );
  } catch (e) {
    debugPrint("Başlatma hatası: $e");
  }
}

class BasarabilirimApp extends StatelessWidget {
  const BasarabilirimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Başarabilirim!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}

class _TabItem {
  final String id;
  final String label;
  final IconData icon;
  final Color accent;

  const _TabItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.accent,
  });
}

const _tabs = [
  _TabItem(id: 'smoke', label: 'Sigara', icon: Icons.smoking_rooms, accent: AppColors.smoke),
  _TabItem(id: 'diet', label: 'Diyet', icon: Icons.restaurant, accent: AppColors.diet),
  _TabItem(id: 'study', label: 'Ders', icon: Icons.menu_book, accent: AppColors.study),
  _TabItem(id: 'projects', label: 'Projeler', icon: Icons.grid_view, accent: AppColors.projects),
  _TabItem(id: 'stats', label: 'Analiz', icon: Icons.bar_chart, accent: Colors.white),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _current = 0;

  final _screens = const [
    SmokeScreen(),
    DietScreen(),
    StudyScreen(),
    ProjectsScreen(),
    StatsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<AppProvider>().refresh();
      setState(() {});
    }
  }

  String _todayStr() {
    const weekdays = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    const months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final tab = _tabs[_current];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header (Padding ve boşluklar azaltıldı)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Başarabilirim!',
                        style: GoogleFonts.spaceMono(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        _todayStr(),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: tab.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: tab.accent.withOpacity(0.3), width: 1.5),
                    ),
                    child: Icon(tab.icon, color: tab.accent, size: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12), // Boşluk azaltıldı

            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final t = _tabs[i];
                  final isActive = i == _current;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _current = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: i < _tabs.length - 1 ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive
                              ? t.accent.withOpacity(0.15)
                              : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: isActive
                                  ? t.accent.withOpacity(0.6)
                                  : Colors.white.withOpacity(0.08),
                              width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Icon(t.icon,
                                size: 16,
                                color: isActive ? t.accent : AppColors.textSecondary),
                            const SizedBox(height: 2),
                            Text(
                              t.label,
                              style: TextStyle(
                                fontSize: 10,
                                color: isActive ? t.accent : AppColors.textSecondary,
                                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 4), // Boşluk azaltıldı

            // Screen
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: KeyedSubtree(
                  key: ValueKey(_current),
                  child: _screens[_current],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}