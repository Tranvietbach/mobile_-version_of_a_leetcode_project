import 'dart:convert';

import 'package:flutter_js/flutter_js.dart';

class JsTestResult {
  JsTestResult({
    required this.passed,
    required this.output,
    required this.expected,
    this.error,
    this.console,
  });

  final bool passed;
  final dynamic output;
  final dynamic expected;
  final String? error;
  final List<String>? console;
}

class JsExecutor {
  JsExecutor() : _runtime = getJavascriptRuntime();

  final JavascriptRuntime _runtime;

  Future<List<JsTestResult>> runTests({
    required String userCode,
    required List<Map<String, dynamic>> tests,
    int? onlyIndex,
  }) async {
    final String testsJson = jsonEncode(tests);
    final String script = '''
      (function(){
        const __console = [];
        const console = { log: function(){ __console.push(Array.from(arguments).join(' ')); } };
        function deepEqual(a,b){
          try { return JSON.stringify(a) === JSON.stringify(b); } catch(e){ return false; }
        }
        const results = [];
        try {
          // user code
          ${userCode}
          const tests = ${testsJson};
          const start = ${onlyIndex == null ? '0' : onlyIndex.toString()};
          const end = ${onlyIndex == null ? 'tests.length' : '(('+onlyIndex.toString()+'+1))'};
          for (let i = start; i < end; i++) {
            let ok = false; let out = null; let err = null;
            try {
              const args = tests[i].args;
              // call required function: solve
              out = (typeof solve === 'function') ? solve.apply(null, args) : undefined;
              ok = deepEqual(out, tests[i].expected);
            } catch (e) {
              err = String(e);
            }
            results.push({ ok: ok, output: out, expected: tests[i].expected, error: err, console: __console.slice(0) });
          }
        } catch (e) {
          results.push({ ok: false, output: null, expected: null, error: String(e), console: __console.slice(0) });
        }
        return JSON.stringify(results);
      })();
    ''';

    final JsEvalResult eval = _runtime.evaluate(script);
    final String serialized = eval.stringResult;
    List<dynamic> decoded;
    try {
      decoded = jsonDecode(serialized) as List<dynamic>;
    } catch (_) {
      return <JsTestResult>[
        JsTestResult(
          passed: false,
          output: null,
          expected: null,
          error: serialized.isEmpty ? 'Execution failed (no output). Check your syntax.' : serialized,
          console: const <String>[],
        ),
      ];
    }
    return decoded.map((dynamic e) {
      final Map<String, dynamic> m = Map<String, dynamic>.from(e as Map);
      return JsTestResult(
        passed: m['ok'] == true,
        output: m['output'],
        expected: m['expected'],
        error: m['error'] as String?,
        console: (m['console'] as List?)?.map((e) => e.toString()).toList(),
      );
    }).toList();
  }
}


