import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/grades_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Статус-бар прозрачный
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const DiaryApp());
}

class DiaryApp extends StatelessWidget {
  const DiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Школьный Дневник',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050508),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C5FF5),
          secondary: Color(0xFF9D97FF),
          surface: Color(0xFF09090F),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// ─── Главный экран с нижней навигацией ───────────────────────────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ScheduleScreen(),
    TasksScreen(),
    GradesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    const items = [
      {'icon': Icons.home_rounded, 'label': 'Главная'},
      {'icon': Icons.calendar_month_rounded, 'label': 'Расписание'},
      {'icon': Icons.check_box_rounded, 'label': 'Задания'},
      {'icon': Icons.bar_chart_rounded, 'label': 'Оценки'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF09090F),
        border: Border(top: BorderSide(color: Color(0x0FFFFFFF), width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Stack(
            children: [
              // Обычные кнопки навигации
              Row(
                children: List.generate(items.length + 1, (i) {
                  // Вставляем пустое место по центру для FAB
                  if (i == 2) {
                    return const Expanded(child: SizedBox());
                  }
                  final idx = i > 2 ? i - 1 : i;
                  final item = items[idx];
                  final isOn = _currentIndex == idx;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentIndex = idx),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 22,
                            color: isOn
                                ? const Color(0xFF9D97FF)
                                : const Color(0xFF606090),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item['label'] as String,
                            style: TextStyle(
                              fontSize: 9.5,
                              color: isOn
                                  ? const Color(0xFF9D97FF)
                                  : const Color(0xFF606090),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              // FAB по центру
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: _VoiceFab(
                    onTap: () => _openVoiceOverlay(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openVoiceOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const VoiceOverlay(),
    );
  }
}

// ─── Стильная кнопка голоса ───────────────────────────────────────────────────
class _VoiceFab extends StatefulWidget {
  final VoidCallback onTap;
  const _VoiceFab({required this.onTap});

  @override
  State<_VoiceFab> createState() => _VoiceFabState();
}

class _VoiceFabState extends State<_VoiceFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _glow = Tween(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glow,
        builder: (_, child) => Container(
          width: 58,
          height: 58,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8B7FFF), Color(0xFF6C5FF5), Color(0xFF5040D0)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C5FF5)
                    .withOpacity(0.5 * _glow.value),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: const Color(0xFF6C5FF5).withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.mic_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

// ─── Оверлей голосового ввода ─────────────────────────────────────────────────
class VoiceOverlay extends StatefulWidget {
  const VoiceOverlay({super.key});

  @override
  State<VoiceOverlay> createState() => _VoiceOverlayState();
}

class _VoiceOverlayState extends State<VoiceOverlay>
    with TickerProviderStateMixin {
  late AnimationController _orbCtrl;
  late AnimationController _ring1Ctrl;
  late AnimationController _ring2Ctrl;
  late AnimationController _ring3Ctrl;

  String _transcript = 'Ждём речь...';
  bool _hasResult = false;

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _ring1Ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
    _ring2Ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
    _ring3Ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();

    Future.delayed(const Duration(milliseconds: 400),
        () => _ring2Ctrl.forward(from: 0.0));
    Future.delayed(const Duration(milliseconds: 800),
        () => _ring3Ctrl.forward(from: 0.0));
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    _ring1Ctrl.dispose();
    _ring2Ctrl.dispose();
    _ring3Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF050508),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: Color(0x1AFFFFFF), width: 1),
          left: BorderSide(color: Color(0x1AFFFFFF), width: 1),
          right: BorderSide(color: Color(0x1AFFFFFF), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Хэндл
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C28),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Тег
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5FF5).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFF6C5FF5).withOpacity(0.4)),
            ),
            child: const Text(
              'ГОЛОСОВОЙ ВВОД',
              style: TextStyle(
                  color: Color(0xFFC0BCFF),
                  fontSize: 10,
                  letterSpacing: 1.5),
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            'Говорите сейчас',
            style: TextStyle(
              color: Color(0xFFF5F5FF),
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 32),

          // ORB анимация
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Кольца
                _buildRing(_ring3Ctrl, 144),
                _buildRing(_ring2Ctrl, 118),
                _buildRing(_ring1Ctrl, 92),
                // Орб
                AnimatedBuilder(
                  animation: _orbCtrl,
                  builder: (_, __) => Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        center: Alignment(-0.3, -0.3),
                        colors: [
                          Color(0xFFA89FFF),
                          Color(0xFF6C5FF5),
                          Color(0xFF3D2FBF),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C5FF5).withOpacity(
                              0.4 + 0.3 * _orbCtrl.value),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.mic_rounded,
                        color: Colors.white, size: 34),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Транскрипт
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F18),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: const Color(0xFF1C1C28), width: 1),
            ),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('РАСПОЗНАНО',
                    style: TextStyle(
                        color: Color(0xFF606090),
                        fontSize: 9,
                        letterSpacing: 1.5)),
                const SizedBox(height: 5),
                Text(_transcript,
                    style: const TextStyle(
                        color: Color(0xFFF5F5FF),
                        fontSize: 14,
                        height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Примеры
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F18),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: const Color(0xFF1C1C28), width: 1),
            ),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ПРИМЕРЫ',
                    style: TextStyle(
                        color: Color(0xFF606090),
                        fontSize: 9,
                        letterSpacing: 1.5)),
                const SizedBox(height: 6),
                _exampleRow('Алгебра,', ' параграф 14, стр. 45'),
                _exampleRow('История,', ' пересказ параграфа 8'),
                _exampleRow('Физика,', ' задачи номер 3, 5, 7'),
              ],
            ),
          ),

          const Spacer(),

          // Кнопки
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                if (_hasResult)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Сохранить ДЗ',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5FF5),
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.stop_rounded),
                    label: const Text('Остановить',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xD9C0392B),
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена',
                      style: TextStyle(
                          color: Color(0xFF606090), fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRing(AnimationController ctrl, double size) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final t = ctrl.value;
        return Opacity(
          opacity: (1.0 - t).clamp(0.0, 1.0) *
              (t > 0.15 ? 1.0 : t / 0.15),
          child: Transform.scale(
            scale: 0.7 + 0.5 * t,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF6C5FF5).withOpacity(0.35),
                  width: 1.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _exampleRow(String bold, String rest) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
              fontSize: 12, height: 1.7, color: Color(0xFFA8A8D0)),
          children: [
            TextSpan(
                text: '«$bold',
                style: const TextStyle(
                    color: Color(0xFFC0BCFF),
                    fontWeight: FontWeight.w600)),
            TextSpan(text: '$rest»'),
          ],
        ),
      ),
    );
  }
}
