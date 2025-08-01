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
    final isLandscape = screenSize.width > screenSize.height;
    
    // Responsive grid layout - 4 columns for iPad landscape, 3 for iPad portrait, 2 for iPhone
    final crossAxisCount = isLargeScreen 
        ? (isLandscape ? 4 : 3) 
        : 2;
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                converterType.icon,
                size: iconSize,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: spacing),
              Flexible(
                child: Text(
                  converterType.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: titleFontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: smallSpacing),
              Flexible(
                child: Text(
                  converterType.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: descriptionFontSize,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 