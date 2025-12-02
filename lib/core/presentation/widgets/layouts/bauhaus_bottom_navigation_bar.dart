/// Bauhaus Bottom Navigation Bar Widget
///
/// Bottom navigation bar following Bauhaus design principles with sharp corners
/// and geometric color indicators.
///
/// Specifications:
/// - Sharp corners with 2px top border
/// - Color indicators for selected item (yellow underline or colored square)
/// - Uses BauhausTypography.tagLabel for labels (ALL CAPS)
/// - 3-4 navigation items
/// - Geometric icons
/// - Minimum 56px height
///
/// Usage:
/// ```dart
/// BauhausBottomNavigationBar(
///   currentIndex: 0,
///   onTap: (index) => setState(() => _currentIndex = index),
///   items: [
///     BauhausBottomNavigationBarItem(
///       icon: Icons.home,
///       label: 'Home',
///     ),
///     BauhausBottomNavigationBarItem(
///       icon: Icons.search,
///       label: 'Search',
///     ),
///   ],
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_spacing.dart';
import '../../theme/bauhaus_typography.dart';

/// Item configuration for Bauhaus bottom navigation bar
class BauhausBottomNavigationBarItem {
  /// Icon to display
  final IconData icon;

  /// Label text (will be converted to uppercase)
  final String label;

  /// Optional custom color for this item when selected
  final Color? selectedColor;

  const BauhausBottomNavigationBarItem({
    required this.icon,
    required this.label,
    this.selectedColor,
  });
}

/// Bauhaus-style bottom navigation bar with geometric design
///
/// Features:
/// - 56px minimum height
/// - 2px top border
/// - Color indicators for selected items
/// - ALL CAPS labels with Bauhaus typography
/// - Geometric icons and shapes
class BauhausBottomNavigationBar extends StatelessWidget {
  /// List of navigation items (3-4 recommended)
  final List<BauhausBottomNavigationBarItem> items;

  /// Currently selected item index
  final int currentIndex;

  /// Callback when an item is tapped
  final ValueChanged<int> onTap;

  /// Background color of the navigation bar
  final Color backgroundColor;

  /// Color for unselected items
  final Color unselectedColor;

  /// Color for selected items (default)
  final Color selectedColor;

  /// Type of selection indicator
  final NavigationIndicatorType indicatorType;

  const BauhausBottomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor = BauhausColors.white,
    this.unselectedColor = BauhausColors.darkGray,
    this.selectedColor = BauhausColors.primaryBlue,
    this.indicatorType = NavigationIndicatorType.underline,
  }) : assert(items.length >= 2 && items.length <= 5, 'Items should be between 2 and 5');

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Bottom navigation bar',
      child: Container(
        height: BauhausSpacing.recommendedTouchTarget,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            top: BorderSide(
              color: BauhausColors.black,
              width: BauhausSpacing.borderStandard,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            items.length,
            (index) => _NavigationBarItem(
              item: items[index],
              isSelected: index == currentIndex,
              onTap: () => onTap(index),
              unselectedColor: unselectedColor,
              selectedColor: items[index].selectedColor ?? selectedColor,
              indicatorType: indicatorType,
            ),
          ),
        ),
      ),
    );
  }
}

/// Type of selection indicator for navigation items
enum NavigationIndicatorType {
  /// Yellow underline below selected item
  underline,

  /// Colored square next to the icon
  square,

  /// Colored circle next to the icon
  circle,
}

/// Private widget for individual navigation bar items
class _NavigationBarItem extends StatelessWidget {
  final BauhausBottomNavigationBarItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Color unselectedColor;
  final Color selectedColor;
  final NavigationIndicatorType indicatorType;

  const _NavigationBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.unselectedColor,
    required this.selectedColor,
    required this.indicatorType,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedColor : unselectedColor;

    return Expanded(
      child: Semantics(
        label: '${item.label} navigation button',
        button: true,
        selected: isSelected,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected && indicatorType != NavigationIndicatorType.underline) ...[
                    _ShapeIndicator(
                      selectedColor: selectedColor,
                      indicatorType: indicatorType,
                    ),
                    SizedBox(width: BauhausSpacing.tight),
                  ],
                  Icon(
                    item.icon,
                    color: color,
                    size: BauhausSpacing.iconMedium,
                  ),
                ],
              ),
              SizedBox(height: BauhausSpacing.tight),
              Text(
                item.label.toUpperCase(),
                style: BauhausTypography.tagLabel.copyWith(
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (isSelected && indicatorType == NavigationIndicatorType.underline)
                Container(
                  margin: EdgeInsets.only(top: BauhausSpacing.tight),
                  height: BauhausSpacing.borderStandard,
                  width: 24,
                  color: selectedColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shape indicator widget for navigation items
class _ShapeIndicator extends StatelessWidget {
  const _ShapeIndicator({
    required this.selectedColor,
    required this.indicatorType,
  });

  final Color selectedColor;
  final NavigationIndicatorType indicatorType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: selectedColor,
        shape: indicatorType == NavigationIndicatorType.circle
            ? BoxShape.circle
            : BoxShape.rectangle,
      ),
    );
  }
}
