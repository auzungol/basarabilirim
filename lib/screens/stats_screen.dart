// lib/screens/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('GEÇMİŞ & ANALİZ', 
          style: GoogleFonts.spaceMono(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'SİGARA', icon: Icon(Icons.smoking_rooms, size: 20)),
            Tab(text: 'DİYET', icon: Icon(Icons.restaurant, size: 20)),
            Tab(text: 'DERS', icon: Icon(Icons.menu_book, size: 20)),
          ],
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, p, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _HistoryList(
                items: p.smoke.history.reversed.toList(),
                type: 'smoke',
              ),
              _HistoryList(
                items: p.diet.history.reversed.toList(),
                type: 'diet',
              ),
              _HistoryList(
                items: p.study.history.reversed.toList(),
                type: 'study',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String type;

  const _HistoryList({required this.items, required this.type});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, color: Colors.white.withOpacity(0.1), size: 64),
            const SizedBox(height: 16),
            const Text('Henüz geçmiş veri yok.', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final date = item['date'] ?? 'Bilinmeyen Tarih';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            borderColor: _getColor().withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(date, style: GoogleFonts.spaceMono(color: _getColor(), fontWeight: FontWeight.bold)),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 16),
                  ],
                ),
                const Divider(color: Colors.white10, height: 20),
                _buildContent(item),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getColor() {
    switch (type) {
      case 'smoke': return AppColors.smoke;
      case 'diet': return AppColors.diet;
      case 'study': return AppColors.study;
      default: return Colors.white;
    }
  }

  Widget _buildContent(Map<String, dynamic> item) {
    if (type == 'smoke') {
      final smoked = item['smoked'] ?? 0;
      final limit = item['limit'] ?? 0;
      final diff = limit - smoked;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatMini(label: 'İçilen', value: '$smoked'),
          _StatMini(label: 'Hedef', value: '$limit'),
          _StatMini(
            label: 'Durum', 
            value: diff >= 0 ? 'BAŞARILI' : 'AŞILDI',
            color: diff >= 0 ? AppColors.success : AppColors.smoke,
          ),
        ],
      );
    } else if (type == 'diet') {
      final cal = item['calories'] ?? 0;
      final goal = item['goal'] ?? 0;
      final water = item['water'] ?? 0;
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatMini(label: 'Kalori', value: '$cal/$goal'),
              _StatMini(label: 'Su', value: '$water b.'),
            ],
          ),
          if (item['meals'] != null && (item['meals'] as List).isNotEmpty) ...[
             const SizedBox(height: 8),
             Text('${(item['meals'] as List).length} öğün kaydedildi', 
               style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]
        ],
      );
    } else {
      // Study
      final mins = item['totalMinutes'] ?? 0;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StatMini(label: 'Toplam Çalışma', value: '$mins dk'),
        ],
      );
    }
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _StatMini({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.spaceMono(
          fontSize: 14, 
          fontWeight: FontWeight.bold, 
          color: color ?? Colors.white
        )),
      ],
    );
  }
}
