import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import '../providers/app_provider.dart';
import 'about_page.dart';
import 'scan_page.dart';
import 'settings_page.dart';
import '../core/theme/app_theme.dart';
import '../widgets/custom_bottom_nav_bar.dart';
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
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const ScanPage(),
    const SettingsPage(),
    const AboutPage(),
  ];

  Timer? _animationTimer;
  final Random _random = Random();

  List<Alignment> _alignments = [
    Alignment.topLeft,
    Alignment.topRight,
    Alignment.bottomCenter,
  ];
  
  // MODIFICATION: Helper function to check for desktop platforms
  bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  @override
  void initState() {
    super.initState();
    _animationTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (mounted) {
        setState(() {
          _alignments = [
            _generateRandomAlignment(),
            _generateRandomAlignment(),
            _generateRandomAlignment(),
          ];
        });
      }
    });
  }

  Alignment _generateRandomAlignment() {
    final alignments = [
      const Alignment(-1.5, -1.5), const Alignment(0, -1.5), const Alignment(1.5, -1.5),
      const Alignment(-1.5, 0), const Alignment(0, 0), const Alignment(1.5, 0),
      const Alignment(-1.5, 1.5), const Alignment(0, 1.5), const Alignment(1.5, 1.5),
    ];
    return alignments[_random.nextInt(alignments.length)];
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // For desktop glass effect
      body: Stack(
        children: [
          // MODIFICATION: Conditionally disable animated background on mobile for performance.
          isDesktop
              ? _buildAnimatedBackground(context)
              : Container(color: Theme.of(context).scaffoldBackgroundColor),
          // MODIFICATION: Choose layout based on platform
          isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context),
          const GlobalToast(),
        ],
      ),
    );
  }

  // WIDGET: Animated Gradient Background (used by both platforms)
  Widget _buildAnimatedBackground(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      color: scaffoldColor,
      child: Stack(
        children: [
          _buildGradientCircle(customColors.gradient1, _alignments[0]),
          _buildGradientCircle(customColors.gradient2, _alignments[1]),
          _buildGradientCircle(customColors.gradient3, _alignments[2]),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: customColors.blurSigma, sigmaY: customColors.blurSigma),
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }
  
  // WIDGET: Desktop layout with Sidebar
  Widget _buildDesktopLayout(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Column(
      children: [
        const WindowTitleBar(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isMinimized = constraints.maxWidth < 850;
              return Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    width: isMinimized ? 70 : 220,
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        SidebarNavItem(icon: Icons.search, title: 'Scan', isSelected: _selectedIndex == 0, isMinimized: isMinimized, onTap: () => setState(() => _selectedIndex = 0)),
                        const SizedBox(height: 4),
                        SidebarNavItem(icon: Icons.settings, title: 'Settings', isSelected: _selectedIndex == 1, isMinimized: isMinimized, onTap: () => setState(() => _selectedIndex = 1)),
                        const SizedBox(height: 4),
                        SidebarNavItem(icon: Icons.info_outline, title: 'About', isSelected: _selectedIndex == 2, isMinimized: isMinimized, onTap: () => setState(() => _selectedIndex = 2)),
                        const Spacer(),
                        SidebarStatsWidget(isMinimized: isMinimized),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Consumer<AppProvider>(builder: (context, app, child) {
                            if (isMinimized) {
                              return RotatedBox(quarterTurns: 3, child: Text(app.appVersion, style: TextStyle(color: customColors.textMuted, fontSize: 10, fontWeight: FontWeight.w200)));
                            }
                            return Text(app.appVersion, style: TextStyle(color: customColors.textMuted, fontSize: 12, fontWeight: FontWeight.w400));
                          }),
                        ),
                      ],
                    ),
                  ),
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
    );
  }

  // WIDGET: Mobile layout with BottomNavBar
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Show animated background through
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
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
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}