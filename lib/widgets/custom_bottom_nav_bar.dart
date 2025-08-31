import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.search,
            isSelected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
            context: context,
          ),
          _buildNavItem(
            icon: Icons.settings,
            isSelected: selectedIndex == 1,
            onTap: () => onItemSelected(1),
            context: context,
          ),
          _buildNavItem(
            icon: Icons.info_outline,
            isSelected: selectedIndex == 2,
            onTap: () => onItemSelected(2),
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>()!;
    final accentColor = theme.colorScheme.primary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                width: isSelected ? 60 : 0,
                height: isSelected ? 60 : 0,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              Icon(
                icon,
                color: isSelected ? theme.colorScheme.onPrimary : customColors.textMuted,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}