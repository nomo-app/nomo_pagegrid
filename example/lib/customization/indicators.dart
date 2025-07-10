import 'package:flutter/material.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';
import '../widgets/example_scaffold.dart';

class IndicatorsExample extends StatefulWidget {
  const IndicatorsExample({super.key});

  @override
  State<IndicatorsExample> createState() => _IndicatorsExampleState();
}

class _IndicatorsExampleState extends State<IndicatorsExample> {
  late Map<int, Widget> items;
  final PageGridController controller = PageGridController();
  int currentPage = 0;
  int totalPages = 0;
  String indicatorStyle = 'dots';

  @override
  void initState() {
    super.initState();
    items = _generateItems();
    controller.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_onPageChanged);
    controller.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    if (mounted) {
      setState(() {
        currentPage = controller.currentPage;
        totalPages = controller.pageCount;
      });
    }
  }

  Map<int, Widget> _generateItems() {
    return {
      for (int i = 0; i < 35; i++)
        i: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                HSLColor.fromAHSL(1.0, (i * 10) % 360, 0.7, 0.6).toColor(),
                HSLColor.fromAHSL(1.0, ((i * 10) + 60) % 360, 0.7, 0.5).toColor(),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${i + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
    };
  }

  Widget _buildIndicator() {
    switch (indicatorStyle) {
      case 'dots':
        return _DotsIndicator(
          currentPage: currentPage,
          totalPages: totalPages,
          onPageTap: (page) => controller.animateToPage(
            page,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ),
        );
      case 'numbers':
        return _NumbersIndicator(
          currentPage: currentPage,
          totalPages: totalPages,
          onPageTap: (page) => controller.animateToPage(
            page,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ),
        );
      case 'progress':
        return _ProgressIndicator(
          currentPage: currentPage,
          totalPages: totalPages,
        );
      case 'thumbnails':
        return _ThumbnailIndicator(
          currentPage: currentPage,
          totalPages: totalPages,
          onPageTap: (page) => controller.jumpToPage(page),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Page Indicators',
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Indicator Style',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Dots'),
                      selected: indicatorStyle == 'dots',
                      onSelected: (_) => setState(() => indicatorStyle = 'dots'),
                    ),
                    ChoiceChip(
                      label: const Text('Numbers'),
                      selected: indicatorStyle == 'numbers',
                      onSelected: (_) => setState(() => indicatorStyle = 'numbers'),
                    ),
                    ChoiceChip(
                      label: const Text('Progress'),
                      selected: indicatorStyle == 'progress',
                      onSelected: (_) => setState(() => indicatorStyle = 'progress'),
                    ),
                    ChoiceChip(
                      label: const Text('Thumbnails'),
                      selected: indicatorStyle == 'thumbnails',
                      onSelected: (_) => setState(() => indicatorStyle = 'thumbnails'),
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
            height: 100,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Center(
              child: _buildIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageTap;

  const _DotsIndicator({
    required this.currentPage,
    required this.totalPages,
    required this.onPageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < totalPages; i++) ...[
          GestureDetector(
            onTap: () => onPageTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: i == currentPage ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: i == currentPage
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _NumbersIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageTap;

  const _NumbersIndicator({
    required this.currentPage,
    required this.totalPages,
    required this.onPageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < totalPages; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ActionChip(
              label: Text('${i + 1}'),
              onPressed: () => onPageTap(i),
              backgroundColor: i == currentPage ? Theme.of(context).colorScheme.primary : null,
              labelStyle: TextStyle(
                color: i == currentPage ? Theme.of(context).colorScheme.onPrimary : null,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _ProgressIndicator({
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalPages > 1 ? (currentPage + 1) / totalPages : 1.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Page ${currentPage + 1} of $totalPages',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

class _ThumbnailIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageTap;

  const _ThumbnailIndicator({
    required this.currentPage,
    required this.totalPages,
    required this.onPageTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < totalPages; i++) ...[
            GestureDetector(
              onTap: () => onPageTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: i == currentPage ? 60 : 50,
                height: i == currentPage ? 60 : 50,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: i == currentPage
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: i == currentPage ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      final itemIndex = i * 16 + index;
                      return Container(
                        color: itemIndex < 35
                            ? HSLColor.fromAHSL(
                                1.0,
                                (itemIndex * 10) % 360,
                                0.7,
                                0.6,
                              ).toColor()
                            : Colors.grey[300],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
