import 'package:flutter/material.dart';
import '../models/converter_type.dart';
import '../services/conversion_service.dart';
import '../widgets/conversion_input.dart';
import '../widgets/unit_selector.dart';
import '../widgets/calculator_input.dart';

class ConverterScreen extends StatefulWidget {
  final ConverterType converterType;

  const ConverterScreen({super.key, required this.converterType});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ConversionService _conversionService = ConversionService();
  
  String _fromUnit = '';
  String _toUnit = '';
  String _result = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUnits();
    _inputController.addListener(_onInputChanged);
  }

  void _initializeUnits() {
    final units = _conversionService.getUnits(widget.converterType);
    if (units.isNotEmpty) {
      _fromUnit = units.first;
      _toUnit = units.length > 1 ? units[1] : units.first;
    }
  }

  void _onInputChanged() {
    _convert();
  }

  void _convert() {
    if (_inputController.text.isEmpty) {
      setState(() {
        _result = '';
      });
      return;
    }

    final input = double.tryParse(_inputController.text);
    if (input == null) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API delay for currency conversion
    if (widget.converterType == ConverterType.currency) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _performConversion(input);
      });
    } else {
      _performConversion(input);
    }
  }

  void _performConversion(double input) {
    try {
      final result = _conversionService.convert(
        widget.converterType,
        input,
        _fromUnit,
        _toUnit,
      );
      
      setState(() {
        _result = result.toStringAsFixed(4);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
    _convert();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.converterType.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input section
            ConversionInput(
              controller: _inputController,
              label: 'Enter value',
            ),
            const SizedBox(height: 24),
            
            // Unit selectors
            Row(
              children: [
                Expanded(
                  child: UnitSelector(
                    value: _fromUnit,
                    units: _conversionService.getUnits(widget.converterType),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _fromUnit = value;
                        });
                        _convert();
                      }
                    },
                    label: '',
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _swapUnits,
                  icon: const Icon(Icons.swap_horiz),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: UnitSelector(
                    value: _toUnit,
                    units: _conversionService.getUnits(widget.converterType),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _toUnit = value;
                        });
                        _convert();
                      }
                    },
                    label: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Result section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Result',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else if (_result.isNotEmpty)
                    Text(
                      _result,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  else
                    Text(
                      'Enter a value to convert',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Calculator section
            CalculatorInput(
              onExpressionEvaluated: (value) {
                _inputController.text = value;
                _convert();
              },
            ),
            
            const Spacer(),
            
            // Info section for currency
            if (widget.converterType == ConverterType.currency)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Using mock exchange rates for demo. Real rates would come from API.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
} 