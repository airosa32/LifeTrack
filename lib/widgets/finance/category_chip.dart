import 'package:flutter/material.dart';

import '../../core/utils/category_icons.dart';
import '../../models/category.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      avatar: Icon(
        CategoryIconRegistry.resolve(category.iconKey),
        size: 18,
        color: selected ? Colors.white : category.color,
      ),
      label: Text(category.name),
      selected: selected,
      selectedColor: category.color,
      labelStyle: TextStyle(color: selected ? Colors.white : null),
      onSelected: (_) => onTap(),
    );
  }
}
