import 'package:flutter/material.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NomoPageGrid Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NomoPageGrid Examples'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NormalGridScreen(),
                  ),
                );
              },
              child: const Text('Normal NomoPageGrid'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SliverGridScreen(),
                  ),
                );
              },
              child: const Text('SliverNomoPageGrid'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ControllerGridScreen(),
                  ),
                );
              },
              child: const Text('PageGridController Demo'),
            ),
          ],
        ),
      ),
    );
  }
}

class NormalGridScreen extends StatefulWidget {
  const NormalGridScreen({super.key});

  @override
  State<NormalGridScreen> createState() => _NormalGridScreenState();
}

class _NormalGridScreenState extends State<NormalGridScreen> {
  late Map<int, Widget> items;

  @override
  void initState() {
    super.initState();
    items = _generateItems();
  }

  Map<int, Widget> _generateItems() {
    return {
      0: _buildItem(Colors.red, '0'),
      1: _buildItem(Colors.yellow, '1'),
      2: _buildItem(Colors.deepOrange, '2'),
      3: _buildItem(Colors.blue, '3'),
      4: _buildItem(Colors.cyan, '4'),
      // 5: _buildItem(Colors.green, '5'),
      // 6: _buildItem(Colors.greenAccent, '6'),
      // 7: _buildItem(Colors.deepPurple, '7'),
      // 8: _buildItem(Colors.blueAccent, '8'),
      // 9: _buildItem(Colors.pink, '9'),
      // 10: _buildItem(Colors.amber, '10'),
      11: _buildItem(Colors.teal, '11'),
      32: _buildItem(Colors.lime, '32'),
      33: _buildItem(Colors.indigo, '33'),
    };
  }

  Widget _buildItem(Color color, String label) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Normal NomoPageGrid'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: NomoPageGrid(
          rows: 4,
          columns: 4,
          itemSize: const Size(64, 64),
          wobbleAmount: 3,
          onChanged: (newItems) {
            setState(() {
              items = newItems;
            });
            print("Items reordered");
          },
          items: items,
        ),
      ),
    );
  }
}

class SliverGridScreen extends StatefulWidget {
  const SliverGridScreen({super.key});

  @override
  State<SliverGridScreen> createState() => _SliverGridScreenState();
}

class _SliverGridScreenState extends State<SliverGridScreen> {
  late Map<int, Widget> items;

  @override
  void initState() {
    super.initState();
    items = _generateItems();
  }

  Map<int, Widget> _generateItems() {
    return {
      0: _buildItem(Colors.red, '0'),
      1: _buildItem(Colors.yellow, '1'),
      2: _buildItem(Colors.deepOrange, '2'),
      3: _buildItem(Colors.blue, '3'),
      4: _buildItem(Colors.cyan, '4'),
      5: _buildItem(Colors.green, '5'),
      6: _buildItem(Colors.greenAccent, '6'),
      7: _buildItem(Colors.deepPurple, '7'),
      8: _buildItem(Colors.blueAccent, '8'),
      9: _buildItem(Colors.pink, '9'),
      10: _buildItem(Colors.amber, '10'),
      11: _buildItem(Colors.teal, '11'),
    };
  }

  Widget _buildItem(Color color, String label) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('SliverNomoPageGrid Example'),
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Drag and drop items in the grid below',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The grid is embedded in a CustomScrollView with other slivers',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverNomoPageGrid(
              rows: 3,
              columns: 4,
              itemSize: const Size(80, 80),
              height: 300,
              wobbleAmount: 3,
              onChanged: (newItems) {
                setState(() {
                  items = newItems;
                });
                print("Sliver items reordered");
              },
              items: items,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Other content below the grid',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                leading: CircleAvatar(
                  child: Text('$index'),
                ),
                title: Text('List item $index'),
                subtitle: const Text('This is a regular sliver list item'),
              ),
              childCount: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class ControllerGridScreen extends StatefulWidget {
  const ControllerGridScreen({super.key});

  @override
  State<ControllerGridScreen> createState() => _ControllerGridScreenState();
}

class _ControllerGridScreenState extends State<ControllerGridScreen> {
  late Map<int, Widget> items;
  final PageGridController controller = PageGridController();
  int currentPage = 0;

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
    setState(() {
      currentPage = controller.currentPage;
    });
  }

  Map<int, Widget> _generateItems() {
    final colors = [
      Colors.red,
      Colors.yellow,
      Colors.deepOrange,
      Colors.blue,
      Colors.cyan,
      Colors.green,
      Colors.greenAccent,
      Colors.deepPurple,
      Colors.blueAccent,
      Colors.pink,
      Colors.amber,
      Colors.teal,
      Colors.lime,
      Colors.indigo,
      Colors.orange,
      Colors.purple,
      Colors.brown,
      Colors.grey,
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.redAccent,
      Colors.yellowAccent,
      Colors.orangeAccent,
      Colors.blueGrey,
      Colors.deepOrangeAccent,
      Colors.pinkAccent,
      Colors.purpleAccent,
      Colors.indigoAccent,
      Colors.cyanAccent,
      Colors.lightBlueAccent,
      Colors.lightGreenAccent,
      Colors.amberAccent,
    ];

    return {
      for (int i = 0; i < colors.length; i++) i: _buildItem(colors[i], '$i'),
    };
  }

  Widget _buildItem(Color color, String label) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PageGridController Demo'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Page ${currentPage + 1} of ${controller.pageCount == 0 ? '?' : controller.pageCount}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: currentPage > 0 ? () => controller.previousPage() : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                    ElevatedButton.icon(
                      onPressed: controller.hasClients && currentPage < controller.pageCount - 1
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
                    ElevatedButton(
                      onPressed: () => controller.jumpToPage(0),
                      child: const Text('Jump to First'),
                    ),
                    ElevatedButton(
                      onPressed: controller.hasClients && controller.pageCount > 0
                          ? () => controller.animateToPage(
                              controller.pageCount - 1,
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeInOutCubic,
                            )
                          : null,
                      child: const Text('Animate to Last'),
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
                wobbleAmount: 3,
                onChanged: (newItems) {
                  setState(() {
                    items = newItems;
                  });
                },
                items: items,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (int i = 0; i < controller.pageCount; i++)
                  ActionChip(
                    label: Text('${i + 1}'),
                    onPressed: () => controller.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    ),
                    backgroundColor: i == currentPage ? Theme.of(context).primaryColor : null,
                    labelStyle: TextStyle(
                      color: i == currentPage ? Colors.white : null,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
