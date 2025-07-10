import 'package:flutter/material.dart';
import '../services/currency_preferences_service.dart';

class SearchableCurrencySelector extends StatefulWidget {
  final String value;
  final List<String> currencies;
  final Function(String?) onChanged;
  final String label;

  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'CHF': 'CHF',
    'CNY': '¥',
    'INR': '₹',
    'BRL': 'R\$',
  };

  // Currency names for better search
  static const Map<String, String> _currencyNames = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'JPY': 'Japanese Yen',
    'CAD': 'Canadian Dollar',
    'AUD': 'Australian Dollar',
    'CHF': 'Swiss Franc',
    'CNY': 'Chinese Yuan',
    'INR': 'Indian Rupee',
    'BRL': 'Brazilian Real',
    'KRW': 'South Korean Won',
    'SGD': 'Singapore Dollar',
    'HKD': 'Hong Kong Dollar',
    'NOK': 'Norwegian Krone',
    'SEK': 'Swedish Krona',
    'DKK': 'Danish Krone',
    'PLN': 'Polish Zloty',
    'CZK': 'Czech Koruna',
    'HUF': 'Hungarian Forint',
    'RUB': 'Russian Ruble',
    'THB': 'Thai Baht',
    'MYR': 'Malaysian Ringgit',
    'IDR': 'Indonesian Rupiah',
    'PHP': 'Philippine Peso',
    'VND': 'Vietnamese Dong',
  };

  const SearchableCurrencySelector({
    super.key,
    required this.value,
    required this.currencies,
    required this.onChanged,
    required this.label,
  });

  @override
  State<SearchableCurrencySelector> createState() => _SearchableCurrencySelectorState();
}

class _SearchableCurrencySelectorState extends State<SearchableCurrencySelector> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isOpen = false;
  List<String> _filteredCurrencies = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = _getSortedCurrencies();
    
    // Listen for focus changes to close overlay
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isOpen) {
        _removeOverlay();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  List<String> _getSortedCurrencies() {
    return CurrencyPreferencesService.sortCurrenciesWithStarredFirst(widget.currencies);
  }

  void _filterCurrencies(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCurrencies = _getSortedCurrencies();
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredCurrencies = widget.currencies.where((currency) {
          final currencyLower = currency.toLowerCase();
          final currencyName = SearchableCurrencySelector._currencyNames[currency]?.toLowerCase() ?? '';
          return currencyLower.contains(lowerQuery) || currencyName.contains(lowerQuery);
        }).toList();

        // Sort filtered results with starred first, then by relevance
        _filteredCurrencies.sort((a, b) {
          final aIsStarred = CurrencyPreferencesService.isStarred(a);
          final bIsStarred = CurrencyPreferencesService.isStarred(b);
          
          if (aIsStarred && !bIsStarred) return -1;
          if (!aIsStarred && bIsStarred) return 1;
          
          // Then by how early the match appears
          final aIndex = a.toLowerCase().indexOf(lowerQuery);
          final bIndex = b.toLowerCase().indexOf(lowerQuery);
          if (aIndex != bIndex) return aIndex.compareTo(bIndex);
          
          return a.compareTo(b);
        });
      }
    });
    _updateOverlay();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  void _updateOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 8.0,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: _filteredCurrencies.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No currencies found',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredCurrencies.length,
                      itemBuilder: (context, index) {
                        final currency = _filteredCurrencies[index];
                        return _buildCurrencyListItem(currency);
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyListItem(String currency) {
    final isStarred = CurrencyPreferencesService.isStarred(currency);
    final symbol = SearchableCurrencySelector._currencySymbols[currency] ?? '';
    final name = SearchableCurrencySelector._currencyNames[currency] ?? '';
    final isSelected = currency == widget.value;

    return InkWell(
      onTap: () {
        widget.onChanged?.call(currency);
        _searchController.clear();
        _filteredCurrencies = _getSortedCurrencies();
        _removeOverlay();
        _focusNode.unfocus();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : null,
        ),
        child: Row(
          children: [
            // Star icon
            Icon(
              isStarred ? Icons.star : Icons.star_border,
              size: 16,
              color: isStarred 
                  ? Colors.amber 
                  : Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(width: 12),
            // Currency info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (symbol.isNotEmpty) ...[
                        Text(
                          symbol,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        currency,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (name.isNotEmpty)
                    Text(
                      name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            // Star toggle
            InkWell(
              onTap: () async {
                final newStarredStatus = await CurrencyPreferencesService.toggleStarred(currency);
                setState(() {
                  _filteredCurrencies = _getSortedCurrencies();
                });
                _updateOverlay();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        newStarredStatus 
                            ? 'Added $currency to favorites' 
                            : 'Removed $currency from favorites',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.star_border,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayText() {
    if (widget.value.isEmpty) return '';
    
    final symbol = SearchableCurrencySelector._currencySymbols[widget.value] ?? '';
    if (symbol.isNotEmpty) {
      return '$symbol ${widget.value}';
    }
    return widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss overlay when tapping outside
        if (_isOpen) {
          _removeOverlay();
          _focusNode.unfocus();
        }
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Container(
          constraints: const BoxConstraints(minWidth: 120),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.value.isEmpty ? 'Search currencies...' : _getDisplayText(),
              hintStyle: widget.value.isEmpty 
                  ? null 
                  : Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: Icon(
                _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            style: Theme.of(context).textTheme.titleMedium,
            onChanged: _filterCurrencies,
            onTap: () {
              if (!_isOpen) {
                _showOverlay();
              }
            },
            onSubmitted: (value) {
              if (_filteredCurrencies.isNotEmpty) {
                widget.onChanged?.call(_filteredCurrencies.first);
                _searchController.clear();
                _filteredCurrencies = _getSortedCurrencies();
                _removeOverlay();
                _focusNode.unfocus();
              }
            },
          ),
        ),
      ),
    );
  }
} 