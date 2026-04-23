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

  void _clearHistoryDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Geçmişi Temizle', style: GoogleFonts.spaceMono(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Bu kategorideki tüm geçmiş veriler silinecek. Emin misiniz?', 
          style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İPTAL', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().clearHistory(type);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Geçmiş temizlendi')),
              );
            },
            child: const Text('SİL', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: AppColors.textSecondary),
            tooltip: 'Geçmişi Temizle',
            onPressed: () {
              final currentType = _tabController.index == 0 ? 'smoke' : (_tabController.index == 1 ? 'diet' : 'study');
              _clearHistoryDialog(currentType);
            },
          ),
          const SizedBox(width: 8),
        ],
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
              _HistoryList(items: p.smoke.history.reversed.toList(), type: 'smoke'),
              _HistoryList(items: p.diet.history.reversed.toList(), type: 'diet'),
              _HistoryList(items: p.study.history.reversed.toList(), type: 'study'),
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

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getColor().withOpacity(0.3)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              iconColor: _getColor(),
              collapsedIconColor: AppColors.textSecondary,
              title: Text(date, style: GoogleFonts.spaceMono(color: _getColor(), fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _buildSummary(item),
              ),
              children: [
                const Divider(color: Colors.white10, height: 1),
                _buildDetails(item),
                const SizedBox(height: 12),
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

  // Kart kapalıyken görünen özet
  Widget _buildSummary(Map<String, dynamic> item) {
    if (type == 'smoke') {
      final smoked = item['smoked'] ?? 0;
      final limit = item['limit'] ?? 0;
      return Text('$smoked / $limit Adet', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary));
    } else if (type == 'diet') {
      final cal = item['calories'] ?? 0;
      // FIX: Geçmiş kayıttaki maintenance (ihtiyaç) değerini al, yoksa goal veya 2000 kullan
      final target = item['maintenance'] ?? item['goal'] ?? 2000;
      return Text('$cal / $target kcal', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary));
    } else {
      final mins = item['totalMinutes'] ?? 0;
      return Text('$mins Dakika Çalışma', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary));
    }
  }

  // Kart açıldığında görünen detaylar
  Widget _buildDetails(Map<String, dynamic> item) {
    if (type == 'smoke') {
      final smoked = item['smoked'] ?? 0;
      final limit = item['limit'] ?? 0;
      final diff = limit - smoked;
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatMini(label: 'İÇİLEN', value: '$smoked'),
            _StatMini(label: 'LİMİT', value: '$limit'),
            _StatMini(
              label: 'DURUM', 
              value: diff >= 0 ? 'BAŞARILI' : 'AŞILDI',
              color: diff >= 0 ? AppColors.success : AppColors.smoke,
            ),
          ],
        ),
      );
    } 
    
    if (type == 'diet') {
      final meals = (item['meals'] as List?) ?? [];
      final water = item['water'] ?? 0;
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.water_drop, color: AppColors.diet, size: 16),
                const SizedBox(width: 8),
                Text('$water Bardak Su İçildi', style: const TextStyle(fontSize: 13, color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 12),
            if (meals.isEmpty)
              const Text('Öğün kaydı bulunamadı.', style: TextStyle(fontSize: 12, color: AppColors.textMuted))
            else
              ...meals.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Text(m['time'] ?? '--:--', style: GoogleFonts.spaceMono(fontSize: 11, color: AppColors.diet)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(m['name'] ?? '', style: const TextStyle(fontSize: 13))),
                    Text('${m['calories']} kcal', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
          ],
        ),
      );
    }

    if (type == 'study') {
      final sessions = (item['sessions'] as List?) ?? [];
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            if (sessions.isEmpty)
              const Text('Oturum kaydı bulunamadı.', style: TextStyle(fontSize: 12, color: AppColors.textMuted))
            else
              ...sessions.map((s) {
                final String subject = s['subject'] ?? 'Ders';
                final String? topic = s['topic'];
                final displayText = (topic != null && topic.isNotEmpty) 
                    ? '$subject - ($topic)' 
                    : subject;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Text(s['time'] ?? '--:--', style: GoogleFonts.spaceMono(fontSize: 11, color: AppColors.study)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(displayText, style: const TextStyle(fontSize: 13))),
                      Text('${s['durationMinutes']} dk', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.study)),
                    ],
                  ),
                );
              }),
          ],
        ),
      );
    }

    return const SizedBox();
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
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 1)),
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