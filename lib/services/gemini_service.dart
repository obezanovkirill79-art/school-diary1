import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  /// Задать вопрос по ДЗ. Возвращает ответ или сообщение об ошибке.
  static Future<String> askHomework({
    required String apiKey,
    required String subject,
    required String homework,
    required String question,
  }) async {
    if (apiKey.isEmpty) {
      return 'Введи Gemini API ключ в настройках, чтобы использовать ИИ-помощника.';
    }

    final prompt = '''
Ты помощник школьника. Предмет: $subject.
Домашнее задание: $homework.
Вопрос ученика: $question

Ответь кратко и понятно для школьника. Если нужно — приведи пример.
''';

    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {'maxOutputTokens': 400},
        }),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        return data['candidates'][0]['content']['parts'][0]['text'] as String;
      } else {
        return 'Ошибка API: ${resp.statusCode}. Проверь ключ в настройках.';
      }
    } catch (e) {
      return 'Нет соединения с интернетом. Проверь сеть.';
    }
  }
}
