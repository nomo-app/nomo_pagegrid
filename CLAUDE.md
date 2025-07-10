# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter package called `nomo_pagegrid` that provides a custom grid widget with drag-and-drop functionality and page-based navigation. The package allows items to be dragged between positions with smooth displacement animations.

## Development Commands

```bash
# Install dependencies
flutter pub get

# Run static analysis
flutter analyze

# Format code (100 char line width)
flutter format . --line-length 100

# Run the example app
cd example && flutter run

# Check package readiness for publishing
flutter pub publish --dry-run
```

## Architecture

The package architecture centers around these key components:

- **NomoPageGrid**: Public API widget that accepts items, dimensions, and callbacks
- **PageGridNotifier**: ChangeNotifier that manages grid state and item positions
- **NomoPageGridDelegate/Layout**: Custom RenderBox implementation for grid layout
- **PageGridItem**: Draggable item wrapper with LongPressDraggable
- **Displacement System**: Smart algorithm that pushes/swaps items during drag operations

The displacement logic (lib/nomo_pagegrid.dart:712-819) handles complex scenarios:
- Items push others out of the way when dragged
- Items swap positions when appropriate
- Displaced items wobble to indicate they're affected
- Multi-item displacement chains are supported

## Code Style

- Page width: 100 characters
- Trailing commas: Always preserved
- Linting: Uses flutter_lints with several rules disabled (see analysis_options.yaml)
- No print statements in production code (avoid_print is disabled for development)

## Testing Approach

Currently no tests exist. When adding tests:
- Use standard Flutter widget testing
- Test displacement logic thoroughly
- Test page navigation and boundaries
- Test drag callbacks and state management