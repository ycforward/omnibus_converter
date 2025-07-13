// Please keep widget files in this directory in alphabetical order: calculator_input.dart, conversion_input.dart, unit_selector.dart
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorInput extends StatefulWidget {
  final void Function(String) onExpressionEvaluated;
  final void Function(String)? onExpressionChanged;
  final String? initialValue;
  final bool hideExpression;
  
  const CalculatorInput({
    super.key,
    required this.onExpressionEvaluated, 
    this.onExpressionChanged,
    this.initialValue,
    this.hideExpression = false,
  });

  @override
  State<CalculatorInput> createState() => CalculatorInputState();
}

class CalculatorInputState extends State<CalculatorInput> {
  String _expression = '';
  String _result = '';
  // Remove _hasUserInput

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _expression = widget.initialValue!;
      _evaluateLive();
      if (widget.onExpressionChanged != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final valueToReport = _result != 'Error' ? _result : widget.initialValue!;
          final reportValue = (widget.initialValue == '1' && valueToReport == '1.0') 
              ? widget.initialValue! 
              : valueToReport;
          widget.onExpressionChanged!(reportValue);
        });
      }
    }
  }

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
      } else if (value == '%') {
        // Treat % as divide by 100 for the last number
        final regex = RegExp(r'(\d+\.?\d*)');
        final matches = regex.allMatches(_expression);
        if (matches.isNotEmpty) {
          final match = matches.last;
          final number = match.group(0);
          if (number != null) {
            _expression = _expression.substring(0, match.start) + (double.parse(number) / 100).toString();
          }
        }
      } else if (value == '±') {
        // Toggle sign of the last number
        final regex = RegExp(r'(\d+\.?\d*)');
        final matches = regex.allMatches(_expression);
        if (matches.isNotEmpty) {
          final match = matches.last;
          final number = match.group(0);
          if (number != null) {
            double n = double.parse(number);
            n = -n;
            _expression = _expression.substring(0, match.start) + n.toString();
          }
        }
      } else {
        // Always append digits to the current expression
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
      // If the expression contains a decimal point, evaluate as double
      if (_expression.contains('.')) {
        String expr = _expression;
        if (expr.endsWith('+') || expr.endsWith('-')) {
          expr += '0';
        } else if (expr.endsWith('×') || expr.endsWith('*') || expr.endsWith('÷') || expr.endsWith('/')) {
          expr += '1';
        }
        final exp = Parser().parse(expr.replaceAll('×', '*').replaceAll('÷', '/'));
        final eval = exp.evaluate(EvaluationType.REAL, ContextModel());
        _result = eval.toString();
        return;
      }
      // If the expression is a valid integer string, keep it as is
      if (RegExp(r'^-?\d+ ?$').hasMatch(_expression)) {
        _result = _expression;
        return;
      }
      String expr = _expression;
      if (expr.endsWith('+') || expr.endsWith('-')) {
        expr += '0';
      } else if (expr.endsWith('×') || expr.endsWith('*') || expr.endsWith('÷') || expr.endsWith('/')) {
        expr += '1';
      }
      final exp = Parser().parse(expr.replaceAll('×', '*').replaceAll('÷', '/'));
      final eval = exp.evaluate(EvaluationType.REAL, ContextModel());
      // Display integers without trailing .0
      if (eval is double && eval == eval.roundToDouble()) {
        _result = eval.toInt().toString();
      } else {
        _result = eval.toString();
      }
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
    final buttons = [
      // Row 1
      '7', '8', '9', 'C', '%',
      // Row 2
      '4', '5', '6', '÷', '×',
      // Row 3
      '1', '2', '3', '-', '+',
      // Row 4
      '.', '0', '⌫', '±', '=',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Show the current expression above the calculator grid (conditionally)
        if (!widget.hideExpression) ...[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _expression.isEmpty ? '0' : _expression,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.1,
            ),
            itemCount: buttons.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final label = buttons[index];
              if (label.isEmpty) {
                return const SizedBox.shrink();
              }
              Color? color;
              double fontSize = 24;
              if (label == '÷' || label == '×' || label == '-' || label == '+' || label == '%') {
                color = Theme.of(context).colorScheme.primary.withOpacity(0.15);
              } else if (label == 'C') {
                color = Colors.red.withOpacity(0.15);
              } else if (label == '⌫') {
                color = Colors.grey.withOpacity(0.15);
                fontSize = 22;
              } else if (label == '=') {
                color = Theme.of(context).colorScheme.primary;
                fontSize = 26;
              } else if (label == '±') {
                color = Colors.grey.withOpacity(0.10);
              }
              return _buildButton(label, color: color, fontSize: fontSize);
            },
          ),
        ),
      ],
    );
  }
} 