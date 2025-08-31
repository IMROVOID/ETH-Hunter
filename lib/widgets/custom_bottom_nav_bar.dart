import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
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

  bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    
    // MODIFICATION: Use a darker color for the nav bar in dark mode.
    final navBarColor = isDark ? const Color(0xFF1F1F1F) : Colors.white;

    final navBarContent = Stack(
      clipBehavior: Clip.none, // Allow the floating icon to draw outside the bounds
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
                customColors: customColors,
              );
            }),
          ),
        ),
      ],
    );

    return Container(
      height: 84,
      margin: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: isDesktop
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: customColors.glassBg.withAlpha((255 * 0.7).round()),
                  child: navBarContent,
                ),
              )
            // MODIFICATION: On mobile, wrap in a container with the solid color to ensure no "second background".
            : Container(
                color: navBarColor,
                child: navBarContent,
              ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
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
            // MODIFICATION: Increased upward movement for the selected item.
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(0, isSelected ? -18 : 0, 0),
              width: isSelected ? 56 : 0,
              height: isSelected ? 56 : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(0, isSelected ? -18 : 0, 0),
              child: Icon(
                icon,
                color: isSelected ? theme.colorScheme.onPrimary : customColors.textMuted,
                size: 24,
              ),
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

    // MODIFICATION: Made the curve wider and deeper to better accommodate the floating icon.
    path.lineTo(centerOfSelectedItem - 60, 0);
    path.cubicTo(
      centerOfSelectedItem - 35, 0,
      centerOfSelectedItem - 45, 45,
      centerOfSelectedItem, 45,
    );
    path.cubicTo(
      centerOfSelectedItem + 45, 45,
      centerOfSelectedItem + 35, 0,
      centerOfSelectedItem + 60, 0,
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