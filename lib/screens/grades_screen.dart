import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});
  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  List<Grade> _grades = [];
  int _nextId = 1;
  String? _selSubject;
  int _selGrade = 5;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final g = await StorageService.loadGrades();
    if (mounted) setState(() { _grades = g; });
  }

  double get _avg {
    if (_grades.isEmpty) return 0;
    return _grades.map((g) => g.value).reduce((a, b) => a + b) / _grades.length;
  }

  Map<String, List<Grade>> get _bySubject {
    final m = <String, List<Grade>>{};
    for (final g in _grades) {
      m.putIfAbsent(g.subject, () => []).add(g);
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Text('Оценки',
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

            // Средний балл
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _statCard(_avg == 0 ? '—' : _avg.toStringAsFixed(1),
                      'средний балл'),
                  const SizedBox(width: 10),
                  _statCard('${_grades.length}', 'всего оценок'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Добавить оценку
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bg3,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ОТМЕТИТЬ ОЦЕНКУ',
                      style: TextStyle(
                          color: AppColors.primary2,
                          fontSize: 9.5,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 10),
                  // Выбор предмета
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: defaultSubjects.map((s) {
                        final on = _selSubject == s.name;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selSubject = s.name),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: on ? AppColors.primary : AppColors.bg4,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: on
                                      ? AppColors.primary
                                      : AppColors.border2),
                            ),
                            child: Text(s.code,
                                style: TextStyle(
                                    color: on
                                        ? Colors.white
                                        : AppColors.text2,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Кнопки оценки
                  Row(
                    children: [2, 3, 4, 5].map((g) {
                      final on = _selGrade == g;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selGrade = g),
                          child: Container(
                            margin: EdgeInsets.only(
                                right: g < 5 ? 6.0 : 0),
                            height: 44,
                            decoration: BoxDecoration(
                              color: on
                                  ? AppColors.primary
                                  : AppColors.bg4,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text('$g',
                                  style: TextStyle(
                                      color: on
                                          ? Colors.white
                                          : AppColors.text,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addGrade,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Добавить оценку',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Список
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _bySubject.entries.map((e) {
                  final avg = e.value
                          .map((g) => g.value)
                          .reduce((a, b) => a + b) /
                      e.value.length;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.bg3,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.key,
                                  style: const TextStyle(
                                      color: AppColors.text,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                children: e.value
                                    .map((g) => _GradeDot(g.value))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        Text(avg.toStringAsFixed(1),
                            style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 22,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String val, String lbl) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bg3,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(val,
                  style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1)),
              Text(lbl,
                  style: const TextStyle(
                      color: AppColors.text2, fontSize: 10)),
            ],
          ),
        ),
      );

  void _addGrade() async {
    if (_selSubject == null) return;
    final now = DateTime.now();
    final grade = Grade(
      id: _nextId++,
      subject: _selSubject!,
      value: _selGrade,
      date: '${now.day}.${now.month}.${now.year}',
    );
    setState(() => _grades.add(grade));
    await StorageService.saveGrades(_grades);
  }
}

class _GradeDot extends StatelessWidget {
  final int value;
  const _GradeDot(this.value);

  Color get _color {
    switch (value) {
      case 5: return const Color(0xFF2A2555);
      case 4: return const Color(0xFF1A2040);
      case 3: return const Color(0xFF2A1E08);
      default: return const Color(0xFF2A1010);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
            color: _color, borderRadius: BorderRadius.circular(7)),
        child: Center(
          child: Text('$value',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ),
      );
}
