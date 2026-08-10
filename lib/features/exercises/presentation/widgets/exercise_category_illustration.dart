import 'package:flutter/material.dart';

import '../../../../core/theme/forge_colors.dart';

/// Illustrazione a stick-figure, disegnata internamente (nessun asset,
/// nessun download), che rappresenta la posa tipica di una categoria di
/// esercizi. Sostituisce l'icona generica del placeholder quando non è
/// ancora disponibile una foto/illustrazione reale dell'esercizio
/// specifico: dà un riferimento visivo pertinente senza inventare un
/// dettaglio tecnico di esecuzione.
class ExerciseCategoryIllustration extends StatelessWidget {
  const ExerciseCategoryIllustration({
    super.key,
    required this.categoryCode,
    this.size = 64,
  });

  final String categoryCode;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StickFigurePainter(pose: _poseFor(categoryCode)),
      ),
    );
  }

  static _Pose _poseFor(String categoryCode) {
    switch (categoryCode) {
      case 'MOBILITA':
        return _Pose.mobility;
      case 'GAMBE_GLUTEI':
        return _Pose.squat;
      case 'PETTO_SPINTA':
        return _Pose.push;
      case 'SCHIENA':
        return _Pose.row;
      case 'SPALLE':
        return _Pose.overheadPress;
      case 'BRACCIA':
        return _Pose.curl;
      case 'CORE':
        return _Pose.plank;
      case 'EQUILIBRIO':
        return _Pose.balance;
      case 'CARDIO':
        return _Pose.march;
      case 'STRETCHING':
        return _Pose.stretch;
      default:
        return _Pose.mobility;
    }
  }
}

enum _Pose {
  mobility,
  squat,
  push,
  row,
  overheadPress,
  curl,
  plank,
  balance,
  march,
  stretch,
}

/// Disegna una stick-figure semplice (testa + linee per busto/arti) su una
/// tela normalizzata 100x100, scalata alla dimensione reale del widget.
class _StickFigurePainter extends CustomPainter {
  const _StickFigurePainter({required this.pose});

  final _Pose pose;

  static const double _unit = 100;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / _unit;
    canvas.save();
    canvas.scale(scale);

    final limb = Paint()
      ..color = ForgeColors.copperLight
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final head = Paint()..color = ForgeColors.copperLight;

    switch (pose) {
      case _Pose.mobility:
        canvas.drawCircle(const Offset(50, 18), 8, head);
        canvas.drawLine(const Offset(50, 26), const Offset(50, 55), limb);
        canvas.drawLine(const Offset(50, 55), const Offset(35, 80), limb);
        canvas.drawLine(const Offset(50, 55), const Offset(65, 80), limb);
        canvas.drawArc(
          const Rect.fromLTWH(24, 22, 24, 24),
          -0.6,
          3.4,
          false,
          limb,
        );
        canvas.drawArc(
          const Rect.fromLTWH(52, 22, 24, 24),
          2.5,
          3.4,
          false,
          limb,
        );
      case _Pose.squat:
        canvas.drawCircle(const Offset(50, 30), 8, head);
        canvas.drawLine(const Offset(50, 38), const Offset(50, 58), limb);
        canvas.drawLine(const Offset(50, 58), const Offset(32, 48), limb);
        canvas.drawLine(const Offset(50, 58), const Offset(68, 48), limb);
        canvas.drawLine(const Offset(50, 58), const Offset(34, 78), limb);
        canvas.drawLine(const Offset(34, 78), const Offset(30, 90), limb);
        canvas.drawLine(const Offset(50, 58), const Offset(66, 78), limb);
        canvas.drawLine(const Offset(66, 78), const Offset(70, 90), limb);
      case _Pose.push:
        canvas.drawCircle(const Offset(28, 45), 8, head);
        canvas.drawLine(const Offset(34, 48), const Offset(70, 55), limb);
        canvas.drawLine(const Offset(34, 52), const Offset(20, 70), limb);
        canvas.drawLine(const Offset(70, 55), const Offset(84, 40), limb);
        canvas.drawLine(const Offset(70, 55), const Offset(80, 78), limb);
        canvas.drawLine(const Offset(20, 70), const Offset(15, 90), limb);
        canvas.drawLine(const Offset(80, 78), const Offset(88, 90), limb);
      case _Pose.row:
        canvas.drawCircle(const Offset(50, 22), 8, head);
        canvas.drawLine(const Offset(50, 30), const Offset(50, 62), limb);
        canvas.drawLine(const Offset(50, 40), const Offset(30, 30), limb);
        canvas.drawLine(const Offset(50, 40), const Offset(70, 30), limb);
        canvas.drawLine(const Offset(50, 62), const Offset(36, 88), limb);
        canvas.drawLine(const Offset(50, 62), const Offset(64, 88), limb);
      case _Pose.overheadPress:
        canvas.drawCircle(const Offset(50, 26), 8, head);
        canvas.drawLine(const Offset(50, 34), const Offset(50, 62), limb);
        canvas.drawLine(const Offset(50, 44), const Offset(30, 20), limb);
        canvas.drawLine(const Offset(50, 44), const Offset(70, 20), limb);
        canvas.drawLine(const Offset(50, 62), const Offset(36, 88), limb);
        canvas.drawLine(const Offset(50, 62), const Offset(64, 88), limb);
      case _Pose.curl:
        canvas.drawCircle(const Offset(50, 22), 8, head);
        canvas.drawLine(const Offset(50, 30), const Offset(50, 62), limb);
        canvas.drawLine(const Offset(50, 40), const Offset(66, 34), limb);
        canvas.drawLine(const Offset(66, 34), const Offset(64, 18), limb);
        canvas.drawLine(const Offset(50, 40), const Offset(32, 55), limb);
        canvas.drawLine(const Offset(50, 62), const Offset(36, 88), limb);
        canvas.drawLine(const Offset(50, 62), const Offset(64, 88), limb);
      case _Pose.plank:
        canvas.drawCircle(const Offset(20, 55), 8, head);
        canvas.drawLine(const Offset(26, 58), const Offset(80, 58), limb);
        canvas.drawLine(const Offset(26, 58), const Offset(20, 78), limb);
        canvas.drawLine(const Offset(80, 58), const Offset(86, 78), limb);
      case _Pose.balance:
        canvas.drawCircle(const Offset(50, 20), 8, head);
        canvas.drawLine(const Offset(50, 28), const Offset(50, 58), limb);
        canvas.drawLine(const Offset(50, 36), const Offset(30, 30), limb);
        canvas.drawLine(const Offset(50, 36), const Offset(70, 44), limb);
        canvas.drawLine(const Offset(50, 58), const Offset(50, 88), limb);
        canvas.drawLine(const Offset(50, 68), const Offset(74, 62), limb);
      case _Pose.march:
        canvas.drawCircle(const Offset(45, 20), 8, head);
        canvas.drawLine(const Offset(45, 28), const Offset(52, 56), limb);
        canvas.drawLine(const Offset(48, 36), const Offset(30, 30), limb);
        canvas.drawLine(const Offset(48, 40), const Offset(68, 50), limb);
        canvas.drawLine(const Offset(52, 56), const Offset(34, 68), limb);
        canvas.drawLine(const Offset(34, 68), const Offset(40, 90), limb);
        canvas.drawLine(const Offset(52, 56), const Offset(68, 78), limb);
        canvas.drawLine(const Offset(68, 78), const Offset(62, 90), limb);
      case _Pose.stretch:
        canvas.drawCircle(const Offset(50, 34), 8, head);
        canvas.drawLine(const Offset(50, 42), const Offset(50, 62), limb);
        canvas.drawLine(const Offset(50, 42), const Offset(28, 22), limb);
        canvas.drawLine(const Offset(50, 42), const Offset(72, 22), limb);
        canvas.drawLine(const Offset(50, 62), const Offset(36, 88), limb);
        canvas.drawLine(const Offset(50, 62), const Offset(64, 88), limb);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StickFigurePainter oldDelegate) =>
      oldDelegate.pose != pose;
}
