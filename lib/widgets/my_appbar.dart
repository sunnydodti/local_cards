import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/provider/theme_provider.dart';

class MyAppbar {
  static AppBar build(
    BuildContext context, {
    String title = 'Local Cards',
    bool back = false,
    Widget? leading,
  }) {
    assert(leading == null || !back,
        'Cannot provide both leading widget and back button');
    Icon icon = Theme.of(context).brightness == Brightness.light
        ? Icon(Icons.light_mode_outlined)
        : Icon(Icons.dark_mode_outlined);
    IconButton backButton = IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: Icon(Icons.arrow_back_outlined),
    );
    return AppBar(
      title: Text(title),
      centerTitle: true,
      leading: back ? backButton : leading,
      actions: [
        IconButton(
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
            icon: icon),
      ],
    );
  }
}
