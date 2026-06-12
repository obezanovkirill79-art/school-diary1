import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const _tasksKey    = 'tasks';
  static const _gradesKey   = 'grades';
  static const _hwKey       = 'homework';
  static const _subjectsKey = 'subjects';
  static const _scheduleKey = 'schedule';
  static const _nameKey     = 'user_name';
  static const _surKey      = 'user_sur';
  static const _apiKey      = 'gemini_api_key';

  // Задания
  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_tasksKey) ?? [];
    return raw.map((s) => Task.fromJson(jsonDecode(s))).toList();
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _tasksKey, tasks.map((t) => jsonEncode(t.toJson())).toList());
  }

  // Оценки
  static Future<List<Grade>> loadGrades() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_gradesKey) ?? [];
    return raw.map((s) => Grade.fromJson(jsonDecode(s))).toList();
  }

  static Future<void> saveGrades(List<Grade> grades) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _gradesKey, grades.map((g) => jsonEncode(g.toJson())).toList());
  }

  // Домашнее задание
  static Future<Map<String, String>> loadHomework() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_hwKey);
    if (raw == null) return {};
    final Map<String, dynamic> m = jsonDecode(raw);
    return m.map((k, v) => MapEntry(k, v.toString()));
  }

  static Future<void> saveHomework(Map<String, String> hw) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_hwKey, jsonEncode(hw));
  }

  // Расписание: Map<день(0-4), List<предмет>>
  static Future<Map<int, List<String>>> loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scheduleKey);
    if (raw == null) return {};
    final Map<String, dynamic> m = jsonDecode(raw);
    return m.map((k, v) =>
        MapEntry(int.parse(k), List<String>.from(v)));
  }

  static Future<void> saveSchedule(Map<int, List<String>> sch) async {
    final prefs = await SharedPreferences.getInstance();
    final m = sch.map((k, v) => MapEntry(k.toString(), v));
    await prefs.setString(_scheduleKey, jsonEncode(m));
  }

  // Профиль
  static Future<String> loadName() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_nameKey) ?? '';
  }

  static Future<String> loadSurname() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_surKey) ?? '';
  }

  static Future<void> saveProfile(String name, String sur) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_nameKey, name);
    await p.setString(_surKey, sur);
  }

  // API Key
  static Future<String> loadApiKey() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_apiKey) ?? '';
  }

  static Future<void> saveApiKey(String key) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_apiKey, key);
  }
}
