import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class LocalRepository {
  const LocalRepository();

  Future<List<Map<String, dynamic>>> loadProblems() async {
    final String jsonString = await rootBundle.loadString('assets/problems.json');
    final Map<String, dynamic> decoded = json.decode(jsonString) as Map<String, dynamic>;
    final List<dynamic> problemsDynamic = decoded['problems'] as List<dynamic>? ?? <dynamic>[];
    return problemsDynamic.map((dynamic e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}


