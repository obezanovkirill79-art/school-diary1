import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../widgets/subject_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name = '';
  Map<String, String> _hw = {};
  List<Subject> _subjects = List.from(defaultSubjects);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await StorageService.loadName();
    final hw   = await StorageService.loadHomework();
    if (mounted) setState(() { _name = name; _hw = hw; });
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Доброе утро';
    if (h < 18) return 'Добрый день';
    return 'Добрый вечер';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_greeting${_name.isNotEmpty ? ', $_name' : ''} 👋',
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _todayStr(),
                          style: const TextStyle(
                              color: AppColors.text3, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  // Аватар → настройки
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/settings')
                        .then((_) => _load()),
                    child: _AvatarButton(name: _name),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Карточка статистики
            _StatCard(hw: _hw, subjects: _subjects),
            const SizedBox(height: 16),

            // Список предметов с ДЗ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  Text('ДОМАШНЕЕ ЗАДАНИЕ',
                      style: TextStyle(
                          color: AppColors.text3,
                          fontSize: 9.5,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _subjects.length,
                itemBuilder: (_, i) {
                  final s = _subjects[i];
                  return SubjectCard(
                    subject: s,
                    homework: _hw[s.name] ?? '',
                    onHwChanged: (v) async {
                      setState(() => _hw[s.name] = v);
                      await StorageService.saveHomework(_hw);
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

  String _todayStr() {
    const months = [
      'января','февраля','марта','апреля','мая','июня',
      'июля','августа','сентября','октября','ноября','декабря'
    ];
    const days = ['Воскресенье','Понедельник','Вторник',
                  'Среда','Четверг','Пятница','Суббота'];
    final now = DateTime.now();
    return '${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]}';
  }
}

class _AvatarButton extends StatelessWidget {
  final String name;
  const _AvatarButton({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
      ),
      child: Center(
        child: Text(initials,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final Map<String, String> hw;
  final List<Subject> subjects;
  const _StatCard({required this.hw, required this.subjects});

  @override
  Widget build(BuildContext context) {
    final filled = hw.values.where((v) => v.isNotEmpty).length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B6CF6), Color(0xFF5040D0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ЗАПОЛНЕНО ДЗ',
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 9.5,
                      letterSpacing: 2.5)),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$filled',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -3,
                          height: 1)),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 4),
                    child: Text('/ ${subjects.length}',
                        style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 24,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const Text('предметов',
                  style: TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
