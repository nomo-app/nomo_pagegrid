import 'dart:async';

import 'package:flutter/material.dart';

/// Internal state interface for PageGridController.
///
/// This abstract class defines the contract between PageGridController
/// and the grid implementation.
abstract class PageGridControllerState {
  int get currentPage;
  int get pageCount;

  Future<void> animateToPage(int page, {required Duration duration, required Curve curve});
  void jumpToPage(int page);
}
