import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class AXTheme {
  static const Color titanium = Color(0xFF1C1F26);
  static const Color panel = Color(0xFF252A33);
  static const Color cyanFlux = Color(0xFF00E5FF);
  static const Color mutedGold = Color(0xFFFFD700);
  static const Color danger = Color(0xFFFF3333);
  static const Color success = Color(0xFF00FF94);
  static const Color warning = Color(0xFFFFC107);
  static const Color manual = Color(0xFFFF5722);

  static TextStyle get brand => GoogleFonts.cinzel(
      color: Colors.white,
      fontWeight: FontWeight.w900,
      letterSpacing: 4,
      fontSize: 28,
      shadows: [Shadow(color: cyanFlux.withOpacity(0.5), blurRadius: 20)]);
  static TextStyle get heading => GoogleFonts.cinzel(
      color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5);
  static TextStyle get body => GoogleFonts.montserrat(
      color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500);
  static TextStyle get terminal => GoogleFonts.sourceCodePro(
      color: cyanFlux, fontSize: 12, fontWeight: FontWeight.w500);
  static TextStyle get digital => GoogleFonts.orbitron(
      color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2);
  static TextStyle get input => GoogleFonts.sourceCodePro(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: 2);
  static TextStyle get value => GoogleFonts.sourceCodePro(
      color: mutedGold, fontWeight: FontWeight.bold, letterSpacing: 1.5);
  static TextStyle get status => GoogleFonts.orbitron(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5);

  static BoxDecoration getPanel(
      {bool isActive = false, bool isDanger = false, bool isManual = false}) {
    Color border = isActive
        ? cyanFlux
        : (isDanger ? danger : (isManual ? manual : Colors.white10));
    return BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(4, 4),
              blurRadius: 10),
          if (isActive)
            BoxShadow(color: cyanFlux.withOpacity(0.15), blurRadius: 15),
          if (isManual)
            BoxShadow(color: manual.withOpacity(0.15), blurRadius: 15),
        ]);
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
        text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}

class MagicalNeonButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final bool isDone;
  final VoidCallback onTap;
  final Color activeColor;
  const MagicalNeonButton(
      {super.key,
      required this.text,
      required this.icon,
      required this.isDone,
      required this.onTap,
      required this.activeColor});
  @override
  State<MagicalNeonButton> createState() => _MagicalNeonButtonState();
}

class _MagicalNeonButtonState extends State<MagicalNeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onTap,
        child: Container(
            height: 80,
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: widget.activeColor.withOpacity(0.1),
                      blurRadius: 10)
                ]),
            child: Stack(alignment: Alignment.center, children: [
              if (!widget.isDone)
                Positioned.fill(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedBuilder(
                            animation: _ctrl,
                            builder: (_, __) {
                              return CustomPaint(
                                  painter: NeonBorderPainter(
                                      _ctrl.value, widget.activeColor));
                            }))),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(widget.isDone ? Icons.check_circle : widget.icon,
                    color: widget.isDone ? AXTheme.success : widget.activeColor,
                    size: 28),
                const SizedBox(height: 8),
                Text(widget.text,
                    style: TextStyle(
                        color: widget.isDone ? AXTheme.success : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1))
              ])
            ])));
  }
}

class NeonBorderPainter extends CustomPainter {
  final double progress;
  final Color color;
  NeonBorderPainter(this.progress, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    final sweep = SweepGradient(
        colors: [Colors.transparent, color, Colors.transparent],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(progress * 2 * math.pi));
    paint.shader = sweep.createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(NeonBorderPainter old) => old.progress != progress;
}

class PanicButton extends StatefulWidget {
  final VoidCallback onPanicTriggered;
  const PanicButton({super.key, required this.onPanicTriggered});
  @override
  State<PanicButton> createState() => _PanicButtonState();
}

class _PanicButtonState extends State<PanicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        widget.onPanicTriggered();
        _c.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPressStart: (_) => _c.forward(),
        onLongPressEnd: (_) => _c.reset(),
        child: Stack(alignment: Alignment.center, children: [
          SizedBox(
              width: 70,
              height: 70,
              child: AnimatedBuilder(
                  animation: _c,
                  builder: (ctx, child) => CircularProgressIndicator(
                      value: _c.value,
                      color: AXTheme.danger,
                      strokeWidth: 6,
                      backgroundColor: Colors.transparent))),
          Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                  color: AXTheme.danger,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AXTheme.danger, blurRadius: 10)
                  ]),
              child: const Icon(Icons.emergency_share,
                  color: Colors.white, size: 30))
        ]));
  }
}

class CyberButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isManual;
  final bool isWarning;
  const CyberButton(
      {super.key,
      required this.text,
      required this.onTap,
      this.isManual = false,
      this.isWarning = false});
  @override
  Widget build(BuildContext context) {
    Color c = onTap == null
        ? Colors.white10
        : (isWarning
            ? AXTheme.warning
            : (isManual ? AXTheme.manual : AXTheme.cyanFlux));
    return GestureDetector(
        onTap: onTap,
        child: Container(
            height: 55,
            decoration: BoxDecoration(
                color: c.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: c),
                boxShadow: [
                  if (onTap != null)
                    BoxShadow(color: c.withOpacity(0.2), blurRadius: 10)
                ]),
            child: Center(
                child: Text(text,
                    style: AXTheme.heading.copyWith(
                        fontSize: 14,
                        color:
                            onTap == null ? Colors.white24 : Colors.white)))));
  }
}

class BlinkingWidget extends StatefulWidget {
  final Widget child;
  const BlinkingWidget({super.key, required this.child});
  @override
  State<BlinkingWidget> createState() => _BlinkingWidgetState();
}

class _BlinkingWidgetState extends State<BlinkingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _c, child: widget.child);
  }
}

class RadarPainter extends CustomPainter {
  final double rotation;
  RadarPainter(this.rotation);
  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width / 2, s.height / 2);
    final radius = s.width / 2;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (int i = 1; i <= 3; i++) {
      p.color = AXTheme.cyanFlux.withOpacity(0.1 * i);
      c.drawCircle(center, radius * (i / 3), p);
    }
    p.color = AXTheme.cyanFlux.withOpacity(0.1);
    c.drawLine(Offset(center.dx, 0), Offset(center.dx, s.height), p);
    c.drawLine(Offset(0, center.dy), Offset(s.width, center.dy), p);
    final shader = SweepGradient(
            colors: [Colors.transparent, AXTheme.cyanFlux.withOpacity(0.5)],
            stops: const [0.5, 1.0],
            transform: GradientRotation(rotation))
        .createShader(Rect.fromCircle(center: center, radius: radius));
    c.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.fill
          ..shader = shader);
  }

  @override
  bool shouldRepaint(RadarPainter old) => old.rotation != rotation;
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;
    for (double i = 0; i < s.width; i += 40) {
      c.drawLine(Offset(i, 0), Offset(i, s.height), p);
    }
    for (double i = 0; i < s.height; i += 40) {
      c.drawLine(Offset(0, i), Offset(s.width, i), p);
    }
  }

  @override
  bool shouldRepaint(old) => false;
}
