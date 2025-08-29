import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/javascript.dart' as lang_js;
import 'package:highlight/languages/python.dart' as lang_py;
import 'package:flutter_highlight/themes/github.dart';

import '../services/js_executor.dart';
import '../services/storage_service.dart';
import '../services/python_executor.dart';

class ProblemDetailPage extends StatefulWidget {
  const ProblemDetailPage({
    super.key,
    required this.problem,
  });

  final Map<String, dynamic> problem;

  @override
  State<ProblemDetailPage> createState() => _ProblemDetailPageState();
}

class _ProblemDetailPageState extends State<ProblemDetailPage> {
  late final CodeController _controller;
  final JsExecutor _executor = JsExecutor();
  final PythonExecutor _pyExecutor = PythonExecutor();
  bool _isRunning = false;
  List<JsTestResult> _results = <JsTestResult>[];
  String _language = 'JavaScript';
  int? _selectedTestIndex;

  @override
  void initState() {
    super.initState();
    _controller = CodeController(
      text: StorageService.getCode(problemId: widget.problem['id'] ?? '', language: _language) ??
          (widget.problem['starterCode'] as String?) ?? 'function solve(){ return null; }',
      language: lang_js.javascript,
    );
  }

  Future<void> _run() async {
    setState(() { _isRunning = true; _results = <JsTestResult>[]; });
    try {
      final List<Map<String, dynamic>> tests = (widget.problem['tests'] as List<dynamic>)
          .map((dynamic e) => Map<String, dynamic>.from(e as Map))
          .toList();
      List<JsTestResult> res;
      if (_language == 'JavaScript') {
        res = await _executor.runTests(
          userCode: _controller.text,
          tests: tests,
          onlyIndex: _selectedTestIndex,
        );
      } else {
        res = await _pyExecutor.runTests(
          userCode: _controller.text,
          tests: tests,
          onlyIndex: _selectedTestIndex,
        );
      }
      setState(() { _results = res; });
      // mark solved if all pass
      final bool solved = res.isNotEmpty && res.every((JsTestResult r) => r.passed);
      if (solved) {
        await StorageService.recordSolveIfFirst(
          problemId: widget.problem['id'] ?? '',
          language: _language,
          difficulty: widget.problem['difficulty'] ?? 'Easy',
        );
      } else {
        await StorageService.setSolved(
          problemId: widget.problem['id'] ?? '',
          language: _language,
          solved: false,
        );
      }
      await StorageService.saveCode(
        problemId: widget.problem['id'] ?? '',
        language: _language,
        code: _controller.text,
      );
    } finally {
      setState(() { _isRunning = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.problem['title'] as String? ?? 'Problem';
    final String description = widget.problem['description'] as String? ?? '';
    final String difficulty = widget.problem['difficulty'] as String? ?? '';
    final List<dynamic> tags = widget.problem['tags'] as List<dynamic>? ?? <dynamic>[];
    final List<dynamic> hints = widget.problem['hints'] as List<dynamic>? ?? <dynamic>[];
    final String problemId = (widget.problem['id'] as String?) ?? '';
    final int revealed = StorageService.getHintsRevealed(problemId);

    final int passedCount = _results.where((JsTestResult r) => r.passed).length;
    final int totalCount = _results.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A45A),
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(title),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _language,
              items: const [
                DropdownMenuItem(value: 'JavaScript', child: Text('JS')),
                DropdownMenuItem(value: 'Python', child: Text('Py')),
              ],
              onChanged: (String? v) {
                if (v == null || v == _language) return;
                setState(() {
                  _language = v;
                  // swap syntax
                  _controller.language = _language == 'JavaScript' ? lang_js.javascript : lang_py.python;
                  // load saved code or fallback starter snippet per language
                  final String? saved = StorageService.getCode(problemId: widget.problem['id'] ?? '', language: _language);
                  if (saved != null) {
                    _controller.text = saved;
                  } else {
                    _controller.text = _language == 'JavaScript'
                        ? ((widget.problem['starterCode'] as String?) ?? 'function solve(){ return null; }')
                        : 'def solve(*args):\n    # TODO: implement\n    return None\n';
                  }
                });
              },
            ),
          ),
          TextButton.icon(
            onPressed: _isRunning ? null : _run,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Run'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DropdownButton<int?>(
                  value: _selectedTestIndex,
                  hint: const Text('All tests'),
                  items: <DropdownMenuItem<int?>>[
                    const DropdownMenuItem<int?>(value: null, child: Text('All tests')),
                    ...List<DropdownMenuItem<int?>>.generate(
                      (widget.problem['tests'] as List<dynamic>).length,
                      (int i) => DropdownMenuItem<int?>(value: i, child: Text('Test ${i + 1}')),
                    ),
                  ],
                  onChanged: (int? v) => setState(() => _selectedTestIndex = v),
                ),
                const SizedBox(width: 12),
                if (StorageService.isSolved(problemId: widget.problem['id'] ?? '', language: _language))
                  const Chip(label: Text('Solved'), backgroundColor: Colors.greenAccent),
              ],
            ),
            Row(
              children: [
                Chip(label: Text(difficulty)),
                const SizedBox(width: 8),
                Wrap(
                  spacing: 6,
                  children: tags.map((dynamic t) => Chip(label: Text('$t'))).toList(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 8),
            if (hints.isNotEmpty) ...[
              Row(
                children: [
                  const Text('Hints: '),
                  Text('($revealed/${hints.length} revealed)'),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: revealed < hints.length
                        ? () async {
                            final int next = revealed + 1;
                            await StorageService.setHintsRevealed(problemId, next);
                            setState(() {});
                          }
                        : null,
                    child: const Text('Reveal next'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List<Widget>.generate(revealed.clamp(0, hints.length), (int i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text('• ${hints[i]}'),
                  );
                }),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.black12)),
                      ),
                      child: Text(_language, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          textSelectionTheme: const TextSelectionThemeData(
                            cursorColor: Color(0xFF00A45A),
                            selectionHandleColor: Color(0xFF00A45A),
                            selectionColor: Color(0x3300A45A),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: CodeTheme(
                            data: const CodeThemeData(styles: githubTheme),
                            child: CodeField(
                              controller: _controller,
                              textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _run,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Run'),
                ),
                const SizedBox(width: 8),
                if (_selectedTestIndex != null)
                  Text('Test ${_selectedTestIndex! + 1}')
                else
                  const Text('All tests'),
              ],
            ),
            const SizedBox(height: 12),
            if (_isRunning) const LinearProgressIndicator(),
            if (_results.isNotEmpty) ...[
              Text('Results: $passedCount / $totalCount passed', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (BuildContext context, int index) {
                    final JsTestResult r = _results[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(r.passed ? Icons.check_circle : Icons.cancel, color: r.passed ? Colors.green : Colors.red),
                        title: Text(r.passed ? 'Passed' : 'Failed'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Expected: ${r.expected}'),
                            Text('Output: ${r.output}'),
                            if ((r.console ?? <String>[]).isNotEmpty) ...[
                              const SizedBox(height: 4),
                              const Text('Console:'),
                              ...r.console!.map((String line) => Text(line)).toList(),
                            ],
                            if (r.error != null) Text('Error: ${r.error}')
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


