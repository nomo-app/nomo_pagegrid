import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';

/// Creates a basic test app wrapper for widget testing
class TestApp extends StatelessWidget {
  final Widget child;
  final Size? screenSize;

  const TestApp({
    super.key,
    required this.child,
    this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: screenSize ?? const Size(400, 800),
        ),
        child: Scaffold(
          body: child,
        ),
      ),
    );
  }
}

/// Creates a stateful wrapper for testing widgets that need state management
class StatefulTestWrapper extends StatefulWidget {
  final Widget Function(BuildContext context, StateSetter setState) builder;

  const StatefulTestWrapper({
    super.key,
    required this.builder,
  });

  @override
  State<StatefulTestWrapper> createState() => _StatefulTestWrapperState();
}

class _StatefulTestWrapperState extends State<StatefulTestWrapper> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context, setState);
  }
}

/// Creates a basic grid item for testing
Widget createTestItem(int index, {Color? color}) {
  return Container(
    key: ValueKey('item_$index'),
    color: color ?? Colors.primaries[index % Colors.primaries.length],
    child: Center(
      child: Text(
        '$index',
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    ),
  );
}

/// Creates a map of test items
Map<int, Widget> createTestItems(int count) {
  return {
    for (int i = 0; i < count; i++) i: createTestItem(i),
  };
}

/// Simulates a drag gesture from one point to another
Future<void> dragFromTo(
  WidgetTester tester, {
  required Offset from,
  required Offset to,
  Duration duration = const Duration(milliseconds: 800),
}) async {
  final TestGesture gesture = await tester.startGesture(from);
  await tester.pump(const Duration(milliseconds: 500)); // Long press duration
  await gesture.moveTo(to, timeStamp: duration);
  await tester.pump();
  await gesture.up();
  await tester.pump();
}

/// Finds the position of an item by its index
Offset? findItemPosition(WidgetTester tester, int index) {
  final finder = find.byKey(ValueKey('item_$index'));
  if (finder.evaluate().isEmpty) return null;

  final RenderBox box = tester.renderObject(finder);
  return box.localToGlobal(Offset.zero) + box.size.center(Offset.zero);
}

/// Swipes horizontally to navigate pages
Future<void> swipeToNextPage(WidgetTester tester) async {
  await tester.drag(
    find.byType(NomoPageGrid),
    const Offset(-300, 0),
    warnIfMissed: false,
  );
  await tester.pumpAndSettle();
}

Future<void> swipeToPreviousPage(WidgetTester tester) async {
  await tester.drag(
    find.byType(NomoPageGrid),
    const Offset(300, 0),
    warnIfMissed: false,
  );
  await tester.pumpAndSettle();
}

/// Extension methods for testing
extension NomoPageGridTester on WidgetTester {
  /// Gets the current page from a NomoPageGrid with controller
  int? getCurrentPage() {
    final controller = widget<NomoPageGrid>(find.byType(NomoPageGrid)).controller;
    return controller?.currentPage;
  }

  /// Gets the total page count from a NomoPageGrid with controller
  int? getPageCount() {
    final controller = widget<NomoPageGrid>(find.byType(NomoPageGrid)).controller;
    return controller?.pageCount;
  }
}
