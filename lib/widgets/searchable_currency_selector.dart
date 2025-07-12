import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/currency_preferences_service.dart';

class SearchableCurrencySelector extends StatefulWidget {
  final String value;
  final List<String> currencies;
  final Function(String?) onChanged;
  final String label;
  final VoidCallback? onStarredChanged; // New callback for starred changes

  static const Map<String, String> _currencySymbols = {
    // Major currencies
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
    'KRW': '₩',
    'RUB': '₽',
    'ZAR': 'R',
    'MXN': '\$',
    'SGD': 'S\$',
    'HKD': 'HK\$',
    'NOK': 'kr',
    'SEK': 'kr',
    'DKK': 'kr',
    'PLN': 'zł',
    'THB': '฿',
    'TRY': '₺',
    'ILS': '₪',
    'AED': 'د.إ',
    'SAR': '﷼',
    'NZD': 'NZ\$',
    'CZK': 'Kč',
    'HUF': 'Ft',
    'BGN': 'лв',
    'RON': 'lei',
    'HRK': 'kn',
    'ISK': 'kr',
    'UAH': '₴',
    'EGP': '£',
    'NGN': '₦',
    'KES': 'KSh',
    'GHS': '₵',
    'UGX': 'USh',
    'TZS': 'TSh',
    'ETB': 'Br',
    'MAD': 'د.م.',
    'DZD': 'دج',
    'TND': 'د.ت',
    'LYD': 'ل.د',
    'AOA': 'Kz',
    'BWP': 'P',
    'MUR': '₨',
    'MZN': 'MT',
    'NAD': 'N\$',
    'SZL': 'E',
    'ZMW': 'ZK',
    'RWF': 'FRw',
    'BIF': 'FBu',
    'DJF': 'Fdj',
    'SOS': 'Sh',
    'MWK': 'MK',
    'MGA': 'Ar',
    'SCR': '₨',
    'GMD': 'D',
    'SLL': 'Le',
    'LRD': 'L\$',
    'CVE': '\$',
    'STD': 'Db',
    'STN': 'Db',
    'XOF': 'CFA',
    'XAF': 'FCFA',
    'GTQ': 'Q',
    'BZD': 'BZ\$',
    'SVC': '₡',
    'HNL': 'L',
    'NIO': 'C\$',
    'CRC': '₡',
    'PAB': 'B/.',
    'CUP': '\$',
    'CUC': 'CUC\$',
    'JMD': 'J\$',
    'HTG': 'G',
    'DOP': 'RD\$',
    'TTD': 'TT\$',
    'BBD': 'Bds\$',
    'XCD': 'EC\$',
    'AWG': 'ƒ',
    'ANG': 'ƒ',
    'SRD': 'Sr\$',
    'GYD': 'GY\$',
    'UYU': '\$U',
    'PYG': '₲',
    'BOB': 'Bs',
    'BOV': 'Bs',
    'PEN': 'S/.',
    'COP': '\$',
    'COU': '\$',
    'VES': 'Bs',
    'VED': 'Bs',
    'CLP': '\$',
    'CLF': '\$',
    'ARS': '\$',
    'FKP': '£',
    'GGP': '£',
    'JEP': '£',
    'IMP': '£',
    'SHP': '£',
    'GIP': '£',
    'FJD': 'FJ\$',
    'PGK': 'K',
    'SBD': 'SI\$',
    'VUV': 'VT',
    'NCX': 'F',
    'XPF': 'F',
    'TOP': 'T\$',
    'WST': 'WS\$',
    'KID': '\$',
    'TVD': '\$',
    'NRU': '\$',
    'PKR': '₨',
    'LKR': '₨',
    'NPR': '₨',
    'BTN': 'Nu.',
    'BDT': '৳',
    'MMK': 'K',
    'LAK': '₭',
    'KHR': '៛',
    'TWD': 'NT\$',
    'MOP': 'MOP\$',
    'BND': 'B\$',
    'MNT': '₮',
    'KZT': '₸',
    'UZS': 'so\'m',
    'KGS': 'с',
    'TJS': 'SM',
    'TMT': 'T',
    'AZN': '₼',
    'GEL': '₾',
    'AMD': '֏',
    'ALL': 'L',
    'MDL': 'L',
    'BYN': 'Br',
    'BYR': 'Br',
    'EEK': 'kr',
    'LVL': 'Ls',
    'LTL': 'Lt',
    'SDG': 'ج.س.',
    'IRR': '﷼',
    'AFN': '؋',
    'IQD': 'ع.د',
    'SYP': '£',
    'LBP': '£',
    'JOD': 'د.ا',
    'KWD': 'د.ك',
    'BHD': '.د.ب',
    'OMR': 'ر.ع.',
    'QAR': 'ر.ق',
    'MYR': 'RM',
    'IDR': 'Rp',
    'PHP': '₱',
    'VND': '₫',
    'RSD': 'дин.',
    'BAM': 'KM',
    'MKD': 'ден',
    'YER': '﷼',
    'CDF': 'FC',
    'XDR': 'SDR',
    'XAG': 'oz',
    'XAU': 'oz',
    'XPD': 'oz',
    'XPT': 'oz',
    'ERN': 'Nfk',
    'LSL': 'M',
    'ZWL': 'Z\$',
    'ZWD': 'Z\$',
    'ZWN': 'Z\$',
    'ZWR': 'Z\$',
    'MRO': 'UM',
    'MRU': 'UM',
    'USN': 'US\$',
    'USS': 'US\$',
    'UYI': 'UYI',
    'UYW': 'UYW',
    'CHE': 'CHE',
    'CHW': 'CHW',
    'MXV': 'MXV',
    'XBA': 'XBA',
    'XBB': 'XBB',
    'XBC': 'XBC',
    'XBD': 'XBD',
    'XTS': 'XTS',
    'XXX': 'XXX',
    'CNH': '¥',
    'CNT': '¥',
    'GBX': 'p',
    'ILR': '₪',
    'KPW': '₩',
    'ZAL': 'R',
    'ZMK': 'ZK',
    'MVR': 'Rf',
    'GNF': 'FG',
    'DEM': 'DM',
    'ESP': '₧',
    'FIM': 'mk',
    'FRF': 'F',
    'GRD': '₯',
    'ITL': '₤',
    'MTL': '₤',
    'NLG': 'ƒ',
    'PTE': 'PTE',
    'SKK': 'Sk',
    'VEF': 'Bs',
    'VEB': 'VEB',
    'TRL': 'TRL',
    'SIT': 'SIT',
    'ROL': 'ROL',
    'PLZ': 'PLZ',
    'MZM': 'MZM',
    'ATS': 'S',
    'BEF': 'BEF',
    'CYP': 'CYP',
    'IEP': '£',
    'LUF': 'LUF',
    'TMM': 'TMM',
    'SDD': 'SDD',
    'RUR': 'RUR',
    'MGF': 'MGF',
    'TPE': 'TPE',
    'TJR': 'TJR',
    'SUR': 'SUR',
    'ZRN': 'ZRN',
    'ZRZ': 'ZRZ',
    'YUD': 'YUD',
    'YUM': 'YUM',
    'YUN': 'YUN',
    'YUR': 'YUR',
    'UYN': 'UYN',
    'UYP': 'UYP',
    'UAK': 'UAK',
    'UGS': 'UGS',
    'SRG': 'SRG',
    'SDP': 'SDP',
    'PEI': 'PEI',
    'PES': 'PES',
    'PEH': 'PEH',
    'NIC': 'NIC',
    'MXP': 'MXP',
    'MZE': 'MZE',
    'LTT': 'LTT',
    'LVR': 'LVR',
    'GHC': '₵',
    'GWE': 'GWE',
    'GWP': 'GWP',
    'GQE': 'GQE',
    'GNS': 'GNS',
    'GNE': 'GNE',
    'ECS': 'ECS',
    'ECV': 'ECV',
    'EQE': 'EQE',
    'DDM': 'DDM',
    'CSK': 'CSK',
    'CLE': 'CLE',
    'BRZ': 'BRZ',
    'BRR': 'BRR',
    'BRN': 'BRN',
    'BRE': 'BRE',
    'BRC': 'BRC',
    'BRB': 'BRB',
    'BOP': 'BOP',
    'BGL': 'BGL',
    'BGK': 'BGK',
    'BGJ': 'BGJ',
    'BEL': 'BEL',
    'BEC': 'BEC',
    'BAN': 'BAN',
    'BAD': 'BAD',
    'AZM': 'AZM',
    'ARA': 'A',
    'ARP': 'A',
    'AON': 'Kz',
    'AOR': 'Kz',
    'AOK': 'Kz',
    'ALK': 'L',
    'AFA': '؋',
    'XEU': 'XEU',
    'XFO': 'XFO',
    'XFU': 'XFU',
    'XRE': 'XRE',
    'XSU': 'XSU',
    'XUA': 'XUA',
    'ESA': 'ESA',
    'ESB': 'ESB',
    'LUC': 'LUC',
    'LUL': 'LUL',
    'MCF': 'MCF',
    'MLF': 'MLF',
    'MTP': '£',
    'MVQ': 'MVQ',
    'GEK': 'GEK',
    'GHP': 'GHP',
    'HRD': 'HRD',
    'ILP': '£',
    'ISJ': 'ISJ',
    'ROK': 'ROK',
    'BUK': 'BUK',
    'BYB': 'BYB',
    'CSJ': 'CSJ',
    'YDD': 'YDD',
    'VNC': 'VNC',
    'VNN': 'VNN',
    'ADB': 'ADB',
    'WIR': 'WIR',
    // Popular cryptocurrencies
    'BTC': '₿',
    'ETH': 'Ξ',
    'LTC': 'Ł',
    'XRP': 'XRP',
    'ADA': '₳',
    'DOT': '●',
    'USDT': '₮',
    'USDC': 'USDC',
    'BNB': 'BNB',
    'SOL': '◎',
    'DOGE': 'Ð',
    'AVAX': 'AVAX',
    'MATIC': 'MATIC',
    'LINK': 'LINK',
    'UNI': '🦄',
    'ATOM': 'ATOM',
    'XLM': '*',
    'VET': 'VET',
    'FIL': '⨎',
    'TRX': 'TRX',
    'ETC': 'ETC',
    'THETA': 'Θ',
    'XMR': 'ɱ',
    'ALGO': 'ALGO',
    'AAVE': 'AAVE',
    'MKR': 'MKR',
    'COMP': 'COMP',
    'SUSHI': '🍣',
    'YFI': 'YFI',
    'SNX': 'SNX',
    'CRV': 'CRV',
    'BAL': 'BAL',
    'REN': 'REN',
    'KNC': 'KNC',
    'ZRX': 'ZRX',
    'BAND': 'BAND',
    'STORJ': 'STORJ',
    'ENJ': 'ENJ',
    'MANA': 'MANA',
    'SAND': 'SAND',
    'AXS': 'AXS',
    'SHIB': 'SHIB',
    'CRO': 'CRO',
    'FTT': 'FTT',
    'HT': 'HT',
    'OKB': 'OKB',
    'LEO': 'LEO',
    'NEAR': 'NEAR',
    'HBAR': 'ℏ',
    'ICP': 'ICP',
    'FLOW': 'FLOW',
    'XTZ': 'ꜩ',
    'EGLD': 'EGLD',
    'MINA': 'MINA',
    'KLAY': 'KLAY',
    'CAKE': 'CAKE',
    'RUNE': 'RUNE',
    'FTM': 'FTM',
    'LUNA': 'LUNA',
    'UST': 'UST',
    'WAVES': 'WAVES',
    'DASH': 'DASH',
    'DCR': 'DCR',
    'ZEC': 'ZEC',
    'DGB': 'DGB',
    'RVN': 'RVN',
    'BTG': 'BTG',
    'BCH': 'BCH',
    'BSV': 'BSV',
    'EOS': 'EOS',
    'NEO': 'NEO',
    'QTUM': 'QTUM',
    'ONT': 'ONT',
    'ZIL': 'ZIL',
    'ICX': 'ICX',
    'IOST': 'IOST',
    'SC': 'SC',
    'LSK': 'LSK',
    'STEEM': 'STEEM',
    'NANO': 'NANO',
    'XEM': 'XEM',
    'DENT': 'DENT',
    'HOT': 'HOT',
    'WIN': 'WIN',
    'BTT': 'BTT',
    'NPXS': 'NPXS',
    'FEG': 'FEG',
    'SAFEMOON': 'SAFEMOON',
    'ELONGATE': 'ELONGATE',
    'BONFIRE': 'BONFIRE',
    'MOONSHOT': 'MOONSHOT',
    'HOKK': 'HOKK',
    'KISHU': 'KISHU',
    'AKITA': 'AKITA',
    'FLOKI': 'FLOKI',
    'SAITAMA': 'SAITAMA',
    'BABYDOGE': 'BABYDOGE',
    'DOGELON': 'DOGELON',
    'CATGIRL': 'CATGIRL',
    'GALA': 'GALA',
    'CHZ': 'CHZ',
    'BAT': 'BAT',
    'SLP': 'SLP',
    'ALICE': 'ALICE',
    'TLM': 'TLM',
    'WAXP': 'WAXP',
    'AUDIO': 'AUDIO',
    'TFUEL': 'TFUEL',
    'CELR': 'CELR',
    'POLY': 'POLY',
    'LRC': 'LRC',
    'IMX': 'IMX',
    'RNDR': 'RNDR',
    'JASMY': 'JASMY',
    'ROSE': 'ROSE',
    'ANKR': 'ANKR',
    'CTSI': 'CTSI',
    'SKL': 'SKL',
    'NKN': 'NKN',
    'COTI': 'COTI',
    'OCEAN': 'OCEAN',
    'FETCH': 'FET',
    'AGIX': 'AGIX',
    'NMR': 'NMR',
    'RLC': 'RLC',
    'GRT': 'GRT',
    'API3': 'API3',
    'MASK': 'MASK',
    'REQ': 'REQ',
    'SIACOIN': 'SC',
    'ARWEAVE': 'AR',
    'HELIUM': 'HNT',
  };

  // Currency names for better search - comprehensive list
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
    'HUF': 'Hungarian Forint',
    'RUB': 'Russian Ruble',
    'THB': 'Thai Baht',
    'MYR': 'Malaysian Ringgit',
    'IDR': 'Indonesian Rupiah',
    'PHP': 'Philippine Peso',
    'VND': 'Vietnamese Dong',
    'ZAR': 'South African Rand',
    'AED': 'UAE Dirham',
    'SAR': 'Saudi Riyal',
    'QAR': 'Qatari Riyal',
    'KWD': 'Kuwaiti Dinar',
    'BHD': 'Bahraini Dinar',
    'OMR': 'Omani Rial',
    'JOD': 'Jordanian Dinar',
    'LBP': 'Lebanese Pound',
    'SYP': 'Syrian Pound',
    'IQD': 'Iraqi Dinar',
    'IRR': 'Iranian Rial',
    'AFN': 'Afghan Afghani',
    'PKR': 'Pakistani Rupee',
    'LKR': 'Sri Lankan Rupee',
    'NPR': 'Nepalese Rupee',
    'BTN': 'Bhutanese Ngultrum',
    'BDT': 'Bangladeshi Taka',
    'MMK': 'Myanmar Kyat',
    'LAK': 'Lao Kip',
    'KHR': 'Cambodian Riel',
    'TWD': 'New Taiwan Dollar',
    'MOP': 'Macanese Pataca',
    'BND': 'Brunei Dollar',
    'MNT': 'Mongolian Tugrik',
    'KZT': 'Kazakhstani Tenge',
    'UZS': 'Uzbekistani Som',
    'KGS': 'Kyrgyzstani Som',
    'TJS': 'Tajikistani Somoni',
    'TMT': 'Turkmenistani Manat',
    'AZN': 'Azerbaijani Manat',
    'GEL': 'Georgian Lari',
    'AMD': 'Armenian Dram',
    'TRY': 'Turkish Lira',
    'BGN': 'Bulgarian Lev',
    'RON': 'Romanian Leu',
    'HRK': 'Croatian Kuna',
    'RSD': 'Serbian Dinar',
    'BAM': 'Bosnia-Herzegovina Convertible Mark',
    'MKD': 'Macedonian Denar',
    'ALL': 'Albanian Lek',
    'MDL': 'Moldovan Leu',
    'UAH': 'Ukrainian Hryvnia',
    'BYN': 'Belarusian Ruble',
    'ISK': 'Icelandic Krona',
    'CZK': 'Czech Koruna',
    'EEK': 'Estonian Kroon',
    'LVL': 'Latvian Lats',
    'LTL': 'Lithuanian Litas',
    'ILS': 'Israeli New Shekel',
    'EGP': 'Egyptian Pound',
    'MAD': 'Moroccan Dirham',
    'TND': 'Tunisian Dinar',
    'DZD': 'Algerian Dinar',
    'LYD': 'Libyan Dinar',
    'SDG': 'Sudanese Pound',
    'ETB': 'Ethiopian Birr',
    'KES': 'Kenyan Shilling',
    'UGX': 'Ugandan Shilling',
    'TZS': 'Tanzanian Shilling',
    'RWF': 'Rwandan Franc',
    'BIF': 'Burundian Franc',
    'DJF': 'Djiboutian Franc',
    'SOS': 'Somali Shilling',
    'AOA': 'Angolan Kwanza',
    'ZMW': 'Zambian Kwacha',
    'BWP': 'Botswanan Pula',
    'SZL': 'Swazi Lilangeni',
    'LSL': 'Lesotho Loti',
    'NAD': 'Namibian Dollar',
    'MZN': 'Mozambican Metical',
    'MWK': 'Malawian Kwacha',
    'MGA': 'Malagasy Ariary',
    'MUR': 'Mauritian Rupee',
    'SCR': 'Seychellois Rupee',
    'GMD': 'Gambian Dalasi',
    'SLL': 'Sierra Leonean Leone',
    'LRD': 'Liberian Dollar',
    'GHS': 'Ghanaian Cedi',
    'NGN': 'Nigerian Naira',
    'XOF': 'West African CFA Franc',
    'XAF': 'Central African CFA Franc',
    'CVE': 'Cape Verdean Escudo',
    'STD': 'São Tomé and Príncipe Dobra',
    'MXN': 'Mexican Peso',
    'GTQ': 'Guatemalan Quetzal',
    'BZD': 'Belize Dollar',
    'SVC': 'Salvadoran Colón',
    'HNL': 'Honduran Lempira',
    'NIO': 'Nicaraguan Córdoba',
    'CRC': 'Costa Rican Colón',
    'PAB': 'Panamanian Balboa',
    'CUP': 'Cuban Peso',
    'JMD': 'Jamaican Dollar',
    'HTG': 'Haitian Gourde',
    'DOP': 'Dominican Peso',
    'TTD': 'Trinidad and Tobago Dollar',
    'BBD': 'Barbadian Dollar',
    'XCD': 'East Caribbean Dollar',
    'AWG': 'Aruban Florin',
    'ANG': 'Netherlands Antillean Guilder',
    'SRD': 'Surinamese Dollar',
    'GYD': 'Guyanese Dollar',
    'UYU': 'Uruguayan Peso',
    'PYG': 'Paraguayan Guarani',
    'BOB': 'Bolivian Boliviano',
    'PEN': 'Peruvian Sol',
    'COP': 'Colombian Peso',
    'VES': 'Venezuelan Bolívar',
    'CLP': 'Chilean Peso',
    'ARS': 'Argentine Peso',
    'FKP': 'Falkland Islands Pound',
    'GGP': 'Guernsey Pound',
    'JEP': 'Jersey Pound',
    'IMP': 'Isle of Man Pound',
    'SHP': 'Saint Helena Pound',
    'GIP': 'Gibraltar Pound',
    'NZD': 'New Zealand Dollar',
    'FJD': 'Fijian Dollar',
    'PGK': 'Papua New Guinean Kina',
    'SBD': 'Solomon Islands Dollar',
    'VUV': 'Vanuatu Vatu',
    'NCX': 'New Caledonian Franc',
    'XPF': 'CFP Franc',
    'TOP': 'Tongan Paʻanga',
    'WST': 'Samoan Tala',
    'KID': 'Kiribati Dollar',
    'TVD': 'Tuvaluan Dollar',
    'NRU': 'Nauruan Dollar',
  };

  const SearchableCurrencySelector({
    super.key,
    required this.value,
    required this.currencies,
    required this.onChanged,
    required this.label,
    this.onStarredChanged, // Optional callback
  });

  // Static getter to access currency symbols from outside
  static String getCurrencySymbol(String currency) {
    return _currencySymbols[currency] ?? '';
  }

  @override
  State<SearchableCurrencySelector> createState() => _SearchableCurrencySelectorState();
}

class _SearchableCurrencySelectorState extends State<SearchableCurrencySelector> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  final List<String> _filteredCurrencies = [];
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  bool _isDisposing = false;
  
  // Cache theme data to avoid accessing context after disposal
  late ThemeData _theme;
  late ColorScheme _colorScheme;
  late TextTheme _textTheme;

  @override
  void initState() {
    super.initState();
    _filteredCurrencies.addAll(_getSortedCurrencies());
    
    // Listen for focus changes to close overlay
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isOpen) {
        _removeOverlay();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache theme data when dependencies change
    _theme = Theme.of(context);
    _colorScheme = _theme.colorScheme;
    _textTheme = _theme.textTheme;
  }

  @override
  void dispose() {
    _isDisposing = true;
    // Remove overlay first before disposing other resources
    _overlayEntry?.remove();
    _overlayEntry = null;
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<String> _getSortedCurrencies() {
    return CurrencyPreferencesService.sortCurrenciesWithStarredFirst(widget.currencies);
  }

  void _filterCurrencies(String query) {
    if (_isDisposing) return;
    setState(() {
      if (query.isEmpty) {
        _filteredCurrencies.clear();
        _filteredCurrencies.addAll(_getSortedCurrencies());
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredCurrencies.clear();
        _filteredCurrencies.addAll(widget.currencies.where((currency) {
          final currencyLower = currency.toLowerCase();
          final currencyName = SearchableCurrencySelector._currencyNames[currency]?.toLowerCase() ?? '';
          return currencyLower.contains(lowerQuery) || currencyName.contains(lowerQuery);
        }).toList());

        // Sort filtered results with starred first, then by relevance
        _filteredCurrencies.sort((a, b) {
          final aStarred = CurrencyPreferencesService.isStarred(a);
          final bStarred = CurrencyPreferencesService.isStarred(b);
          
          if (aStarred && !bStarred) return -1;
          if (!aStarred && bStarred) return 1;
          
          // If both have same starred status, sort by relevance (exact match first)
          final aExact = a.toLowerCase() == lowerQuery;
          final bExact = b.toLowerCase() == lowerQuery;
          
          if (aExact && !bExact) return -1;
          if (!aExact && bExact) return 1;
          
          return a.compareTo(b);
        });
      }
    });
    _updateOverlay();
  }

  void _showOverlay() {
    if (_overlayEntry != null || _isDisposing) return;
    
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    if (mounted && !_isDisposing) {
      setState(() {
        _isOpen = true;
      });
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    // Only setState if the widget is still mounted and not being disposed
    if (mounted && !_isDisposing) {
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
      builder: (context) => GestureDetector(
        onTap: () {
          _removeOverlay();
          _focusNode.unfocus();
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                width: size.width,
                child: CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: Offset(0.0, size.height + 5.0),
                  child: GestureDetector(
                    onTap: () {
                      // Prevent taps on the dropdown from closing it
                    },
                    child: Material(
                      elevation: 8.0,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        decoration: BoxDecoration(
                          color: _colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _filteredCurrencies.length,
                            itemBuilder: (context, index) {
                              return _buildCurrencyListItem(_filteredCurrencies[index]);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
        _filteredCurrencies.clear();
        _filteredCurrencies.addAll(_getSortedCurrencies());
        _removeOverlay();
        _focusNode.unfocus();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? _colorScheme.primaryContainer.withOpacity(0.3)
              : null,
        ),
        child: Row(
          children: [
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
                          style: _textTheme.titleMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        currency,
                        style: _textTheme.titleMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (name.isNotEmpty)
                    Text(
                      name,
                      style: _textTheme.bodySmall?.copyWith(
                        color: _colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            // Star toggle - shows current state and allows toggling
            InkWell(
              onTap: () async {
                if (_isDisposing) return;
                final newStarredStatus = await CurrencyPreferencesService.toggleStarred(currency);
                if (mounted && !_isDisposing) {
                  setState(() {
                    _filteredCurrencies.clear();
                    _filteredCurrencies.addAll(_getSortedCurrencies());
                  });
                  _updateOverlay();
                  
                  // Notify other instances about the starred change
                  widget.onStarredChanged?.call();
                  
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
                  isStarred ? Icons.star : Icons.star_border,
                  size: 18,
                  color: isStarred 
                      ? Colors.amber 
                      : _colorScheme.outline.withOpacity(0.7),
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
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
          if (_isOpen) {
            _removeOverlay();
            _focusNode.unfocus();
          }
        }
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Container(
          constraints: const BoxConstraints(minWidth: 120),
          decoration: BoxDecoration(
            border: Border.all(
              color: _colorScheme.outline.withOpacity(0.3),
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
                  : _textTheme.titleMedium?.copyWith(
                      color: _colorScheme.onSurface,
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
                color: _colorScheme.primary,
              ),
            ),
            style: _textTheme.titleMedium,
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
                _filteredCurrencies.clear();
                _filteredCurrencies.addAll(_getSortedCurrencies());
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