import 'package:flutter/material.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';
import '../widgets/example_scaffold.dart';

class ControllerUsageExample extends StatefulWidget {
  const ControllerUsageExample({super.key});

  @override
  State<ControllerUsageExample> createState() => _ControllerUsageExampleState();
}

class _ControllerUsageExampleState extends State<ControllerUsageExample> {
  late Map<int, Widget> items;
  final PageGridController controller = PageGridController();
  int currentPage = 0;
  int totalPages = 0;

  @override
  void initState() {
    super.initState();
    items = _generateItems();
    controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        currentPage = controller.currentPage;
        totalPages = controller.pageCount;
      });
    }
  }

  Map<int, Widget> _generateItems() {
    final colors = List.generate(
      30,
      (index) => HSLColor.fromAHSL(
        1.0,
        (index * 12) % 360,
        0.7,
        0.5,
      ).toColor(),
    );

    return {
      for (int i = 0; i < colors.length; i++)
        i: Container(
          decoration: BoxDecoration(
            color: colors[i],
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors[i],
                colors[i].withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Center(
            child: Text(
              '${i + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
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
      title: 'Controller Usage',
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Page ${currentPage + 1} of $totalPages',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: currentPage > 0 ? () => controller.previousPage() : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: controller.hasClients && currentPage < totalPages - 1
                          ? () => controller.nextPage()
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => controller.jumpToPage(0),
                      child: const Text('First Page'),
                    ),
                    OutlinedButton(
                      onPressed: totalPages > 0
                          ? () => controller.animateToPage(
                              totalPages - 1,
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeInOutCubic,
                            )
                          : null,
                      child: const Text('Last Page'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: NomoPageGrid(
                controller: controller,
                rows: 4,
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
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < totalPages; i++) ...[
                      _PageIndicator(
                        pageNumber: i + 1,
                        isActive: i == currentPage,
                        onTap: () => controller.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        ),
                      ),
                      if (i < totalPages - 1) const SizedBox(width: 8),
                    ],
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

class _PageIndicator extends StatelessWidget {
  final int pageNumber;
  final bool isActive;
  final VoidCallback onTap;

  const _PageIndicator({
    required this.pageNumber,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isActive ? 48 : 36,
        height: isActive ? 48 : 36,
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(isActive ? 12 : 8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            '$pageNumber',
            style: TextStyle(
              color: isActive
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
