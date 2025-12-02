/// Bauhaus Search Bar Widget
///
/// A geometric search input field following Bauhaus design principles.
/// Features a search icon, sharp corners, and animated focus state.
///
/// Specifications:
/// - Geometric search icon
/// - Sharp corners (BorderRadius.zero)
/// - 1px black border normally
/// - 4px yellow left border when focused (animated)
/// - Uses BauhausTypography for text styles
/// - Uses BauhausSpacing for padding
///
/// Usage:
/// ```dart
/// BauhausSearchBar(
///   placeholder: 'Search notes...',
///   onChanged: (query) => searchNotes(query),
///   onSubmitted: () => performSearch(),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_spacing.dart';

/// Bauhaus-style search bar with geometric design and animated focus state
///
/// This search bar follows Bauhaus principles:
/// - Clear functional purpose (search)
/// - Geometric forms (sharp corners, clear icon)
/// - Animated visual feedback (yellow accent on focus)
/// - High contrast for accessibility
class BauhausSearchBar extends StatefulWidget {
  /// Placeholder text shown when search field is empty (MUST be localized)
  final String placeholder;

  /// Callback when search text changes
  final ValueChanged<String>? onChanged;

  /// Callback when user submits search (presses enter/search button)
  final VoidCallback? onSubmitted;

  /// Text editing controller for the search field
  final TextEditingController? controller;

  /// Whether to show a clear button when text is entered
  final bool showClearButton;

  /// Focus node for managing focus
  final FocusNode? focusNode;

  /// Semantic label for accessibility (MUST be localized, defaults to placeholder)
  final String? semanticLabel;

  /// Semantic label for clear button (MUST be localized if showClearButton is true)
  final String? clearButtonLabel;

  const BauhausSearchBar({
    super.key,
    required this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.showClearButton = true,
    this.focusNode,
    this.semanticLabel,
    this.clearButtonLabel,
  });

  @override
  State<BauhausSearchBar> createState() => _BauhausSearchBarState();
}

class _BauhausSearchBarState extends State<BauhausSearchBar> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChange() {
    final hasText = _controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel ?? widget.placeholder,
      textField: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: BauhausColors.white,
          border: Border(
            // Animated yellow left border on focus - 4px when focused, 1px normally
            left: BorderSide(
              color: _isFocused ? BauhausColors.yellow : BauhausColors.black,
              width: _isFocused
                  ? BauhausSpacing.borderThick // 4px
                  : BauhausSpacing.borderThin, // 1px
            ),
            top: const BorderSide(
              color: BauhausColors.black,
              width: BauhausSpacing.borderThin,
            ),
            right: const BorderSide(
              color: BauhausColors.black,
              width: BauhausSpacing.borderThin,
            ),
            bottom: const BorderSide(
              color: BauhausColors.black,
              width: BauhausSpacing.borderThin,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: BauhausSpacing.medium,
            vertical: BauhausSpacing.small,
          ),
          child: Row(
            children: [
              // Search icon
              Icon(
                Icons.search,
                color: BauhausColors.darkGray,
                size: BauhausSpacing.iconMedium,
              ),
              const SizedBox(width: BauhausSpacing.small),

              // Search input field
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
                  onSubmitted: (_) => widget.onSubmitted?.call(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BauhausColors.black,
                      ),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle:
                        Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: BauhausColors.darkGray,
                            ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              // Clear button (shown when text is entered)
              if (widget.showClearButton && _hasText) ...[
                const SizedBox(width: BauhausSpacing.small),
                Semantics(
                  label: widget.clearButtonLabel,
                  button: true,
                  child: GestureDetector(
                    onTap: _clearSearch,
                    child: Container(
                      width: BauhausSpacing.iconMedium,
                      height: BauhausSpacing.iconMedium,
                      decoration: const BoxDecoration(
                        color: BauhausColors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: BauhausColors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
