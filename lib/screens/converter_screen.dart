import 'package:flutter/material.dart';
import '../models/converter_type.dart';
import '../services/conversion_service.dart';
import '../services/exchange_rate_service.dart';
import '../widgets/conversion_input.dart';
import '../widgets/unit_selector.dart';
import '../widgets/searchable_currency_selector.dart';
import '../widgets/calculator_input.dart';

class ConverterScreen extends StatefulWidget {
  final ConverterType converterType;

  const ConverterScreen({super.key, required this.converterType});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final ConversionService _conversionService = ConversionService();
  
  String _fromUnit = '';
  String _toUnit = '';
  String _result = '';
  String _sourceValue = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUnits();
  }

  void _initializeUnits() {
    final units = _conversionService.getUnits(widget.converterType);
    if (units.isNotEmpty) {
      if (widget.converterType == ConverterType.currency) {
        // Set default currency conversion to USD → CNY
        _fromUnit = units.contains('USD') ? 'USD' : units.first;
        _toUnit = units.contains('CNY') ? 'CNY' : (units.length > 1 ? units[1] : units.first);
      } else {
        // For other conversions, use first two units
        _fromUnit = units.first;
        _toUnit = units.length > 1 ? units[1] : units.first;
      }
    }
  }

  void _onCalculatorChanged(String value) {
    setState(() {
      _sourceValue = value;
    });
    _convertLive(value);
  }

  void _convertLive(String value) {
    if (value.isEmpty) {
      setState(() {
        _result = '';
      });
      return;
    }
    final input = double.tryParse(value);
    if (input == null) {
      setState(() {
        _result = '';
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    
    _performConversion(input);
  }

  Future<void> _performConversion(double input) async {
    try {
      final result = await _conversionService.convert(
        widget.converterType,
        input,
        _fromUnit,
        _toUnit,
      );
      
      if (mounted) {
        setState(() {
          _result = result.toStringAsFixed(4);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
    _convertLive(_sourceValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.converterType.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Unit selectors (now in separate rows)
              Column(
                children: [
                  widget.converterType == ConverterType.currency
                      ? SearchableCurrencySelector(
                          value: _fromUnit,
                          currencies: _conversionService.getUnits(widget.converterType),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _fromUnit = value;
                              });
                              _convertLive(_sourceValue);
                            }
                          },
                          label: '',
                        )
                      : UnitSelector(
                          value: _fromUnit,
                          units: _conversionService.getUnits(widget.converterType),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _fromUnit = value;
                              });
                              _convertLive(_sourceValue);
                            }
                          },
                          label: '',
                          isCurrency: false,
                        ),
                  const SizedBox(height: 8),
                  Center(
                    child: IconButton(
                      onPressed: _swapUnits,
                      icon: const Icon(Icons.swap_horiz),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  widget.converterType == ConverterType.currency
                      ? SearchableCurrencySelector(
                          value: _toUnit,
                          currencies: _conversionService.getUnits(widget.converterType),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _toUnit = value;
                              });
                              _convertLive(_sourceValue);
                            }
                          },
                          label: '',
                        )
                      : UnitSelector(
                          value: _toUnit,
                          units: _conversionService.getUnits(widget.converterType),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _toUnit = value;
                              });
                              _convertLive(_sourceValue);
                            }
                          },
                          label: '',
                          isCurrency: false,
                        ),
                ],
              ),
              const SizedBox(height: 24),
              // Source and target value boxes side by side
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16, right: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _sourceValue.isEmpty ? '0' : _sourceValue,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16, left: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'To',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 4),
                          _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  _result.isEmpty ? '-' : _result,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Calculator section fills all remaining space, no extra box above
              Expanded(
                child: CalculatorInput(
                  onExpressionEvaluated: (value) {
                    _onCalculatorChanged(value);
                  },
                  onExpressionChanged: (value) {
                    _onCalculatorChanged(value);
                  },
                ),
              ),
              
              // Info section for currency
              if (widget.converterType == ConverterType.currency) ...[
                const SizedBox(height: 16),
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
                        Icons.update,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ExchangeRateService.getLastFetchTimeFormatted() ??
                              'No exchange rates available. Please check your internet connection.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
} 