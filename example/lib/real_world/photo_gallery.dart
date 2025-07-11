import 'package:flutter/material.dart';
import 'package:nomo_pagegrid/nomo_pagegrid.dart';
import '../widgets/example_scaffold.dart';

class PhotoGalleryExample extends StatefulWidget {
  const PhotoGalleryExample({super.key});

  @override
  State<PhotoGalleryExample> createState() => _PhotoGalleryExampleState();
}

class _PhotoGalleryExampleState extends State<PhotoGalleryExample> {
  late Map<int, Widget> photos;
  final Set<int> selectedPhotos = {};
  bool isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    photos = _generatePhotos();
  }

  Map<int, Widget> _generatePhotos() {
    final categories = [
      'mountains',
      'beach',
      'city',
      'forest',
      'night',
      'sunset',
      'ocean',
      'desert',
      'snow',
      'flowers',
      'wildlife',
      'architecture',
      'food',
      'people',
      'technology',
      'abstract',
      'nature',
      'travel',
      'animals',
      'sports',
      'fashion',
      'art',
      'music',
      'vintage',
    ];

    return {
      for (int i = 0; i < categories.length; i++)
        i: _PhotoItem(
          index: i,
          category: categories[i],
          isSelected: selectedPhotos.contains(i),
          onTap: isSelectionMode ? () => _toggleSelection(i) : null,
          onLongPress: () => _startSelection(i),
        ),
    };
  }

  void _startSelection(int index) {
    setState(() {
      isSelectionMode = true;
      selectedPhotos.clear();
      selectedPhotos.add(index);
      photos = _generatePhotos();
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (selectedPhotos.contains(index)) {
        selectedPhotos.remove(index);
      } else {
        selectedPhotos.add(index);
      }
      photos = _generatePhotos();
    });
  }

  void _clearSelection() {
    setState(() {
      isSelectionMode = false;
      selectedPhotos.clear();
      photos = _generatePhotos();
    });
  }

  void _deleteSelected() {
    setState(() {
      for (final index in selectedPhotos) {
        photos.remove(index);
      }
      isSelectionMode = false;
      selectedPhotos.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedPhotos.length} photos deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              photos = _generatePhotos();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Photo Gallery',
      actions: [
        if (isSelectionMode) ...[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: selectedPhotos.isNotEmpty ? _deleteSelected : null,
            tooltip: 'Delete selected',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _clearSelection,
            tooltip: 'Cancel selection',
          ),
        ] else
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: () => _startSelection(0),
            tooltip: 'Select photos',
          ),
      ],
      child: Column(
        children: [
          if (isSelectionMode)
            Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${selectedPhotos.length} selected',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (selectedPhotos.length == photos.length) {
                          selectedPhotos.clear();
                        } else {
                          selectedPhotos.addAll(photos.keys);
                        }
                        photos = _generatePhotos();
                      });
                    },
                    child: Text(
                      selectedPhotos.length == photos.length ? 'Deselect all' : 'Select all',
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: NomoPageGrid(
                rows: 3,
                columns: 3,
                itemSize: const Size(110, 110),
                items: photos,
                onChanged: (newPhotos) {
                  if (!isSelectionMode) {
                    setState(() {
                      photos = newPhotos;
                    });
                  }
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  onPressed: selectedPhotos.isNotEmpty || !isSelectionMode
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Share functionality not implemented'),
                            ),
                          );
                        }
                      : null,
                ),
                _ActionButton(
                  icon: Icons.favorite_border,
                  label: 'Favorite',
                  onPressed: selectedPhotos.isNotEmpty || !isSelectionMode
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to favorites'),
                            ),
                          );
                        }
                      : null,
                ),
                _ActionButton(
                  icon: Icons.edit,
                  label: 'Edit',
                  onPressed: (selectedPhotos.length == 1) || (!isSelectionMode && photos.isNotEmpty)
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit functionality not implemented'),
                            ),
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoItem extends StatelessWidget {
  final int index;
  final String category;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _PhotoItem({
    required this.index,
    required this.category,
    required this.isSelected,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isSelected ? 9 : 12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://picsum.photos/seed/$category-$index/400/400',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
