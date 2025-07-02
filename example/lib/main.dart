import 'dart:math';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/rendering/sliver.dart';
import 'package:flutter/src/rendering/sliver_grid.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollBehavior().copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
        overscroll: true,
        physics: AlwaysScrollableScrollPhysics(),
        scrollbars: true,
        platform: TargetPlatform.android,
      ),
      child: MaterialApp(
        home: Scaffold(
          // body: GridView.count(
          //   scrollDirection: Axis.horizontal,
          //   crossAxisCount: 10,
          //   childAspectRatio: 1,
          //   mainAxisSpacing: 16,

          //   children: [
          //     for (int i = 0; i < 100; i++) SizedBox(width: 64, height: 64, child: Text("$i")),
          //   ],
          // ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return NomoPageGrid(
                rows: 8,
                columns: 4,
                itemSize: 64,
                maxWidth: constraints.maxWidth,
                items: {
                  0: Container(
                    color: Colors.red,
                  ),
                  1: Container(
                    color: Colors.yellow,
                  ),
                  3: Container(
                    color: Colors.blue,
                  ),
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class NomoPageGrid extends StatefulWidget {
  final int rows;
  final int columns;
  final double itemSize;
  final double maxWidth;

  final Map<int, Widget> items;

  const NomoPageGrid({
    super.key,
    required this.rows,
    required this.columns,
    required this.itemSize,
    required this.maxWidth,
    required this.items,
  });

  @override
  State<NomoPageGrid> createState() => _NomoPageGridState();
}

class _NomoPageGridState extends State<NomoPageGrid> {
  late final PageGridNotifier pageGridNotifier = PageGridNotifier(
    viewportWidth: widget.maxWidth,
    columns: widget.columns,
    rows: widget.rows,
    initalItems: widget.items,
    itemSize: widget.itemSize,
  );

  @override
  void dispose() {
    pageGridNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
            },
          ),
          child: GridView.builder(
            physics: PageScrollPhysics(),
            scrollDirection: Axis.horizontal,
            controller: pageGridNotifier.controller,
            gridDelegate: NomoPageGridDelegate(
              rows: widget.rows,
              columns: widget.columns,
              itemSize: 64,
            ),
            dragStartBehavior: DragStartBehavior.down,
            findChildIndexCallback: (key) {
              print("Find Child Index");
            },
            cacheExtent: widget.maxWidth * 3,
            itemBuilder: (context, index) {
              print("Rebuilding $index");
              final item = widget.items[index];

              return PageGridItem(
                index: index,
                pageGridNotifier: pageGridNotifier,
                child: item,
              );
            },
            // semanticChildCount: rows * columns * 2,
            itemCount: widget.rows * widget.columns * 3,
          ),
        ),
        AnimationPreviewOverlay(pageGridNotifier: pageGridNotifier),
        Positioned(
          right: 0,
          width: 24,
          top: 0,
          bottom: 0,
          child: ListenableBuilder(
            listenable: Listenable.merge([
              pageGridNotifier.isDragging,
              pageGridNotifier.pageNotifier,
            ]),
            builder: (context, child) {
              if (pageGridNotifier.pageNotifier.value >= pageGridNotifier.maxPages - 1) {
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
    );
  }
}

class NomoPageGridLayout extends SliverGridLayout {
  final int rows;
  final int columns;
  final double crossAxisExtent;
  final double mainAxisExtent;
  final double maxItemSize;

  late final double itemWidth;
  late final double itemHeight;

  NomoPageGridLayout({
    required this.maxItemSize,
    required this.rows,
    required this.columns,
    required this.crossAxisExtent,
    required this.mainAxisExtent,
  }) {
    itemWidth = mainAxisExtent / columns;
    itemHeight = crossAxisExtent / rows;
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

    double mainAxisOffset = col * itemWidth + page * mainAxisExtent;

    final double crossAxisOffset = row * itemHeight;

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
    print("Max $max");
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
      maxItemSize: 64,
      crossAxisExtent: constraints.crossAxisExtent,
      mainAxisExtent: constraints.viewportMainAxisExtent,
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

class PageGridItem extends StatelessWidget {
  final int index;
  final Widget? child;
  final PageGridNotifier pageGridNotifier;

  const PageGridItem({
    required this.index,
    required this.child,
    required this.pageGridNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: pageGridNotifier.notifierMap[index]!,
      builder: (context, itemChild, placeholer) {
        if (itemChild == null) return placeholer!;
        return DragTarget<int>(
          onAcceptWithDetails: (details) => pageGridNotifier.onItemReceive(index, details.data),
          builder: (context, candidateData, rejectedData) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 64, maxWidth: 64),
                child: LongPressDraggable<int>(
                  data: index,
                  onDragUpdate: pageGridNotifier.onChildDragUpdate,
                  onDragStarted: () {
                    pageGridNotifier.isDragging.value = true;
                  },
                  onDragCompleted: () {
                    pageGridNotifier.isDragging.value = false;
                  },
                  onDraggableCanceled: (_, _) {
                    pageGridNotifier.isDragging.value = false;
                  },
                  feedback: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 64, maxWidth: 64),
                    child: itemChild,
                  ),
                  childWhenDragging: SizedBox.shrink(),
                  child: itemChild,
                ),
              ),
            );
          },
        );
      },
      child: DragTarget<int>(
        onAcceptWithDetails: (details) =>
            pageGridNotifier.onPlaceHolderReceive(index, details.data),

        builder: (context, candidateData, rejectedData) {
          return switch (candidateData.isNotEmpty) {
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
            false => SizedBox.shrink(
              //    key: ValueKey('empty $index'),
            ),
          };
        },
      ),
    );
  }
}

class PageGridNotifier {
  final int rows;
  final int columns;
  final Map<int, Widget> initalItems;

  final double viewportWidth;
  final double itemSize;

  int get childrenPerPage => rows * columns;

  final controller = ScrollController();
  final pageNotifier = ValueNotifier(0);
  final isDragging = ValueNotifier(false);

  // Index of the item the user is currently hovering over.
  final hoveredIndex = ValueNotifier<int?>(null);

  // Map of {itemIndex: targetIndex} for items that need to animate.
  final animationPreviewMap = ValueNotifier<Map<int, int>>({});

  final showRightPageScrollIndicator = ValueNotifier(false);

  late final notifierMap = {
    for (int i = 0; i < maxPages * childrenPerPage; i++)
      i: ValueNotifier<Widget?>(
        initalItems[i],
      ),
  };

  PageGridNotifier({
    required this.viewportWidth,
    required this.initalItems,
    required this.rows,
    required this.columns,
    required this.itemSize,
  }) {
    controller.addListener(onScrollPositionChanged);
    hoveredIndex.addListener(_onHoverIndexChanged);
  }

  int maxPages = 3;

  bool _enteredRightSide = false;
  bool _enteredLeftSide = false;

  void dispose() {
    pageNotifier.dispose();
    isDragging.dispose();
    hoveredIndex.dispose();
    animationPreviewMap.dispose();
    controller
      ..removeListener(onScrollPositionChanged)
      ..dispose();
  }

  void _onHoverIndexChanged() {
    final newHoverIndex = hoveredIndex.value;

    if (newHoverIndex == null) {
      animationPreviewMap.value = {};
      return;
    }

    // This logic is a "dry run" of onItemReceive.
    // It calculates the best push but only populates the animation map.
    final pushDirections = [
      [0, 1],
      [0, -1],
      [1, 0],
      [-1, 0],
    ];
    var possiblePushes = <({List<int> direction, List<int> chain})>[];

    for (final direction in pushDirections) {
      final chain = _getPushChain(newHoverIndex, direction);
      if (chain != null && chain.isNotEmpty) {
        possiblePushes.add((direction: direction, chain: chain));
      }
    }

    if (possiblePushes.isEmpty) {
      animationPreviewMap.value = {};
      return;
    }

    possiblePushes.sort((a, b) => a.chain.length.compareTo(b.chain.length));
    final bestPush = possiblePushes.first;
    final direction = bestPush.direction;
    final chain = bestPush.chain;
    final page = newHoverIndex ~/ childrenPerPage;

    final newAnimations = <int, int>{};
    for (final indexToMove in chain) {
      final targetIndex = _getIndexInDirection(indexToMove, direction, page);
      if (targetIndex != -1) {
        newAnimations[indexToMove] = targetIndex;
      }
    }
    animationPreviewMap.value = newAnimations;
  }

  Offset getOffsetForIndex(int index) {
    final page = index ~/ childrenPerPage;
    final pageIndex = index % childrenPerPage;
    final row = pageIndex ~/ columns;
    final col = pageIndex % columns;

    final pageOffset = page * viewportWidth;

    return Offset(
      pageOffset + (col * itemSize) - controller.offset,
      row * itemSize,
    );
  }

  void onScrollPositionChanged() {
    final page = (controller.offset / viewportWidth).ceil();
    pageNotifier.value = page;
  }

  void onPlaceHolderReceive(int newPosition, int oldPosition) {
    // Handles dropping an item onto an empty cell.
    final itemChild = notifierMap[oldPosition]?.value;
    notifierMap[oldPosition]?.value = null;
    notifierMap[newPosition]?.value = itemChild;
    print("Moved from $oldPosition to empty spot $newPosition");
  }

  void onItemReceive(int newPosition, int oldPosition) {
    if (newPosition == oldPosition) return;

    final draggedItem = notifierMap[oldPosition]!.value!;
    final itemAtNewPosition = notifierMap[newPosition]!.value;

    final pushDirections = [
      [0, 1], // Right
      [0, -1], // Left
      [1, 0], // Down
      [-1, 0], // Up
    ];

    // Temporarily remove the dragged item from its original position.
    notifierMap[oldPosition]!.value = null;

    // Use a list of records with named fields for clarity.
    var possiblePushes = <({List<int> direction, List<int> chain})>[];

    for (final direction in pushDirections) {
      final chain = _getPushChain(newPosition, direction);
      if (chain != null && chain.isNotEmpty) {
        // Add a named record to the list.
        possiblePushes.add((direction: direction, chain: chain));
      }
    }

    if (possiblePushes.isEmpty) {
      // If no pushes are possible (item is "boxed in"), perform a swap.
      notifierMap[oldPosition]!.value = itemAtNewPosition;
      notifierMap[newPosition]!.value = draggedItem;
      print("Swap occurred between $oldPosition and $newPosition");
      return;
    }

    // Find the best push (the one with the shortest chain of items to move).
    possiblePushes.sort((a, b) => a.chain.length.compareTo(b.chain.length));
    final bestPush = possiblePushes.first;
    final direction = bestPush.direction;
    final chain = bestPush.chain;
    final page = newPosition ~/ childrenPerPage;

    // Execute the push by moving each item in the chain.
    for (final indexToMove in chain.reversed) {
      final item = notifierMap[indexToMove]!.value;
      final targetIndex = _getIndexInDirection(indexToMove, direction, page);
      if (targetIndex != -1) {
        notifierMap[targetIndex]!.value = item;
      }
    }

    // Place the dragged item in the newly freed spot.
    notifierMap[newPosition]!.value = draggedItem;
    print("Pushed from $newPosition with chain of length ${chain.length} in direction $direction");
  }

  // Calculates the chain of items that would be pushed starting from an index.
  // Returns the list of indices in the chain, or null if a push is not possible.
  List<int>? _getPushChain(int startIndex, List<int> direction) {
    final page = startIndex ~/ childrenPerPage;
    final chain = <int>[];
    var currentIndex = startIndex;

    while (true) {
      final coords = _getCoords(currentIndex, page);
      if (coords == null) return null; // Index is not on the current page.

      if (notifierMap[currentIndex]?.value == null) {
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

  // Helper to get (row, col) from an index on a given page.
  List<int>? _getCoords(int index, int page) {
    final int pageStartIndex = page * childrenPerPage;
    if (index < pageStartIndex || index >= pageStartIndex + childrenPerPage) {
      return null; // Not on this page
    }
    final pageIndex = index % childrenPerPage;
    final row = pageIndex ~/ columns;
    final col = pageIndex % columns;
    return [row, col];
  }

  // Helper to get index in a direction. Returns -1 if out of bounds.
  int _getIndexInDirection(int fromIndex, List<int> direction, int page) {
    final coords = _getCoords(fromIndex, page);
    if (coords == null) return -1;

    final newRow = coords[0] + direction[0];
    final newCol = coords[1] + direction[1];

    // Check boundaries
    if (newRow < 0 || newRow >= rows || newCol < 0 || newCol >= columns) {
      return -1;
    }

    final pageStartIndex = page * childrenPerPage;
    return pageStartIndex + newRow * columns + newCol;
  }

  void onChildDragUpdate(DragUpdateDetails dragUpdate) {
    final globalOffset = dragUpdate.globalPosition;

    print(globalOffset.dx);

    if (viewportWidth - globalOffset.dx < 32) {
      if (_enteredRightSide) return;
      _enteredRightSide = true;
      Future.delayed(
        const Duration(seconds: 1),
        () {
          if (_enteredRightSide) {
            controller.animateTo(
              controller.offset + viewportWidth,
              duration: const Duration(milliseconds: 140),
              curve: Curves.fastOutSlowIn,
            );
          }
        },
      );

      print("Righside");
      return;
    }

    if (globalOffset.dx < 32) {
      if (_enteredLeftSide) return;
      _enteredLeftSide = true;
      Future.delayed(
        const Duration(seconds: 1),
        () {
          if (_enteredLeftSide) {
            controller.animateTo(
              controller.offset - viewportWidth,
              duration: const Duration(milliseconds: 140),
              curve: Curves.fastOutSlowIn,
            );
          }
        },
      );

      print("Righside");
      return;
    }
    _enteredLeftSide = false;
    _enteredRightSide = false;
  }
}

class AnimationPreviewOverlay extends StatelessWidget {
  final PageGridNotifier pageGridNotifier;

  const AnimationPreviewOverlay({super.key, required this.pageGridNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<int, int>>(
      valueListenable: pageGridNotifier.animationPreviewMap,
      builder: (context, animationMap, _) {
        return Stack(
          children: [
            for (final entry in animationMap.entries)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: pageGridNotifier.getOffsetForIndex(entry.value).dx,
                top: pageGridNotifier.getOffsetForIndex(entry.value).dy,
                child: SizedBox(
                  width: pageGridNotifier.itemSize,
                  height: pageGridNotifier.itemSize,
                  child: pageGridNotifier.notifierMap[entry.key]!.value!,
                ),
              ),
          ],
        );
      },
    );
  }
}
