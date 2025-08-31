// =================================================================================
// ETH Hunter :: A Polished Flutter Desktop/Mobile Application
// Developed by ROVOID (Roham Andarzgou)
//
// --- SUPPORT THIS PROJECT ---
// If you find this application useful, please consider a donation. Thank you!
// BTC: bc1qd35yqx3xt28dy6fd87xzd62cj7ch35p68ep3p8
// ETH: 0xA39Dfd80309e881cF1464dDb00cF0a17bF0322e3
// USDT (TRC20): THMe6FdXkA2Pw45yKaXBHRnkX3fjyKCzfy
// SOL: 9QZHMTN4Pu6BCxiN2yABEcR3P4sXtBjkog9GXNxWbav1
// TON: UQCp0OawnofpZTNZk-69wlqIx_wQpzKBgDpxY2JK5iynh3mC
// =================================================================================

import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:system_theme/system_theme.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'core/theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/main_layout.dart';

// MODIFICATION: Custom ScrollBehavior to enable smooth scrolling with a mouse.
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

// MODIFICATION: Helper function to check for desktop platforms
bool isDesktop() {
  if (kIsWeb) return false;
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}

// MODIFICATION: Helper function to make the wallpaper-derived color more vibrant.
Color _saturateColor(Color color) {
  final hslColor = HSLColor.fromColor(color);
  // Increase saturation by 15%, capping at 1.0
  final saturatedColor = hslColor.withSaturation((hslColor.saturation + 0.15).clamp(0.0, 1.0));
  return saturatedColor.toColor();
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (isDesktop()) {
    await windowManager.ensureInitialized();
  }

  final String executableDirectory;
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    executableDirectory = (await getApplicationDocumentsDirectory()).path;
  } else if (!kDebugMode && isDesktop()) {
    executableDirectory = p.dirname(Platform.resolvedExecutable);
  } else {
    executableDirectory = (await getApplicationDocumentsDirectory()).path;
  }

  if (isDesktop()) {
    WindowOptions windowOptions = const WindowOptions(
      size: Size(900, 620),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(MyApp(executableDirectory: executableDirectory));
  
  if (isDesktop()) {
    doWhenWindowReady(() {
      final win = appWindow;
      win.minSize = const Size(800, 600);
      win.size = const Size(900, 620);
      win.alignment = Alignment.center;
      win.title = "ETH Hunter";
      win.show();
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.executableDirectory});
  final String executableDirectory;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(executableDirectory: executableDirectory),
      child: DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          Color accentColor;
          if (lightDynamic != null && darkDynamic != null && !isDesktop()) {
            // MODIFICATION: Use the more vibrant color on mobile.
            accentColor = _saturateColor(lightDynamic.primary);
          } else {
            accentColor = SystemTheme.accentColor.accent;
          }

          return Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              return MaterialApp(
                title: 'ETH Hunter',
                debugShowCheckedModeBanner: false,
                scrollBehavior: MyCustomScrollBehavior(),
                theme: AppTheme.light(accentColor),
                darkTheme: AppTheme.dark(accentColor),
                themeMode: appProvider.themeMode.flutterThemeMode,
                home: const MainLayout(),
              );
            },
          );
        },
      ),
    );
  }
}