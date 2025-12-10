/// Tag Input Widget with Autocomplete
///
/// An input field for adding tags with autocompl completion of existing tags.
///
/// Features:
/// - Autocomplete with existing tags
/// - Create new tags by pressing enter
/// - Display selected tags as removable chips
/// - Bauhaus-styled design
/// - Validation (no empty names, max length)
///
/// Usage:
/// ```dart
/// TagInput(
///   selectedTags: selectedTags,
///   onTagsChanged: (tags) => setState(() => selectedTags = tags),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/core/domain/result.dart';
import 'package:notes/core/presentation/theme/bauhaus_colors.dart';
import 'package:notes/core/presentation/theme/bauhaus_spacing.dart';
import 'package:notes/core/presentation/theme/bauhaus_typography.dart';
import 'package:notes/core/presentation/widgets/tags/bauhaus_tag_chip.dart';
import 'package:notes/features/tags/domain/models/tag.dart';
import 'package:notes/features/tags/application/tag_providers.dart';

/// Maximum length for tag names
const int _maxTagNameLength = 50;

/// Tag input widget with autocomplete functionality
///
/// This widget provides:
/// - Autocomplete suggestions from existing tags
/// - Ability to create new tags
/// - Visual display of selected tags as removable chips
/// - Validation of tag names
class TagInput extends ConsumerStatefulWidget {
  /// Currently selected tags
  final List<Tag> selectedTags;

  /// Callback when tags list changes
  final ValueChanged<List<Tag>> onTagsChanged;

  /// Placeholder text for the input field
  final String? placeholder;

  const TagInput({
    super.key,
    required this.selectedTags,
    required this.onTagsChanged,
    this.placeholder,
  });

  @override
  ConsumerState<TagInput> createState() => _TagInputState();
}

class _TagInputState extends ConsumerState<TagInput> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Add a tag to the selected tags list
  void _addTag(Tag tag) {
    // Don't add duplicates
    if (widget.selectedTags.any((t) => t.id == tag.id)) {
      return;
    }

    widget.onTagsChanged([...widget.selectedTags, tag]);
    _textController.clear();
  }

  /// Remove a tag from the selected tags list
  void _removeTag(Tag tag) {
    widget.onTagsChanged(
      widget.selectedTags.where((t) => t.id != tag.id).toList(),
    );
  }

  /// Create a new tag from the input text
  Future<void> _createNewTag(String name) async {
    final trimmedName = name.trim();

    // Validate
    if (trimmedName.isEmpty) return;
    if (trimmedName.length > _maxTagNameLength) return;

    // Check if tag already exists
    final allTagsAsync = ref.read(allTagsProvider);
    final allTags = allTagsAsync.value ?? [];

    final existingTag = allTags.where((t) =>
      t.name.toLowerCase() == trimmedName.toLowerCase()
    ).firstOrNull;

    if (existingTag != null) {
      // Tag exists, just add it
      _addTag(existingTag);
      return;
    }

    // Create new tag with default blue color
    final notifier = ref.read(tagProvider.notifier);
    final result = await notifier.createTag(
      name: trimmedName,
      color: '#0000FF', // Default blue color
    );

    if (result.isSuccess) {
      _addTag(result.dataOrNull!);
    } else {
      // Show error - tag creation failed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create tag')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allTagsAsync = ref.watch(allTagsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Selected tags display
        if (widget.selectedTags.isNotEmpty) ...[
          Wrap(
            spacing: BauhausSpacing.small,
            runSpacing: BauhausSpacing.small,
            children: widget.selectedTags.map((tag) {
              return BauhausTagChip(
                label: tag.displayName,
                backgroundColor: _parseColor(tag.color),
                onTap: () => _removeTag(tag),
              );
            }).toList(),
          ),
          SizedBox(height: BauhausSpacing.medium),
        ],

        // Autocomplete input
        allTagsAsync.when(
          data: (allTags) {
            // Filter out already selected tags
            final availableTags = allTags
                .where((tag) => !widget.selectedTags.any((t) => t.id == tag.id))
                .toList();

            return Autocomplete<Tag>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<Tag>.empty();
                }

                return availableTags.where((tag) {
                  return tag.name
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                });
              },
              displayStringForOption: (tag) => tag.name,
              fieldViewBuilder: (
                BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted,
              ) {
                // Keep our own controller in sync
                _textController.text = textEditingController.text;

                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: widget.placeholder ?? 'Add tags...',
                    hintStyle: BauhausTypography.bodyText.copyWith(
                      color: BauhausColors.darkGray,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                        color: BauhausColors.black,
                        width: BauhausSpacing.borderThin,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                        color: BauhausColors.yellow,
                        width: BauhausSpacing.borderThick,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: BauhausSpacing.medium,
                      vertical: BauhausSpacing.small,
                    ),
                  ),
                  style: BauhausTypography.bodyText,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    // Create new tag or select from autocomplete
                    _createNewTag(value);
                  },
                );
              },
              onSelected: (Tag selectedTag) {
                _addTag(selectedTag);
              },
              optionsViewBuilder: (
                BuildContext context,
                AutocompleteOnSelected<Tag> onSelected,
                Iterable<Tag> options,
              ) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    child: Container(
                      width: 300,
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: BauhausColors.white,
                        border: Border.all(
                          color: BauhausColors.black,
                          width: BauhausSpacing.borderThin,
                        ),
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final tag = options.elementAt(index);
                          return InkWell(
                            onTap: () => onSelected(tag),
                            child: Container(
                              padding: EdgeInsets.all(BauhausSpacing.medium),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: BauhausColors.lightGray,
                                    width: BauhausSpacing.borderThin,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: _parseColor(tag.color),
                                      border: Border.all(
                                        color: BauhausColors.black,
                                        width: BauhausSpacing.borderThin,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: BauhausSpacing.small),
                                  Expanded(
                                    child: Text(
                                      tag.displayName,
                                      style: BauhausTypography.bodyText,
                                    ),
                                  ),
                                  if (tag.usageCount > 0)
                                    Text(
                                      '(${tag.usageCount})',
                                      style: BauhausTypography.caption.copyWith(
                                        color: BauhausColors.darkGray,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => TextField(
            controller: _textController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.placeholder ?? 'Add tags...',
              hintStyle: BauhausTypography.bodyText.copyWith(
                color: BauhausColors.darkGray,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(
                  color: BauhausColors.black,
                  width: BauhausSpacing.borderThin,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: BauhausSpacing.medium,
                vertical: BauhausSpacing.small,
              ),
            ),
            style: BauhausTypography.bodyText,
            enabled: false,
          ),
          error: (error, _) => TextField(
            controller: _textController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.placeholder ?? 'Add tags...',
              hintStyle: BauhausTypography.bodyText.copyWith(
                color: BauhausColors.darkGray,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(
                  color: BauhausColors.red,
                  width: BauhausSpacing.borderThin,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: BauhausSpacing.medium,
                vertical: BauhausSpacing.small,
              ),
            ),
            style: BauhausTypography.bodyText,
            onSubmitted: (value) => _createNewTag(value),
          ),
        ),
      ],
    );
  }

  /// Parse hex color string to Color object
  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return BauhausColors.primaryBlue; // Default color
    }
  }
}
