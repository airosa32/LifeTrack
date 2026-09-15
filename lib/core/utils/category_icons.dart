import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

/// Substitui o antigo esquema de emoji por ícones vetoriais reais.
/// Cada categoria guarda uma `iconKey` (String) que é resolvida aqui —
/// assim o mesmo conceito ("Alimentação") sempre usa o mesmo ícone,
/// e novas categorias personalizadas escolhem de uma lista fixa em vez
/// de digitar um emoji (que renderiza mal em algumas plataformas).
class CategoryIconRegistry {
  CategoryIconRegistry._();

  static const Map<String, IconData> _icons = {
    'cart_fill': CupertinoIcons.cart_fill,
    'car_fill': CupertinoIcons.car_detailed,
    'house_fill': CupertinoIcons.house_fill,
    'bolt_fill': CupertinoIcons.bolt_fill,
    'bag_fill': CupertinoIcons.bag_fill,
    'heart_fill': CupertinoIcons.heart_fill,
    'book_fill': CupertinoIcons.book_fill,
    'game_fill': CupertinoIcons.game_controller_solid,
    'creditcard_fill': CupertinoIcons.creditcard_fill,
    'tv_fill': CupertinoIcons.tv_fill,
    'scissors': CupertinoIcons.scissors,
    'paw_fill': CupertinoIcons.paw_solid,
    'wrench_fill': CupertinoIcons.gear_alt_fill,
    'tag_fill': CupertinoIcons.tag_fill,
    'briefcase_fill': CupertinoIcons.briefcase_fill,
    'desktop_fill': CupertinoIcons.desktopcomputer,
    'chart_fill': CupertinoIcons.chart_bar_fill,
    'undo_fill': CupertinoIcons.arrow_uturn_left,
    'gift_fill': CupertinoIcons.gift_fill,
    'plane_fill': CupertinoIcons.airplane,
    'phone_fill': CupertinoIcons.phone_fill,
    'grid_fill': CupertinoIcons.square_grid_2x2_fill,
  };

  /// Ordem em que aparecem no seletor de ícone da categoria personalizada.
  static const List<String> pickableKeys = [
    'tag_fill',
    'cart_fill',
    'bag_fill',
    'car_fill',
    'house_fill',
    'bolt_fill',
    'heart_fill',
    'book_fill',
    'game_fill',
    'creditcard_fill',
    'tv_fill',
    'scissors',
    'paw_fill',
    'wrench_fill',
    'briefcase_fill',
    'desktop_fill',
    'chart_fill',
    'gift_fill',
    'plane_fill',
    'phone_fill',
    'grid_fill',
  ];

  static IconData resolve(String key) => _icons[key] ?? CupertinoIcons.tag_fill;

  /// Paleta usada tanto nas categorias padrão quanto no seletor de cor
  /// das categorias personalizadas — cores saturadas o suficiente para
  /// contrastar com um ícone branco por cima (inspirado em apps como
  /// o de finanças do Behance usado como referência).
  static const List<Color> colorPalette = [
    Color(0xFFFF9F43), // laranja
    Color(0xFF4A90E2), // azul
    Color(0xFF2ECC71), // verde
    Color(0xFFE74C3C), // vermelho
    Color(0xFF9B59B6), // roxo
    Color(0xFF1ABC9C), // teal
    Color(0xFFF1C40F), // amarelo
    Color(0xFFE84393), // rosa
    Color(0xFF34495E), // slate
    Color(0xFF16A085), // verde-escuro
  ];

  static Color colorAt(int index) => colorPalette[index % colorPalette.length];
}
