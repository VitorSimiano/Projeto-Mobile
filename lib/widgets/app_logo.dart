import 'package:flutter/material.dart';

import '../utils/theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.wine],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(Icons.movie_filter_rounded, color: Colors.white, size: size),
        ),
        const SizedBox(width: 10),
        Text.rich(
          TextSpan(
            children: const [
              TextSpan(
                text: 'Cine',
                style: TextStyle(fontWeight: FontWeight.w300, color: Colors.white),
              ),
              TextSpan(
                text: 'Finder',
                style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.accent),
              ),
            ],
          ),
          style: TextStyle(fontSize: size * 1.1, letterSpacing: 0.5),
        ),
      ],
    );
  }
}
