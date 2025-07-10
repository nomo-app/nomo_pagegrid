import 'package:flutter/material.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';
import '../widgets/example_scaffold.dart';

class CustomItemsExample extends StatefulWidget {
  const CustomItemsExample({super.key});

  @override
  State<CustomItemsExample> createState() => _CustomItemsExampleState();
}

class _CustomItemsExampleState extends State<CustomItemsExample> {
  late Map<int, Widget> items;

  @override
  void initState() {
    super.initState();
    items = _generateItems();
  }

  Map<int, Widget> _generateItems() {
    final itemData = [
      (Icons.home, 'Home', Colors.blue),
      (Icons.favorite, 'Favorites', Colors.red),
      (Icons.settings, 'Settings', Colors.grey),
      (Icons.person, 'Profile', Colors.green),
      (Icons.notifications, 'Alerts', Colors.orange),
      (Icons.camera, 'Camera', Colors.purple),
      (Icons.music_note, 'Music', Colors.pink),
      (Icons.map, 'Maps', Colors.teal),
      (Icons.shopping_cart, 'Shop', Colors.amber),
      (Icons.email, 'Mail', Colors.indigo),
      (Icons.calendar_today, 'Calendar', Colors.cyan),
      (Icons.cloud, 'Cloud', Colors.lightBlue),
    ];

    return {
      for (int i = 0; i < itemData.length; i++)
        i: _buildCustomItem(
          itemData[i].$1,
          itemData[i].$2,
          itemData[i].$3,
        ),
    };
  }

  Widget _buildCustomItem(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Custom Items',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Custom Widget Items',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This example shows how to create custom items with icons and labels. Each item has its own styling and color scheme.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: NomoPageGrid(
                rows: 4,
                columns: 3,
                itemSize: const Size(90, 90),
                items: items,
                onChanged: (newItems) {
                  setState(() {
                    items = newItems;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Long press any item and drag to reorder. Items will animate smoothly to their new positions.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
