import 'package:flutter/material.dart';
import 'basic/simple_grid.dart';
import 'basic/custom_items.dart';
import 'basic/empty_slots.dart';
import 'advanced/controller_usage.dart';
import 'advanced/drag_callbacks.dart';
import 'advanced/multi_page.dart';
import 'advanced/animations.dart';
import 'customization/theming.dart';
import 'customization/sizes.dart';
import 'customization/indicators.dart';
import 'real_world/photo_gallery.dart';
import 'real_world/app_launcher.dart';
import 'real_world/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NomoPageGrid Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExampleCatalog(),
    );
  }
}

class ExampleCatalog extends StatelessWidget {
  const ExampleCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NomoPageGrid Examples'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            'Basic Examples',
            'Get started with fundamental grid features',
            [
              _ExampleTile(
                title: 'Simple Grid',
                subtitle: 'Basic grid with colored containers',
                icon: Icons.grid_view,
                builder: () => const SimpleGridExample(),
              ),
              _ExampleTile(
                title: 'Custom Items',
                subtitle: 'Grid with custom widget items',
                icon: Icons.widgets,
                builder: () => const CustomItemsExample(),
              ),
              _ExampleTile(
                title: 'Empty Slots',
                subtitle: 'Handling grids with empty positions',
                icon: Icons.grid_off,
                builder: () => const EmptySlotsExample(),
              ),
            ],
          ),
          _buildSection(
            context,
            'Advanced Examples',
            'Explore advanced features and controls',
            [
              _ExampleTile(
                title: 'Controller Usage',
                subtitle: 'Full controller demo with navigation',
                icon: Icons.control_camera,
                builder: () => const ControllerUsageExample(),
              ),
              _ExampleTile(
                title: 'Drag Callbacks',
                subtitle: 'Track drag events and feedback',
                icon: Icons.touch_app,
                builder: () => const DragCallbacksExample(),
              ),
              _ExampleTile(
                title: 'Multi-Page Grid',
                subtitle: 'Large grid with multiple pages',
                icon: Icons.view_carousel,
                builder: () => const MultiPageExample(),
              ),
              _ExampleTile(
                title: 'Animations',
                subtitle: 'Custom wobble and visual effects',
                icon: Icons.animation,
                builder: () => const AnimationsExample(),
              ),
            ],
          ),
          _buildSection(
            context,
            'Customization',
            'Style and configure your grids',
            [
              _ExampleTile(
                title: 'Theming',
                subtitle: 'Different color schemes and themes',
                icon: Icons.palette,
                builder: () => const ThemingExample(),
              ),
              _ExampleTile(
                title: 'Sizes',
                subtitle: 'Various grid dimensions and layouts',
                icon: Icons.aspect_ratio,
                builder: () => const SizesExample(),
              ),
              _ExampleTile(
                title: 'Indicators',
                subtitle: 'Custom page indicators and controls',
                icon: Icons.radio_button_checked,
                builder: () => const IndicatorsExample(),
              ),
            ],
          ),
          _buildSection(
            context,
            'Real-World Examples',
            'Production-ready implementations',
            [
              _ExampleTile(
                title: 'Photo Gallery',
                subtitle: 'Image grid with reordering',
                icon: Icons.photo_library,
                builder: () => const PhotoGalleryExample(),
              ),
              _ExampleTile(
                title: 'App Launcher',
                subtitle: 'App icon grid with folders',
                icon: Icons.apps,
                builder: () => const AppLauncherExample(),
              ),
              _ExampleTile(
                title: 'Dashboard',
                subtitle: 'Widget dashboard with tiles',
                icon: Icons.dashboard,
                builder: () => const DashboardExample(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String description,
    List<_ExampleTile> tiles,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ...tiles,
        const Divider(height: 1),
      ],
    );
  }
}

class _ExampleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget Function() builder;

  const _ExampleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => builder(),
          ),
        );
      },
    );
  }
}
