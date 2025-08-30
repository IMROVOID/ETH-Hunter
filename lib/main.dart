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
import 'package:dynamic_color/dynamic_color.dart'; // MODIFICATION: Added for wallpaper color

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // MODIFICATION: Desktop-only window initialization
  if (isDesktop()) {
    await windowManager.ensureInitialized();
  }

  // MODIFICATION: Platform-aware path for portable data storage
  final String executableDirectory;
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    executableDirectory = (await getApplicationDocumentsDirectory()).path;
  } else if (!kDebugMode && isDesktop()) {
    executableDirectory = p.dirname(Platform.resolvedExecutable);
  } else {
    executableDirectory = (await getApplicationDocumentsDirectory()).path;
  }

  // MODIFICATION: Desktop-only window options
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
  
  // MODIFICATION: Desktop-only bitsdojo_window setup
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
      // MODIFICATION: Use DynamicColorBuilder for Material You theming on Android
      child: DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          // Determine the accent color based on platform
          Color accentColor;
          if (lightDynamic != null && darkDynamic != null) {
            // Use wallpaper color on Android
            accentColor = lightDynamic.primary;
          } else {
            // Use system accent color on Desktop
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