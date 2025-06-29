import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorInput extends StatefulWidget {
  final void Function(String) onExpressionEvaluated;
  final void Function(String)? onExpressionChanged;
  const CalculatorInput({required this.onExpressionEvaluated, this.onExpressionChanged});

  @override
  State<CalculatorInput> createState() => CalculatorInputState();
}

class CalculatorInputState extends State<CalculatorInput> {
  String _expression = '';
  String _result = '';

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '';
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == '=') {
        if (_result != 'Error' && _result.isNotEmpty) {
          widget.onExpressionEvaluated(_result);
        }
        return;
      } else {
        _expression += value;
      }
      _evaluateLive();
      if (widget.onExpressionChanged != null) {
        widget.onExpressionChanged!(_result != 'Error' ? _result : '');
      }
    });
  }

  void _evaluateLive() {
    try {
      if (_expression.isEmpty) {
        _result = '';
        return;
      }
      final exp = Parser().parse(_expression.replaceAll('×', '*').replaceAll('÷', '/'));
      final eval = exp.evaluate(EvaluationType.REAL, ContextModel());
      _result = eval.toString();
    } catch (e) {
      _result = 'Error';
    }
  }

  Widget _buildButton(String label, {Color? color, double fontSize = 24}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: color ?? Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 1,
          padding: const EdgeInsets.all(8),
        ),
        onPressed: () => _onButtonPressed(label),
        child: Text(
          label, 
          style: TextStyle(fontSize: fontSize),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _expression.isEmpty ? '0' : _expression,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 4),
              Text(
                _result.isEmpty ? '' : '= $_result',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 320, // Fixed height for the calculator grid
          child: GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2, // Better aspect ratio for buttons
            children: [
              _buildButton('7'),
              _buildButton('8'),
              _buildButton('9'),
              _buildButton('÷', color: Theme.of(context).colorScheme.primary.withOpacity(0.15)),
              _buildButton('4'),
              _buildButton('5'),
              _buildButton('6'),
              _buildButton('×', color: Theme.of(context).colorScheme.primary.withOpacity(0.15)),
              _buildButton('1'),
              _buildButton('2'),
              _buildButton('3'),
              _buildButton('-', color: Theme.of(context).colorScheme.primary.withOpacity(0.15)),
              _buildButton('0'),
              _buildButton('.'),
              _buildButton('C', color: Colors.red.withOpacity(0.15)),
              _buildButton('+', color: Theme.of(context).colorScheme.primary.withOpacity(0.15)),
              _buildButton('⌫', color: Colors.grey.withOpacity(0.15), fontSize: 22),
              _buildButton('=', color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      ],
    );
  }
} 