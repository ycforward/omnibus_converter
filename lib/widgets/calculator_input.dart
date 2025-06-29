import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class _CalculatorInput extends StatefulWidget {
  final void Function(String) onExpressionEvaluated;
  const _CalculatorInput({required this.onExpressionEvaluated});

  @override
  State<_CalculatorInput> createState() => _CalculatorInputState();
}

class _CalculatorInputState extends State<_CalculatorInput> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  String _error = '';

  void _evaluate() {
    setState(() {
      _error = '';
      _result = '';
      try {
        final exp = Parser().parse(_controller.text);
        final eval = exp.evaluate(EvaluationType.REAL, ContextModel());
        _result = eval.toString();
        widget.onExpressionEvaluated(_result);
      } catch (e) {
        _error = 'Invalid expression';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Calculator', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Enter expression (e.g. 2*14+5)',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.text,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _evaluate,
              child: const Text('Evaluate'),
            ),
          ],
        ),
        if (_result.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Result: $_result', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        if (_error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(_error, style: const TextStyle(color: Colors.red)),
          ),
      ],
    );
  }
} 