import 'package:flutter/material.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';
import '../widgets/example_scaffold.dart';

class ThemingExample extends StatefulWidget {
  const ThemingExample({super.key});

  @override
  State<ThemingExample> createState() => _ThemingExampleState();
}

class _ThemingExampleState extends State<ThemingExample> {
  late Map<int, Widget> items;
  ThemeMode themeMode = ThemeMode.light;
  Color primaryColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    items = _generateItems();
  }

  Map<int, Widget> _generateItems() {
    final icons = [
      Icons.palette,
      Icons.brush,
      Icons.color_lens,
      Icons.format_paint,
      Icons.gradient,
      Icons.wallpaper,
      Icons.style,
      Icons.texture,
      Icons.layers,
    ];

    return {
      for (int i = 0; i < icons.length; i++)
        i: _ThemedItem(
          icon: icons[i],
          index: i,
          primaryColor: primaryColor,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
      ),
      child: ExampleScaffold(
        title: 'Theming',
        child: Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Theme Customization',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ThemeModeButton(
                        icon: Icons.light_mode,
                        label: 'Light',
                        isSelected: themeMode == ThemeMode.light,
                        onTap: () => setState(() {
                          themeMode = ThemeMode.light;
                          items = _generateItems();
                        }),
                      ),
                      const SizedBox(width: 8),
                      _ThemeModeButton(
                        icon: Icons.dark_mode,
                        label: 'Dark',
                        isSelected: themeMode == ThemeMode.dark,
                        onTap: () => setState(() {
                          themeMode = ThemeMode.dark;
                          items = _generateItems();
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final color in [
                        Colors.blue,
                        Colors.purple,
                        Colors.green,
                        Colors.orange,
                        Colors.red,
                        Colors.teal,
                        Colors.pink,
                        Colors.indigo,
                      ])
                        _ColorButton(
                          color: color,
                          isSelected: primaryColor == color,
                          onTap: () => setState(() {
                            primaryColor = color;
                            items = _generateItems();
                          }),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: NomoPageGrid(
                      rows: 3,
                      columns: 3,
                      itemSize: const Size(100, 100),
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
          ],
        ),
      ),
    );
  }
}

class _ThemedItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final Color primaryColor;

  const _ThemedItem({
    required this.icon,
    required this.index,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
      colorScheme.error,
      colorScheme.errorContainer,
      colorScheme.surfaceContainerHighest,
    ];

    final color = colors[index % colors.length];
    final onColor = index < 3 || index == 6
        ? colorScheme.onPrimary
        : colorScheme.onPrimaryContainer;

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
        child: Icon(
          icon,
          size: 40,
          color: onColor,
        ),
      ),
    );
  }
}

class _ThemeModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              )
            : null,
      ),
    );
  }
}
