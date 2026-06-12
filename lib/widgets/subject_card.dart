import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/models.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';

class SubjectCard extends StatefulWidget {
  final Subject subject;
  final String homework;
  final ValueChanged<String> onHwChanged;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.homework,
    required this.onHwChanged,
  });

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> {
  bool _expanded = false;
  bool _aiLoading = false;
  String _aiResult = '';
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.homework);
  }

  @override
  void didUpdateWidget(SubjectCard old) {
    super.didUpdateWidget(old);
    if (old.homework != widget.homework) {
      _ctrl.text = widget.homework;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _accentColor {
    final hex = widget.subject.colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          // Строка заголовка
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Иконка предмета
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(
                      child: Text(
                        widget.subject.code,
                        style: TextStyle(
                            color: _accentColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Название и ДЗ
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.subject.name,
                            style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                                fontWeight: FontWeight.w650)),
                        if (widget.homework.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.homework,
                            style: const TextStyle(
                                color: AppColors.text2, fontSize: 11.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.text3,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Раскрытая панель
          if (_expanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ДОМАШНЕЕ ЗАДАНИЕ',
                      style: TextStyle(
                          color: AppColors.text3,
                          fontSize: 9,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _ctrl,
                    style: const TextStyle(
                        color: AppColors.text, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Введи задание...',
                      hintStyle:
                          const TextStyle(color: AppColors.text3),
                      filled: true,
                      fillColor: AppColors.bg4,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.border2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.border2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    onChanged: widget.onHwChanged,
                  ),

                  const SizedBox(height: 10),

                  // Кнопка AI
                  GestureDetector(
                    onTap: _askAI,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDim,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryRing),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              color: AppColors.primary3, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            _aiLoading
                                ? 'Думаю...'
                                : 'Помощь ИИ по заданию',
                            style: const TextStyle(
                                color: AppColors.primary3,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // AI ответ
                  if (_aiResult.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bg4,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border2),
                      ),
                      child: Text(_aiResult,
                          style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 12.5,
                              height: 1.6)),
                    ),
                  ],

                  if (_aiLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: LinearProgressIndicator(
                          color: AppColors.primary,
                          backgroundColor: AppColors.primaryDim),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _askAI() async {
    if (_ctrl.text.isEmpty) return;
    setState(() { _aiLoading = true; _aiResult = ''; });
    final apiKey = await StorageService.loadApiKey();
    final result = await GeminiService.askHomework(
      apiKey: apiKey,
      subject: widget.subject.name,
      homework: _ctrl.text,
      question: 'Объясни это задание и помоги с ним',
    );
    if (mounted) setState(() { _aiResult = result; _aiLoading = false; });
  }
}
