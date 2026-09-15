import 'package:flutter/material.dart';

/// Anima a entrada de um item de lista com fade + leve deslize de baixo
/// para cima, começando com um atraso proporcional ao índice — cria o
/// efeito "cascata" comum em apps polidos quando uma lista termina de
/// carregar. O atraso é real (via Future.delayed), não apenas uma
/// duração mais longa, para que os itens realmente entrem em sequência.
class StaggeredListItem extends StatefulWidget {
  final int index;
  final Widget child;

  const StaggeredListItem({super.key, required this.index, required this.child});

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    final delayMs = 35 * widget.index.clamp(0, 12);
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.08),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
