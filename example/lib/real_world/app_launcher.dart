import 'package:flutter/material.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';
import '../widgets/example_scaffold.dart';

class AppLauncherExample extends StatefulWidget {
  const AppLauncherExample({super.key});

  @override
  State<AppLauncherExample> createState() => _AppLauncherExampleState();
}

class _AppLauncherExampleState extends State<AppLauncherExample> {
  late Map<int, Widget> apps;
  final PageGridController controller = PageGridController();

  @override
  void initState() {
    super.initState();
    apps = _generateApps();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Map<int, Widget> _generateApps() {
    final appData = [
      // Page 1 - Main Apps
      (Icons.phone, 'Phone', Colors.green),
      (Icons.message, 'Messages', Colors.blue),
      (Icons.email, 'Mail', Colors.lightBlue),
      (Icons.camera_alt, 'Camera', Colors.grey),
      (Icons.photo_library, 'Photos', Colors.orange),
      (Icons.map, 'Maps', Colors.teal),
      (Icons.calendar_today, 'Calendar', Colors.red),
      (Icons.access_time, 'Clock', Colors.purple),
      (Icons.cloud, 'Weather', Colors.cyan),
      (Icons.calculate, 'Calculator', Colors.amber),
      (Icons.note, 'Notes', Colors.yellow),
      (Icons.music_note, 'Music', Colors.pink),
      (Icons.videocam, 'Video', Colors.deepPurple),
      (Icons.book, 'Books', Colors.brown),
      (Icons.settings, 'Settings', Colors.blueGrey),
      (Icons.folder, 'Files', Colors.indigo),

      // Page 2 - Productivity
      (Icons.work, 'Work', Colors.blue),
      (Icons.edit_document, 'Docs', Colors.lightBlue),
      (Icons.table_chart, 'Sheets', Colors.green),
      (Icons.slideshow, 'Slides', Colors.orange),
      (Icons.drive_file_move, 'Drive', Colors.yellow),
      (Icons.task_alt, 'Tasks', Colors.red),
      (Icons.group, 'Teams', Colors.purple),
      (Icons.video_call, 'Meet', Colors.teal),

      // Page 3 - Social & Entertainment
      (Icons.chat, 'Chat', Colors.green),
      (Icons.public, 'Social', Colors.blue),
      (Icons.movie, 'Movies', Colors.red),
      (Icons.sports_esports, 'Games', Colors.orange),
      (Icons.newspaper, 'News', Colors.grey),
      (Icons.shopping_cart, 'Shop', Colors.purple),
      (Icons.restaurant, 'Food', Colors.amber),
      (Icons.fitness_center, 'Fitness', Colors.pink),
    ];

    return {
      for (int i = 0; i < appData.length; i++)
        i: _AppIcon(
          icon: appData[i].$1,
          label: appData[i].$2,
          color: appData[i].$3,
          onTap: () => _launchApp(appData[i].$2),
        ),
    };
  }

  void _launchApp(String appName) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Launching $appName...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'App Launcher',
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search apps',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.mic),
                      onPressed: () {},
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Search functionality not implemented'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
            ),

            // App Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: NomoPageGrid(
                  controller: controller,
                  rows: 5,
                  columns: 4,
                  itemSize: const Size(75, 90),
                  items: apps,
                  wobbleAmount: 2,
                  onChanged: (newApps) {
                    setState(() {
                      apps = newApps;
                    });
                  },
                ),
              ),
            ),

            // Dock
            Container(
              height: 100,
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _DockIcon(
                    icon: Icons.phone,
                    color: Colors.green,
                    onTap: () => _launchApp('Phone'),
                  ),
                  _DockIcon(
                    icon: Icons.message,
                    color: Colors.blue,
                    onTap: () => _launchApp('Messages'),
                  ),
                  _DockIcon(
                    icon: Icons.web,
                    color: Colors.orange,
                    onTap: () => _launchApp('Browser'),
                  ),
                  _DockIcon(
                    icon: Icons.camera_alt,
                    color: Colors.grey,
                    onTap: () => _launchApp('Camera'),
                  ),
                ],
              ),
            ),

            // Page Indicator
            SizedBox(
              height: 30,
              child: Builder(
                builder: (context) {
                  final currentPage = controller.currentPage;
                  final totalPages = (apps.length - 1) ~/ 20 + 1;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < totalPages; i++)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: i == currentPage
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AppIcon({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DockIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DockIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
