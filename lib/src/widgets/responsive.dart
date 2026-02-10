import 'package:flutter/material.dart';

/// ResponsiveLayout provide a utility widget that can
/// support small medium and large screen as wish.
class ResponsiveLayout extends StatelessWidget {
  static const double defaultTabletBreakpoint = 600;
  static const double defaultDesktopBreakpoint = 1200;

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final double tabletBreakpoint;
  final double desktopBreakpoint;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.tabletBreakpoint = defaultTabletBreakpoint,
    this.desktopBreakpoint = defaultDesktopBreakpoint,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < defaultTabletBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= defaultTabletBreakpoint &&
      MediaQuery.sizeOf(context).width < defaultDesktopBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= defaultDesktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= desktopBreakpoint && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= tabletBreakpoint && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}
