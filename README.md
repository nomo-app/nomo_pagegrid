# NomoPageGrid

[![pub package](https://img.shields.io/pub/v/nomo_pagegrid.svg)](https://pub.dev/packages/nomo_pagegrid)
[![pub points](https://img.shields.io/pub/points/nomo_pagegrid)](https://pub.dev/packages/nomo_pagegrid/score)
[![likes](https://img.shields.io/pub/likes/nomo_pagegrid)](https://pub.dev/packages/nomo_pagegrid/score)
[![popularity](https://img.shields.io/pub/popularity/nomo_pagegrid)](https://pub.dev/packages/nomo_pagegrid/score)
[![license](https://img.shields.io/github/license/nomo-app/nomo_pagegrid)](https://github.com/nomo-app/nomo_pagegrid/blob/master/LICENSE)

A customizable Flutter widget for creating grid layouts with drag-and-drop functionality, page-based navigation, and smooth displacement animations. Perfect for creating app launchers, photo galleries, or any grid-based interface that needs reordering capabilities.

## ✨ Features

- 🎯 **Drag-and-Drop** - Long-press any item to drag it to a new position
- 📄 **Page Navigation** - Swipe between pages for grids with many items
- 🎭 **Smart Displacement** - Items automatically move out of the way with smooth animations
- 🎪 **Wobble Effect** - Visual feedback when items are displaced
- 📐 **Flexible Layout** - Customize rows, columns, and item sizes
- 🎢 **Sliver Support** - Use `SliverNomoPageGrid` in scrollable views
- 🎮 **Controller Support** - Programmatic page navigation with `PageGridController`
- 📍 **Empty Slots** - Support for grids with empty positions
- 🚀 **Performance** - Optimized for smooth 60fps animations

## 🎬 Demo

<p align="center">
  <img src="https://raw.githubusercontent.com/nomo-app/nomo_pagegrid/master/doc/images/demo.gif" width="300" alt="NomoPageGrid Demo">
</p>

## 📦 Installation

Add `nomo_pagegrid` to your `pubspec.yaml`:

```yaml
dependencies:
  nomo_pagegrid: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

### Basic Grid

```dart
import 'package:nomo_pagegrid/nomo_pagegrid.dart';

NomoPageGrid(
  rows: 4,
  columns: 4,
  itemSize: Size(80, 80),
  items: {
    0: Container(color: Colors.red),
    1: Container(color: Colors.blue),
    2: Container(color: Colors.green),
    3: Container(color: Colors.yellow),
  },
  onChanged: (newItems) {
    setState(() {
      items = newItems;
    });
  },
)
```

### With Custom Items

```dart
NomoPageGrid(
  rows: 3,
  columns: 3,
  itemSize: Size(100, 100),
  wobbleAmount: 5.0, // Increase wobble effect
  items: {
    for (int i = 0; i < apps.length; i++)
      i: AppIcon(app: apps[i]),
  },
  onChanged: (newItems) {
    // Save new arrangement
    setState(() {
      items = newItems;
    });
  },
)
```

## 📖 Usage Examples

### Using PageGridController

Control page navigation programmatically:

```dart
class MyGridScreen extends StatefulWidget {
  @override
  State<MyGridScreen> createState() => _MyGridScreenState();
}

class _MyGridScreenState extends State<MyGridScreen> {
  final PageGridController controller = PageGridController();
  Map<int, Widget> items = {
    for (int i = 0; i < 20; i++)
      i: Container(
        color: Colors.primaries[i % Colors.primaries.length],
        child: Center(child: Text('$i')),
      ),
  };
  
  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      print('Current page: ${controller.currentPage}');
      print('Total pages: ${controller.pageCount}');
    });
  }
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Grid Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.first_page),
            onPressed: () => controller.jumpToPage(0),
          ),
          IconButton(
            icon: Icon(Icons.last_page),
            onPressed: () => controller.animateToPage(
              controller.pageCount - 1,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
      body: NomoPageGrid(
        controller: controller,
        rows: 4,
        columns: 4,
        itemSize: Size(80, 80),
        items: items,
        onChanged: (newItems) {
          setState(() => items = newItems);
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => controller.previousPage(),
            ),
            ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, _, __) {
                return Text(
                  'Page ${controller.currentPage + 1} of ${controller.pageCount}',
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () => controller.nextPage(),
            ),
          ],
        ),
      ),
    );
  }
}
```

### SliverNomoPageGrid in CustomScrollView

Use within scrollable views:

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      title: Text('My App'),
      floating: true,
      snap: true,
    ),
    SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Drag items to reorder'),
      ),
    ),
    SliverNomoPageGrid(
      rows: 3,
      columns: 4,
      itemSize: Size(80, 80),
      height: 300, // Required for sliver
      items: {
        0: Icon(Icons.home, size: 40),
        1: Icon(Icons.star, size: 40),
        2: Icon(Icons.settings, size: 40),
        3: Icon(Icons.person, size: 40),
        // Add more items...
      },
      onChanged: (newItems) {
        setState(() => items = newItems);
      },
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(
          title: Text('List Item $index'),
        ),
        childCount: 20,
      ),
    ),
  ],
)
```

### Photo Gallery Example

```dart
NomoPageGrid(
  rows: 3,
  columns: 3,
  itemSize: Size(120, 120),
  items: {
    for (int i = 0; i < photos.length; i++)
      i: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          photos[i].url,
          fit: BoxFit.cover,
        ),
      ),
  },
  onChanged: (newItems) {
    // Reorder photos
    setState(() {
      photos = newItems.entries
          .map((e) => photos[e.key])
          .toList();
    });
  },
)
```

## 📊 API Reference

### NomoPageGrid

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `rows` | `int` | ✅ | - | Number of rows per page |
| `columns` | `int` | ✅ | - | Number of columns per page |
| `itemSize` | `Size` | ✅ | - | Size of each grid item |
| `items` | `Map<int, Widget>` | ✅ | - | Items to display (key = position) |
| `width` | `double?` | ❌ | Parent width | Grid width |
| `height` | `double?` | ❌ | Parent height | Grid height |
| `wobbleAmount` | `double` | ❌ | 3.0 | Wobble animation amplitude |
| `onChanged` | `Function(Map<int, Widget>)?` | ❌ | null | Callback when items are reordered |
| `controller` | `PageGridController?` | ❌ | null | Controller for page navigation |

### SliverNomoPageGrid

Same as `NomoPageGrid` with these differences:
- `height` is **required** for proper sliver sizing
- `width` is not available (uses full available width)

### PageGridController

**Properties:**
- `currentPage` → `int` - Current page index
- `pageCount` → `int` - Total number of pages
- `hasClients` → `bool` - Whether attached to a grid

**Methods:**
- `nextPage({Duration? duration, Curve? curve})` - Navigate to next page
- `previousPage({Duration? duration, Curve? curve})` - Navigate to previous page
- `animateToPage(int page, {Duration duration, Curve curve})` - Animate to specific page
- `jumpToPage(int page)` - Jump to page without animation

## 🎨 Customization

### Custom Item Builder

```dart
Widget buildItem(int index, String label, IconData icon) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.blue.shade100,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 32),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    ),
  );
}
```

### Handling Empty Slots

```dart
NomoPageGrid(
  rows: 4,
  columns: 4,
  itemSize: Size(80, 80),
  items: {
    0: buildItem(0, 'Home', Icons.home),
    1: buildItem(1, 'Search', Icons.search),
    3: buildItem(3, 'Profile', Icons.person), // Skip index 2
    7: buildItem(7, 'Settings', Icons.settings), // Skip 4,5,6
  },
  onChanged: (newItems) {
    setState(() => items = newItems);
  },
)
```

## 🔧 Advanced Features

### Displacement System

The grid uses a smart displacement algorithm that:
- Detects when a dragged item overlaps another item
- Calculates the optimal displacement direction
- Animates items out of the way smoothly
- Supports chain reactions for multiple item displacement

### Wobble Animation

Items that are displaced show a subtle wobble animation to indicate they're being affected by the drag operation. Customize with:

```dart
NomoPageGrid(
  wobbleAmount: 5.0, // Increase wobble intensity
  // or
  wobbleAmount: 0, // Disable wobble
  // ... other parameters
)
```

### Edge Navigation

When dragging items near the edges of the grid, it automatically navigates to adjacent pages, making it easy to move items across pages.

## 📱 Platform Support

| Platform | Status |
|----------|--------|
| iOS | ✅ Fully supported |
| Android | ✅ Fully supported |
| Web | ✅ Fully supported |
| macOS | ✅ Fully supported |
| Windows | ✅ Fully supported |
| Linux | ✅ Fully supported |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup

1. Clone the repository
```bash
git clone https://github.com/nomo-app/nomo_pagegrid.git
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the example app
```bash
cd example
flutter run
```

4. Run tests
```bash
flutter test
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Credits

Developed and maintained by the [NOMO App](https://github.com/nomo-app) team.

## 🐛 Bugs and Feature Requests

Please file issues and feature requests at the [issue tracker](https://github.com/nomo-app/nomo_pagegrid/issues).

## 📚 See Also

- [API Documentation](https://pub.dev/documentation/nomo_pagegrid/latest/)
- [Example App](example/)
- [Changelog](CHANGELOG.md)