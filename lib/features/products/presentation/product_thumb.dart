import 'package:flutter/material.dart';

/// Icon for a product group, shown when a product has no picture.
IconData categoryIcon(String? category) {
  return switch (category) {
    'Atta & Grains' => Icons.grain,
    'Dal & Pulses' => Icons.spa_outlined,
    'Oil & Ghee' => Icons.oil_barrel_outlined,
    'Spices' => Icons.local_fire_department_outlined,
    'Sugar, Salt & Tea' => Icons.coffee_outlined,
    'Biscuits' => Icons.cookie_outlined,
    'Namkeen & Snacks' => Icons.fastfood_outlined,
    'Instant & Packaged Food' => Icons.ramen_dining_outlined,
    'Dairy & Bakery' => Icons.egg_alt_outlined,
    'Beverages' => Icons.local_drink_outlined,
    'Cleaning & Household' => Icons.cleaning_services_outlined,
    'Personal Care' => Icons.soap_outlined,
    'Candy & Chocolate' => Icons.icecream_outlined,
    _ => Icons.inventory_2_outlined,
  };
}

/// Small square picture for lists. Without a picture, or when it cannot be
/// loaded (for example offline), shows an icon for the product's category.
class ProductThumb extends StatelessWidget {
  const ProductThumb({
    super.key,
    required this.imageUrl,
    this.category,
    this.size = 48,
  });

  final String? imageUrl;
  final String? category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = SizedBox(
      width: size,
      height: size,
      child: Icon(
        categoryIcon(category),
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
    final url = imageUrl;
    if (url == null) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}
