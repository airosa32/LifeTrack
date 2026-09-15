import 'package:flutter/material.dart';

/// Recorta a base de um container em uma curva suave (tipo "sorriso"
/// invertido). O parâmetro [dip] controla o quanto a curva desce no
/// centro — variar esse valor ao longo do tempo (via [CurvedGradientHeader])
/// é o que faz a onda "respirar" continuamente.
class WaveHeaderClipper extends CustomClipper<Path> {
  final double dip;

  const WaveHeaderClipper({this.dip = 24, Listenable? reclip}) : super(reclip: reclip);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 36);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + dip,
      size.width,
      size.height - 36,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant WaveHeaderClipper oldClipper) => oldClipper.dip != dip;
}

/// Onda "espelhada" (curva para cima no centro) — usada no topo da barra
/// de navegação inferior, para o mesmo efeito orgânico no rodapé do app.
class WaveFooterClipper extends CustomClipper<Path> {
  final double dip;

  const WaveFooterClipper({this.dip = 16, Listenable? reclip}) : super(reclip: reclip);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 24);
    path.quadraticBezierTo(size.width / 2, -dip, size.width, 24);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant WaveFooterClipper oldClipper) => oldClipper.dip != dip;
}
