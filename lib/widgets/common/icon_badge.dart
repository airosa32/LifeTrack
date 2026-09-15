import 'package:flutter/material.dart';

/// Badge quadrado colorido com ícone centralizado — o padrão visual
/// usado no app Ajustes do iPhone (Wi-Fi azul, Notificações vermelho, etc).
/// Dá identidade visual imediata a cada linha/seção sem poluir a tela.
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.58),
    );
  }
}
