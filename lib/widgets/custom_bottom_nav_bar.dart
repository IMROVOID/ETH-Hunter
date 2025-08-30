import 'package:flutter/material.dart';
import 'dart:ui';
import '../core/theme/app_theme.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  CustomBottomNavBarState createState() => CustomBottomNavBarState();
}

class CustomBottomNavBarState extends State<CustomBottomNavBar> {
  final List<IconData> _icons = [
    Icons.search,
    Icons.settings,
    Icons.info_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final navBarColor = isDark ? const Color(0xFF121212) : Colors.white;

    return Container(
      height: 84,
      margin: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            // MODIFICATION: Fixed deprecated 'withOpacity'
            color: customColors.glassBg.withAlpha((255 * 0.7).round()),
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 84),
                  painter: _NavBarPainter(
                    itemCount: _icons.length,
                    selectedIndex: widget.selectedIndex,
                    navBarColor: navBarColor,
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_icons.length, (index) {
                      return _buildNavItem(
                        icon: _icons[index],
                        isSelected: widget.selectedIndex == index,
                        onTap: () => widget.onItemSelected(index),
                        // MODIFICATION: Pass customColors to the method
                        customColors: customColors,
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    // MODIFICATION: Added customColors parameter
    required CustomColors customColors,
  }) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        height: 70,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animated circle for selected item
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              width: isSelected ? 56 : 0,
              height: isSelected ? 56 : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor,
              ),
            ),
            // Icon
            Icon(
              icon,
              // MODIFICATION: Now correctly uses the passed customColors
              color: isSelected ? theme.colorScheme.onPrimary : customColors.textMuted,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarPainter extends CustomPainter {
  final int itemCount;
  final int selectedIndex;
  final Color navBarColor;

  _NavBarPainter({
    required this.itemCount,
    required this.selectedIndex,
    required this.navBarColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = navBarColor
      ..style = PaintingStyle.fill;

    final itemWidth = size.width / itemCount;
    final centerOfSelectedItem = (selectedIndex * itemWidth) + (itemWidth / 2);

    final path = Path();
    path.moveTo(0, 20);
    path.quadraticBezierTo(0, 0, 20, 0);
    path.lineTo(centerOfSelectedItem - 40, 0);
    path.cubicTo(
      centerOfSelectedItem - 25, 0,
      centerOfSelectedItem - 35, 25,
      centerOfSelectedItem, 25,
    );
    path.cubicTo(
      centerOfSelectedItem + 35, 25,
      centerOfSelectedItem + 25, 0,
      centerOfSelectedItem + 40, 0,
    );
    path.lineTo(size.width - 20, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}