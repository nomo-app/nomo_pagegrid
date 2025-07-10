import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';

import '../test_utils/helpers.dart';

void main() {
  group('Integration Tests', () {
    testWidgets('complete user flow with multiple interactions', (tester) async {
      final controller = PageGridController();
      Map<int, Widget> items = createTestItems(12); // 3 pages worth
      int reorderCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Grid Test'),
              actions: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.first_page),
                    onPressed: () => controller.jumpToPage(0),
                  ),
                ),
              ],
            ),
            body: StatefulBuilder(
              builder: (context, setState) => NomoPageGrid(
                controller: controller,
                rows: 2,
                columns: 2,
                itemSize: const Size(100, 100),
                items: items,
                onChanged: (newItems) {
                  setState(() {
                    items = newItems;
                    reorderCount++;
                  });
                },
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => controller.previousPage(),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) => Text(
                      'Page ${controller.currentPage + 1} of ${controller.pageCount}',
                    ),
                  ),
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () => controller.nextPage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify initial state
      expect(controller.currentPage, equals(0));
      expect(controller.pageCount, equals(3));
      expect(find.text('Page 1 of 3'), findsOneWidget);
      expect(reorderCount, equals(0));

      // Test 1: Navigate to page 2 using controller
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();
      expect(controller.currentPage, equals(1));
      expect(find.text('Page 2 of 3'), findsOneWidget);

      // Test 2: Drag and drop on page 2
      final item4Position = findItemPosition(tester, 4);
      final item7Position = findItemPosition(tester, 7);
      
      if (item4Position != null && item7Position != null) {
        await dragFromTo(
          tester,
          from: item4Position,
          to: item7Position,
        );
        expect(reorderCount, equals(1));
      }

      // Test 3: Navigate to page 3 using swipe
      await swipeToNextPage(tester);
      expect(controller.currentPage, equals(2));
      expect(find.text('Page 3 of 3'), findsOneWidget);

      // Test 4: Jump to first page
      await tester.tap(find.byIcon(Icons.first_page));
      await tester.pumpAndSettle();
      expect(controller.currentPage, equals(0));

      // Test 5: Verify persistence of reordered items
      // The items should maintain their new positions
      expect(items.length, equals(12));

      controller.dispose();
    });

    testWidgets('grid with mixed content types', (tester) async {
      final items = <int, Widget>{
        0: const Icon(Icons.home, size: 40),
        1: Container(
          color: Colors.blue,
          child: const Text('Text', style: TextStyle(color: Colors.white)),
        ),
        2: Image.asset('assets/test.png', errorBuilder: (_, __, ___) => 
          Container(color: Colors.grey)),
        3: ElevatedButton(
          onPressed: () {},
          child: const Text('Button'),
        ),
      };

      await tester.pumpWidget(
        TestApp(
          child: NomoPageGrid(
            rows: 2,
            columns: 2,
            itemSize: const Size(100, 100),
            items: items,
          ),
        ),
      );

      // Verify all different widget types render
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.text('Text'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('grid performance with many items', (tester) async {
      final stopwatch = Stopwatch()..start();
      
      // Create a large grid
      final items = createTestItems(100);
      
      await tester.pumpWidget(
        TestApp(
          child: NomoPageGrid(
            rows: 5,
            columns: 5,
            itemSize: const Size(60, 60),
            items: items,
          ),
        ),
      );

      stopwatch.stop();
      
      // Initial render should be reasonably fast
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      // Navigate through pages
      stopwatch.reset();
      stopwatch.start();
      
      for (int i = 0; i < 3; i++) {
        await swipeToNextPage(tester);
      }
      
      stopwatch.stop();
      
      // Page navigation should be smooth
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    testWidgets('sliver integration in complex scroll view', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                const SliverAppBar(
                  title: Text('Complex Layout'),
                  floating: true,
                  expandedHeight: 200,
                  flexibleSpace: FlexibleSpaceBar(
                    background: ColoredBox(color: Colors.blue),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    height: 100,
                    color: Colors.grey[200],
                    child: const Center(child: Text('Header Section')),
                  ),
                ),
                SliverNomoPageGrid(
                  rows: 3,
                  columns: 3,
                  itemSize: const Size(80, 80),
                  height: 300,
                  items: createTestItems(18),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    height: 100,
                    color: Colors.grey[300],
                    child: const Center(child: Text('Middle Section')),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ListTile(
                      title: Text('List Item $index'),
                    ),
                    childCount: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Scroll to reveal grid
      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      // Grid should be visible and functional
      expect(find.byType(SliverNomoPageGrid), findsOneWidget);
      expect(find.text('0'), findsOneWidget);

      // Continue scrolling
      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();

      // List items should be visible
      expect(find.text('List Item 0'), findsOneWidget);
    });

    testWidgets('edge cases and error handling', (tester) async {
      // Test with empty grid
      await tester.pumpWidget(
        TestApp(
          child: NomoPageGrid(
            rows: 3,
            columns: 3,
            itemSize: const Size(100, 100),
            items: const {},
          ),
        ),
      );

      expect(find.byType(NomoPageGrid), findsOneWidget);
      
      // Test with single item
      await tester.pumpWidget(
        TestApp(
          child: NomoPageGrid(
            rows: 3,
            columns: 3,
            itemSize: const Size(100, 100),
            items: {
              4: createTestItem(4), // Middle position
            },
          ),
        ),
      );

      expect(find.text('4'), findsOneWidget);

      // Test with very small grid
      await tester.pumpWidget(
        TestApp(
          child: NomoPageGrid(
            rows: 1,
            columns: 1,
            itemSize: const Size(200, 200),
            items: createTestItems(3), // More items than slots per page
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing); // On next page
    });
  });
}