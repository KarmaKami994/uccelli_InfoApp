// lib/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// A custom AppBar that shows either a logo or a back arrow.
///
/// If [showBack] is true, displays a back arrow; otherwise shows your logo.
PreferredSizeWidget customAppBar(
  BuildContext context, {
  required String title,
  List<Widget>? actions,
  PreferredSizeWidget? bottom,
  bool showBack = false,
}) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  final isDark = themeProvider.isDarkMode;

  return AppBar(
    automaticallyImplyLeading: false,
    leading: showBack
        ? IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
            onPressed: () => Navigator.of(context).pop(),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              isDark
                  ? 'lib/assets/images/logo_dark.png'
                  : 'lib/assets/images/logo_light.png',
              fit: BoxFit.contain,
            ),
          ),
    title: Text(
      title,
      style: Theme.of(context).appBarTheme.titleTextStyle,
    ),
    actions: actions,
    backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
    elevation: Theme.of(context).appBarTheme.elevation,
    bottom: bottom,
  );
}
