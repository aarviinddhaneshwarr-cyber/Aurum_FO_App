import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

// ==========================================
// AURUM X: ULTRA LUXURY DARK CERAMIC THEME (100% CONSISTENT)
// ==========================================
class AXTheme {
  // 1. BACKGROUND & PANELS (Deep Titanium Ceramic)
  static const Color bg = Color(0xFF0D0F12); // Deepest OLED-style Slate
  static const Color panel = Color(
    0xFF15181D,
  ); // Slightly elevated Ceramic Surface

  // 2. THE STRICT COLOR PALETTE
  static const Color primaryText = Color(0xFFFFFFFF); // Pure Crisp White
  static const Color secondaryText = Color(0xFF8B95A5); // Premium Slate Grey

  // The Core Identifiers
  static const Color goldFlux = Color(
    0xFFFFD700,
  ); // Pure Aurum Gold (Auto-Sync/Common)
  static const Color manual = Color(
    0xFFF8F9FA,
  ); // Platinum White (Manual Entry)

  // The Magic Energy
  static const Color cyanFlux = Color(0xFF00E5FF);

  // Strict Status Colors
  static const Color success = Color(0xFF00E676);
  static const Color danger = Color(0xFFFF1744);
  static const Color warning = Color(0xFFFF9100);

  // Fallbacks
  static const Color titanium = bg;
  static const Color mutedGold = goldFlux;
  static const Color textMain = primaryText;

  // 3. THE ONE UNIFIED BORDER (Absolute Consistency)
  // Used everywhere: Panels, Buttons, Inputs. Exactly 1px thick.
  static Color subtleBorder = Colors.white.withOpacity(0.06);

  // PREMIUM SHADOWS (Soft, Wide, Ceramic Depth)
  static const Color lightShadow = Color(0x08FFFFFF); // Ultra faint light
  static const Color darkShadow = Color(0x80000000); // Deep bottom shadow

  // 4. LUXURY PANELS
  static BoxDecoration getPanel({
    bool isActive = false,
    bool isManual = false,
  }) {
    return BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(20),
      // CONSISTENT BORDER RULE
      border: Border.all(color: subtleBorder, width: 1.0),
      boxShadow: const [
        BoxShadow(color: lightShadow, offset: Offset(-5, -5), blurRadius: 12),
        BoxShadow(color: darkShadow, offset: Offset(5, 5), blurRadius: 15),
      ],
    );
  }

  // The Clean Dent (For Input Fields)
  static BoxDecoration getInsetPanel() {
    return BoxDecoration(
      color: const Color(0xFF0A0C0F), // Darker core
      borderRadius: BorderRadius.circular(12),
      // CONSISTENT BORDER RULE
      border: Border.all(color: subtleBorder, width: 1.0),
    );
  }

  // 5. TYPOGRAPHY (ULTRA CRISP - ZERO BLUR)
  static const TextStyle brand = TextStyle(
    fontFamily: 'Orbitron',
    fontWeight: FontWeight.bold,
    color: primaryText,
    letterSpacing: 3,
  );
  static const TextStyle heading = TextStyle(
    fontFamily: 'Orbitron',
    fontWeight: FontWeight.bold,
    color: primaryText,
    letterSpacing: 1.5,
  );
  static const TextStyle body = TextStyle(
    fontFamily: 'Rajdhani',
    fontWeight: FontWeight.w600,
    color: secondaryText,
  );
  static const TextStyle terminal = TextStyle(
    fontFamily: 'ShareTechMono',
    color: secondaryText,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle status = TextStyle(
    fontFamily: 'Orbitron',
    fontWeight: FontWeight.bold,
    color: primaryText,
  );

  // Value & Inputs ALWAYS use GoldFlux for Consistency
  static const TextStyle value = TextStyle(
    fontFamily: 'Rajdhani',
    fontWeight: FontWeight.bold,
    color: goldFlux,
  );
  static const TextStyle input = TextStyle(
    fontFamily: 'ShareTechMono',
    color: goldFlux,
    fontSize: 18,
    letterSpacing: 2,
  );

  // Digital Displays (Crisp Gold)
  static TextStyle get digital => const TextStyle(
    fontFamily: 'ShareTechMono',
    color: goldFlux,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
  );
}

// ==========================================
// UPPERCASE FORMATTER
// ==========================================
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

// ==========================================
// GRID PAINTER (BLANK FOR LUXURY SOLID BG)
// ==========================================
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {}
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// 3D CYBER BUTTON (CONSISTENT BORDER & CLEAN SNAP)
// ==========================================
class CyberButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isWarning;
  final bool isManual;
  const CyberButton({
    super.key,
    required this.text,
    this.onTap,
    this.isWarning = false,
    this.isManual = false,
  });

  @override
  State<CyberButton> createState() => _CyberButtonState();
}

class _CyberButtonState extends State<CyberButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    Color baseColor = widget.isWarning
        ? AXTheme.danger
        : (widget.isManual ? AXTheme.manual : AXTheme.goldFlux);
    bool isDisabled = widget.onTap == null;

    return GestureDetector(
      onTapDown: (_) => isDisabled ? null : setState(() => _pressed = true),
      onTapUp: (_) {
        if (!isDisabled) {
          setState(() => _pressed = false);
          widget.onTap!();
        }
      },
      onTapCancel: () => isDisabled ? null : setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: AXTheme.panel,
            borderRadius: BorderRadius.circular(16),
            // STRICT CONSISTENCY: 1px subtle border
            border: Border.all(color: AXTheme.subtleBorder, width: 1.0),
            boxShadow: _pressed || isDisabled
                ? []
                : const [
                    BoxShadow(
                      color: AXTheme.lightShadow,
                      offset: Offset(-4, -4),
                      blurRadius: 10,
                    ),
                    BoxShadow(
                      color: AXTheme.darkShadow,
                      offset: Offset(4, 4),
                      blurRadius: 12,
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                fontFamily: 'Orbitron',
                color: isDisabled ? AXTheme.secondaryText : baseColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// MAGICAL NEON BUTTON (ULTRA THIN & ELEGANT SPECTRUM)
// ==========================================
class MagicalNeonButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final bool isDone;
  final Color activeColor;
  final VoidCallback onTap;

  const MagicalNeonButton({
    super.key,
    required this.text,
    required this.icon,
    required this.isDone,
    required this.activeColor,
    required this.onTap,
  });

  @override
  State<MagicalNeonButton> createState() => _MagicalNeonButtonState();
}

class _MagicalNeonButtonState extends State<MagicalNeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbitController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDisabled = widget.isDone;

    return GestureDetector(
      onTap: isDisabled ? null : widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ULTRA-THIN MAGIC BORDER (Cyan -> Green -> Gold)
          if (!isDisabled)
            AnimatedBuilder(
              animation: _orbitController,
              builder: (_, __) => CustomPaint(
                painter: _NeonBorderPainter(_orbitController.value),
                child: Container(height: 64, width: double.infinity),
              ),
            ),

          // Inner Luxury Surface
          Container(
            height: 58,
            width: double.infinity,
            margin: const EdgeInsets.all(3), // Space for the ultra-thin laser
            decoration: BoxDecoration(
              color: AXTheme.panel,
              borderRadius: BorderRadius.circular(16),
              // STRICT CONSISTENCY: 1px subtle border matches exactly
              border: Border.all(color: AXTheme.subtleBorder, width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: AXTheme.lightShadow,
                  offset: Offset(-4, -4),
                  blurRadius: 10,
                ),
                BoxShadow(
                  color: AXTheme.darkShadow,
                  offset: Offset(4, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.isDone ? Icons.check_circle : widget.icon,
                  color: widget.isDone ? AXTheme.success : AXTheme.goldFlux,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.text,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.bold,
                    color: widget.isDone
                        ? AXTheme.success
                        : AXTheme.primaryText,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NeonBorderPainter extends CustomPainter {
  final double animationValue;
  _NeonBorderPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      // ULTRA THIN ELEGANT LASER (Reduced to 1.2px)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          AXTheme.cyanFlux.withOpacity(0.0),
          AXTheme.cyanFlux, // CYAN
          const Color(0xFF00E676), // GREEN
          AXTheme.goldFlux, // GOLD
          AXTheme.goldFlux.withOpacity(0.0),
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        transform: GradientRotation(animationValue * 2 * math.pi),
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==========================================
// RADAR PAINTER
// ==========================================
class RadarPainter extends CustomPainter {
  final double angle;
  RadarPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    Paint circlePaint = Paint()
      ..color = AXTheme.cyanFlux.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width / 2, circlePaint);
    canvas.drawCircle(center, size.width / 3, circlePaint);
    canvas.drawCircle(center, size.width / 6, circlePaint);

    Paint sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: math.pi / 2,
        colors: [Colors.transparent, AXTheme.cyanFlux.withOpacity(0.5)],
        transform: GradientRotation(angle),
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width / 2),
      angle,
      math.pi / 2,
      true,
      sweepPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==========================================
// MAGICAL SOS BUTTON (WITH HOLD EFFECT)
// ==========================================
class PanicButton extends StatefulWidget {
  final VoidCallback onPanicTriggered;
  const PanicButton({super.key, required this.onPanicTriggered});
  @override
  State<PanicButton> createState() => _PanicButtonState();
}

class _PanicButtonState extends State<PanicButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Fast rotation for the Danger Magic Ring when held
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handlePressDown() {
    setState(() => _pressed = true);
    _pulseController.repeat(); // Start magic spin
  }

  void _handlePressUp() {
    setState(() => _pressed = false);
    _pulseController.stop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _handlePressDown(),
      onTapUp: (_) => _handlePressUp(),
      onTapCancel: () => _handlePressUp(),
      onLongPress: widget.onPanicTriggered,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // DANGER MAGIC RING (Only visible when pressed)
          if (_pressed)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => CustomPaint(
                painter: _DangerOrbitPainter(_pulseController.value),
                child: const SizedBox(
                  width: 70,
                  height: 70,
                ), // Slightly larger than button
              ),
            ),

          // Inner Button
          AnimatedScale(
            scale: _pressed ? 0.92 : 1.0, // Deeper snap for SOS
            duration: const Duration(milliseconds: 100),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AXTheme.danger,
                shape: BoxShape.circle,
                // STRICT CONSISTENCY: Same subtle border
                border: Border.all(color: AXTheme.subtleBorder, width: 1.0),
                boxShadow: _pressed
                    ? []
                    : [
                        BoxShadow(
                          color: AXTheme.lightShadow,
                          offset: const Offset(-3, -3),
                          blurRadius: 8,
                        ),
                        BoxShadow(
                          color: AXTheme.darkShadow,
                          offset: const Offset(4, 4),
                          blurRadius: 10,
                        ),
                      ],
              ),
              child: const Center(
                child: Icon(Icons.sos, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerOrbitPainter extends CustomPainter {
  final double animationValue;
  _DangerOrbitPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          2.0 // Slightly thicker for danger alert
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          AXTheme.warning, // Orange
          AXTheme.goldFlux, // Yellow/Gold
          AXTheme.danger, // Red
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.5, 0.8, 1.0],
        transform: GradientRotation(animationValue * 2 * math.pi),
      ).createShader(rect);

    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==========================================
// BLINKING WIDGET
// ==========================================
class BlinkingWidget extends StatefulWidget {
  final Widget child;
  const BlinkingWidget({super.key, required this.child});
  @override
  State<BlinkingWidget> createState() => _BlinkingWidgetState();
}

class _BlinkingWidgetState extends State<BlinkingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _ctrl, child: widget.child);
  }
}
