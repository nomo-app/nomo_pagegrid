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
      5: _buildItem(Colors.green, '5'),
      6: _buildItem(Colors.greenAccent, '6'),
      7: _buildItem(Colors.deepPurple, '7'),
      8: _buildItem(Colors.blueAccent, '8'),
      9: _buildItem(Colors.pink, '9'),
      10: _buildItem(Colors.amber, '10'),
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
      appBar: AppBar(
        title: const Text('Normal NomoPageGrid'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: NomoPageGrid(
          rows: 4,
          columns: 4,
          itemSize: const Size(80, 80),
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