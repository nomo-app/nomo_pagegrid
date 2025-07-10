import 'package:flutter/material.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';
import '../widgets/example_scaffold.dart';

class SizesExample extends StatefulWidget {
  const SizesExample({super.key});

  @override
  State<SizesExample> createState() => _SizesExampleState();
}

class _SizesExampleState extends State<SizesExample> {
  late Map<int, Widget> items;
  int rows = 3;
  int columns = 3;
  double itemWidth = 80;
  double itemHeight = 80;

  @override
  void initState() {
    super.initState();
    items = _generateItems();
  }

  Map<int, Widget> _generateItems() {
    final colors = List.generate(
      rows * columns * 2,
      (index) => HSLColor.fromAHSL(
        1.0,
        (index * 30) % 360,
        0.6,
        0.5,
      ).toColor(),
    );

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
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
    };
  }

  void _updateGrid() {
    setState(() {
      items = _generateItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Grid Sizes',
      child: Row(
        children: [
          Container(
            width: 300,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grid Configuration',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  _ConfigSection(
                    title: 'Rows: $rows',
                    child: Slider(
                      value: rows.toDouble(),
                      min: 2,
                      max: 6,
                      divisions: 4,
                      label: rows.toString(),
                      onChanged: (value) {
                        rows = value.round();
                        _updateGrid();
                      },
                    ),
                  ),
                  _ConfigSection(
                    title: 'Columns: $columns',
                    child: Slider(
                      value: columns.toDouble(),
                      min: 2,
                      max: 6,
                      divisions: 4,
                      label: columns.toString(),
                      onChanged: (value) {
                        columns = value.round();
                        _updateGrid();
                      },
                    ),
                  ),
                  _ConfigSection(
                    title: 'Item Width: ${itemWidth.round()}',
                    child: Slider(
                      value: itemWidth,
                      min: 40,
                      max: 120,
                      divisions: 8,
                      label: itemWidth.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          itemWidth = value;
                        });
                      },
                    ),
                  ),
                  _ConfigSection(
                    title: 'Item Height: ${itemHeight.round()}',
                    child: Slider(
                      value: itemHeight,
                      min: 40,
                      max: 120,
                      divisions: 8,
                      label: itemHeight.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          itemHeight = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Presets',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _PresetButton(
                    label: 'Compact (4x4, 60x60)',
                    onTap: () {
                      rows = 4;
                      columns = 4;
                      itemWidth = 60;
                      itemHeight = 60;
                      _updateGrid();
                    },
                  ),
                  const SizedBox(height: 8),
                  _PresetButton(
                    label: 'Standard (3x3, 80x80)',
                    onTap: () {
                      rows = 3;
                      columns = 3;
                      itemWidth = 80;
                      itemHeight = 80;
                      _updateGrid();
                    },
                  ),
                  const SizedBox(height: 8),
                  _PresetButton(
                    label: 'Large (2x3, 100x100)',
                    onTap: () {
                      rows = 2;
                      columns = 3;
                      itemWidth = 100;
                      itemHeight = 100;
                      _updateGrid();
                    },
                  ),
                  const SizedBox(height: 8),
                  _PresetButton(
                    label: 'Wide (3x2, 120x80)',
                    onTap: () {
                      rows = 3;
                      columns = 2;
                      itemWidth = 120;
                      itemHeight = 80;
                      _updateGrid();
                    },
                  ),
                  const SizedBox(height: 8),
                  _PresetButton(
                    label: 'Tall (2x3, 80x120)',
                    onTap: () {
                      rows = 2;
                      columns = 3;
                      itemWidth = 80;
                      itemHeight = 120;
                      _updateGrid();
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: NomoPageGrid(
                          rows: rows,
                          columns: columns,
                          itemSize: Size(itemWidth, itemHeight),
                          items: items,
                          onChanged: (newItems) {
                            setState(() {
                              items = newItems;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Grid Size: ${columns * itemWidth.round()} x ${rows * itemHeight.round()}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Items: ${items.length}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _ConfigSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 16),
      ],
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}
