class ShelfItem {
  final String id;
  final String name;
  final String brand;
  final String category;
  final double price;
  final int estimatedUses;
  final int remainingUses;
  final String indicatorColor;
  final String? imageUrl;
  final List<String> ingredients;

  ShelfItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.estimatedUses,
    required this.remainingUses,
    required this.indicatorColor,
    this.imageUrl,
    required this.ingredients,
  });

  factory ShelfItem.fromJson(Map<String, dynamic> json) {
    return ShelfItem(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Product',
      brand: json['brand'] as String? ?? '',
      category: json['category'] as String? ?? 'Other',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      estimatedUses: json['estimated_uses'] as int? ?? 50,
      remainingUses:
          json['remaining_uses'] as int? ??
          (json['estimated_uses'] as int? ?? 50),
      indicatorColor: json['indicator_color'] as String? ?? '0xFFE040FB',
      imageUrl: json['image_url'] as String?,
      ingredients: json['ingredients'] != null
          ? List<String>.from(json['ingredients'] as Iterable)
          : <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'price': price,
      'estimated_uses': estimatedUses,
      'remaining_uses': remainingUses,
      'indicator_color': indicatorColor,
      'image_url': imageUrl,
      'ingredients': ingredients,
    };
  }

  ShelfItem copyWith({
    String? id,
    String? name,
    String? brand,
    String? category,
    double? price,
    int? estimatedUses,
    int? remainingUses,
    String? indicatorColor,
    String? imageUrl,
    List<String>? ingredients,
  }) {
    return ShelfItem(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      price: price ?? this.price,
      estimatedUses: estimatedUses ?? this.estimatedUses,
      remainingUses: remainingUses ?? this.remainingUses,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}
