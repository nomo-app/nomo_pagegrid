import 'package:flutter/material.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';
import '../widgets/example_scaffold.dart';

class AnimationsExample extends StatefulWidget {
  const AnimationsExample({super.key});

  @override
  State<AnimationsExample> createState() => _AnimationsExampleState();
}

class _AnimationsExampleState extends State<AnimationsExample> {
  late Map<int, Widget> items;
  double wobbleAmount = 3.0;

  @override
  void initState() {
    super.initState();
    items = _generateItems();
  }

  Map<int, Widget> _generateItems() {
    final gradients = [
      [Colors.purple, Colors.pink],
      [Colors.blue, Colors.cyan],
      [Colors.orange, Colors.red],
      [Colors.green, Colors.teal],
      [Colors.amber, Colors.orange],
      [Colors.indigo, Colors.blue],
      [Colors.pink, Colors.red],
      [Colors.teal, Colors.green],
      [Colors.deepPurple, Colors.purple],
    ];

    return {
      for (int i = 0; i < gradients.length; i++)
        i: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradients[i],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: gradients[i][0].withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Animations',
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Wobble Amount: ${wobbleAmount.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Slider(
                  value: wobbleAmount,
                  min: 0,
                  max: 10,
                  divisions: 20,
                  label: wobbleAmount.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      wobbleAmount = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Adjust the slider to change the wobble effect when items are displaced',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    NomoPageGrid(
                      rows: 3,
                      columns: 3,
                      itemSize: const Size(100, 100),
                      items: items,
                      wobbleAmount: wobbleAmount,
                      onChanged: (newItems) {
                        setState(() {
                          items = newItems;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _AnimationPreset(
                                  label: 'No Wobble',
                                  value: 0,
                                  currentValue: wobbleAmount,
                                  onTap: () => setState(() => wobbleAmount = 0),
                                ),
                                const SizedBox(width: 8),
                                _AnimationPreset(
                                  label: 'Subtle',
                                  value: 1.5,
                                  currentValue: wobbleAmount,
                                  onTap: () => setState(() => wobbleAmount = 1.5),
                                ),
                                const SizedBox(width: 8),
                                _AnimationPreset(
                                  label: 'Default',
                                  value: 3,
                                  currentValue: wobbleAmount,
                                  onTap: () => setState(() => wobbleAmount = 3),
                                ),
                                const SizedBox(width: 8),
                                _AnimationPreset(
                                  label: 'Playful',
                                  value: 6,
                                  currentValue: wobbleAmount,
                                  onTap: () => setState(() => wobbleAmount = 6),
                                ),
                                const SizedBox(width: 8),
                                _AnimationPreset(
                                  label: 'Extreme',
                                  value: 10,
                                  currentValue: wobbleAmount,
                                  onTap: () => setState(() => wobbleAmount = 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimationPreset extends StatelessWidget {
  final String label;
  final double value;
  final double currentValue;
  final VoidCallback onTap;

  const _AnimationPreset({
    required this.label,
    required this.value,
    required this.currentValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = (currentValue - value).abs() < 0.1;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }
}
