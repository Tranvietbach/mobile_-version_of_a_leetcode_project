import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String _solutionsBox = 'solutions';
  static const String _userBox = 'user';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(_solutionsBox);
    await Hive.openBox<dynamic>(_userBox);
  }

  static Box<dynamic> _box() => Hive.box<dynamic>(_solutionsBox);
  static Box<dynamic> _user() => Hive.box<dynamic>(_userBox);

  static String _codeKey(String problemId, String language) => 'code:$problemId:$language';
  static String _solvedKey(String problemId, String language) => 'solved:$problemId:$language';
  static String _hintsKey(String problemId) => 'hints:$problemId';
  static String _solvedAtKey(String problemId, String language) => 'solvedAt:$problemId:$language';
  static const String _userNameKey = 'user:name';
  static const String _skulptScriptKey = 'py:skulpt:1.2.0';

  static Future<void> saveCode({
    required String problemId,
    required String language,
    required String code,
  }) async {
    await _box().put(_codeKey(problemId, language), code);
  }

  static String? getCode({
    required String problemId,
    required String language,
  }) {
    return _box().get(_codeKey(problemId, language)) as String?;
  }

  static Future<void> setSolved({
    required String problemId,
    required String language,
    required bool solved,
  }) async {
    await _box().put(_solvedKey(problemId, language), solved);
  }

  static bool isSolved({
    required String problemId,
    required String language,
  }) {
    return (_box().get(_solvedKey(problemId, language)) as bool?) ?? false;
  }

  static int getHintsRevealed(String problemId) {
    return (_box().get(_hintsKey(problemId)) as int?) ?? 0;
  }

  static Future<void> setHintsRevealed(String problemId, int count) async {
    await _box().put(_hintsKey(problemId), count);
  }

  static Future<void> setSolvedAt({
    required String problemId,
    required String language,
    required int timestampMs,
  }) async {
    await _box().put(_solvedAtKey(problemId, language), timestampMs);
  }

  static int? getSolvedAt({
    required String problemId,
    required String language,
  }) {
    return _box().get(_solvedAtKey(problemId, language)) as int?;
  }

  static Future<void> setUserName(String name) async {
    await _user().put(_userNameKey, name);
  }

  static String getUserName() {
    return (_user().get(_userNameKey) as String?) ?? 'You';
  }

  static Future<void> cacheSkulptScript(String script) async {
    await _user().put(_skulptScriptKey, script);
  }

  static String? getSkulptScript() {
    return _user().get(_skulptScriptKey) as String?;
  }

  static int pointsForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return 10;
      case 'Medium':
        return 20;
      case 'Hard':
        return 30;
      default:
        return 5;
    }
  }

  static Future<int> recordSolveIfFirst({
    required String problemId,
    required String language,
    required String difficulty,
  }) async {
    final bool already = isSolved(problemId: problemId, language: language);
    if (already) return 0;
    await setSolved(problemId: problemId, language: language, solved: true);
    await setSolvedAt(problemId: problemId, language: language, timestampMs: DateTime.now().millisecondsSinceEpoch);
    return pointsForDifficulty(difficulty);
  }

  static List<Map<String, dynamic>> getSolveHistory() {
    final List<Map<String, dynamic>> history = <Map<String, dynamic>>[];
    for (final dynamic key in _box().keys) {
      final String k = key.toString();
      if (k.startsWith('solvedAt:')) {
        final int? ts = _box().get(k) as int?;
        if (ts != null) {
          // key format: solvedAt:problemId:language
          final List<String> parts = k.split(':');
          if (parts.length >= 3) {
            history.add(<String, dynamic>{
              'problemId': parts[1],
              'language': parts[2],
              'timestampMs': ts,
            });
          }
        }
      }
    }
    history.sort((a, b) => (b['timestampMs'] as int).compareTo(a['timestampMs'] as int));
    return history;
  }
}


