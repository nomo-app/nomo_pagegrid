import 'package:flutter/material.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';
import '../widgets/example_scaffold.dart';

class MultiPageExample extends StatefulWidget {
  const MultiPageExample({super.key});

  @override
  State<MultiPageExample> createState() => _MultiPageExampleState();
}

class _MultiPageExampleState extends State<MultiPageExample> {
  late Map<int, Widget> items;
  final PageGridController controller = PageGridController();
  int currentPage = 0;
  bool showNumbers = true;

  @override
  void initState() {
    super.initState();
    items = _generateItems();
    controller.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    if (mounted) {
      setState(() {
        currentPage = controller.currentPage;
      });
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onPageChanged);
    controller.dispose();
    super.dispose();
  }

  Map<int, Widget> _generateItems() {
    return {
      for (int i = 0; i < 50; i++) i: _buildItem(i),
    };
  }

  Widget _buildItem(int index) {
    final hue = (index * 7.2) % 360;
    final color = HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.8),
            color,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (showNumbers)
            Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'P${(index ~/ 20) + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Multi-Page Grid',
      actions: [
        IconButton(
          icon: Icon(showNumbers ? Icons.numbers : Icons.hide_source),
          onPressed: () {
            setState(() {
              showNumbers = !showNumbers;
              items = _generateItems();
            });
          },
          tooltip: showNumbers ? 'Hide numbers' : 'Show numbers',
        ),
      ],
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This grid has ${items.length} items across multiple pages',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                ...[
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _QuickNavButton(
                        label: 'Page 1',
                        onPressed: () => controller.jumpToPage(0),
                      ),
                      _QuickNavButton(
                        label: 'Page 2',
                        onPressed: () => controller.animateToPage(
                          1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        ),
                      ),
                      _QuickNavButton(
                        label: 'Last Page',
                        onPressed: () => controller.animateToPage(
                          (items.length - 1) ~/ 20,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: NomoPageGrid(
                  controller: controller,
                  rows: 5,
                  columns: 4,
                  itemSize: const Size(70, 70),
                  items: items,
                  wobbleAmount: 4,
                  onChanged: (newItems) {
                    setState(() {
                      items = newItems;
                    });
                  },
                ),
              ),
            ),
          ),
          Container(
            height: 60,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: Builder(
                builder: (context) {
                  final totalPages = (items.length - 1) ~/ 20 + 1;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.first_page),
                        onPressed: currentPage > 0 ? () => controller.jumpToPage(0) : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: currentPage > 0 ? () => controller.previousPage() : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Page ${currentPage + 1} of $totalPages',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: currentPage < totalPages - 1
                            ? () => controller.nextPage()
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.last_page),
                        onPressed: currentPage < totalPages - 1
                            ? () => controller.jumpToPage(totalPages - 1)
                            : null,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickNavButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _QuickNavButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
