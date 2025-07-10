import 'package:flutter/material.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';
import '../widgets/example_scaffold.dart';

class EmptySlotsExample extends StatefulWidget {
  const EmptySlotsExample({super.key});

  @override
  State<EmptySlotsExample> createState() => _EmptySlotsExampleState();
}

class _EmptySlotsExampleState extends State<EmptySlotsExample> {
  late Map<int, Widget> items;
  final int gridSize = 12;

  @override
  void initState() {
    super.initState();
    items = _generateItems();
  }

  Map<int, Widget> _generateItems() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
    ];

    return {
      0: _buildItem(colors[0], 'A'),
      2: _buildItem(colors[1], 'B'),
      3: _buildItem(colors[2], 'C'),
      7: _buildItem(colors[3], 'D'),
      9: _buildItem(colors[4], 'E'),
      11: _buildItem(colors[5], 'F'),
    };
  }

  Widget _buildItem(Color color, String label) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _addItem() {
    for (int i = 0; i < gridSize; i++) {
      if (!items.containsKey(i)) {
        setState(() {
          final colors = [
            Colors.cyan,
            Colors.amber,
            Colors.teal,
            Colors.indigo,
            Colors.deepPurple,
            Colors.lime,
          ];
          final color = colors[items.length % colors.length];
          final label = String.fromCharCode(65 + items.length);
          items[i] = _buildItem(color, label);
        });
        break;
      }
    }
  }

  void _removeItem() {
    if (items.isNotEmpty) {
      setState(() {
        final lastKey = items.keys.reduce((a, b) => a > b ? a : b);
        items.remove(lastKey);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Empty Slots',
      actions: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: items.isNotEmpty ? _removeItem : null,
          tooltip: 'Remove item',
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: items.length < gridSize ? _addItem : null,
          tooltip: 'Add item',
        ),
      ],
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Grid with ${items.length} items and ${gridSize - items.length} empty slots',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Items can be dragged to any empty position. Use the buttons to add or remove items.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: NomoPageGrid(
                      rows: 3,
                      columns: 4,
                      itemSize: const Size(80, 80),
                      items: items,
                      onChanged: (newItems) {
                        setState(() {
                          items = newItems;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < gridSize; i++) ...[
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: items.containsKey(i)
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  if ((i + 1) % 4 == 0 && i < gridSize - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
