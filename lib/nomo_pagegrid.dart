import 'dart:math';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/rendering/sliver.dart';
import 'package:flutter/src/rendering/sliver_grid.dart';

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
            findChildIndexCallback: (key) {},
            cacheExtent: widget.maxWidth * 3,
            itemBuilder: (context, index) {
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return ValueListenableBuilder(
          valueListenable: pageGridNotifier.notifierMap[index]!,
          builder: (context, itemChild, placeholer) {
            if (itemChild == null) return placeholer!;
            return DragTarget<int>(
              onAcceptWithDetails: (details) => pageGridNotifier.onItemReceive(index, details.data),
              onWillAcceptWithDetails: (details) {
                if (details.data != index) {
                  pageGridNotifier.previewDisplacement(details.data, index, details.offset);
                }
                return true;
              },
              onLeave: (data) {
                pageGridNotifier.clearDisplacementPreview();
              },
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
                      onDragEnd: (details) {
                        pageGridNotifier.dragEnded();
                      },
                      feedback: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 64, maxWidth: 64),
                        child: itemChild,
                      ),
                      childWhenDragging: SizedBox.shrink(),
                      child: ValueListenableBuilder<Map<int, int>?>(
                        valueListenable: pageGridNotifier.displacementPreview,
                        builder: (context, displacement, __) {
                          return ValueListenableBuilder<Set<int>>(
                            valueListenable: pageGridNotifier.excludeFromAnimation,
                            builder: (context, excludedPositions, __) {
                              return ValueListenableBuilder<Set<int>>(
                                valueListenable: pageGridNotifier.wobblingItems,
                                builder: (context, wobblingItemIndices, __) {
                                  Offset offset = Offset.zero;
                                  Duration duration;
                                  Widget child;

                                  // Don't animate positions that are excluded (recently dropped items)
                                  if (excludedPositions.contains(index)) {
                                    duration = Duration.zero;
                                  } else if (displacement == null) {
                                    duration = const Duration(milliseconds: 200);
                                  } else {
                                    duration = const Duration(milliseconds: 100);
                                  }

                                  // Only apply displacement if this position isn't excluded
                                  if (!excludedPositions.contains(index) &&
                                      displacement != null &&
                                      displacement.containsKey(index)) {
                                    final newIndex = displacement[index]!;

                                    final oldPage = index ~/ pageGridNotifier.childrenPerPage;
                                    final newPage = newIndex ~/ pageGridNotifier.childrenPerPage;

                                    if (oldPage == newPage) {
                                      final oldCoords = pageGridNotifier.getCoords(index, oldPage);
                                      final newCoords = pageGridNotifier.getCoords(
                                        newIndex,
                                        newPage,
                                      );

                                      if (oldCoords != null && newCoords != null) {
                                        final itemWidth = constraints.maxWidth;
                                        final itemHeight = constraints.maxHeight;

                                        final deltaCol = newCoords[1] - oldCoords[1];
                                        final deltaRow = newCoords[0] - oldCoords[0];
                                        offset = Offset(
                                          deltaCol * itemWidth,
                                          deltaRow * itemHeight,
                                        );
                                      }
                                    }
                                  }

                                  // Add wobble effect for displaced items
                                  child = itemChild;
                                  if (wobblingItemIndices.contains(index)) {
                                    // Calculate wobble direction based on displacement
                                    Offset wobbleDirection = Offset.zero;
                                    if (displacement != null && displacement.containsKey(index)) {
                                      final newIndex = displacement[index]!;
                                      final oldPage = index ~/ pageGridNotifier.childrenPerPage;
                                      final newPage = newIndex ~/ pageGridNotifier.childrenPerPage;

                                      if (oldPage == newPage) {
                                        final oldCoords = pageGridNotifier.getCoords(
                                          index,
                                          oldPage,
                                        );
                                        final newCoords = pageGridNotifier.getCoords(
                                          newIndex,
                                          newPage,
                                        );

                                        if (oldCoords != null && newCoords != null) {
                                          final deltaCol = newCoords[1] - oldCoords[1];
                                          final deltaRow = newCoords[0] - oldCoords[0];

                                          // Normalize the direction
                                          if (deltaCol != 0 || deltaRow != 0) {
                                            final length = math.sqrt(
                                              deltaCol * deltaCol + deltaRow * deltaRow,
                                            );
                                            wobbleDirection = Offset(
                                              deltaCol / length,
                                              deltaRow / length,
                                            );
                                          }
                                        }
                                      }
                                    }

                                    child = _WobbleWidget(
                                      child: itemChild,
                                      direction: wobbleDirection,
                                    );
                                  }

                                  return AnimatedContainer(
                                    duration: duration,
                                    curve: Curves.ease,
                                    transform: Matrix4.translationValues(offset.dx, offset.dy, 0),
                                    child: child,
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
          child: DragTarget<int>(
            onAcceptWithDetails: (details) =>
                pageGridNotifier.onPlaceHolderReceive(index, details.data),
            onWillAcceptWithDetails: (details) {
              pageGridNotifier.clearDisplacementPreview();
              return true;
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
                  false => SizedBox.shrink(
                    //    key: ValueKey('empty $index'),
                  ),
                },
              );
            },
          ),
        );
      },
    );
  }
}

class PageGridNotifier {
  final int rows;
  final int columns;
  final Map<int, Widget> initalItems;

  final double viewportWidth;

  int get childrenPerPage => rows * columns;

  final controller = ScrollController();
  final pageNotifier = ValueNotifier(0);
  final isDragging = ValueNotifier(false);
  // Removed lastDropTarget to fix flickering issue

  final showRightPageScrollIndicator = ValueNotifier(false);

  final displacementPreview = ValueNotifier<Map<int, int>?>(null);

  // Track positions that should not animate (recently dropped items)
  final excludeFromAnimation = ValueNotifier<Set<int>>({});
  
  // Track wobbling items for preview animation
  final wobblingItems = ValueNotifier<Set<int>>({});
  
  // Store the last push result from preview to ensure consistency with drop
  Map<int, int>? _lastPushResult;

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
  }) {
    controller.addListener(onScrollPositionChanged);
  }

  int maxPages = 3;

  bool _enteredRightSide = false;
  bool _enteredLeftSide = false;

  void dispose() {
    pageNotifier.dispose();
    isDragging.dispose();
    excludeFromAnimation.dispose();
    wobblingItems.dispose();
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
    final itemChild = notifierMap[oldPosition]?.value;
    notifierMap[oldPosition]?.value = null;
    notifierMap[newPosition]?.value = itemChild;
  }

  void dragEnded() {
    isDragging.value = false;
    clearDisplacementPreview();
    // Clear the exclusion list after a short delay to allow smooth completion
    Future.delayed(const Duration(milliseconds: 250), () {
      excludeFromAnimation.value = {};
    });
  }

  void onItemReceive(int newPosition, int oldPosition) {
    if (newPosition == oldPosition) return;

    final draggedItem = notifierMap[oldPosition]!.value!;
    final itemAtNewPosition = notifierMap[newPosition]!.value;

    // Use the stored push result from preview to ensure consistency
    final pushResult = _lastPushResult ?? _calculatePush(newPosition, oldPosition);

    if (pushResult == null) {
      return;
    }

    // Clear displacement preview immediately to prevent dragged item from animating
    clearDisplacementPreview();
    
    // Clear the stored result as it's been used
    _lastPushResult = null;

    // Mark the target position as excluded from animations
    final currentExclusions = Set<int>.from(excludeFromAnimation.value);
    currentExclusions.add(newPosition);
    excludeFromAnimation.value = currentExclusions;

    // Handle swap
    if (pushResult.length == 2 &&
        pushResult[oldPosition] == newPosition &&
        pushResult[newPosition] == oldPosition) {
      notifierMap[newPosition]!.value = draggedItem;
      notifierMap[oldPosition]!.value = itemAtNewPosition;
      return;
    }

    // Handle push - this should match the preview exactly
    final itemsToMove = <int, Widget?>{};  
    for (final fromIndex in pushResult.keys) {
      if (fromIndex != oldPosition) { // Don't store the dragged item
        itemsToMove[fromIndex] = notifierMap[fromIndex]!.value;
      }
    }

    // Apply moves in the correct order
    for (final entry in pushResult.entries) {
      final fromIndex = entry.key;
      final toIndex = entry.value;
      if (fromIndex != oldPosition) { // Don't move the dragged item yet
        notifierMap[toIndex]!.value = itemsToMove[fromIndex];
      }
    }

    // Place the dragged item at target position
    notifierMap[newPosition]!.value = draggedItem;
    
    // Clear the old position if it's not being used by another item
    if (!pushResult.containsValue(oldPosition)) {
      notifierMap[oldPosition]!.value = null;
    }
  }

  void previewDisplacement(int draggedIndex, int targetIndex, Offset hoverOffset) {
    final pushResult = _calculatePushWithEvasion(targetIndex, draggedIndex, hoverOffset);
    if (pushResult != null) {
      pushResult.remove(draggedIndex);
      
      // Store the push result for consistency during actual drop
      _lastPushResult = Map<int, int>.from(pushResult);
      _lastPushResult![draggedIndex] = targetIndex; // Re-add the dragged item mapping
      
      displacementPreview.value = pushResult;
      
      // Set wobbling items
      wobblingItems.value = pushResult.keys.toSet();
    }
  }

  void clearDisplacementPreview() {
    displacementPreview.value = null;
    wobblingItems.value = {};
  }

  Map<int, int>? _calculatePushWithEvasion(int newPosition, int oldPosition, Offset hoverOffset) {
    final itemAtNewPosition = notifierMap[newPosition]!.value;

    // Case 1: Dropping on an empty spot, no push needed.
    if (itemAtNewPosition == null) {
      return {oldPosition: newPosition};
    }

    // Calculate evasion direction based on hover position on target
    final evasionDirection = _calculateEvasionDirectionFromHover(hoverOffset);

    // Case 2: Try evasion first if we have a preferred direction
    if (evasionDirection != null) {
      final evasionChain = _getPushChain(newPosition, evasionDirection);
      if (evasionChain != null) {
        // Evasion is possible, use it
        final page = newPosition ~/ childrenPerPage;
        final pushResult = <int, int>{};
        for (final indexToMove in evasionChain.reversed) {
          final targetIndex = _getIndexInDirection(indexToMove, evasionDirection, page);
          if (targetIndex != -1) {
            pushResult[indexToMove] = targetIndex;
          }
        }
        pushResult[oldPosition] = newPosition;
        return pushResult;
      }
    }

    // Case 3: Fallback to original push logic if evasion fails
    return _calculatePush(newPosition, oldPosition);
  }

  List<int>? _calculateEvasionDirectionFromHover(Offset hoverOffset) {
    // hoverOffset is relative to the target widget (0,0 is top-left, 64,64 is bottom-right)
    const itemSize = 64.0; // Standard item size

    // Calculate which side of the item we're hovering over
    final relativeX = hoverOffset.dx / itemSize; // 0.0 = left edge, 1.0 = right edge
    final relativeY = hoverOffset.dy / itemSize; // 0.0 = top edge, 1.0 = bottom edge

    // Determine distances to each edge
    final distanceToLeft = relativeX;
    final distanceToRight = 1.0 - relativeX;
    final distanceToTop = relativeY;
    final distanceToBottom = 1.0 - relativeY;

    // Find the closest edge and evade in the opposite direction
    final minDistance = math.min(
      math.min(distanceToLeft, distanceToRight),
      math.min(distanceToTop, distanceToBottom),
    );

    if (minDistance == distanceToLeft) {
      // Hovering over left side, evade left
      return [0, -1]; // Left
    } else if (minDistance == distanceToRight) {
      // Hovering over right side, evade right
      return [0, 1]; // Right
    } else if (minDistance == distanceToTop) {
      // Hovering over top side, evade up
      return [-1, 0]; // Up
    } else if (minDistance == distanceToBottom) {
      // Hovering over bottom side, evade down
      return [1, 0]; // Down
    }

    return null; // Fallback
  }

  Map<int, int>? _calculatePush(int newPosition, int oldPosition) {
    final itemAtNewPosition = notifierMap[newPosition]!.value;

    // Case 1: Dropping on an empty spot, no push needed.
    if (itemAtNewPosition == null) {
      return {oldPosition: newPosition};
    }

    // Case 2: Pushing items
    final pushDirections = [
      [0, 1], // Right
      [0, -1], // Left
      [1, 0], // Down
      [-1, 0], // Up
    ];

    var possiblePushes = <({List<int> direction, List<int> chain})>[];

    for (final direction in pushDirections) {
      final chain = _getPushChain(newPosition, direction);
      if (chain != null) {
        possiblePushes.add((direction: direction, chain: chain));
      }
    }

    if (possiblePushes.isEmpty) {
      // Case 3: No valid push found, perform a swap.
      return {oldPosition: newPosition, newPosition: oldPosition};
    }

    possiblePushes.sort((a, b) => a.chain.length.compareTo(b.chain.length));
    final bestPush = possiblePushes.first;
    final direction = bestPush.direction;
    final chain = bestPush.chain;
    final page = newPosition ~/ childrenPerPage;

    final pushResult = <int, int>{};
    for (final indexToMove in chain.reversed) {
      final targetIndex = _getIndexInDirection(indexToMove, direction, page);
      if (targetIndex != -1) {
        pushResult[indexToMove] = targetIndex;
      }
    }
    pushResult[oldPosition] = newPosition;

    return pushResult;
  }

  List<int>? _getPushChain(int startIndex, List<int> direction) {
    final page = startIndex ~/ childrenPerPage;
    final chain = <int>[];
    var currentIndex = startIndex;

    while (true) {
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

  List<int>? getCoords(int index, int page) {
    final int pageStartIndex = page * childrenPerPage;
    if (index < pageStartIndex || index >= pageStartIndex + childrenPerPage) {
      return null; // Not on this page
    }
    final pageIndex = index % childrenPerPage;
    final row = pageIndex ~/ columns;
    final col = pageIndex % columns;
    return [row, col];
  }

  int _getIndexInDirection(int fromIndex, List<int> direction, int page) {
    final coords = getCoords(fromIndex, page);
    if (coords == null) return -1;

    final newRow = coords[0] + direction[0];
    final newCol = coords[1] + direction[1];

    if (newRow < 0 || newRow >= rows || newCol < 0 || newCol >= columns) {
      return -1;
    }

    final pageStartIndex = page * childrenPerPage;
    return pageStartIndex + newRow * columns + newCol;
  }

  void onChildDragUpdate(DragUpdateDetails dragUpdate) {
    final globalOffset = dragUpdate.globalPosition;

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
      return;
    }
    _enteredLeftSide = false;
    _enteredRightSide = false;
  }
}

// Wobble animation widget for displaced items
class _WobbleWidget extends StatefulWidget {
  final Widget child;
  final Offset direction;

  const _WobbleWidget({
    required this.child,
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
        final wobbleAmount = 3.0; // Pixels to move back and forth
        final offsetX = widget.direction.dx * _animation.value * wobbleAmount;
        final offsetY = widget.direction.dy * _animation.value * wobbleAmount;

        return Transform.translate(
          offset: Offset(offsetX, offsetY),
          child: widget.child,
        );
      },
    );
  }
}
