import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:ui' as ui;

class Logo extends HookConsumerWidget {
  final ui.Image logo;
  final Size? size;

  const Logo({
    super.key,
    required this.logo,
    this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomPaint(
      size: size ?? Size.zero,
      painter: LogoPainter(
        logo: logo,
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  final ui.Image logo;

  const LogoPainter({
    required this.logo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final drawSize = Size(min(logo.width.toDouble(), size.width),
        min(logo.height.toDouble(), size.height));
    final offset = ui.Offset(
        (size.width / 2 - drawSize.width / 2).roundToDouble(),
        (size.height / 2 - drawSize.height / 2).roundToDouble());
    canvas.drawImageRect(
      logo,
      Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
      Rect.fromLTWH(offset.dx, offset.dy, drawSize.width, drawSize.height),
      Paint()
        ..imageFilter = ui.ImageFilter.blur(
            sigmaX: 40 / (256 / drawSize.width),
            sigmaY: 40 / (256 / drawSize.width),
            tileMode: TileMode.decal),
    );
    paintImage(
      canvas: canvas,
      image: logo,
      rect: Rect.fromLTWH(
        offset.dx,
        offset.dy,
        drawSize.width,
        drawSize.height,
      ),
      filterQuality: FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
