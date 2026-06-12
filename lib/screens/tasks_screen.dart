import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> _tasks = [];
  int _nextId = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tasks = await StorageService.loadTasks();
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _nextId = tasks.isEmpty
            ? 1
            : tasks.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1;
      });
    }
  }

  Future<void> _save() => StorageService.saveTasks(_tasks);

  List<Task> get _active => _tasks.where((t) => !t.done).toList();
  List<Task> get _done   => _tasks.where((t) =>  t.done).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Задания',
                            style: TextStyle(
                                color: AppColors.text,
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.8)),
                        Text('${_active.length} активных',
                            style: const TextStyle(
                                color: AppColors.text3, fontSize: 12)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showAddTask(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text('Задание',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (_active.isNotEmpty) ...[
                    _sectionLabel('Активные'),
                    ..._active.map((t) => _TaskTile(
                          task: t,
                          onDone: () async {
                            setState(() => t.done = true);
                            await _save();
                          },
                          onDelete: () async {
                            setState(() => _tasks.remove(t));
                            await _save();
                          },
                        )),
                  ],
                  if (_done.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _sectionLabel('Выполнено'),
                    ..._done.map((t) => _TaskTile(
                          task: t,
                          onDone: () async {
                            setState(() => t.done = false);
                            await _save();
                          },
                          onDelete: () async {
                            setState(() => _tasks.remove(t));
                            await _save();
                          },
                        )),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t.toUpperCase(),
            style: const TextStyle(
                color: AppColors.text3,
                fontSize: 9.5,
                letterSpacing: 2,
                fontWeight: FontWeight.w700)),
      );

  void _showAddTask(BuildContext context) {
    final nameCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    String? selSubject;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF09090F),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                          color: AppColors.bg5,
                          borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                const Text('Новое задание',
                    style: TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                _modalInput(nameCtrl, 'Название задания...'),
                const SizedBox(height: 8),
                _modalInput(dateCtrl, 'Срок (напр. 15 июня, Завтра)...'),
                const SizedBox(height: 10),
                // Чипы предметов
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: defaultSubjects.map((s) {
                    final on = selSubject == s.name;
                    return GestureDetector(
                      onTap: () => setSt(() => selSubject = s.name),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: on ? AppColors.primary : AppColors.bg3,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: on
                                  ? AppColors.primary
                                  : AppColors.border),
                        ),
                        child: Text(s.name,
                            style: TextStyle(
                                color: on ? Colors.white : AppColors.text2,
                                fontSize: 11.5)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.isEmpty) return;
                      setState(() {
                        _tasks.add(Task(
                          id: _nextId++,
                          name: nameCtrl.text.trim(),
                          subject: selSubject ?? '',
                          date: dateCtrl.text.trim(),
                        ));
                      });
                      _save();
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Добавить',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modalInput(TextEditingController ctrl, String hint) =>
      TextField(
        controller: ctrl,
        style: const TextStyle(color: AppColors.text, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.text3),
          filled: true,
          fillColor: AppColors.bg3,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.border2)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.border2)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      );
}

class _TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onDone;
  final VoidCallback onDelete;
  const _TaskTile(
      {required this.task, required this.onDone, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onDone,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.done ? AppColors.primary : Colors.transparent,
                border: Border.all(
                    color: task.done ? AppColors.primary : AppColors.text3,
                    width: 2),
              ),
              child: task.done
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 13)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: TextStyle(
                    color: task.done ? AppColors.text3 : AppColors.text,
                    fontSize: 13.5,
                    decoration:
                        task.done ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (task.subject.isNotEmpty || task.date.isNotEmpty)
                  Text(
                    [task.subject, task.date]
                        .where((s) => s.isNotEmpty)
                        .join(' · '),
                    style: const TextStyle(
                        color: AppColors.text3, fontSize: 11),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close_rounded,
                color: AppColors.text3, size: 18),
          ),
        ],
      ),
    );
  }
}
