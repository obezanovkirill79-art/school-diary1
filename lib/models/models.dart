// ─── Предмет ──────────────────────────────────────────────────────────────────
class Subject {
  final String name;
  final String code;
  final String colorHex;
  String homework;
  String book;

  Subject({
    required this.name,
    required this.code,
    required this.colorHex,
    this.homework = '',
    this.book = '',
  });

  Map<String, dynamic> toJson() => {
    'name': name, 'code': code, 'colorHex': colorHex,
    'homework': homework, 'book': book,
  };

  factory Subject.fromJson(Map<String, dynamic> j) => Subject(
    name: j['name'], code: j['code'], colorHex: j['colorHex'],
    homework: j['homework'] ?? '', book: j['book'] ?? '',
  );
}

// ─── Задание ──────────────────────────────────────────────────────────────────
class Task {
  final int id;
  String name;
  String subject;
  String date;
  bool done;

  Task({required this.id, required this.name,
        this.subject = '', this.date = '', this.done = false});

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'subject': subject, 'date': date, 'done': done};

  factory Task.fromJson(Map<String, dynamic> j) => Task(
    id: j['id'], name: j['name'],
    subject: j['subject'] ?? '', date: j['date'] ?? '',
    done: j['done'] ?? false,
  );
}

// ─── Оценка ───────────────────────────────────────────────────────────────────
class Grade {
  final int id;
  final String subject;
  final int value;
  final String date;

  Grade({required this.id, required this.subject,
         required this.value, required this.date});

  Map<String, dynamic> toJson() =>
      {'id': id, 'subject': subject, 'value': value, 'date': date};

  factory Grade.fromJson(Map<String, dynamic> j) => Grade(
    id: j['id'], subject: j['subject'],
    value: j['value'], date: j['date'],
  );
}

// ─── Предметы по умолчанию ───────────────────────────────────────────────────
final List<Subject> defaultSubjects = [
  Subject(name: 'Русский язык',     code: 'РУС', colorHex: '#b878d8'),
  Subject(name: 'Литература',       code: 'ЛИТ', colorHex: '#d080e8'),
  Subject(name: 'Иностранный язык', code: 'АНГ', colorHex: '#c060c0'),
  Subject(name: 'Алгебра',          code: 'АЛГ', colorHex: '#7888f0'),
  Subject(name: 'Вер. и статистика',code: 'ВЕР', colorHex: '#5878e8'),
  Subject(name: 'Геометрия',        code: 'ГЕО', colorHex: '#6080f0'),
  Subject(name: 'Информатика',      code: 'ИНФ', colorHex: '#48c8a0'),
  Subject(name: 'Физика',           code: 'ФИЗ', colorHex: '#c08848'),
  Subject(name: 'Химия',            code: 'ХИМ', colorHex: '#48b878'),
  Subject(name: 'Биология',         code: 'БИО', colorHex: '#a068d0'),
  Subject(name: 'История',          code: 'ИСТ', colorHex: '#40a870'),
  Subject(name: 'Обществознание',   code: 'ОБЩ', colorHex: '#c0b040'),
  Subject(name: 'География',        code: 'ГЕО2',colorHex: '#b8a848'),
  Subject(name: 'Физкультура',      code: 'ФКТ', colorHex: '#e06080'),
];
