import 'package:flutter/material.dart';

import '../utils/theme.dart';

/// TabBar estilizada, usada nas telas de Filmes e Séries.
class CineTabBar extends StatelessWidget implements PreferredSizeWidget {
  const CineTabBar({super.key, required this.labels});

  final List<String> labels;

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      labelColor: Colors.white,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      tabs: [for (final label in labels) Tab(text: label)],
    );
  }
}
