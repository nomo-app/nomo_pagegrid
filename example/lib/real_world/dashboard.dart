import 'package:flutter/material.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';
import '../widgets/example_scaffold.dart';

class DashboardExample extends StatefulWidget {
  const DashboardExample({super.key});

  @override
  State<DashboardExample> createState() => _DashboardExampleState();
}

class _DashboardExampleState extends State<DashboardExample> {
  late Map<int, Widget> widgets;
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    widgets = _generateWidgets();
  }

  Map<int, Widget> _generateWidgets() {
    return {
      0: _DashboardWidget(
        title: 'Revenue',
        icon: Icons.attach_money,
        color: Colors.green,
        value: '\$125,430',
        change: '+12.5%',
        isPositive: true,
      ),
      1: _DashboardWidget(
        title: 'Orders',
        icon: Icons.shopping_bag,
        color: Colors.blue,
        value: '1,234',
        change: '+5.2%',
        isPositive: true,
      ),
      2: _DashboardWidget(
        title: 'Visitors',
        icon: Icons.people,
        color: Colors.purple,
        value: '45.2K',
        change: '-2.1%',
        isPositive: false,
      ),
      3: _DashboardWidget(
        title: 'Performance',
        icon: Icons.speed,
        color: Colors.orange,
        value: '92%',
        change: '+8.0%',
        isPositive: true,
      ),
      5: _ChartWidget(
        title: 'Sales Chart',
        color: Colors.indigo,
      ),
      7: _TaskWidget(
        title: 'Tasks',
        tasks: [
          ('Review Q4 Report', false),
          ('Update Dashboard', true),
          ('Team Meeting', false),
          ('Client Call', false),
        ],
      ),
      8: _DashboardWidget(
        title: 'Messages',
        icon: Icons.message,
        color: Colors.teal,
        value: '23',
        subtitle: 'Unread',
      ),
      9: _DashboardWidget(
        title: 'Storage',
        icon: Icons.storage,
        color: Colors.red,
        value: '82%',
        subtitle: 'Used',
      ),
      10: _ActivityWidget(
        title: 'Recent Activity',
        activities: [
          ('New order received', '2 min ago', Icons.shopping_cart),
          ('Server backup completed', '15 min ago', Icons.backup),
          ('User registration', '1 hour ago', Icons.person_add),
        ],
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Dashboard',
      actions: [
        IconButton(
          icon: Icon(isEditMode ? Icons.done : Icons.edit),
          onPressed: () {
            setState(() {
              isEditMode = !isEditMode;
            });
          },
          tooltip: isEditMode ? 'Done editing' : 'Edit layout',
        ),
      ],
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Business Dashboard',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        isEditMode
                            ? 'Drag widgets to rearrange'
                            : 'Last updated: ${DateTime.now().toString().substring(11, 16)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (!isEditMode)
                  FilledButton.tonal(
                    onPressed: () {
                      setState(() {
                        widgets = _generateWidgets();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dashboard refreshed'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Text('Refresh'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: NomoPageGrid(
                      rows: 4,
                      columns: 3,
                      itemSize: const Size(180, 140),
                      items: widgets,
                      wobbleAmount: isEditMode ? 3 : 0,
                      onChanged: isEditMode
                          ? (newWidgets) {
                              setState(() {
                                widgets = newWidgets;
                              });
                            }
                          : null,
                    ),
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

class _DashboardWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String value;
  final String? change;
  final bool? isPositive;
  final String? subtitle;

  const _DashboardWidget({
    required this.title,
    required this.icon,
    required this.color,
    required this.value,
    this.change,
    this.isPositive,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                if (change != null && isPositive != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive!
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      change!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isPositive! ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle ?? title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartWidget extends StatelessWidget {
  final String title;
  final Color color;

  const _ChartWidget({
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(0.6, color),
                _buildBar(0.8, color),
                _buildBar(0.4, color),
                _buildBar(0.9, color),
                _buildBar(0.7, color),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(double height, Color color) {
    return Container(
      width: 20,
      height: 60 * height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(4),
        ),
      ),
    );
  }
}

class _TaskWidget extends StatelessWidget {
  final String title;
  final List<(String, bool)> tasks;

  const _TaskWidget({
    required this.title,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Row(
                    children: [
                      Icon(
                        task.$2 ? Icons.check_circle : Icons.circle_outlined,
                        size: 16,
                        color: task.$2 ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task.$1,
                          style: TextStyle(
                            fontSize: 12,
                            decoration: task.$2 ? TextDecoration.lineThrough : null,
                            color: task.$2 ? Theme.of(context).colorScheme.onSurfaceVariant : null,
                          ),
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

class _ActivityWidget extends StatelessWidget {
  final String title;
  final List<(String, String, IconData)> activities;

  const _ActivityWidget({
    required this.title,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: activities.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return Row(
                    children: [
                      Icon(
                        activity.$3,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.$1,
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              activity.$2,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
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
