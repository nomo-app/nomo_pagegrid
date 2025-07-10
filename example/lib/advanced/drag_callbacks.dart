import 'package:flutter/material.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';
import '../widgets/example_scaffold.dart';

class DragCallbacksExample extends StatefulWidget {
  const DragCallbacksExample({super.key});

  @override
  State<DragCallbacksExample> createState() => _DragCallbacksExampleState();
}

class _DragCallbacksExampleState extends State<DragCallbacksExample> {
  late Map<int, Widget> items;
  String currentStatus = 'Ready to drag';
  final List<String> eventLog = [];

  @override
  void initState() {
    super.initState();
    items = _generateItems();
  }

  Map<int, Widget> _generateItems() {
    final icons = [
      Icons.star,
      Icons.favorite,
      Icons.bookmark,
      Icons.thumb_up,
      Icons.flag,
      Icons.lightbulb,
      Icons.flash_on,
      Icons.wb_sunny,
      Icons.cloud,
    ];

    return {
      for (int i = 0; i < icons.length; i++) i: _buildItem(i, icons[i]),
    };
  }

  Widget _buildItem(int index, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 4),
          Text(
            'Item ${index + 1}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _addEvent(String event) {
    setState(() {
      eventLog.insert(0, '${DateTime.now().toString().substring(11, 19)} - $event');
      if (eventLog.length > 10) {
        eventLog.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Drag Callbacks',
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  currentStatus,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: NomoPageGrid(
                        rows: 3,
                        columns: 3,
                        itemSize: const Size(100, 100),
                        items: items,
                        onChanged: (newItems) {
                          setState(() {
                            currentStatus = 'Items reordered';
                          });

                          _addEvent('Items have been reordered');

                          setState(() {
                            items = newItems;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Event Log',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: eventLog.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  eventLog[index],
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
