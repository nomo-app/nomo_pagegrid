import 'package:flutter/material.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';

class PlaygroundExample extends StatefulWidget {
  const PlaygroundExample({super.key});

  @override
  State<PlaygroundExample> createState() => _PlaygroundExampleState();
}

class _PlaygroundExampleState extends State<PlaygroundExample>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageGridController _gridController = PageGridController();

  // Grid configuration
  int rows = 3;
  int columns = 3;
  double itemWidth = 80;
  double itemHeight = 80;
  double wobbleAmount = 3;
  double mainAxisSpacing = 8;
  double crossAxisSpacing = 8;

  // Items
  late Map<int, Widget> items;
  int itemCount = 9;

  // Indicator style
  _IndicatorStyle indicatorStyle = _IndicatorStyle.dots;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    items = _generateItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _gridController.dispose();
    super.dispose();
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
      Colors.indigo,
      Colors.lime,
      Colors.brown,
    ];

    return {
      for (int i = 0; i < itemCount; i++)
        i: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors[i % colors.length].shade300,
                colors[i % colors.length].shade700,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colors[i % colors.length].withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
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

  void _addItem() {
    setState(() {
      items[itemCount] = _generateItems()[itemCount % 12]!;
      itemCount++;
    });
  }

  void _removeItem() {
    if (items.isNotEmpty) {
      setState(() {
        final lastKey = items.keys.reduce((a, b) => a > b ? a : b);
        items.remove(lastKey);
        itemCount = items.length;
      });
    }
  }

  void _applyPreset(String preset) {
    setState(() {
      switch (preset) {
        case 'compact':
          rows = 4;
          columns = 4;
          itemWidth = 60;
          itemHeight = 60;
          mainAxisSpacing = 4;
          crossAxisSpacing = 4;
          break;
        case 'standard':
          rows = 3;
          columns = 3;
          itemWidth = 80;
          itemHeight = 80;
          mainAxisSpacing = 8;
          crossAxisSpacing = 8;
          break;
        case 'large':
          rows = 2;
          columns = 2;
          itemWidth = 120;
          itemHeight = 120;
          mainAxisSpacing = 16;
          crossAxisSpacing = 16;
          break;
        case 'wide':
          rows = 2;
          columns = 4;
          itemWidth = 100;
          itemHeight = 60;
          mainAxisSpacing = 12;
          crossAxisSpacing = 8;
          break;
        case 'tall':
          rows = 4;
          columns = 2;
          itemWidth = 60;
          itemHeight = 100;
          mainAxisSpacing = 8;
          crossAxisSpacing = 12;
          break;
      }
      itemCount = rows * columns;
      items = _generateItems();
    });
  }

  void _applyWobblePreset(String preset) {
    setState(() {
      switch (preset) {
        case 'none':
          wobbleAmount = 0;
          break;
        case 'subtle':
          wobbleAmount = 1;
          break;
        case 'default':
          wobbleAmount = 3;
          break;
        case 'playful':
          wobbleAmount = 5;
          break;
        case 'extreme':
          wobbleAmount = 10;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playground'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Grid'),
            Tab(text: 'Animation'),
            Tab(text: 'Indicators'),
          ],
        ),
      ),
      body: Row(
        children: [
          // Control Panel
          SizedBox(
            width: 320,
            child: Card(
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildGridControls(),
                  _buildAnimationControls(),
                  _buildIndicatorControls(),
                ],
              ),
            ),
          ),
          // Grid Preview
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
                          controller: _gridController,
                          rows: rows,
                          columns: columns,
                          itemSize: Size(itemWidth, itemHeight),
                          wobbleAmount: wobbleAmount,
                          mainAxisSpacing: mainAxisSpacing,
                          crossAxisSpacing: crossAxisSpacing,
                          items: items,
                          onChanged: (newItems) {
                            setState(() {
                              items = newItems;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildIndicators(),
                      const SizedBox(height: 16),
                      Text(
                        'Grid Size: ${columns * itemWidth.round() + (columns - 1) * mainAxisSpacing.round()} x ${rows * itemHeight.round() + (rows - 1) * crossAxisSpacing.round()}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Items: ${items.length} | Page ${_gridController.hasClients ? _gridController.currentPage + 1 : 1} of ${_gridController.hasClients ? _gridController.pageCount : 1}',
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

  Widget _buildGridControls() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConfigSection(
            title: 'Grid Dimensions',
            children: [
              _SliderRow(
                label: 'Rows',
                value: rows.toDouble(),
                min: 2,
                max: 6,
                divisions: 4,
                onChanged: (value) {
                  setState(() {
                    rows = value.round();
                  });
                },
              ),
              _SliderRow(
                label: 'Columns',
                value: columns.toDouble(),
                min: 2,
                max: 6,
                divisions: 4,
                onChanged: (value) {
                  setState(() {
                    columns = value.round();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ConfigSection(
            title: 'Item Size',
            children: [
              _SliderRow(
                label: 'Width',
                value: itemWidth,
                min: 40,
                max: 120,
                divisions: 8,
                onChanged: (value) {
                  setState(() {
                    itemWidth = value;
                  });
                },
              ),
              _SliderRow(
                label: 'Height',
                value: itemHeight,
                min: 40,
                max: 120,
                divisions: 8,
                onChanged: (value) {
                  setState(() {
                    itemHeight = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ConfigSection(
            title: 'Spacing',
            children: [
              _SliderRow(
                label: 'Horizontal',
                value: mainAxisSpacing,
                min: 0,
                max: 32,
                divisions: 8,
                onChanged: (value) {
                  setState(() {
                    mainAxisSpacing = value;
                  });
                },
              ),
              _SliderRow(
                label: 'Vertical',
                value: crossAxisSpacing,
                min: 0,
                max: 32,
                divisions: 8,
                onChanged: (value) {
                  setState(() {
                    crossAxisSpacing = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ConfigSection(
            title: 'Items',
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _addItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Item'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: items.isNotEmpty ? _removeItem : null,
                      icon: const Icon(Icons.remove),
                      label: const Text('Remove Item'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ConfigSection(
            title: 'Presets',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PresetButton(
                    label: 'Compact',
                    onPressed: () => _applyPreset('compact'),
                  ),
                  _PresetButton(
                    label: 'Standard',
                    onPressed: () => _applyPreset('standard'),
                  ),
                  _PresetButton(
                    label: 'Large',
                    onPressed: () => _applyPreset('large'),
                  ),
                  _PresetButton(
                    label: 'Wide',
                    onPressed: () => _applyPreset('wide'),
                  ),
                  _PresetButton(
                    label: 'Tall',
                    onPressed: () => _applyPreset('tall'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationControls() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConfigSection(
            title: 'Wobble Effect',
            children: [
              _SliderRow(
                label: 'Amount',
                value: wobbleAmount,
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: (value) {
                  setState(() {
                    wobbleAmount = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                wobbleAmount == 0
                    ? 'No wobble'
                    : wobbleAmount < 2
                        ? 'Subtle'
                        : wobbleAmount < 4
                            ? 'Normal'
                            : wobbleAmount < 6
                                ? 'Playful'
                                : 'Extreme',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ConfigSection(
            title: 'Animation Presets',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PresetButton(
                    label: 'No Wobble',
                    onPressed: () => _applyWobblePreset('none'),
                  ),
                  _PresetButton(
                    label: 'Subtle',
                    onPressed: () => _applyWobblePreset('subtle'),
                  ),
                  _PresetButton(
                    label: 'Default',
                    onPressed: () => _applyWobblePreset('default'),
                  ),
                  _PresetButton(
                    label: 'Playful',
                    onPressed: () => _applyWobblePreset('playful'),
                  ),
                  _PresetButton(
                    label: 'Extreme',
                    onPressed: () => _applyWobblePreset('extreme'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Wobble Animation',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The wobble effect adds personality to the displacement animation. '
                    'When you drag an item, other items will wobble as they move out of the way. '
                    'Try different values to find the perfect feel for your app!',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorControls() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConfigSection(
            title: 'Indicator Style',
            children: [
              RadioListTile<_IndicatorStyle>(
                title: const Text('Dots'),
                value: _IndicatorStyle.dots,
                groupValue: indicatorStyle,
                onChanged: (value) {
                  setState(() {
                    indicatorStyle = value!;
                  });
                },
              ),
              RadioListTile<_IndicatorStyle>(
                title: const Text('Numbers'),
                value: _IndicatorStyle.numbers,
                groupValue: indicatorStyle,
                onChanged: (value) {
                  setState(() {
                    indicatorStyle = value!;
                  });
                },
              ),
              RadioListTile<_IndicatorStyle>(
                title: const Text('Progress Bar'),
                value: _IndicatorStyle.progress,
                groupValue: indicatorStyle,
                onChanged: (value) {
                  setState(() {
                    indicatorStyle = value!;
                  });
                },
              ),
              RadioListTile<_IndicatorStyle>(
                title: const Text('Thumbnails'),
                value: _IndicatorStyle.thumbnails,
                groupValue: indicatorStyle,
                onChanged: (value) {
                  setState(() {
                    indicatorStyle = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.touch_app,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Interactive Indicators',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'All indicators are interactive! Click or tap on any indicator '
                    'to navigate directly to that page. Try adding more items to '
                    'create multiple pages and see the indicators in action.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    if (!_gridController.hasClients || _gridController.pageCount <= 1) {
      return const SizedBox.shrink();
    }

    return switch (indicatorStyle) {
      _IndicatorStyle.dots => _DotsIndicator(controller: _gridController),
      _IndicatorStyle.numbers => _NumbersIndicator(controller: _gridController),
      _IndicatorStyle.progress => _ProgressIndicator(controller: _gridController),
      _IndicatorStyle.thumbnails => _ThumbnailsIndicator(
          controller: _gridController,
          itemsPerPage: rows * columns,
          items: items,
        ),
    };
  }
}

// Indicator implementations
class _DotsIndicator extends StatelessWidget {
  final PageGridController controller;

  const _DotsIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            controller.pageCount,
            (index) => GestureDetector(
              onTap: () => controller.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              child: Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == controller.currentPage
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NumbersIndicator extends StatelessWidget {
  final PageGridController controller;

  const _NumbersIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            controller.pageCount,
            (index) => GestureDetector(
              onTap: () => controller.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              child: Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == controller.currentPage
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: index == controller.currentPage
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: index == controller.currentPage
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final PageGridController controller;

  const _ProgressIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final progress = (controller.currentPage + 1) / controller.pageCount;
        return Column(
          children: [
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Page ${controller.currentPage + 1} of ${controller.pageCount}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}

class _ThumbnailsIndicator extends StatelessWidget {
  final PageGridController controller;
  final int itemsPerPage;
  final Map<int, Widget> items;

  const _ThumbnailsIndicator({
    required this.controller,
    required this.itemsPerPage,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            controller.pageCount,
            (pageIndex) {
              final startIndex = pageIndex * itemsPerPage;
              final endIndex = (startIndex + itemsPerPage).clamp(0, items.length);
              final pageItems = items.entries
                  .where((e) => e.key >= startIndex && e.key < endIndex)
                  .take(4)
                  .toList();

              return GestureDetector(
                onTap: () => controller.animateToPage(
                  pageIndex,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                child: Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: pageIndex == controller.currentPage
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                      width: pageIndex == controller.currentPage ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: GridView.count(
                      crossAxisCount: 2,
                      physics: const NeverScrollableScrollPhysics(),
                      children: pageItems
                          .map((e) => Transform.scale(
                                scale: 0.8,
                                child: e.value,
                              ))
                          .toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Helper widgets
class _ConfigSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ConfigSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            value.round().toString(),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PresetButton({
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

enum _IndicatorStyle {
  dots,
  numbers,
  progress,
  thumbnails,
}