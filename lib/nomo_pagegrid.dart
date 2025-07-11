import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'src/page_grid_controller.dart';
import 'src/page_grid_controller_state.dart';
export 'src/page_grid_controller.dart';

/// Represents the edge navigation state for page transitions.
///
/// Used internally to indicate which edge (left or right) is being navigated
/// when transitioning between pages in the grid.
enum EdgeNavigationState {
  /// Navigation from the left edge
  left,

  /// Navigation from the right edge
  right,
}

/// A customizable grid widget with drag-and-drop functionality and page-based navigation.
///
/// [NomoPageGrid] creates a grid layout where items can be dragged and reordered
/// by long-pressing and dragging them to new positions. The grid supports multiple
/// pages that users can navigate between by swiping horizontally.
///
/// ## Features:
/// - **Drag and Drop**: Long-press any item to drag it to a new position
/// - **Smart Displacement**: Items automatically move out of the way when dragging
/// - **Page Navigation**: Swipe left/right to navigate between pages
/// - **Customizable Layout**: Configure rows, columns, and item sizes
/// - **Empty Slots**: Supports grids with empty positions
/// - **Controller Support**: Use [PageGridController] for programmatic control
///
/// ## Basic Usage:
/// ```dart
/// NomoPageGrid(
///   rows: 3,
///   columns: 3,
///   itemSize: Size(64, 64),
///   items: {
///     0: Container(color: Colors.red),
///     1: Container(color: Colors.blue),
///     2: Container(color: Colors.green),
///   },
///   onChanged: (newItems) {
///     setState(() => items = newItems);
///   },
/// )
/// ```
///
/// ## With Controller:
/// ```dart
/// final controller = PageGridController();
///
/// NomoPageGrid(
///   controller: controller,
///   rows: 4,
///   columns: 4,
///   itemSize: Size(80, 80),
///   items: items,
///   onChanged: (newItems) => setState(() => items = newItems),
/// )
///
/// // Navigate programmatically
/// controller.nextPage();
/// controller.previousPage();
/// controller.animateToPage(2);
/// ```
///
/// The widget automatically calculates the number of pages based on the total
/// number of items and the grid dimensions (rows × columns per page).
class NomoPageGrid extends StatelessWidget {
  /// Number of rows in the grid per page.
  ///
  /// Must be a positive integer. Together with [columns], this determines
  /// how many items can fit on a single page.
  final int rows;

  /// Number of columns in the grid per page.
  ///
  /// Must be a positive integer. Together with [rows], this determines
  /// how many items can fit on a single page.
  final int columns;

  /// The size of each grid item.
  ///
  /// All items in the grid will have this exact size. The total grid size
  /// is calculated based on this size multiplied by the number of rows/columns.
  final Size itemSize;

  /// Optional fixed width for the grid.
  ///
  /// If not specified, the grid will use the maximum available width from
  /// its parent constraints. Useful for centering the grid or limiting its width.
  final double? width;

  /// Optional fixed height for the grid.
  ///
  /// If not specified, the grid will use the maximum available height from
  /// its parent constraints. When placed in an unbounded height context
  /// (e.g., inside a Column), the grid will automatically calculate its
  /// height based on the number of rows, item size, and cross-axis spacing:
  /// `height = rows * itemSize.height + (rows - 1) * crossAxisSpacing`
  /// 
  /// For more control, you can:
  /// - Provide an explicit height value
  /// - Wrap the grid in a SizedBox with a specific height
  /// - Use Expanded when inside a Column or Flex widget
  final double? height;

  /// The amount of wobble effect applied to displaced items.
  ///
  /// When an item is displaced by dragging another item, it will wobble
  /// with this amplitude (in logical pixels). Defaults to 3.0.
  /// Set to 0 to disable the wobble effect.
  final double wobbleAmount;

  /// Map of items to display in the grid.
  ///
  /// The key represents the position index (0-based) and the value is the
  /// widget to display at that position. Empty positions (missing keys) will
  /// show as empty slots in the grid.
  ///
  /// Position indices are calculated as: `index = page * (rows * columns) + row * columns + column`
  final Map<int, Widget> items;

  /// Callback invoked when items are reordered through drag-and-drop.
  ///
  /// The callback receives the new item arrangement as a Map where keys
  /// are position indices and values are the widgets. You should update
  /// your state with these new positions to persist the changes.
  ///
  /// Example:
  /// ```dart
  /// onChanged: (newItems) {
  ///   setState(() => items = newItems);
  /// }
  /// ```
  final void Function(Map<int, Widget> newItems)? onChanged;

  /// Optional controller for programmatic page navigation.
  ///
  /// Use [PageGridController] to navigate between pages programmatically,
  /// get the current page, or listen to page changes.
  ///
  /// See [PageGridController] for more details.
  final PageGridController? controller;
  
  /// The spacing between items along the main axis (horizontal).
  ///
  /// Defaults to 0.0. This adds space between columns in the grid.
  final double mainAxisSpacing;
  
  /// The spacing between items along the cross axis (vertical).
  ///
  /// Defaults to 0.0. This adds space between rows in the grid.
  final double crossAxisSpacing;

  const NomoPageGrid({
    super.key,
    required this.rows,
    required this.columns,
    required this.itemSize,
    required this.items,
    this.width,
    this.height,
    this.wobbleAmount = 3,
    this.onChanged,
    this.controller,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the required height based on grid configuration with spacing
        final calculatedHeight = rows * itemSize.height + 
                                (rows > 1 ? (rows - 1) * crossAxisSpacing : 0);
        
        // Calculate the required width based on grid configuration with spacing
        final calculatedWidth = columns * itemSize.width + 
                               (columns > 1 ? (columns - 1) * mainAxisSpacing : 0);
        
        // Determine the appropriate height to use
        final effectiveHeight = height ?? (constraints.maxHeight.isFinite 
            ? constraints.maxHeight 
            : calculatedHeight);
            
        // Determine the appropriate width to use
        final effectiveWidth = width ?? (constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : calculatedWidth);
        
        return _NomoPageGrid(
          rows: rows,
          columns: columns,
          itemSize: itemSize,
          items: items,
          width: effectiveWidth,
          height: effectiveHeight,
          wobbleAmount: wobbleAmount,
          onChanged: onChanged,
          controller: controller,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        );
      },
    );
  }
}

/// A sliver version of [NomoPageGrid] that can be used within [CustomScrollView]
/// and other sliver-based scrollable widgets.
///
/// This widget wraps the standard [NomoPageGrid] in a [SliverToBoxAdapter],
/// making it compatible with sliver layouts while maintaining all the
/// drag-and-drop functionality of the original widget.
///
/// The [height] parameter is required for sliver context to properly
/// size the widget along the scroll axis.
///
/// Example usage:
/// ```dart
/// CustomScrollView(
///   slivers: [
///     SliverAppBar(title: Text('My App')),
///     SliverNomoPageGrid(
///       rows: 3,
///       columns: 3,
///       itemSize: Size(64, 64),
///       height: 400,
///       items: {
///         0: Container(color: Colors.red),
///         1: Container(color: Colors.blue),
///       },
///       onChanged: (newItems) => setState(() => items = newItems),
///     ),
///     SliverList(
///       delegate: SliverChildBuilderDelegate(
///         (context, index) => ListTile(title: Text('Item $index')),
///       ),
///     ),
///   ],
/// )
/// ```
class SliverNomoPageGrid extends StatelessWidget {
  /// Number of rows in the grid
  final int rows;

  /// Number of columns in the grid
  final int columns;

  /// Size of each item in the grid
  final Size itemSize;

  /// Required height of the sliver widget
  final double? height;

  /// Amount of wobble effect when items are displaced (default: 3)
  final double wobbleAmount;

  /// Map of items where key is the position index and value is the widget
  final Map<int, Widget> items;

  /// Callback when items are reordered through drag-and-drop
  final void Function(Map<int, Widget> newItems)? onChanged;

  /// Optional controller for programmatic page navigation
  final PageGridController? controller;

  const SliverNomoPageGrid({
    super.key,
    required this.rows,
    required this.columns,
    required this.itemSize,
    required this.items,
    this.height,
    this.wobbleAmount = 3,
    this.onChanged,
    this.controller,
  }) : assert(
         height != null && height > 0,
         'SliverNomoPageGrid requires a positive height value',
       );

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: _SliverNomoPageGridContent(
        rows: rows,
        columns: columns,
        itemSize: itemSize,
        height: height!,
        wobbleAmount: wobbleAmount,
        items: items,
        onChanged: onChanged,
        controller: controller,
      ),
    );
  }
}

class _SliverNomoPageGridContent extends StatefulWidget {
  final int rows;
  final int columns;
  final Size itemSize;
  final double height;
  final double wobbleAmount;
  final Map<int, Widget> items;
  final void Function(Map<int, Widget> newItems)? onChanged;
  final PageGridController? controller;

  const _SliverNomoPageGridContent({
    required this.rows,
    required this.columns,
    required this.itemSize,
    required this.height,
    required this.wobbleAmount,
    required this.items,
    required this.onChanged,
    this.controller,
  });

  @override
  State<_SliverNomoPageGridContent> createState() => _SliverNomoPageGridContentState();
}

class _SliverNomoPageGridContentState extends State<_SliverNomoPageGridContent> {
  bool _isHorizontalScrollActive = false;
  final GlobalKey _gridKey = GlobalKey();

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _isHorizontalScrollActive = false;
    } else if (notification is ScrollEndNotification) {
      _isHorizontalScrollActive = false;
    } else if (notification is UserScrollNotification) {
      final direction = notification.direction;
      if (direction == ScrollDirection.idle) {
        _isHorizontalScrollActive = false;
      }
    }

    return _isHorizontalScrollActive;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: SizedBox(
        height: widget.height,
        child: _SliverCoordinateTransformer(
          child: NomoPageGrid(
            key: _gridKey,
            rows: widget.rows,
            columns: widget.columns,
            itemSize: widget.itemSize,
            items: widget.items,
            height: widget.height,
            wobbleAmount: widget.wobbleAmount,
            onChanged: widget.onChanged,
            controller: widget.controller,
          ),
        ),
      ),
    );
  }
}

class _SliverCoordinateTransformer extends StatelessWidget {
  final Widget child;

  const _SliverCoordinateTransformer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        // This wrapper ensures drag coordinates are properly transformed
        // relative to the sliver viewport when used in CustomScrollView
        return child;
      },
    );
  }
}

class _NomoPageGrid extends StatefulWidget {
  final int rows;
  final int columns;
  final Size itemSize;
  final double width;
  final double height;
  final double wobbleAmount;
  final Map<int, Widget> items;
  final void Function(Map<int, Widget> newItems)? onChanged;
  final PageGridController? controller;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  
  _NomoPageGrid({
    required this.rows,
    required this.columns,
    required this.itemSize,
    required this.wobbleAmount,
    required this.items,
    required this.width,
    required this.height,
    required this.onChanged,
    this.controller,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
  }) : assert(
          height.isFinite && height > 0,
          'NomoPageGrid requires a finite positive height. '
          'Either provide an explicit height parameter or ensure the widget '
          'is placed in a container with bounded height constraints.',
        ),
        assert(
          width.isFinite && width > 0,
          'NomoPageGrid requires a finite positive width. '
          'Either provide an explicit width parameter or ensure the widget '
          'is placed in a container with bounded width constraints.',
        );

  @override
  State<_NomoPageGrid> createState() => _NomoPageGridState();
}

class _NomoPageGridState extends State<_NomoPageGrid> implements PageGridControllerState {
  final GlobalKey _stackKey = GlobalKey();

  late final PageGridNotifier pageGridNotifier = PageGridNotifier(
    viewportWidth: widget.width,
    viewportHeight: widget.height,
    columns: widget.columns,
    rows: widget.rows,
    initalItems: widget.items,
    itemSize: widget.itemSize,
    wobbleAmount: widget.wobbleAmount,
    onChanged: widget.onChanged,
    mainAxisSpacing: widget.mainAxisSpacing,
    crossAxisSpacing: widget.crossAxisSpacing,
  );

  @override
  void initState() {
    super.initState();
    widget.controller?.attach(this);
    pageGridNotifier.pageNotifier.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    pageGridNotifier.pageNotifier.removeListener(_onPageChanged);
    widget.controller?.detach(this);
    pageGridNotifier.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    widget.controller?.notifyPageChanged();
  }

  @override
  int get currentPage => pageGridNotifier.pageNotifier.value;

  @override
  int get pageCount => pageGridNotifier.pageCountNotifier.value;

  @override
  Future<void> animateToPage(int page, {required Duration duration, required Curve curve}) async {
    final targetOffset = page * widget.width;
    await pageGridNotifier.controller.animateTo(
      targetOffset,
      duration: duration,
      curve: curve,
    );
  }

  @override
  void jumpToPage(int page) {
    final targetOffset = page * widget.width;
    pageGridNotifier.controller.jumpTo(targetOffset);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: widget.height,
        maxHeight: widget.height,
        minWidth: widget.width,
        maxWidth: widget.width,
      ),
      child: Stack(
        key: _stackKey,
        children: [
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
              },
            ),
            child: ValueListenableBuilder(
              valueListenable: pageGridNotifier.pageCountNotifier,
              builder: (context, pageCount, child) {
                return GridView.builder(
                physics: PageScrollPhysics(),
                scrollDirection: Axis.horizontal,
                controller: pageGridNotifier.controller,
                gridDelegate: NomoPageGridDelegate(
                  rows: widget.rows,
                  columns: widget.columns,
                  itemSize: widget.itemSize.width,  // Use actual item width
                  mainAxisSpacing: widget.mainAxisSpacing,
                  crossAxisSpacing: widget.crossAxisSpacing,
                ),
                dragStartBehavior: DragStartBehavior.down,

                cacheExtent: widget.width * pageCount,
                itemBuilder: (context, index) {
                  final item = widget.items[index];

                  return PageGridItem(
                    index: index,
                    pageGridNotifier: pageGridNotifier,
                    gridStackKey: _stackKey,
                    child: item,
                  );
                },
                itemCount: widget.rows * widget.columns * pageCount,
              );
            },
          ),
        ),
        Positioned(
          right: 0,
          width: 24,
          top: 0,
          bottom: 0,
          child: ListenableBuilder(
            listenable: Listenable.merge([
              pageGridNotifier.isDragging,
              pageGridNotifier.pageNotifier,
              pageGridNotifier.pageCountNotifier,
            ]),
            builder: (context, child) {
              final currentPage = pageGridNotifier.pageNotifier.value;
              final totalPages = pageGridNotifier.pageCountNotifier.value;
              final isLastPage = currentPage >= totalPages - 1;

              if (isLastPage) {
                return SizedBox.shrink();
              }
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 140),
                child: switch (pageGridNotifier.isDragging.value) {
                  false => SizedBox.shrink(
                    key: ValueKey('sddd'),
                  ),

                  true => Container(
                    key: ValueKey('draggable a'),
                    color: Colors.black12,
                  ),
                },
              );
            },
          ),
        ),
        Positioned(
          left: 0,
          width: 24,
          top: 0,
          bottom: 0,
          child: ListenableBuilder(
            listenable: Listenable.merge([
              pageGridNotifier.isDragging,
              pageGridNotifier.pageNotifier,
              pageGridNotifier.pageCountNotifier,
            ]),
            builder: (context, child) {
              if (pageGridNotifier.pageNotifier.value <= 0) return SizedBox.shrink();
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 140),
                child: switch (pageGridNotifier.isDragging.value) {
                  false => SizedBox.shrink(
                    key: ValueKey('aaa'),
                  ),

                  true => Container(
                    key: ValueKey('draggable'),
                    color: Colors.black12,
                  ),
                },
              );
            },
          ),
        ),
      ],
    ),
    );
  }
}

class NomoPageGridLayout extends SliverGridLayout {
  final int rows;
  final int columns;
  final double crossAxisExtent;
  final double mainAxisExtent;
  final double maxItemSize;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  late final double itemWidth;
  late final double itemHeight;

  NomoPageGridLayout({
    required this.maxItemSize,
    required this.rows,
    required this.columns,
    required this.crossAxisExtent,
    required this.mainAxisExtent,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
  }) {
    // Calculate item dimensions accounting for spacing
    itemWidth = columns > 1 
        ? (mainAxisExtent - (columns - 1) * mainAxisSpacing) / columns
        : mainAxisExtent;
    itemHeight = rows > 1
        ? (crossAxisExtent - (rows - 1) * crossAxisSpacing) / rows
        : crossAxisExtent;
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    // Which page are we on?
    final int page = (scrollOffset / mainAxisExtent).floor();
    return page * rows * columns;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    // Which page are we on?
    final int page = (scrollOffset / mainAxisExtent).floor();
    // Last index on this page
    return ((page + 1) * rows * columns) - 1;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final int itemsPerPage = rows * columns;
    final int page = index ~/ itemsPerPage;
    final int pageIndex = index % itemsPerPage;
    final int row = pageIndex ~/ columns;
    final int col = pageIndex % columns;

    // Calculate position with spacing
    double mainAxisOffset = col * (itemWidth + mainAxisSpacing) + page * mainAxisExtent;
    final double crossAxisOffset = row * (itemHeight + crossAxisSpacing);

    return SliverGridGeometry(
      scrollOffset: mainAxisOffset,
      crossAxisOffset: crossAxisOffset,
      mainAxisExtent: itemWidth,
      crossAxisExtent: itemHeight,
    );
  }

  @override
  double computeMaxScrollOffset(int childCount) {
    final int itemsPerPage = rows * columns;
    final int pageCount = (childCount / itemsPerPage).ceil();
    final max = pageCount * mainAxisExtent;

    return max;
  }
}

class NomoPageGridDelegate extends SliverGridDelegate {
  final int rows;
  final int columns;
  final double itemSize; // main axis size
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const NomoPageGridDelegate({
    required this.rows,
    required this.columns,
    required this.itemSize,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
  });

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    return NomoPageGridLayout(
      rows: rows,
      columns: columns,
      maxItemSize: itemSize,
      crossAxisExtent: constraints.crossAxisExtent,
      mainAxisExtent: constraints.viewportMainAxisExtent,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
    );
  }

  @override
  bool shouldRelayout(covariant NomoPageGridDelegate oldDelegate) {
    return oldDelegate.rows != rows ||
        oldDelegate.columns != columns ||
        oldDelegate.itemSize != itemSize ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing;
  }
}

class InnerPageGridItem extends StatefulWidget {
  final ItemPageSpot state;
  final int index;
  final PageGridNotifier pageGridNotifier;
  final GlobalKey gridStackKey;

  const InnerPageGridItem(this.state, this.index, this.pageGridNotifier, this.gridStackKey);

  @override
  State<InnerPageGridItem> createState() => _InnerPageGridItemState();
}

class _InnerPageGridItemState extends State<InnerPageGridItem> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final child = _WobbleWidget(
          wobbleAmount: widget.pageGridNotifier.wobbleAmount,
          direction: switch (widget.state) {
            EvadingPageSpot evading => evading.wobble ?? Offset.zero,

            _ => Offset.zero,
          },
          child: AnimatedContainer(
            duration: widget.state.isDropping ? Duration.zero : const Duration(milliseconds: 200),
            curve: Curves.ease,
            transform: switch (widget.state) {
              EvadingPageSpot evading => Matrix4.translationValues(
                evading.dx * constraints.maxWidth,
                evading.dy * constraints.maxHeight,
                0,
              ),
              _ => Matrix4.translationValues(0, 0, 0),
            },
            child: widget.state.item,
          ),
        );

        return DragTarget<int>(
          onAcceptWithDetails: (details) {
            // Convert global offset to local coordinates for consistency
            Offset localOffset = details.offset;

            final RenderBox? gridStackBox =
                widget.gridStackKey.currentContext?.findRenderObject() as RenderBox?;
            if (gridStackBox != null && gridStackBox.attached) {
              localOffset = gridStackBox.globalToLocal(details.offset);
            }

            widget.pageGridNotifier.onItemReceive(widget.index, details.data, localOffset);
          },
          onMove: (details) {
            if (widget.index == details.data) return;

            // Convert global offset to local coordinates relative to the grid
            // Use the grid Stack's RenderBox for accurate coordinate conversion
            Offset localOffset = details.offset;

            final RenderBox? gridStackBox =
                widget.gridStackKey.currentContext?.findRenderObject() as RenderBox?;
            if (gridStackBox != null && gridStackBox.attached) {
              localOffset = gridStackBox.globalToLocal(details.offset);
            }

            widget.pageGridNotifier.calcPreviewDisplacement(
              details.data,
              widget.index,
              localOffset,
            );
          },
          onWillAcceptWithDetails: (details) {
            return details.data != widget.index;
          },
          onLeave: (data) {
            widget.pageGridNotifier.clearDisplacementPreview();
          },
          builder: (context, candidateData, rejectedData) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: widget.pageGridNotifier.itemSize.height,
                  maxWidth: widget.pageGridNotifier.itemSize.width,
                ),
                child: LongPressDraggable(
                  data: widget.index,
                  onDragUpdate: widget.pageGridNotifier.onChildDragUpdate,
                  onDragStarted: () {
                    widget.pageGridNotifier.isDragging.value = true;
                  },

                  onDragEnd: (details) {
                    widget.pageGridNotifier.dragEnded();
                  },
                  childWhenDragging: SizedBox.shrink(),
                  feedback: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: widget.pageGridNotifier.itemSize.height,
                      maxWidth: widget.pageGridNotifier.itemSize.width,
                    ),
                    child: child,
                  ),
                  child: child,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class PageGridItem extends StatelessWidget {
  final int index;
  final Widget? child;
  final PageGridNotifier pageGridNotifier;
  final GlobalKey gridStackKey;

  const PageGridItem({
    required this.index,
    required this.child,
    required this.pageGridNotifier,
    required this.gridStackKey,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: pageGridNotifier.notifierMap[index]!,
      builder: (context, itemState, placeholer) {
        return switch (itemState) {
          EmptyPageSpot() => placeholer!,
          ItemPageSpot itemState => InnerPageGridItem(
            itemState,
            index,
            pageGridNotifier,
            gridStackKey,
          ),
        };
      },
      child: DragTarget<int>(
        onAcceptWithDetails: (details) =>
            pageGridNotifier.onPlaceHolderReceive(index, details.data),

        onLeave: (data) {
          // pageGridNotifier.clearDisplacementPreview();
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            child: switch (candidateData.isNotEmpty) {
              true => Center(
                key: ValueKey('placeholder $index $candidateData'),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 64, maxWidth: 64),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black12,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              false => SizedBox.shrink(),
            },
          );
        },
      ),
    );
  }
}

sealed class PageSpotState {
  const PageSpotState();

  Widget? get item => switch (this) {
    EmptyPageSpot _ => null,
    ItemPageSpot item => item.item,
  };
}

final class EmptyPageSpot extends PageSpotState {}

final class ItemPageSpot extends PageSpotState {
  final Widget item;
  final bool isDropping;

  const ItemPageSpot(this.item, {this.isDropping = false});
}

final class EvadingPageSpot extends ItemPageSpot {
  final int dx;
  final int dy;

  final Offset? wobble;

  const EvadingPageSpot(super.item, this.dx, this.dy, this.wobble, {super.isDropping = false});
}

enum PushDirection {
  FromTop(0, 1),
  FromLeft(-1, 0),
  FromRight(1, 0),
  FromBottom(0, -1);

  final int x;
  final int y;
  const PushDirection(this.x, this.y);
}

enum DirectionCompatibility {
  same(0),
  perpendicular(1),
  opposite(2);

  final int score;
  const DirectionCompatibility(this.score);
}

DirectionCompatibility getDirectionCompatibility(
  PushDirection preferred,
  PushDirection candidate,
) {
  // Same direction
  if (preferred == candidate) {
    return DirectionCompatibility.same;
  }

  // Opposite directions
  if ((preferred == PushDirection.FromLeft && candidate == PushDirection.FromRight) ||
      (preferred == PushDirection.FromRight && candidate == PushDirection.FromLeft) ||
      (preferred == PushDirection.FromTop && candidate == PushDirection.FromBottom) ||
      (preferred == PushDirection.FromBottom && candidate == PushDirection.FromTop)) {
    return DirectionCompatibility.opposite;
  }

  // Perpendicular directions
  return DirectionCompatibility.perpendicular;
}

typedef Position = ({int x, int y});

/// Manages the state and logic for the page grid widget
final class PageGridNotifier {
  final int rows;
  final int columns;
  final Map<int, Widget> initalItems;
  final Size itemSize;
  final double viewportWidth;
  final double viewportHeight;
  final double wobbleAmount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  int get childrenPerPage => rows * columns;
  double get targetWidth => viewportWidth / columns;
  double get targetHeight => viewportHeight / rows;

  final controller = ScrollController();
  final pageNotifier = ValueNotifier(0);
  final isDragging = ValueNotifier(false);
  final showRightPageScrollIndicator = ValueNotifier(false);

  final void Function(Map<int, Widget> newItems)? onChanged;

  late final ValueNotifier<int> pageCountNotifier;

  // Store the last push result from preview to ensure consistency with drop
  Map<int, int>? _lastPushResult;
  final Set<int> _activeEvasionIndexes = {};

  late final notifierMap = {
    for (int i = 0; i < maxPages * childrenPerPage; i++)
      i: ValueNotifier<PageSpotState>(
        switch (initalItems[i]) {
          Widget item => ItemPageSpot(item),
          _ => EmptyPageSpot(),
        },
      ),
  };

  Map<int, Widget> get currentItems => {
    for (final entry in notifierMap.entries)
      if (entry.value.value.item != null) entry.key: entry.value.value.item!,
  };

  PageGridNotifier({
    required this.viewportWidth,
    required this.viewportHeight,
    required this.initalItems,
    required this.rows,
    required this.columns,
    required this.itemSize,
    required this.wobbleAmount,
    required this.onChanged,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
  }) {
    final maxIndex = initalItems.isEmpty
        ? 0
        : initalItems.keys.reduce(
            (value, element) {
              return max(value, element);
            },
          );
    final pages = maxIndex == 0 ? 1 : (maxIndex / childrenPerPage).ceil();
    pageCountNotifier = ValueNotifier(pages);

    controller.addListener(onScrollPositionChanged);
  }

  int maxPages = 3;

  Timer? _edgeNavigationTimer;
  EdgeNavigationState? _currentEdgeState;

  static const Duration _initialNavigationDelay = Duration(milliseconds: 600);
  static const Duration _repeatNavigationDelay = Duration(milliseconds: 400);

  void addPage() {
    // TODO: addpage
  }

  void dispose() {
    _stopEdgeNavigation();
    pageNotifier.dispose();
    isDragging.dispose();
    controller
      ..removeListener(onScrollPositionChanged)
      ..dispose();
  }

  void onScrollPositionChanged() {
    final page = (controller.offset / viewportWidth).ceil();
    pageNotifier.value = page;
  }

  void onPlaceHolderReceive(int newPosition, int oldPosition) {
    // Handles dropping an item onto an empty cell.
    final itemState = notifierMap[oldPosition]?.value;

    if (itemState == null || itemState is EmptyPageSpot) return;

    notifierMap[oldPosition]?.value = EmptyPageSpot();
    notifierMap[newPosition]?.value = itemState;
    onItemsChanged();
  }

  void dragEnded() {
    _stopEdgeNavigation();
    isDragging.value = false;
    clearDisplacementPreview();
  }

  void onItemsChanged() {
    if (onChanged != null) onChanged!(currentItems);
  }

  void onItemReceive(int newPosition, int oldPosition, Offset offset) {
    if (newPosition == oldPosition) return;

    // Use the stored push result from preview to ensure consistency

    final pushResult =
        _lastPushResult ??
        _calculatePush(
          newPosition,
          oldPosition,
          _calculateEvasionDirectionFromHover(offset, newPosition),
        );

    if (pushResult == null) {
      return;
    }

    // Clear displacement preview immediately to prevent dragged item from animating
    clearDisplacementPreview();

    // Clear the stored result as it's been used
    _lastPushResult = null;

    // Handle swap
    final draggedItem = notifierMap[oldPosition]!.value;
    if (pushResult.length == 2 &&
        pushResult[oldPosition] == newPosition &&
        pushResult[newPosition] == oldPosition) {
      final itemAtNewPosition = notifierMap[newPosition]!.value;

      // Mark both items as dropping to prevent animation
      if (draggedItem is ItemPageSpot) {
        notifierMap[newPosition]!.value = ItemPageSpot(draggedItem.item, isDropping: true);
      }
      if (itemAtNewPosition is ItemPageSpot) {
        notifierMap[oldPosition]!.value = ItemPageSpot(itemAtNewPosition.item, isDropping: true);
      }

      onItemsChanged();

      // Clear isDropping flag after animation duration
      Future.delayed(const Duration(milliseconds: 200), () {
        if (notifierMap[newPosition]!.value is ItemPageSpot) {
          final item = notifierMap[newPosition]!.value as ItemPageSpot;
          notifierMap[newPosition]!.value = ItemPageSpot(item.item, isDropping: false);
        }
        if (notifierMap[oldPosition]!.value is ItemPageSpot) {
          final item = notifierMap[oldPosition]!.value as ItemPageSpot;
          notifierMap[oldPosition]!.value = ItemPageSpot(item.item, isDropping: false);
        }
      });

      return;
    }

    // Handle push - this should match the preview exactly
    final itemsToMove = <int, PageSpotState>{};
    for (final fromIndex in pushResult.keys) {
      if (fromIndex != oldPosition) {
        // Don't store the dragged item
        itemsToMove[fromIndex] = notifierMap[fromIndex]!.value;
      }
    }

    // Track all affected indices for clearing isDropping flag later
    final affectedIndices = <int>{};

    // Apply moves in the correct order with isDropping flag
    for (final entry in pushResult.entries) {
      final fromIndex = entry.key;
      final toIndex = entry.value;
      if (fromIndex != oldPosition) {
        // Don't move the dragged item yet
        final itemToMove = itemsToMove[fromIndex]!;
        if (itemToMove is ItemPageSpot) {
          notifierMap[toIndex]!.value = ItemPageSpot(itemToMove.item, isDropping: true);
          affectedIndices.add(toIndex);
        } else {
          notifierMap[toIndex]!.value = itemToMove;
        }
      }
    }

    // Place the dragged item at target position with isDropping flag
    if (draggedItem is ItemPageSpot) {
      notifierMap[newPosition]!.value = ItemPageSpot(draggedItem.item, isDropping: true);
      affectedIndices.add(newPosition);
    } else {
      notifierMap[newPosition]!.value = draggedItem;
    }

    // Clear the old position if it's not being used by another item
    if (!pushResult.containsValue(oldPosition)) {
      notifierMap[oldPosition]!.value = EmptyPageSpot();
    }

    onItemsChanged();

    // Clear isDropping flag after animation duration
    if (affectedIndices.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 200), () {
        for (final index in affectedIndices) {
          if (notifierMap[index]!.value is ItemPageSpot) {
            final item = notifierMap[index]!.value as ItemPageSpot;
            notifierMap[index]!.value = ItemPageSpot(item.item, isDropping: false);
          }
        }
      });
    }
  }

  // Used for debouncing animation of Displacement
  BigInt activeDisplacementCount = BigInt.zero;
  int? activeDisplacementTarget;
  // Used for debouncing calc of Displacement
  PushDirection? activePushDirection;

  void previewDisplacement(Map<int, int> pushResult, int targetIndex) async {
    activeDisplacementCount += BigInt.one;
    final saved = activeDisplacementCount;

    await Future.delayed(Duration(milliseconds: 200));
    if (saved != activeDisplacementCount) return;
    if (activeDisplacementTarget != targetIndex) return;

    /// Clear Spots not in path
    final toClear = _activeEvasionIndexes.difference(pushResult.keys.toSet());
    for (final index in toClear) {
      final value = notifierMap[index]!.value;
      if (value is EvadingPageSpot) {
        notifierMap[index]!.value = ItemPageSpot(value.item);
      }
    }
    _activeEvasionIndexes.clear();
    _activeEvasionIndexes.addAll(pushResult.keys);

    for (final entry in pushResult.entries) {
      final index = entry.key;
      final newIndex = entry.value;
      final oldPage = index ~/ childrenPerPage;
      final newPage = newIndex ~/ childrenPerPage;
      // Removed assertion - now supports cross-page displacement
      final oldCoords = getCoords(index, oldPage);
      final newCoords = getCoords(newIndex, newPage);
      
      // Calculate coordinate deltas including page offset
      var deltaCol = newCoords.x - oldCoords.x;
      var deltaRow = newCoords.y - oldCoords.y;
      
      // Add page offset when moving across pages
      if (oldPage != newPage) {
        final pageDelta = newPage - oldPage;
        // When moving to next/previous page, items need to account for page width
        deltaCol += pageDelta * columns;
      }
      Offset? wobbleDirection;
      // Normalize the direction
      if (deltaCol != 0 || deltaRow != 0) {
        final length = sqrt(
          deltaCol * deltaCol + deltaRow * deltaRow,
        );
        wobbleDirection = Offset(
          deltaCol / length,
          deltaRow / length,
        );
      }

      final notifier = notifierMap[index]!;
      notifier.value = EvadingPageSpot(
        (notifier.value as ItemPageSpot).item,
        deltaCol,
        deltaRow,
        wobbleDirection,
      );
    }
  }

  void calcPreviewDisplacement(int draggedIndex, int targetIndex, Offset hoverOffset) {
    final direction = _calculateEvasionDirectionFromHover(hoverOffset, targetIndex);
    if (direction == activePushDirection && targetIndex == activeDisplacementTarget) return;

    activePushDirection = direction;

    final pushResult = _calculatePush(targetIndex, draggedIndex, direction);
    if (pushResult != null) {
      activeDisplacementTarget = targetIndex;
      pushResult.remove(draggedIndex);
      // Store the push result for consistency during actual drop
      _lastPushResult = Map<int, int>.from(pushResult);
      _lastPushResult![draggedIndex] = targetIndex; // Re-add the dragged item

      previewDisplacement(pushResult, targetIndex);
    }
  }

  void clearDisplacementPreview() {
    print("Cleared");
    activeDisplacementCount = BigInt.zero;
    activeDisplacementTarget = null;
    activePushDirection = null;

    for (final index in _activeEvasionIndexes) {
      final value = notifierMap[index]!.value;
      if (value is EvadingPageSpot) {
        notifierMap[index]!.value = ItemPageSpot(value.item);
      }
    }
    _activeEvasionIndexes.clear();
  }

  PushDirection _calculateEvasionDirectionFromHover(Offset hoverOffset, int index) {
    hoverOffset = hoverOffset.translate(itemSize.width / 2, itemSize.height / 2);

    final page = index ~/ childrenPerPage;

    final position = getCoords(index, page);
    final offset = Offset(
      position.x * targetWidth + targetWidth / 2,
      position.y * targetHeight + targetHeight / 2,
    );

    // Calculate which side of the item we're hovering over
    final relativeX = offset.dx - hoverOffset.dx;
    final relativeY = offset.dy - hoverOffset.dy;

    if (relativeX.abs() > relativeY.abs()) {
      if (relativeX < 0) return PushDirection.FromLeft;
      if (relativeX > 0) return PushDirection.FromRight;
    } else {
      if (relativeY > 0) return PushDirection.FromTop;
      if (relativeY < 0) return PushDirection.FromBottom;
    }

    return PushDirection.FromLeft;
  }

  Map<int, int>? _calculatePush(
    int newPosition,
    int oldPosition,
    PushDirection preferedDirection,
  ) {
    final itemAtNewPosition = notifierMap[newPosition]!.value;

    // Case 1: Dropping on an empty spot, no push needed.
    if (itemAtNewPosition is EmptyPageSpot) {
      return {oldPosition: newPosition};
    }

    var bestPush = _getPushChain(newPosition, oldPosition, preferedDirection);
    var direction = preferedDirection;

    if (bestPush == null) {
      var possiblePushes = <({PushDirection direction, List<int> chain})>[];

      for (final direction in PushDirection.values) {
        final chain = _getPushChain(newPosition, oldPosition, direction);
        if (chain != null) {
          possiblePushes.add((direction: direction, chain: chain));
        }
      }

      if (possiblePushes.isNotEmpty) {
        possiblePushes.sort((a, b) {
          // First sort by chain length
          final lengthComparison = a.chain.length.compareTo(b.chain.length);
          if (lengthComparison != 0) return lengthComparison;

          // For equal lengths, prefer perpendicular over opposite directions
          final aCompat = getDirectionCompatibility(preferedDirection, a.direction);
          final bCompat = getDirectionCompatibility(preferedDirection, b.direction);
          return aCompat.score.compareTo(bCompat.score);
        });

        bestPush = possiblePushes.first.chain;
        direction = possiblePushes.first.direction;
      }
    }

    // If still no Push is found we swap
    if (bestPush == null) {
      return {oldPosition: newPosition, newPosition: oldPosition};
    }

    final page = newPosition ~/ childrenPerPage;

    final pushResult = <int, int>{};
    for (final indexToMove in bestPush.reversed) {
      final targetIndex = _getIndexInDirection(indexToMove, direction, page);
      if (targetIndex != -1) {
        pushResult[indexToMove] = targetIndex;
      }
    }
    pushResult[oldPosition] = newPosition;

    return pushResult;
  }

  List<int>? _getPushChain(int startIndex, int draggedIndex, PushDirection direction) {
    final page = startIndex ~/ childrenPerPage;
    final chain = <int>[];
    var currentIndex = startIndex;

    while (true) {
      final val = notifierMap[currentIndex]?.value;
      if (val is EmptyPageSpot || currentIndex == draggedIndex) {
        // Found an empty spot, the push is possible.
        break;
      }

      chain.add(currentIndex);

      final nextIndex = _getIndexInDirection(currentIndex, direction, page);
      if (nextIndex == -1) {
        // Reached the edge of the grid, push is not possible in this direction.
        return null;
      }
      currentIndex = nextIndex;
    }
    return chain;
  }

  Position getCoords(int index, int page) {
    final int pageStartIndex = page * childrenPerPage;
    if (index < pageStartIndex || index >= pageStartIndex + childrenPerPage) {
      throw UnimplementedError();
    }
    final pageIndex = index % childrenPerPage;
    final row = pageIndex ~/ columns;
    final col = pageIndex % columns;
    return (x: col, y: row);
  }

  int _getIndexInDirection(int fromIndex, PushDirection direction, int page) {
    final coords = getCoords(fromIndex, page);

    final newRow = coords.y + direction.y;
    final newCol = coords.x + direction.x;

    if (newRow < 0 || newRow >= rows || newCol < 0 || newCol >= columns) {
      return -1;
    }

    final pageStartIndex = page * childrenPerPage;
    return pageStartIndex + newRow * columns + newCol;
  }

  void _startEdgeNavigation(EdgeNavigationState edge) {
    _currentEdgeState = edge;

    // Initial navigation after delay
    _edgeNavigationTimer = Timer(_initialNavigationDelay, () {
      _navigateToEdge();

      // Setup repeating navigation
      _edgeNavigationTimer = Timer.periodic(_repeatNavigationDelay, (_) {
        _navigateToEdge();
      });
    });
  }

  void _stopEdgeNavigation() {
    _edgeNavigationTimer?.cancel();
    _edgeNavigationTimer = null;
    _currentEdgeState = null;
  }

  void _navigateToEdge() {
    if (_currentEdgeState == null) return;

    final currentPage = pageNotifier.value;
    final maxPage = pageCountNotifier.value - 1;

    if (_currentEdgeState == EdgeNavigationState.right && currentPage < maxPage) {
      controller.animateTo(
        controller.offset + viewportWidth,
        duration: const Duration(milliseconds: 140),
        curve: Curves.fastOutSlowIn,
      );
    } else if (_currentEdgeState == EdgeNavigationState.left && currentPage > 0) {
      controller.animateTo(
        controller.offset - viewportWidth,
        duration: const Duration(milliseconds: 140),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      // Stop navigation if we've reached the boundary
      _stopEdgeNavigation();
    }
  }

  void onChildDragUpdate(DragUpdateDetails dragUpdate) {
    final globalOffset = dragUpdate.globalPosition;

    // Edge detection zones: 32px for activation
    const edgeZone = 32.0;
    // Hysteresis zone: 40px to prevent oscillation
    const hysteresisZone = 40.0;

    final isInRightEdge = viewportWidth - globalOffset.dx < edgeZone;
    final isInLeftEdge = globalOffset.dx < edgeZone;
    final isOutsideHysteresis =
        globalOffset.dx > hysteresisZone && globalOffset.dx < viewportWidth - hysteresisZone;

    if (isInRightEdge) {
      if (_currentEdgeState != EdgeNavigationState.right) {
        _stopEdgeNavigation();
        _startEdgeNavigation(EdgeNavigationState.right);
      }
    } else if (isInLeftEdge) {
      if (_currentEdgeState != EdgeNavigationState.left) {
        _stopEdgeNavigation();
        _startEdgeNavigation(EdgeNavigationState.left);
      }
    } else if (isOutsideHysteresis && _currentEdgeState != null) {
      // Only stop navigation when clearly outside the hysteresis zone
      _stopEdgeNavigation();
    }
  }
}

// Wobble animation widget for displaced items
class _WobbleWidget extends StatefulWidget {
  final Widget child;
  final Offset direction;
  final double wobbleAmount;

  const _WobbleWidget({
    required this.child,
    required this.wobbleAmount,
    this.direction = Offset.zero,
  });

  @override
  State<_WobbleWidget> createState() => _WobbleWidgetState();
}

class _WobbleWidgetState extends State<_WobbleWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400), // Slower animation
      vsync: this,
    );

    _animation =
        Tween<double>(
          begin: -1.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeIn, // Smoother curve
          ),
        );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Create smooth back-and-forth motion in displacement direction
        final offsetX = widget.direction.dx * _animation.value * widget.wobbleAmount;
        final offsetY = widget.direction.dy * _animation.value * widget.wobbleAmount;

        return Transform.translate(
          offset: Offset(offsetX, offsetY),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
