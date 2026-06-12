import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selDay = DateTime.now().weekday - 1; // 0=Пн
  Map<int, List<String>> _schedule = {};
  final _times = ['08:00','09:00','10:00','11:00','12:00','13:00','14:00'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sch = await StorageService.loadSchedule();
    if (mounted) setState(() => _schedule = sch);
  }

  List<String> get _todayLessons =>
      _schedule[_selDay] ?? List.filled(7, '');

  @override
  Widget build(BuildContext context) {
    const dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт'];
    const dayFull = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница'];
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Расписание',
                        style: TextStyle(
                            color: AppColors.text,
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Дни недели
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(5, (i) {
                  final isOn = i == _selDay;
                  final day = now.subtract(
                      Duration(days: now.weekday - 1 - i));
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selDay = i),
                      child: Container(
                        margin: EdgeInsets.only(right: i < 4 ? 4.0 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isOn ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Column(
                          children: [
                            Text(dayNames[i],
                                style: TextStyle(
                                    color: isOn
                                        ? Colors.white70
                                        : AppColors.text3,
                                    fontSize: 9.5)),
                            const SizedBox(height: 4),
                            Text('${day.day}',
                                style: TextStyle(
                                    color: isOn ? Colors.white : AppColors.text,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 4),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(dayFull[_selDay],
                    style: const TextStyle(
                        color: AppColors.text2,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ),

            // Уроки
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _times.length,
                itemBuilder: (_, i) {
                  final lessons = _todayLessons;
                  final name = i < lessons.length ? lessons[i] : '';
                  return _LessonRow(
                    num: i + 1,
                    time: _times[i],
                    name: name,
                    onChanged: (v) async {
                      final updated = List<String>.from(
                          _schedule[_selDay] ?? List.filled(7, ''));
                      while (updated.length <= i) updated.add('');
                      updated[i] = v;
                      setState(() => _schedule[_selDay] = updated);
                      await StorageService.saveSchedule(_schedule);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonRow extends StatefulWidget {
  final int num;
  final String time;
  final String name;
  final ValueChanged<String> onChanged;
  const _LessonRow(
      {required this.num, required this.time,
       required this.name, required this.onChanged});
  @override
  State<_LessonRow> createState() => _LessonRowState();
}

class _LessonRowState extends State<_LessonRow> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.name);
  }

  @override
  void didUpdateWidget(_LessonRow old) {
    super.didUpdateWidget(old);
    if (old.name != widget.name) _ctrl.text = widget.name;
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isEmpty = widget.name.isEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isEmpty ? AppColors.bg3.withOpacity(0.5) : AppColors.bg3,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isEmpty ? AppColors.border : AppColors.border2),
      ),
      child: Row(
        children: [
          Text('${widget.num}',
              style: const TextStyle(
                  color: AppColors.text3,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _ctrl,
              onChanged: widget.onChanged,
              style: const TextStyle(
                  color: AppColors.text, fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'Предмет...',
                hintStyle: const TextStyle(color: AppColors.text3),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Text(widget.time,
              style: const TextStyle(
                  color: AppColors.text3, fontSize: 10)),
        ],
      ),
    );
  }
}
