import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class SidebarNavItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final bool isMinimized;
  final VoidCallback onTap;

  const SidebarNavItem({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.isMinimized,
    required this.onTap,
  });

  @override
  State<SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<SidebarNavItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;
    final isLight = theme.brightness == Brightness.light;

    final bool showBg = widget.isSelected || _isHovering;

    // Determine the icon color more robustly.
    // If selected, use the color scheme's `onPrimary` color, which is designed
    // for optimal contrast on top of the primary accent color.
    // If not selected, use the muted text color.
    final iconColor = widget.isSelected
        ? theme.colorScheme.onPrimary
        : customColors.textMuted;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(8),
      onHover: (hovering) => setState(() => _isHovering = hovering),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          mainAxisAlignment: widget.isMinimized ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50, // Reduced width to prevent overflow
              height: 38,
              decoration: BoxDecoration(
                color: showBg
                    ? accentColor.withOpacity(isLight ? 0.4 : 0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                widget.icon,
                size: 22,
                color: iconColor,
              ),
            ),
            // The text now fades smoothly and is wrapped in Expanded to prevent overflow
            if (!widget.isMinimized)
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: widget.isMinimized ? 0.0 : 1.0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0), // Reduced gap
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: widget.isSelected
                            ? theme.textTheme.bodyLarge?.color
                            : customColors.textMuted,
                        fontWeight: widget.isSelected
                            ? (isLight ? FontWeight.w500 : FontWeight.w400)
                            : (isLight ? FontWeight.w300 : FontWeight.w200),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}