import 'package:apna_shop/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The app mark: a shopping tote with an upward trend, on a blue tile.
/// Drawn with icons, so it needs no image files and scales cleanly.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Apna Shop',
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.28),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3B82F6), AppColors.primary],
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
                size: size * 0.56,
              ),
            ),
            Positioned(
              right: -size * 0.08,
              bottom: -size * 0.08,
              child: Container(
                width: size * 0.38,
                height: size * 0.38,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: size * 0.04,
                  ),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: size * 0.24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Apna" in a heavy weight and "Shop" in a lighter one.
class AppWordmark extends StatelessWidget {
  const AppWordmark({super.key, this.fontSize = 28});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Apna',
            style: TextStyle(fontWeight: FontWeight.w700, color: color),
          ),
          TextSpan(
            text: 'Shop',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      style: TextStyle(fontSize: fontSize, letterSpacing: -0.5),
      semanticsLabel: 'Apna Shop',
    );
  }
}
