import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_js/flutter_js.dart';
import 'package:http/http.dart' as http;

import 'js_executor.dart';
import 'storage_service.dart';

class PythonExecutor {
  PythonExecutor() : _runtime = getJavascriptRuntime();

  final JavascriptRuntime _runtime;

  Future<void> _ensureSkulptLoaded() async {
    final JsEvalResult check = _runtime.evaluate("typeof Sk !== 'undefined' ? '1' : '0'");
    if (check.stringResult == '1') return;

    String? script = StorageService.getSkulptScript();
    if (script == null) {
      try {
        script = await rootBundle.loadString('assets/third_party/skulpt.min.js');
      } catch (_) {
        // ignore if asset missing
      }
    }
    if (script == null) {
      try {
        final http.Response resp = await http.get(Uri.parse('https://cdn.jsdelivr.net/npm/skulpt@1.2.0/dist/skulpt.min.js'));
        if (resp.statusCode == 200) {
          script = resp.body;
          await StorageService.cacheSkulptScript(script);
        }
      } catch (_) {}
    }
    if (script == null) {
      throw Exception('Skulpt runtime not available (offline).');
    }
    _runtime.evaluate(script);
    // Verify Sk is defined; if not, try CDN fallback even if asset existed
    final JsEvalResult postEval = _runtime.evaluate("typeof Sk !== 'undefined' ? '1' : '0'");
    if (postEval.stringResult != '1') {
      try {
        final http.Response resp = await http.get(Uri.parse('https://cdn.jsdelivr.net/npm/skulpt@1.2.0/dist/skulpt.min.js'));
        if (resp.statusCode == 200) {
          final String cdnScript = resp.body;
          await StorageService.cacheSkulptScript(cdnScript);
          _runtime.evaluate(cdnScript);
        }
      } catch (_) {}
    }
  }

  String _toPythonLiteral(dynamic value) {
    if (value == null) return 'None';
    if (value is bool) return value ? 'True' : 'False';
    if (value is num) return value.toString();
    if (value is String) {
      final String escaped = value.replaceAll('\\', r'\\').replaceAll("'", r"\'");
      return "'${escaped}'";
    }
    if (value is List) {
      return '[' + value.map(_toPythonLiteral).join(', ') + ']';
    }
    if (value is Map) {
      final entries = value.entries.map((e) => '${_toPythonLiteral(e.key)}: ${_toPythonLiteral(e.value)}').join(', ');
      return '{' + entries + '}';
    }
    return 'None';
  }

  Future<List<JsTestResult>> runTests({
    required String userCode,
    required List<Map<String, dynamic>> tests,
    int? onlyIndex,
  }) async {
    await _ensureSkulptLoaded();

    final List<Map<String, dynamic>> slice = onlyIndex == null
        ? tests
        : (onlyIndex >= 0 && onlyIndex < tests.length)
            ? <Map<String, dynamic>>[tests[onlyIndex]]
            : <Map<String, dynamic>>[];

    final List<JsTestResult> results = <JsTestResult>[];

    for (final Map<String, dynamic> t in slice) {
      final String argsLit = _toPythonLiteral(t['args']);
      final String expectedLit = _toPythonLiteral(t['expected']);

      final String pyHarness = """
${userCode}
__res = None
__err = None
try:
    __res = solve(*${argsLit})
except Exception as e:
    __err = str(e)
__ok = (__err is None) and (__res == ${expectedLit})
print('__RESULT__|' + ('OK' if __ok else 'FAIL'))
print('__OUTPUT__|' + repr(__res))
print('__EXPECTED__|' + repr(${expectedLit}))
if __err is not None:
    print('__ERROR__|' + __err)
""";

      final String js = """
(function(){
  var __out = [];
  function __outf(t){ __out.push(String(t)); }
  try {
    Sk.configure({ output: __outf, read: function(x){ throw 'File not found: '+x; } });
    Sk.execLimit = 1e7;
    var __code = ${jsonEncode(pyHarness)};
    Sk.importMainWithBody('<stdin>', false, __code);
  } catch (e) {
    try { __out.push('__ERROR__|' + (e && e.toString ? e.toString() : String(e))); } catch(_) { __out.push('__ERROR__|Unknown error'); }
  }
  return JSON.stringify(__out);
})()
""";

      final JsEvalResult eval = _runtime.evaluate(js);
      final List<dynamic> outLines = jsonDecode(eval.stringResult) as List<dynamic>;
      bool ok = false;
      String? err;
      dynamic output;
      dynamic expected;
      for (final dynamic line in outLines) {
        final String s = line.toString();
        if (s.startsWith('__RESULT__|')) {
          ok = s.contains('OK');
        } else if (s.startsWith('__OUTPUT__|')) {
          output = s.substring('__OUTPUT__|'.length);
        } else if (s.startsWith('__EXPECTED__|')) {
          expected = s.substring('__EXPECTED__|'.length);
        } else if (s.startsWith('__ERROR__|')) {
          err = s.substring('__ERROR__|'.length);
        }
      }
      results.add(JsTestResult(passed: ok, output: output, expected: expected, error: err, console: outLines.map((e)=>e.toString()).toList()));
    }

    return results;
  }
}


