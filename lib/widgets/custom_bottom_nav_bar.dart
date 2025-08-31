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
    
    // MODIFICATION: Use a lighter color for dark mode nav bar
    final navBarColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    final navBarContent = Stack(
      children: [
        CustomPaint(
          size: const Size(double.infinity, 84),
          painter: _NavBarPainter(
            itemCount: _icons.length,
            selectedIndex: widget.selectedIndex,
            navBarColor: isDesktop ? customColors.glassBg : navBarColor,
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
        // MODIFICATION: Conditionally apply blur effect only on desktop
        child: isDesktop
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: customColors.glassBg.withAlpha((255 * 0.7).round()),
                  child: navBarContent,
                ),
              )
            : navBarContent,
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
            // MODIFICATION: Animated floating effect for the selected item
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(0, isSelected ? -12 : 0, 0),
              width: isSelected ? 56 : 0,
              height: isSelected ? 56 : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor,
              ),
            ),
            // MODIFICATION: Animated icon to move with the circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(0, isSelected ? -12 : 0, 0),
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

    // MODIFICATION: Widened and deepened the curve for a better fit
    path.lineTo(centerOfSelectedItem - 50, 0);
    path.cubicTo(
      centerOfSelectedItem - 30, 0,
      centerOfSelectedItem - 40, 40,
      centerOfSelectedItem, 40,
    );
    path.cubicTo(
      centerOfSelectedItem + 40, 40,
      centerOfSelectedItem + 30, 0,
      centerOfSelectedItem + 50, 0,
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