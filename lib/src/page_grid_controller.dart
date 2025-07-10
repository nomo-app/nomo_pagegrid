import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'page_grid_controller_state.dart';

/// A controller for [NomoPageGrid] that enables programmatic page navigation.
/// 
/// This controller follows Flutter's standard controller patterns and provides
/// methods to navigate between pages, similar to [PageController].
/// 
/// Example usage:
/// ```dart
/// final controller = PageGridController();
/// 
/// NomoPageGrid(
///   controller: controller,
///   rows: 4,
///   columns: 4,
///   itemSize: Size(80, 80),
///   items: items,
/// )
/// 
/// // Navigate programmatically
/// controller.nextPage();
/// controller.previousPage();
/// controller.animateToPage(2, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
/// ```
class PageGridController extends ChangeNotifier {
  PageGridControllerState? _state;
  
  /// The current page index.
  /// 
  /// Returns 0 if the controller is not attached to a grid.
  int get currentPage => _state?.currentPage ?? 0;
  
  /// The total number of pages in the grid.
  /// 
  /// Returns 0 if the controller is not attached to a grid.
  int get pageCount => _state?.pageCount ?? 0;
  
  /// Whether the controller is attached to a grid.
  bool get hasClients => _state != null;
  
  /// Animates to the next page with optional duration and curve.
  /// 
  /// If already at the last page, this method does nothing.
  /// Defaults to 140ms duration with [Curves.easeInOut].
  Future<void> nextPage({Duration? duration, Curve? curve}) async {
    assert(_state != null, 'PageGridController not attached to any grid');
    if (_state == null) return;
    
    final nextPageIndex = currentPage + 1;
    if (nextPageIndex < pageCount) {
      await animateToPage(
        nextPageIndex, 
        duration: duration ?? const Duration(milliseconds: 140),
        curve: curve ?? Curves.easeInOut,
      );
    }
  }
  
  /// Animates to the previous page with optional duration and curve.
  /// 
  /// If already at the first page, this method does nothing.
  /// Defaults to 140ms duration with [Curves.easeInOut].
  Future<void> previousPage({Duration? duration, Curve? curve}) async {
    assert(_state != null, 'PageGridController not attached to any grid');
    if (_state == null) return;
    
    final previousPageIndex = currentPage - 1;
    if (previousPageIndex >= 0) {
      await animateToPage(
        previousPageIndex,
        duration: duration ?? const Duration(milliseconds: 140), 
        curve: curve ?? Curves.easeInOut,
      );
    }
  }
  
  /// Animates to a specific page with the given duration and curve.
  /// 
  /// The [page] must be between 0 and [pageCount] - 1.
  Future<void> animateToPage(int page, {required Duration duration, required Curve curve}) async {
    assert(_state != null, 'PageGridController not attached to any grid');
    assert(page >= 0, 'Page index must be non-negative');
    
    if (_state == null) return;
    assert(page < pageCount, 'Page index $page is out of range [0, ${pageCount - 1}]');
    
    await _state!.animateToPage(page, duration: duration, curve: curve);
  }
  
  /// Immediately jumps to the specified page without animation.
  /// 
  /// The [page] must be between 0 and [pageCount] - 1.
  void jumpToPage(int page) {
    assert(_state != null, 'PageGridController not attached to any grid');
    assert(page >= 0, 'Page index must be non-negative');
    
    if (_state == null) return;
    assert(page < pageCount, 'Page index $page is out of range [0, ${pageCount - 1}]');
    
    _state!.jumpToPage(page);
  }
  
  // Package-private methods for internal use
  @internal
  void attach(PageGridControllerState state) {
    assert(_state == null, 'PageGridController already attached to a grid');
    _state = state;
    // Defer initial notification to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
  
  @internal
  void detach(PageGridControllerState state) {
    assert(_state == state, 'PageGridController detached from wrong grid');
    _state = null;
  }
  
  @internal
  void notifyPageChanged() {
    notifyListeners();
  }
}