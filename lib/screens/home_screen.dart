import 'converter_screen.dart';
import 'favorites_screen.dart';
import '../models/converter_type.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Unit Converter'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: TabBar(
            tabs: [
              const Tab(
                icon: Icon(Icons.calculate),
                text: 'Converters',
              ),
              Tab(
                icon: Icon(Icons.favorite, color: Colors.red),
                text: 'Favorites',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ConvertersTab(),
            FavoritesScreen(),
          ],
        ),
      ),
    );
  }
}

class _ConvertersTab extends StatelessWidget {
  const _ConvertersTab();

  @override
  Widget build(BuildContext context) {
    final sortedTypes = List<ConverterType>.from(ConverterType.values)
      ..sort((a, b) => a.title.compareTo(b.title));
    
    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 600; // iPad compatibility mode threshold
    
    // Responsive grid layout
    final crossAxisCount = isLargeScreen ? 3 : 2;
    final crossAxisSpacing = isLargeScreen ? 24.0 : 16.0;
    final mainAxisSpacing = isLargeScreen ? 24.0 : 16.0;
    final childAspectRatio = isLargeScreen ? 1.1 : 0.95;
    final horizontalPadding = isLargeScreen ? 32.0 : 16.0;
    final verticalPadding = isLargeScreen ? 24.0 : 16.0;
    
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: isLargeScreen ? 32.0 : 24.0),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: mainAxisSpacing,
                  childAspectRatio: childAspectRatio,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: sortedTypes.length,
                itemBuilder: (context, index) {
                  final converterType = sortedTypes[index];
                return _ConverterCard(converterType: converterType);
                },
              ),
            ),
          ],
      ),
    );
  }
}

class _ConverterCard extends StatelessWidget {
  final ConverterType converterType;

  const _ConverterCard({required this.converterType});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 600; // iPad compatibility mode threshold
    
    // Responsive card styling
    final cardPadding = isLargeScreen ? 20.0 : 16.0;
    final iconSize = isLargeScreen ? 56.0 : 48.0;
    final titleFontSize = isLargeScreen ? 18.0 : null;
    final descriptionFontSize = isLargeScreen ? 14.0 : null;
    final spacing = isLargeScreen ? 16.0 : 12.0;
    final smallSpacing = isLargeScreen ? 8.0 : 4.0;
    
    return Card(
      elevation: 4,
      child: InkWell(
        key: ValueKey('converter_card_${converterType.name}'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConverterScreen(converterType: converterType),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: cardPadding, horizontal: cardPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                converterType.icon,
                size: iconSize,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: spacing),
              Text(
                converterType.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: titleFontSize,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: smallSpacing),
              Text(
                converterType.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: descriptionFontSize,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TabletHomeScreen extends StatefulWidget {
  const TabletHomeScreen({super.key});

  @override
  State<TabletHomeScreen> createState() => _TabletHomeScreenState();
}

class _TabletHomeScreenState extends State<TabletHomeScreen> {
  int _selectedIndex = 0;
  ConverterType? _selectedConverter;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Converter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Row(
        children: [
          // Sidebar with converter categories
          Container(
            width: isLandscape ? 300 : 250,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Navigation tabs
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildNavTab(0, Icons.calculate, 'Converters'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildNavTab(1, Icons.favorite, 'Favorites', color: Colors.red),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Content based on selected tab
                Expanded(
                  child: _selectedIndex == 0 
                      ? _buildConvertersList()
                      : const FavoritesScreen(),
                ),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: _selectedConverter != null
                ? ConverterScreen(converterType: _selectedConverter!)
                : _buildWelcomeScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTab(int index, IconData icon, String label, {Color? color}) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          if (index == 1) {
            _selectedConverter = null; // Clear converter when switching to favorites
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : color ?? Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : color ?? Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConvertersList() {
    final sortedTypes = List<ConverterType>.from(ConverterType.values)
      ..sort((a, b) => a.title.compareTo(b.title));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedTypes.length,
      itemBuilder: (context, index) {
        final converterType = sortedTypes[index];
        final isSelected = _selectedConverter == converterType;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isSelected ? 4 : 2,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedConverter = converterType;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: isSelected 
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      converterType.icon,
                      size: 32,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          converterType.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          converterType.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calculate_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 24),
          Text(
            'Select a Converter',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Choose a converter from the sidebar to get started',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 