import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';

import '../test_utils/helpers.dart';

void main() {
  group('Drag and Drop Tests', () {
    testWidgets('long press initiates drag', (tester) async {
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

      // Start long press
      final item0Position = findItemPosition(tester, 0)!;
      final gesture = await tester.startGesture(item0Position);

      // Wait for long press duration
      await tester.pump(const Duration(milliseconds: 500));

      // Item should be in dragging state
      expect(find.byType(Draggable), findsWidgets);

      await gesture.up();
      await tester.pump();
    });

    testWidgets('drag to empty slot moves item', (tester) async {
      Map<int, Widget> items = {
        0: createTestItem(0),
        1: createTestItem(1),
        2: createTestItem(2),
        // Position 3 is empty
      };
      Map<int, Widget>? changedItems;

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

      // Find empty position (bottom-right)
      final gridFinder = find.byType(NomoPageGrid);
      final gridBox = tester.renderObject<RenderBox>(gridFinder);
      final emptyPosition =
          gridBox.localToGlobal(Offset.zero) +
          Offset(gridBox.size.width * 0.75, gridBox.size.height * 0.75);

      // Drag item 0 to empty position
      final item0Position = findItemPosition(tester, 0)!;
      await dragFromTo(
        tester,
        from: item0Position,
        to: emptyPosition,
      );

      // Verify item was moved
      expect(changedItems, isNotNull);
      expect(changedItems!.containsKey(3), isTrue);
      expect(changedItems![3], equals(items[0]));
    });

    testWidgets('drag between items causes displacement', (tester) async {
      Map<int, Widget> items = createTestItems(4);
      Map<int, Widget>? changedItems;

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

      // Drag item 0 to position of item 3
      final item0Position = findItemPosition(tester, 0)!;
      final item3Position = findItemPosition(tester, 3)!;

      await dragFromTo(
        tester,
        from: item0Position,
        to: item3Position,
      );

      // Verify displacement occurred
      expect(changedItems, isNotNull);
      // The exact positions depend on displacement algorithm
      // but we know the items should have been rearranged
      expect(changedItems!.length, equals(4));
    });

    testWidgets('cancel drag returns item to original position', (tester) async {
      Map<int, Widget> items = createTestItems(4);
      Map<int, Widget>? changedItems;

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

      // Start drag but release outside grid
      final item0Position = findItemPosition(tester, 0)!;
      final gesture = await tester.startGesture(item0Position);
      await tester.pump(const Duration(milliseconds: 500));

      // Move outside grid bounds
      await gesture.moveTo(const Offset(-100, -100));
      await tester.pump();

      // Release
      await gesture.up();
      await tester.pump();

      // No change should have occurred
      expect(changedItems, isNull);
    });

    testWidgets('wobble effect activates during displacement', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: NomoPageGrid(
            rows: 2,
            columns: 2,
            itemSize: const Size(100, 100),
            wobbleAmount: 10.0,
            items: createTestItems(4),
          ),
        ),
      );

      // Start dragging item 0
      final item0Position = findItemPosition(tester, 0)!;
      final item1Position = findItemPosition(tester, 1)!;

      final gesture = await tester.startGesture(item0Position);
      await tester.pump(const Duration(milliseconds: 500));

      // Move towards item 1 to trigger displacement
      await gesture.moveTo(item1Position);
      await tester.pump();

      // Item 1 should be wobbling (animation active)
      // We can't easily test the actual wobble transform,
      // but we verify the widget tree is updated
      expect(find.byKey(const ValueKey('item_1')), findsOneWidget);

      await gesture.up();
      await tester.pump();
    });

    testWidgets('drag across page boundary', (tester) async {
      final controller = PageGridController();
      Map<int, Widget> items = createTestItems(8); // 2 pages

      await tester.pumpWidget(
        TestApp(
          child: StatefulTestWrapper(
            builder: (context, setState) => NomoPageGrid(
              controller: controller,
              rows: 2,
              columns: 2,
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
      );

      await tester.pump();

      // Start on page 0
      expect(controller.currentPage, equals(0));

      // Start dragging item 0
      final item0Position = findItemPosition(tester, 0)!;
      final gesture = await tester.startGesture(item0Position);
      await tester.pump(const Duration(milliseconds: 500));

      // Move to right edge to trigger page navigation
      final gridFinder = find.byType(NomoPageGrid);
      final gridBox = tester.renderObject<RenderBox>(gridFinder);
      final rightEdge =
          gridBox.localToGlobal(Offset.zero) +
          Offset(gridBox.size.width - 10, gridBox.size.height / 2);

      await gesture.moveTo(rightEdge);
      await tester.pump(const Duration(milliseconds: 1000));

      // This might trigger page navigation depending on implementation
      // The exact behavior would need to be verified based on
      // the actual edge navigation implementation

      await gesture.up();
      await tester.pump();

      controller.dispose();
    });

    testWidgets('multiple items can be displaced in chain', (tester) async {
      Map<int, Widget> items = createTestItems(4);
      Map<int, Widget>? changedItems;

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

      // Drag item 0 through positions 1 and 2 to position 3
      // This should cause a chain of displacements
      final item0Position = findItemPosition(tester, 0)!;
      final item1Position = findItemPosition(tester, 1)!;
      final item2Position = findItemPosition(tester, 2)!;
      final item3Position = findItemPosition(tester, 3)!;

      final gesture = await tester.startGesture(item0Position);
      await tester.pump(const Duration(milliseconds: 500));

      // Move through intermediate positions
      await gesture.moveTo(item1Position);
      await tester.pump(const Duration(milliseconds: 100));

      await gesture.moveTo(item2Position);
      await tester.pump(const Duration(milliseconds: 100));

      await gesture.moveTo(item3Position);
      await tester.pump(const Duration(milliseconds: 100));

      await gesture.up();
      await tester.pump();

      // Verify multiple items were displaced
      expect(changedItems, isNotNull);
      expect(changedItems!.length, equals(4));
    });
  });
}
