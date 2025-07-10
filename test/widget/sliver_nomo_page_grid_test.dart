import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';

import '../test_utils/helpers.dart';

void main() {
  group('SliverNomoPageGrid Widget Tests', () {
    testWidgets('renders correctly in CustomScrollView', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverNomoPageGrid(
                  rows: 2,
                  columns: 2,
                  itemSize: const Size(100, 100),
                  height: 250,
                  items: createTestItems(4),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SliverNomoPageGrid), findsOneWidget);
      expect(find.byType(NomoPageGrid), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('requires height parameter', (tester) async {
      expect(
        () => SliverNomoPageGrid(
          rows: 2,
          columns: 2,
          itemSize: const Size(100, 100),
          height: null,
          items: const {},
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('height must be positive', (tester) async {
      expect(
        () => SliverNomoPageGrid(
          rows: 2,
          columns: 2,
          itemSize: const Size(100, 100),
          height: 0,
          items: const {},
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => SliverNomoPageGrid(
          rows: 2,
          columns: 2,
          itemSize: const Size(100, 100),
          height: -100,
          items: const {},
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('works with other slivers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                const SliverAppBar(
                  title: Text('Test App'),
                  floating: true,
                ),
                SliverNomoPageGrid(
                  rows: 2,
                  columns: 2,
                  itemSize: const Size(100, 100),
                  height: 250,
                  items: createTestItems(4),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ListTile(title: Text('Item $index')),
                    childCount: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SliverAppBar), findsOneWidget);
      expect(find.byType(SliverNomoPageGrid), findsOneWidget);
      expect(find.byType(SliverList), findsOneWidget);

      // Grid items
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // List items
      expect(find.text('Item 0'), findsOneWidget);
    });

    testWidgets('handles drag and drop within sliver', (tester) async {
      Map<int, Widget>? changedItems;
      Map<int, Widget> items = createTestItems(4);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                StatefulBuilder(
                  builder: (context, setState) => SliverNomoPageGrid(
                    rows: 2,
                    columns: 2,
                    itemSize: const Size(100, 100),
                    height: 250,
                    items: items,
                    onChanged: (newItems) {
                      setState(() {
                        changedItems = newItems;
                        items = newItems;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Perform drag operation
      final item0Position = findItemPosition(tester, 0);
      final item3Position = findItemPosition(tester, 3);

      if (item0Position != null && item3Position != null) {
        await dragFromTo(
          tester,
          from: item0Position,
          to: item3Position,
        );

        // Verify onChanged was called
        expect(changedItems, isNotNull);
      }
    });

    testWidgets('maintains fixed height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverNomoPageGrid(
                  rows: 2,
                  columns: 2,
                  itemSize: const Size(100, 100),
                  height: 300,
                  items: createTestItems(4),
                ),
              ],
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(SliverNomoPageGrid),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      expect(sizedBox.height, equals(300));
    });

    testWidgets('controller works with sliver', (tester) async {
      final controller = PageGridController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverNomoPageGrid(
                  controller: controller,
                  rows: 2,
                  columns: 2,
                  itemSize: const Size(100, 100),
                  height: 250,
                  items: createTestItems(8), // 2 pages
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      expect(controller.hasClients, isTrue);
      expect(controller.currentPage, equals(0));
      expect(controller.pageCount, equals(2));

      controller.dispose();
    });

    testWidgets('scroll notification handling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                const SliverAppBar(
                  title: Text('Test'),
                  expandedHeight: 200,
                ),
                SliverNomoPageGrid(
                  rows: 2,
                  columns: 2,
                  itemSize: const Size(100, 100),
                  height: 250,
                  items: createTestItems(8),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => SizedBox(
                      height: 100,
                      child: Text('Item $index'),
                    ),
                    childCount: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Scroll the CustomScrollView
      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      // Grid should still be functional
      expect(find.byType(SliverNomoPageGrid), findsOneWidget);
    });
  });
}
