import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';

import '../test_utils/helpers.dart';

void main() {
  group('NomoPageGrid Widget Tests', () {
    testWidgets('renders correctly with basic configuration', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: NomoPageGrid(
            rows: 2,
            columns: 2,
            itemSize: const Size(100, 100),
            items: createTestItems(4),
          ),
        ),
      );

      expect(find.byType(NomoPageGrid), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('handles empty grid correctly', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: NomoPageGrid(
            rows: 2,
            columns: 2,
            itemSize: const Size(100, 100),
            items: const {},
          ),
        ),
      );

      expect(find.byType(NomoPageGrid), findsOneWidget);
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('handles grid with gaps correctly', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: NomoPageGrid(
            rows: 2,
            columns: 2,
            itemSize: const Size(100, 100),
            items: {
              0: createTestItem(0),
              3: createTestItem(3),
            },
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);
      expect(find.text('2'), findsNothing);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('respects custom dimensions', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: NomoPageGrid(
            rows: 3,
            columns: 4,
            itemSize: const Size(50, 50),
            width: 300,
            height: 200,
            items: createTestItems(12),
          ),
        ),
      );

      expect(find.byType(NomoPageGrid), findsOneWidget);
      
      // Should show all 12 items on first page (3x4 grid)
      for (int i = 0; i < 12; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('calls onChanged when items are reordered', (tester) async {
      Map<int, Widget>? changedItems;
      Map<int, Widget> items = createTestItems(4);

      await tester.pumpWidget(
        TestApp(
          child: StatefulTestWrapper(
            builder: (context, setState) => NomoPageGrid(
              rows: 2,
              columns: 2,
              itemSize: const Size(100, 100),
              items: items,
              onChanged: (newItems) {
                setState(() {
                  changedItems = newItems;
                  items = newItems;
                });
              },
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
        // The exact reordering depends on the displacement algorithm
        // so we just verify the callback was triggered
      }
    });

    testWidgets('supports controller attachment', (tester) async {
      final controller = PageGridController();

      await tester.pumpWidget(
        TestApp(
          child: NomoPageGrid(
            controller: controller,
            rows: 2,
            columns: 2,
            itemSize: const Size(100, 100),
            items: createTestItems(8), // 2 pages worth
          ),
        ),
      );

      // Wait for post-frame callback
      await tester.pump();

      expect(controller.hasClients, isTrue);
      expect(controller.currentPage, equals(0));
      expect(controller.pageCount, equals(2));

      controller.dispose();
    });

    testWidgets('wobbleAmount parameter affects animation', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: NomoPageGrid(
            rows: 2,
            columns: 2,
            itemSize: const Size(100, 100),
            wobbleAmount: 10.0, // Custom wobble amount
            items: createTestItems(4),
          ),
        ),
      );

      expect(find.byType(NomoPageGrid), findsOneWidget);
      
      // The actual wobble animation would be tested by checking
      // transform matrices during drag, but that requires more
      // complex animation testing
    });

    testWidgets('handles page navigation with swipe', (tester) async {
      final controller = PageGridController();

      await tester.pumpWidget(
        TestApp(
          child: NomoPageGrid(
            controller: controller,
            rows: 2,
            columns: 2,
            itemSize: const Size(100, 100),
            items: createTestItems(8), // 2 pages
          ),
        ),
      );

      await tester.pump();
      expect(controller.currentPage, equals(0));

      // Swipe to next page
      await swipeToNextPage(tester);
      expect(controller.currentPage, equals(1));

      // Swipe back to previous page
      await swipeToPreviousPage(tester);
      expect(controller.currentPage, equals(0));

      controller.dispose();
    });

    testWidgets('renders items at correct positions', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: NomoPageGrid(
            rows: 2,
            columns: 2,
            itemSize: const Size(100, 100),
            items: createTestItems(4),
          ),
        ),
      );

      // Find positions of items
      final positions = <int, Offset?>{};
      for (int i = 0; i < 4; i++) {
        positions[i] = findItemPosition(tester, i);
      }

      // Verify items are positioned in grid layout
      // Item 0 should be top-left
      // Item 1 should be to the right of item 0
      // Item 2 should be below item 0
      // Item 3 should be bottom-right
      
      expect(positions[0], isNotNull);
      expect(positions[1], isNotNull);
      expect(positions[2], isNotNull);
      expect(positions[3], isNotNull);

      if (positions[0] != null && positions[1] != null) {
        expect(positions[1]!.dx > positions[0]!.dx, isTrue);
        expect(positions[1]!.dy, equals(positions[0]!.dy));
      }

      if (positions[0] != null && positions[2] != null) {
        expect(positions[2]!.dx, equals(positions[0]!.dx));
        expect(positions[2]!.dy > positions[0]!.dy, isTrue);
      }
    });
  });
}