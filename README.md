# NomoPageGrid

A Flutter package that provides a custom grid widget with drag-and-drop functionality and page-based navigation. The package allows items to be dragged between positions with smooth displacement animations.

## Features

- **Drag-and-drop** functionality with long press
- **Page-based navigation** for grids with many items
- **Smooth displacement animations** when dragging items
- **Wobble effect** for displaced items
- **Customizable** grid dimensions and item sizes
- **SliverNomoPageGrid** for use in CustomScrollView
- **Auto-scroll** at edges when dragging

## Getting started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  nomo_pagegrid: ^1.0.0
```

## Usage

### Basic NomoPageGrid

```dart
NomoPageGrid(
  rows: 4,
  columns: 4,
  itemSize: Size(80, 80),
  items: {
    0: Container(color: Colors.red),
    1: Container(color: Colors.blue),
    2: Container(color: Colors.green),
    // Add more items...
  },
  onChanged: (newItems) {
    setState(() {
      items = newItems;
    });
  },
)
```

### Using PageGridController

```dart
class MyGridScreen extends StatefulWidget {
  @override
  State<MyGridScreen> createState() => _MyGridScreenState();
}

class _MyGridScreenState extends State<MyGridScreen> {
  final PageGridController controller = PageGridController();
  
  @override
  void initState() {
    super.initState();
    // Listen to page changes
    controller.addListener(() {
      print('Current page: ${controller.currentPage}');
    });
  }
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Navigation controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => controller.previousPage(),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () => controller.nextPage(),
            ),
          ],
        ),
        // Grid with controller
        Expanded(
          child: NomoPageGrid(
            controller: controller,
            rows: 4,
            columns: 4,
            itemSize: Size(80, 80),
            items: items,
            onChanged: (newItems) {
              setState(() {
                items = newItems;
              });
            },
          ),
        ),
      ],
    );
  }
}
```

#### PageGridController Methods

- `nextPage()`: Navigate to the next page with default animation
- `previousPage()`: Navigate to the previous page with default animation
- `animateToPage(int page, {Duration duration, Curve curve})`: Animate to a specific page
- `jumpToPage(int page)`: Jump to a page without animation

#### PageGridController Properties

- `currentPage`: The current page index
- `pageCount`: Total number of pages
- `hasClients`: Whether the controller is attached to a grid

### SliverNomoPageGrid in CustomScrollView

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      title: Text('My App'),
      pinned: true,
    ),
    SliverNomoPageGrid(
      rows: 3,
      columns: 4,
      itemSize: Size(80, 80),
      height: 300, // Required for sliver
      items: {
        0: Container(color: Colors.red),
        1: Container(color: Colors.blue),
        // Add more items...
      },
      onChanged: (newItems) {
        setState(() {
          items = newItems;
        });
      },
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(
          title: Text('Item $index'),
        ),
        childCount: 20,
      ),
    ),
  ],
)
```

## Parameters

### NomoPageGrid

- `rows` (required): Number of rows in the grid
- `columns` (required): Number of columns in the grid
- `itemSize` (required): Size of each item in the grid
- `items` (required): Map of items where key is position index
- `width`: Optional width (uses available width if not specified)
- `height`: Optional height (uses available height if not specified)
- `wobbleAmount`: Amount of wobble effect (default: 3)
- `onChanged`: Callback when items are reordered

### SliverNomoPageGrid

Same as NomoPageGrid with these differences:
- `height` (required): Height of the sliver widget
- `width` is not available (uses full available width)

## Example

See the `/example` folder for a complete example app demonstrating both NomoPageGrid and SliverNomoPageGrid.

## Additional information

For more information, bug reports, or feature requests, please visit the [GitHub repository](https://github.com/nomo-app/nomo_pagegrid).
