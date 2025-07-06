import 'package:flutter/material.dart';
import '../services/currency_service.dart';

class CategorizedUnitSelector extends StatefulWidget {
  final String value;
  final List<String> units;
  final ValueChanged<String?> onChanged;
  final String label;

  const CategorizedUnitSelector({
    super.key,
    required this.value,
    required this.units,
    required this.onChanged,
    this.label = '',
  });

  @override
  State<CategorizedUnitSelector> createState() => _CategorizedUnitSelectorState();
}

class _CategorizedUnitSelectorState extends State<CategorizedUnitSelector> {
  List<CurrencyCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await CurrencyService.getCategorizedCurrencies();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to simple list if categorization fails
      setState(() {
        _categories = [
          CurrencyCategory(
            name: 'Currencies',
            currencies: widget.units,
            isExpanded: true,
          ),
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Loading currencies...'),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            if (widget.label.isNotEmpty) ...[
              Text(
                widget.label,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                _getDisplayText(widget.value),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_drop_down),
        children: _categories.map((category) {
          return _buildCategorySection(category);
        }).toList(),
      ),
    );
  }

  Widget _buildCategorySection(CurrencyCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          child: Text(
            category.name,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        // Currency options
        ...category.currencies.map((currency) {
          final isSelected = currency == widget.value;
          final isPopular = CurrencyService.isPopularCurrency(currency);
          final isCrypto = CurrencyService.isCryptoCurrency(currency);
          
          return ListTile(
            dense: true,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPopular)
                  Icon(
                    Icons.star,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  )
                else if (isCrypto)
                  Icon(
                    Icons.currency_bitcoin,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  )
                else
                  const SizedBox(width: 16),
                const SizedBox(width: 8),
                Text(
                  currency,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            title: Text(
              CurrencyService.getCurrencyDisplayName(currency),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  )
                : null,
            onTap: () {
              widget.onChanged(currency);
              Navigator.of(context).pop();
            },
          );
        }).toList(),
      ],
    );
  }

  String _getDisplayText(String currency) {
    final displayName = CurrencyService.getCurrencyDisplayName(currency);
    return '$currency - $displayName';
  }
} 