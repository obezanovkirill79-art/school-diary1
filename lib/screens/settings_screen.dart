import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameCtrl   = TextEditingController();
  final _surCtrl    = TextEditingController();
  final _apiCtrl    = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _nameCtrl.text = await StorageService.loadName();
    _surCtrl.text  = await StorageService.loadSurname();
    _apiCtrl.text  = await StorageService.loadApiKey();
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _surCtrl.dispose(); _apiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header с кнопкой назад
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 20, 8),
              child: Row(
                children: [
                  // Стильная таблетка-кнопка назад
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.bg3,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border2),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back_ios_new_rounded,
                              color: AppColors.text2, size: 14),
                          SizedBox(width: 4),
                          Text('Назад',
                              style: TextStyle(
                                  color: AppColors.text2,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Настройки',
                      style: TextStyle(
                          color: AppColors.text,
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.8)),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _section('Профиль', [
                    _settingRow(Icons.person_outline_rounded, 'Имя',
                        _nameCtrl, 'Введи имя...'),
                    _settingRow(Icons.person_outline_rounded, 'Фамилия',
                        _surCtrl, 'Введи фамилию...'),
                  ]),
                  const SizedBox(height: 18),

                  _section('Gemini API ключ', [
                    _settingRow(Icons.smart_toy_outlined, 'API Key',
                        _apiCtrl, 'AIza...', obscure: true),
                  ]),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 6, 2, 0),
                    child: Text(
                      'Получи бесплатно на aistudio.google.com → Get API key',
                      style: const TextStyle(
                          color: AppColors.text3, fontSize: 11, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Кнопка сохранить
                  GestureDetector(
                    onTap: _save,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B7FFF), Color(0xFF5040D0)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: const Center(
                        child: Text('Сохранить',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> rows) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(
                  color: AppColors.text2,
                  fontSize: 9.5,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bg3,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border2),
            ),
            child: Column(children: rows),
          ),
        ],
      );

  Widget _settingRow(IconData ico, String lbl,
      TextEditingController ctrl, String hint,
      {bool obscure = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primaryDim,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(ico, color: AppColors.primary2, size: 15),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(lbl,
                style: const TextStyle(
                    color: AppColors.text2, fontSize: 11.5)),
          ),
          Expanded(
            child: TextField(
              controller: ctrl,
              obscureText: obscure,
              style: const TextStyle(
                  color: AppColors.text, fontSize: 12.5),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.text3),
                filled: true,
                fillColor: AppColors.bg4,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide:
                        const BorderSide(color: AppColors.border2)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide:
                        const BorderSide(color: AppColors.border2)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    await StorageService.saveProfile(
        _nameCtrl.text.trim(), _surCtrl.text.trim());
    await StorageService.saveApiKey(_apiCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Сохранено!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
