import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: Row(
        children: [
          Expanded(child: MoveWindow()),
          const WindowButtons(),
        ],
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonColors = WindowButtonColors(
      iconNormal: Theme.of(context).colorScheme.onSurface,
      mouseOver: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      mouseDown: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      iconMouseOver: Theme.of(context).colorScheme.primary,
      iconMouseDown: Theme.of(context).colorScheme.primary,
    );
    final closeButtonColors = WindowButtonColors(
      mouseOver: const Color(0xFFD32F2F),
      mouseDown: const Color(0xFFB71C1C),
      iconNormal: Theme.of(context).colorScheme.onSurface,
      iconMouseOver: Colors.white,
    );

    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}