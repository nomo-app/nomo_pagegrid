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

  int get childrenPerPage => rows * columns;

  final controller = ScrollController();
  final pageNotifier = ValueNotifier(0);
  final isDragging = ValueNotifier(false);

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
  }) {
    controller.addListener(onScrollPositionChanged);
  }

  int maxPages = 3;

  bool _enteredRightSide = false;
  bool _enteredLeftSide = false;

  void dispose() {
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

  void onPlaceHolderReceive(int placeholder, int oldPosition) {
    final itemChild = notifierMap[oldPosition]?.value;
    notifierMap[oldPosition]?.value = null;

    notifierMap[placeholder]?.value = itemChild;

    print("Placeholder: $placeholder received: $oldPosition");
  }

  void onItemReceive(int newPosition, int oldPosition) {
    final oldPosItem = notifierMap[oldPosition]?.value;
    final newPosItem = notifierMap[newPosition]?.value;

    notifierMap[oldPosition]?.value = newPosItem;
    notifierMap[newPosition]?.value = oldPosItem;

    print("newPosition: $newPosition received: $oldPosition");
  }

  void onChildDragUpdate(DragUpdateDetails dragUpdate) {
    final globalOffset = dragUpdate.globalPosition;

    print(globalOffset.dx);

    if (viewportWidth - globalOffset.dx < 32) {
      if (_enteredRightSide) return;
      _enteredRightSide = true;
      Future.delayed(
        Duration(seconds: 1),
        () {
          if (_enteredRightSide) {
            controller.animateTo(
              controller.offset + viewportWidth,
              duration: Duration(milliseconds: 140),
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
        Duration(seconds: 1),
        () {
          if (_enteredLeftSide) {
            controller.animateTo(
              controller.offset - viewportWidth,
              duration: Duration(milliseconds: 140),
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
