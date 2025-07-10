import 'package:flutter/material.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';
import '../widgets/example_scaffold.dart';

class SimpleGridExample extends StatefulWidget {
  const SimpleGridExample({super.key});

  @override
  State<SimpleGridExample> createState() => _SimpleGridExampleState();
}

class _SimpleGridExampleState extends State<SimpleGridExample> {
  late Map<int, Widget> items;

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
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
    ];

    return {
      for (int i = 0; i < colors.length; i++)
        i: Container(
          decoration: BoxDecoration(
            color: colors[i],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${i + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Simple Grid',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Long press and drag to reorder items',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: NomoPageGrid(
                  rows: 3,
                  columns: 3,
                  itemSize: const Size(100, 100),
                  items: items,
                  onChanged: (newItems) {
                    setState(() {
                      items = newItems;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Items reordered!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
