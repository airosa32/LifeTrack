import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../core/utils/category_icons.dart';
import '../../models/category.dart';

/// Círculo colorido com o ícone vetorial da categoria — usado em todo
/// lugar que antes mostrava o emoji da categoria (card de transação,
/// detalhes, seletor de categoria, lista em Configurações). Centralizar
/// aqui garante visual 100% consistente em qualquer tela.
class CategoryAvatar extends StatelessWidget {
  final Category? category;
  final double size;

  const CategoryAvatar({super.key, required this.category, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final color = category?.color ?? Theme.of(context).colorScheme.outline;
    final icon = category != null
        ? CategoryIconRegistry.resolve(category!.iconKey)
        : CupertinoIcons.question_circle;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: size * 0.5),
    );
  }
}
