import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';

void main() {
  group('PageGridController', () {
    late PageGridController controller;

    setUp(() {
      controller = PageGridController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state is correct', () {
      expect(controller.currentPage, equals(0));
      expect(controller.pageCount, equals(0));
      expect(controller.hasClients, isFalse);
    });

    test('notifies listeners when page changes', () {
      int notificationCount = 0;
      controller.addListener(() {
        notificationCount++;
      });

      // This would normally be called by the grid widget
      controller.notifyPageChanged();

      expect(notificationCount, equals(1));
    });

    test('throws assertion error when navigating without attachment', () {
      expect(
        () => controller.nextPage(),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => controller.previousPage(),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => controller.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => controller.jumpToPage(0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('disposes without errors', () {
      final testController = PageGridController();
      void listener() {}
      testController.addListener(listener);
      testController.removeListener(listener);
      
      expect(() => testController.dispose(), returnsNormally);
    });

    test('page validation assertions work correctly', () {
      // These would fail with attached state that has pageCount > 0
      expect(
        () => controller.animateToPage(-1, duration: Duration(milliseconds: 300), curve: Curves.easeInOut),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => controller.jumpToPage(-1),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}