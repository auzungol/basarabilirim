// lib/screens/projects_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  bool _showForm = false;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  Priority _priority = Priority.mid;
  String _deadline = '';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submitProject(AppProvider p) {
    if (_nameCtrl.text.trim().isEmpty) return;
    p.addProject(_nameCtrl.text.trim(), _descCtrl.text.trim(), _priority, _deadline);
    _nameCtrl.clear();
    _descCtrl.clear();
    setState(() { _showForm = false; _priority = Priority.mid; _deadline = ''; });
  }

  Color _priorityColor(Priority pr) {
    switch (pr) {
      case Priority.high: return AppColors.smoke;
      case Priority.mid: return AppColors.warning;
      case Priority.low: return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, p, _) {
        final active = p.projects.active;
        final done = p.projects.completed;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Add button
              GestureDetector(
                onTap: () => setState(() => _showForm = !_showForm),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.projects.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.projects.withOpacity(0.4)),
                  ),
                  child: Text(
                    _showForm ? '✕ İptal' : '+ Yeni Proje Ekle',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.projects, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),

              // Add form
              if (_showForm) ...[
                const SizedBox(height: 12),
                AppCard(
                  borderColor: AppColors.projects,
                  backgroundColor: const Color(0xFF0D001A),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(hintText: 'Proje adı *'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _descCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(hintText: 'Açıklama (isteğe bağlı)'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Öncelik',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                        letterSpacing: 1)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<Priority>(
                                      value: _priority,
                                      dropdownColor: const Color(0xFF1A1A2E),
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                      isExpanded: true,
                                      onChanged: (v) =>
                                          setState(() => _priority = v ?? Priority.mid),
                                      items: Priority.values
                                          .map((pr) => DropdownMenuItem(
                                                value: pr,
                                                child: Text(pr.label),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Son Tarih',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                        letterSpacing: 1)),
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                                      builder: (context, child) => Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.dark(
                                            primary: AppColors.projects,
                                          ),
                                        ),
                                        child: child!,
                                      ),
                                    );
                                    if (picked != null) {
                                      setState(() => _deadline =
                                          '${picked.day}.${picked.month}.${picked.year}');
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    child: Text(
                                      _deadline.isEmpty ? 'Seç...' : _deadline,
                                      style: TextStyle(
                                          color: _deadline.isEmpty
                                              ? AppColors.textMuted
                                              : Colors.white,
                                          fontSize: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AccentButton(
                        label: 'Projeyi Kaydet',
                        color: AppColors.projects,
                        fullWidth: true,
                        onTap: () => _submitProject(p),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              if (active.isEmpty && !_showForm)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'Henüz proje yok.\nHadi başla! 🚀',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.8),
                  ),
                ),

              ...active.map((proj) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ProjectCard(
                        project: proj,
                        onToggle: () => p.toggleProject(proj.id),
                        onDelete: () => p.deleteProject(proj.id),
                        onAddTask: (name) => p.addTask(proj.id, name),
                        onToggleTask: (i) => p.toggleTask(proj.id, i),
                        priorityColor: _priorityColor(proj.priority)),
                  )),

              if (done.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'TAMAMLANANLAR (${done.length})',
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                ...done.map((proj) => Opacity(
                      opacity: 0.5,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ProjectCard(
                            project: proj,
                            onToggle: () => p.toggleProject(proj.id),
                            onDelete: () => p.deleteProject(proj.id),
                            onAddTask: (_) {},
                            onToggleTask: (_) {},
                            priorityColor: _priorityColor(proj.priority)),
                      ),
                    )),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final Project project;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final ValueChanged<String> onAddTask;
  final ValueChanged<int> onToggleTask;
  final Color priorityColor;

  const _ProjectCard({
    required this.project,
    required this.onToggle,
    required this.onDelete,
    required this.onAddTask,
    required this.onToggleTask,
    required this.priorityColor,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _expanded = false;
  final _taskCtrl = TextEditingController();

  @override
  void dispose() {
    _taskCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return AppCard(
      borderColor: Colors.white,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: widget.onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: p.done ? AppColors.success : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: p.done ? AppColors.success : Colors.white.withOpacity(0.2),
                        width: 2),
                  ),
                  child: p.done
                      ? const Icon(Icons.check, size: 14, color: Color(0xFF001A08))
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          p.name,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration:
                                  p.done ? TextDecoration.lineThrough : null),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.priorityColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            p.priority.label,
                            style: TextStyle(
                                fontSize: 10,
                                color: widget.priorityColor,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1),
                          ),
                        ),
                        if (p.deadline.isNotEmpty)
                          Text('📅 ${p.deadline}',
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                    if (p.desc.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(p.desc,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ),
                    if (p.tasks.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: p.progress,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.projects),
                          minHeight: 3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${p.completedTasks}/${p.tasks.length} görev',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                          _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary,
                          size: 18),
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: Icon(Icons.delete_outline,
                        color: AppColors.smoke.withOpacity(0.5), size: 20),
                  ),
                ],
              ),
            ],
          ),

          // Tasks expansion
          if (_expanded && !p.done) ...[
            Divider(height: 20, color: Colors.white.withOpacity(0.06)),
            ...p.tasks.asMap().entries.map((e) {
              final i = e.key;
              final t = e.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => widget.onToggleTask(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: t.done ? AppColors.projects : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: t.done
                                  ? AppColors.projects
                                  : Colors.white.withOpacity(0.2),
                              width: 2),
                        ),
                        child: t.done
                            ? const Icon(Icons.check, size: 10, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t.name,
                        style: TextStyle(
                          color: t.done
                              ? Colors.white.withOpacity(0.3)
                              : Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          decoration: t.done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    onSubmitted: (v) {
                      widget.onAddTask(v.trim());
                      _taskCtrl.clear();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Görev ekle...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconBtn(
                  icon: Icons.add,
                  color: AppColors.projects.withOpacity(0.5),
                  iconColor: Colors.white,
                  onTap: () {
                    widget.onAddTask(_taskCtrl.text.trim());
                    _taskCtrl.clear();
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
