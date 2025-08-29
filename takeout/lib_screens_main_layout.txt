import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'about_page.dart';
import 'scan_page.dart';
import 'settings_page.dart';
import '../core/theme/app_theme.dart';
import '../widgets/global_toast.dart';
import '../widgets/sidebar_nav_item.dart';
import '../widgets/sidebar_stats_widget.dart';
import '../widgets/window_title_bar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const ScanPage(),
    const SettingsPage(),
    const AboutPage(),
  ];

  Timer? _animationTimer;
  final Random _random = Random();

  // State for three animated gradients
  List<Alignment> _alignments = [
    Alignment.topLeft,
    Alignment.topRight,
    Alignment.bottomCenter,
  ];

  @override
  void initState() {
    super.initState();
    _animationTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      setState(() {
        _alignments = [
          _generateRandomAlignment(),
          _generateRandomAlignment(),
          _generateRandomAlignment(),
        ];
      });
    });
  }

  // Generates a random alignment from a predefined list to avoid clustering
  Alignment _generateRandomAlignment() {
    final alignments = [
      const Alignment(-1.5, -1.5),
      const Alignment(0, -1.5),
      const Alignment(1.5, -1.5),
      const Alignment(-1.5, 0),
      const Alignment(0, 0),
      const Alignment(1.5, 0),
      const Alignment(-1.5, 1.5),
      const Alignment(0, 1.5),
      const Alignment(1.5, 1.5),
    ];
    return alignments[_random.nextInt(alignments.length)];
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Animated Gradient Background
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            color: scaffoldColor,
            child: Stack(
              children: [
                _buildGradientCircle(customColors.gradient1, _alignments[0]),
                _buildGradientCircle(customColors.gradient2, _alignments[1]),
                _buildGradientCircle(customColors.gradient3, _alignments[2]),
                BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: customColors.blurSigma,
                      sigmaY: customColors.blurSigma),
                  child: Container(color: Colors.transparent),
                ),
              ],
            ),
          ),
          // Main App Content
          Column(
            children: [
              const WindowTitleBar(),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isMinimized = constraints.maxWidth < 850;
                    return Row(
                      children: [
                        // Sidebar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                          width: isMinimized ? 70 : 220,
                          color: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              SidebarNavItem(
                                icon: Icons.search,
                                title: 'Scan',
                                isSelected: _selectedIndex == 0,
                                isMinimized: isMinimized,
                                onTap: () => setState(() => _selectedIndex = 0),
                              ),
                              const SizedBox(height: 4),
                              SidebarNavItem(
                                icon: Icons.settings,
                                title: 'Settings',
                                isSelected: _selectedIndex == 1,
                                isMinimized: isMinimized,
                                onTap: () => setState(() => _selectedIndex = 1),
                              ),
                              const SizedBox(height: 4),
                              SidebarNavItem(
                                icon: Icons.info_outline,
                                title: 'About',
                                isSelected: _selectedIndex == 2,
                                isMinimized: isMinimized,
                                onTap: () => setState(() => _selectedIndex = 2),
                              ),
                              const Spacer(),
                              SidebarStatsWidget(isMinimized: isMinimized),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Consumer<AppProvider>(
                                    builder: (context, app, child) {
                                  if (isMinimized) {
                                    return RotatedBox(
                                      quarterTurns: 3,
                                      child: Text(
                                        app.appVersion,
                                        style: TextStyle(
                                            color: customColors.textMuted,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w200),
                                      ),
                                    );
                                  }
                                  return Text(
                                    app.appVersion,
                                    style: TextStyle(
                                        color: customColors.textMuted,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        // Main Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 30, 30),
                            child: _pages[_selectedIndex],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          // Global Toast Overlay
          const GlobalToast(),
        ],
      ),
    );
  }

  Widget _buildGradientCircle(Color color, Alignment alignment) {
    return AnimatedAlign(
      duration: const Duration(seconds: 5),
      curve: Curves.fastOutSlowIn,
      alignment: alignment,
      child: Container(
        height: 350,
        width: 350,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}