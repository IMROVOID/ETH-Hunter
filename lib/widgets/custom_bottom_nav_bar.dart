import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
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

class CustomBottomNavBarState extends State<CustomBottomNavBar> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _startPosition = 0.0;
  double _endPosition = 0.0;

  final List<IconData> _icons = [
    Icons.search,
    Icons.settings,
    Icons.info_outline,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      final itemWidth = MediaQuery.of(context).size.width / _icons.length;
      setState(() {
        _startPosition = (oldWidget.selectedIndex * itemWidth) + (itemWidth / 2);
        _endPosition = (widget.selectedIndex * itemWidth) + (itemWidth / 2);
      });
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navBarColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    const navBarHeight = 65.0; // Navbar height
    const indicatorSize = 70.0; // The overflowing circle size

    return Container(
      height: 100, // Total area for the navbar + overflow
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final double currentPosition = Tween<double>(begin: _startPosition, end: _endPosition).evaluate(_animation);
          
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Layer 1: The sliding, overflowing, colored circle
              Positioned(
                left: currentPosition - (indicatorSize / 2),
                top: (navBarHeight - indicatorSize) / 2,
                child: Container(
                  width: indicatorSize,
                  height: indicatorSize,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Layer 2: The navbar shape with the animated cutout
              CustomPaint(
                size: const Size(double.infinity, navBarHeight),
                painter: _NavBarPainter(
                  itemCount: _icons.length,
                  indicatorPosition: currentPosition,
                  indicatorRadius: indicatorSize / 2,
                  navBarColor: navBarColor,
                ),
              ),

              // Layer 3: The icons
              SizedBox(
                height: navBarHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_icons.length, (index) {
                    return _buildNavItem(
                      icon: _icons[index],
                      isSelected: widget.selectedIndex == index,
                      onTap: () => widget.onItemSelected(index),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>()!;
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Icon(
          icon,
          color: isSelected ? theme.colorScheme.onPrimary : customColors.textMuted,
          size: 26,
        ),
      ),
    );
  }
}

class _NavBarPainter extends CustomPainter {
  final int itemCount;
  final double indicatorPosition;
  final double indicatorRadius;
  final Color navBarColor;

  _NavBarPainter({
    required this.itemCount,
    required this.indicatorPosition,
    required this.indicatorRadius,
    required this.navBarColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = navBarColor
      ..style = PaintingStyle.fill;
    
    const cornerRadius = Radius.circular(20);
    const cutoutPadding = 10.0; // The space between the indicator and the cutout edge

    // Main navbar body as a rounded rectangle path
    final navPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        cornerRadius,
      ));

    // Circle path for the cutout
    final circlePath = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(indicatorPosition, size.height / 2),
        radius: indicatorRadius + cutoutPadding,
      ));

    // Create the final path by cutting the circle out of the navbar body
    final finalPath = Path.combine(
      PathOperation.difference,
      navPath,
      circlePath,
    );

    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(covariant _NavBarPainter oldDelegate) {
    return indicatorPosition != oldDelegate.indicatorPosition ||
           navBarColor != oldDelegate.navBarColor;
  }
}