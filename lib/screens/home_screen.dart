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
    
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.95,
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
    return Card(
      elevation: 4,
      child: InkWell(
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
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                converterType.icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                converterType.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                converterType.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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