import 'dart:ui' show Color;

enum CategoryType { income, expense }

CategoryType categoryTypeFromString(String value) {
  return CategoryType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => CategoryType.expense,
  );
}

class Category {
  final String id;
  final String name;

  /// Chave que resolve para um ícone vetorial via `CategoryIconRegistry`
  /// (ver core/utils/category_icons.dart). Trocado de emoji para ícone
  /// vetorial porque emoji renderiza de forma inconsistente/feia entre
  /// plataformas (especialmente Flutter Web no Windows).
  final String iconKey;

  /// Cor em ARGB (`Color.value`) do badge circular da categoria.
  final int colorValue;

  final CategoryType type;
  final bool isDefault;

  const Category({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorValue,
    required this.type,
    this.isDefault = false,
  });

  Color get color => Color(colorValue);

  Category copyWith({
    String? id,
    String? name,
    String? iconKey,
    int? colorValue,
    CategoryType? type,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      iconKey: json['iconKey'] as String? ?? 'tag_fill',
      colorValue: json['colorValue'] as int? ?? 0xFF8A919B,
      type: categoryTypeFromString(json['type'] as String),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconKey': iconKey,
      'colorValue': colorValue,
      'type': type.name,
      'isDefault': isDefault,
    };
  }
}
