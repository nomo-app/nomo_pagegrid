import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';

void main() {
  testWidgets('NomoPageGrid smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NomoPageGrid(
            rows: 2,
            columns: 2,
            itemSize: 64,
            maxWidth: 400,
            items: {
              0: Container(color: Colors.red),
              1: Container(color: Colors.green),
              2: Container(color: Colors.blue),
              3: Container(color: Colors.yellow),
            },
          ),
        ),
      ),
    );

    // Verify that our widget is present.
    expect(find.byType(NomoPageGrid), findsOneWidget);
  });
}
