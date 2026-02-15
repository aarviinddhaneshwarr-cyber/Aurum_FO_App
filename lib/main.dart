import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

// ==========================================
// 1. THEME ENGINE
// ==========================================

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
    fontSize: 24,
    shadows: [Shadow(color: cyanFlux.withOpacity(0.5), blurRadius: 15)],
  );
  static TextStyle get heading => GoogleFonts.cinzel(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
  );
  static TextStyle get body => GoogleFonts.montserrat(
    color: Colors.white,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  // FIX: Added 'value' style here
  static TextStyle get value => GoogleFonts.sourceCodePro(
    color: mutedGold,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
  );

  static TextStyle get digital => GoogleFonts.orbitron(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
  );

  static BoxDecoration getPanel({
    bool isActive = false,
    bool isDanger = false,
    bool isWarning = false,
    bool isManual = false,
  }) {
    Color borderColor = Colors.white10;
    if (isActive) borderColor = cyanFlux;
    if (isDanger) borderColor = danger;
    if (isWarning) borderColor = warning;
    if (isManual) borderColor = manual;

    return BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: borderColor,
        width: (isActive || isDanger || isWarning || isManual) ? 1.5 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          offset: const Offset(4, 4),
          blurRadius: 10,
        ),
        if (isActive)
          BoxShadow(color: cyanFlux.withOpacity(0.15), blurRadius: 15),
        if (isManual)
          BoxShadow(color: manual.withOpacity(0.15), blurRadius: 15),
      ],
    );
  }
}

// ==========================================
// 2. GLOBAL COMPONENTS
// ==========================================

class CyberButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isDanger;
  final bool isManual;
  final bool isSuccess;
  final bool isWarning; // FIX: Added parameter

  const CyberButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isDanger = false,
    this.isManual = false,
    this.isSuccess = false,
    this.isWarning = false, // FIX: Initialize parameter
  });

  @override
  Widget build(BuildContext context) {
    Color color = AXTheme.cyanFlux;
    if (isDanger)
      color = AXTheme.danger;
    else if (isManual)
      color = AXTheme.manual;
    else if (isSuccess)
      color = AXTheme.success;
    else if (isWarning)
      color = AXTheme.warning;

    if (onTap == null) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Center(
          child: Text(
            text,
            style: AXTheme.heading.copyWith(
              color: Colors.white24,
              fontSize: 14,
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10)],
        ),
        child: Center(
          child: Text(
            text,
            style: AXTheme.heading.copyWith(
              color: Colors.white,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class BlinkingText extends StatefulWidget {
  final String text;
  const BlinkingText({super.key, required this.text});
  @override
  State<BlinkingText> createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<BlinkingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Text(
        widget.text,
        style: AXTheme.body.copyWith(
          color: AXTheme.warning,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  SignaturePainter(this.points);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AXTheme.cyanFlux
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(ui.PointMode.points, [points[i]!], paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}

class RadarPainter extends CustomPainter {
  final double rotation;
  RadarPainter(this.rotation);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (int i = 1; i <= 3; i++) {
      paint.color = AXTheme.cyanFlux.withOpacity(0.1 * i);
      canvas.drawCircle(center, radius * (i / 3), paint);
    }
    paint.color = AXTheme.cyanFlux.withOpacity(0.1);
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      paint,
    );
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
    final sweepShader = SweepGradient(
      colors: [Colors.transparent, AXTheme.cyanFlux.withOpacity(0.5)],
      stops: const [0.5, 1.0],
      transform: GradientRotation(rotation),
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.fill
        ..shader = sweepShader,
    );
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}

// ==========================================
// 3. APP ENTRY
// ==========================================

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const AurumFOApp());
}

class AurumFOApp extends StatelessWidget {
  const AurumFOApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aurum FO',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AXTheme.titanium,
        primaryColor: AXTheme.cyanFlux,
      ),
      home: const SystemCheckScreen(),
    );
  }
}

// ==========================================
// 4. SCREEN FLOW
// ==========================================

// --- SCREEN 1: SYSTEM CHECK ---
class SystemCheckScreen extends StatefulWidget {
  const SystemCheckScreen({super.key});
  @override
  State<SystemCheckScreen> createState() => _SystemCheckScreenState();
}

class _SystemCheckScreenState extends State<SystemCheckScreen> {
  List<Map<String, dynamic>> _checks = [
    {
      "name": "SECURE SERVER LINK",
      "icon": Icons.cloud_done,
      "status": 0,
      "critical": true,
    },
    {
      "name": "GPS TRIANGULATION",
      "icon": Icons.gps_fixed,
      "status": 0,
      "critical": true,
    },
    {
      "name": "BODY CAM FEED",
      "icon": Icons.videocam,
      "status": 0,
      "critical": true,
    },
    {
      "name": "BLUETOOTH SCALE",
      "icon": Icons.bluetooth_connected,
      "status": 0,
      "critical": false,
    },
  ];
  bool _checking = true;
  bool _hasWarning = false;
  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  void _runDiagnostics() async {
    setState(() {
      _checking = true;
      _hasWarning = false;
    });
    for (int i = 0; i < _checks.length; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          if (_checks[i]['name'] == "BLUETOOTH SCALE") {
            _checks[i]['status'] = 2;
            _hasWarning = true;
          } else {
            _checks[i]['status'] = 1;
          }
        });
      }
    }
    setState(() => _checking = false);
    if (!_hasWarning) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DutyLoginScreen()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(child: Text("AURUM X", style: AXTheme.brand)),
              const SizedBox(height: 10),
              Text(
                "FIELD OFFICER TERMINAL",
                style: AXTheme.body.copyWith(
                  letterSpacing: 3,
                  color: AXTheme.cyanFlux,
                ),
              ),
              const SizedBox(height: 50),
              ..._checks.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            item['icon'],
                            color: item['status'] == 1
                                ? AXTheme.success
                                : (item['status'] == 2
                                      ? AXTheme.warning
                                      : Colors.white24),
                            size: 20,
                          ),
                          const SizedBox(width: 15),
                          Text(item['name'], style: AXTheme.body),
                        ],
                      ),
                      if (item['status'] == 1)
                        Text(
                          "OK",
                          style: AXTheme.value.copyWith(
                            color: AXTheme.success,
                            fontSize: 12,
                          ),
                        )
                      else if (item['status'] == 2)
                        Text(
                          "OFFLINE",
                          style: AXTheme.value.copyWith(
                            color: AXTheme.warning,
                            fontSize: 12,
                          ),
                        )
                      else
                        const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            color: Colors.white24,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              if (_checking)
                const CircularProgressIndicator(color: AXTheme.cyanFlux)
              else if (_hasWarning)
                CyberButton(
                  text: "PROCEED WITH WARNING",
                  isWarning: true,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DutyLoginScreen()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- SCREEN 2: LOGIN ---
class DutyLoginScreen extends StatefulWidget {
  const DutyLoginScreen({super.key});
  @override
  State<DutyLoginScreen> createState() => _DutyLoginScreenState();
}

class _DutyLoginScreenState extends State<DutyLoginScreen> {
  bool _isBondSigned = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Center(
              child: Text(
                "AURUM X",
                style: AXTheme.brand.copyWith(fontSize: 24),
              ),
            ),
            const SizedBox(height: 40),
            FadeInDown(
              child: Text(
                "OFFICER\nLOGIN",
                style: AXTheme.heading.copyWith(
                  fontSize: 32,
                  color: AXTheme.cyanFlux,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: AXTheme.getPanel(isActive: true),
              child: TextField(
                style: AXTheme.value.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: const Icon(Icons.badge, color: AXTheme.cyanFlux),
                  hintText: "OFFICER ID",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AXTheme.getPanel(isActive: false, isDanger: true),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.gavel, color: AXTheme.danger, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        "DUTY DECLARATION",
                        style: AXTheme.heading.copyWith(
                          fontSize: 14,
                          color: AXTheme.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "I hereby declare that I am sharing my live location and body-cam feed. I accept liability for assets in custody.",
                    style: AXTheme.body.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => setState(() => _isBondSigned = !_isBondSigned),
                    child: Row(
                      children: [
                        Icon(
                          _isBondSigned
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: _isBondSigned
                              ? AXTheme.success
                              : Colors.white54,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "I ACCEPT & E-SIGN",
                          style: TextStyle(
                            color: _isBondSigned
                                ? Colors.white
                                : Colors.white54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            CyberButton(
              text: "START SHIFT",
              onTap: _isBondSigned
                  ? () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RadarDashboardScreen(),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// --- SCREEN 3: RADAR ---
class RadarDashboardScreen extends StatefulWidget {
  const RadarDashboardScreen({super.key});
  @override
  State<RadarDashboardScreen> createState() => _RadarDashboardScreenState();
}

class _RadarDashboardScreenState extends State<RadarDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;
  final List<Map<String, dynamic>> _tasks = [
    {
      "name": "ARVIND SHARMA",
      "address": "B-402, Titanium Heights, Navi Mumbai",
      "distance": "2.4 KM",
      "note": "Address Confirmed. KYC Pending.",
      "priority": true,
    },
    {
      "name": "MEERA IYER",
      "address": "Villa 9, Palm Greens, Thane",
      "distance": "12 KM",
      "note": "Repeated Customer. VIP.",
      "priority": false,
    },
  ];
  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("AURUM X", style: AXTheme.brand.copyWith(fontSize: 20)),
                  Row(
                    children: [
                      const SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AXTheme.cyanFlux,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "SYNCING LOGS",
                        style: AXTheme.body.copyWith(
                          fontSize: 10,
                          color: AXTheme.cyanFlux,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _radarController,
                    builder: (_, __) => CustomPaint(
                      size: const Size(200, 200),
                      painter: RadarPainter(
                        _radarController.value * 2 * math.pi,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _tasks.length.toString(),
                        style: AXTheme.digital.copyWith(
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "ACTIVE TASKS",
                        style: AXTheme.body.copyWith(
                          color: AXTheme.cyanFlux,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: 100 * index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: AXTheme.getPanel(isActive: task['priority']),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task['name'],
                                    style: AXTheme.heading.copyWith(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    task['address'],
                                    style: AXTheme.body.copyWith(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  task['distance'],
                                  style: AXTheme.digital.copyWith(
                                    fontSize: 12,
                                    color: AXTheme.cyanFlux,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white10),
                          Row(
                            children: [
                              const Icon(
                                Icons.support_agent,
                                size: 14,
                                color: AXTheme.mutedGold,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "HQ NOTE: ${task['note']}",
                                style: AXTheme.body.copyWith(
                                  fontSize: 11,
                                  color: AXTheme.mutedGold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          CyberButton(
                            text: "ENGAGE TARGET",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ValuationScreen(taskData: task),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- SCREEN 4: VALUATION COCKPIT ---
class ValuationScreen extends StatefulWidget {
  final Map<String, dynamic>? taskData;
  const ValuationScreen({super.key, this.taskData});
  @override
  State<ValuationScreen> createState() => _ValuationScreenState();
}

class _ValuationScreenState extends State<ValuationScreen> {
  bool _isManualMode = false;
  bool _scaleConnected = false;
  bool _xrfConnected = false;
  bool _isScanningScale = false;
  bool _isScanningXrf = false;
  bool _isKaratMode = true;
  List<Map<String, dynamic>> _items = [];
  double get _totalWeight =>
      _items.fold(0.0, (sum, item) => sum + item['weight']);
  final TextEditingController _otpCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _purityCtrl = TextEditingController();

  void _toggleMode() {
    if (_isManualMode) {
      setState(() {
        _isManualMode = false;
      });
    } else {
      _otpCtrl.clear();
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: AXTheme.panel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: AXTheme.manual),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    Text(
                      "ADMIN OVERRIDE",
                      style: AXTheme.heading.copyWith(color: AXTheme.manual),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close, color: Colors.white54),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Icon(Icons.lock_open, color: AXTheme.manual, size: 40),
                const SizedBox(height: 10),
                Text(
                  "Enter OTP for Manual Entry.",
                  style: AXTheme.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _otpCtrl,
                  textAlign: TextAlign.center,
                  style: AXTheme.digital.copyWith(fontSize: 24),
                  decoration: const InputDecoration(
                    hintText: "1234",
                    hintStyle: TextStyle(color: Colors.white24),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          "CANCEL",
                          style: AXTheme.body.copyWith(color: Colors.white54),
                        ),
                      ),
                    ),
                    Expanded(
                      child: CyberButton(
                        text: "UNLOCK",
                        isManual: true,
                        onTap: () {
                          if (_otpCtrl.text == "1234") {
                            Navigator.pop(ctx);
                            setState(() => _isManualMode = true);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _connectHardware(String type) async {
    if (_isManualMode) return;
    setState(() {
      if (type == 'scale') _isScanningScale = true;
      if (type == 'xrf') _isScanningXrf = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        if (type == 'scale') {
          _isScanningScale = false;
          _scaleConnected = true;
          _weightCtrl.text = "12.67";
        }
        if (type == 'xrf') {
          _isScanningXrf = false;
          _xrfConnected = true;
          _purityCtrl.text = "22";
        }
      });
    }
  }

  void _triggerAICamera() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: 600,
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          color: AXTheme.panel,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "AI OPTICAL SCAN",
                  style: AXTheme.heading.copyWith(color: AXTheme.cyanFlux),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AXTheme.cyanFlux, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.center_focus_weak,
                    color: Colors.white54,
                    size: 80,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const LinearProgressIndicator(color: AXTheme.cyanFlux),
                      const SizedBox(height: 10),
                      Text(
                        "ANALYZING GEOMETRY & LUSTER...",
                        style: AXTheme.body.copyWith(
                          fontSize: 10,
                          color: AXTheme.cyanFlux,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            CyberButton(
              text: "CAPTURE & POPULATE",
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _nameCtrl.text = "Gold Necklace (AI)";
                  _descCtrl.text =
                      "Detected: 1 Main Piece + 2 Earrings. Red Stone setting observed.";
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AXTheme.success,
                    content: Text(
                      "AI DATA POPULATED",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addItem() {
    if (_nameCtrl.text.isEmpty ||
        _weightCtrl.text.isEmpty ||
        _purityCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AXTheme.danger,
          content: Text(
            "All fields are required.",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }
    setState(() {
      _items.add({
        "name": _nameCtrl.text,
        "desc": _descCtrl.text,
        "weight": double.parse(_weightCtrl.text),
        "purity": double.parse(_purityCtrl.text),
        "unit": _isKaratMode ? "K" : "%",
        "mode": _isManualMode ? "MANUAL" : "AUTO",
      });
      _nameCtrl.clear();
      _descCtrl.clear();
      _weightCtrl.clear();
      _purityCtrl.clear();
      if (!_isManualMode) {
        _scaleConnected = false;
        _xrfConnected = false;
      }
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    Color activeColor = _isManualMode ? AXTheme.manual : AXTheme.cyanFlux;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AXTheme.cyanFlux),
          onPressed: () {},
        ),
        title: Text(
          "VALUATION COCKPIT",
          style: AXTheme.heading.copyWith(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: AXTheme.getPanel(isActive: true),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        "TOTAL ITEMS",
                        style: AXTheme.body.copyWith(
                          color: AXTheme.cyanFlux,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${_items.length}",
                        style: AXTheme.digital.copyWith(fontSize: 28),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 50, color: Colors.white10),
                  Column(
                    children: [
                      Text(
                        "TOTAL WEIGHT",
                        style: AXTheme.body.copyWith(
                          color: AXTheme.mutedGold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${_totalWeight.toStringAsFixed(2)} g",
                        style: AXTheme.digital.copyWith(
                          fontSize: 28,
                          color: AXTheme.mutedGold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_items.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "ADDED ITEMS",
                  style: AXTheme.body.copyWith(
                    color: Colors.white38,
                    letterSpacing: 1.5,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ..._items
                  .asMap()
                  .entries
                  .map((entry) => _buildItemCard(entry.key, entry.value))
                  .toList(),
              const SizedBox(height: 20),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: _buildModeTab(
                      "🤖 AUTO SYNC",
                      !_isManualMode,
                      AXTheme.cyanFlux,
                    ),
                  ),
                  Expanded(
                    child: _buildModeTab(
                      "✍️ MANUAL ENTRY",
                      _isManualMode,
                      AXTheme.manual,
                    ),
                  ),
                ],
              ),
            ),
            if (!_isManualMode) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildHardwareSquare(
                      Icons.bluetooth,
                      "SCALE",
                      _scaleConnected,
                      _isScanningScale,
                      () => _connectHardware('scale'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildHardwareSquare(
                      Icons.qr_code_scanner,
                      "XRF",
                      _xrfConnected,
                      _isScanningXrf,
                      () => _connectHardware('xrf'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              if (!_scaleConnected || !_xrfConnected)
                const Center(
                  child: BlinkingText(
                    text: "⚠ TAP HARDWARE BUTTONS TO CONNECT",
                  ),
                )
              else
                Center(
                  child: Text(
                    "HARDWARE READY • DATA SYNCED",
                    style: AXTheme.body.copyWith(
                      color: AXTheme.success,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white10),
            ],
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "ITEM ENTRY",
                style: AXTheme.body.copyWith(
                  color: activeColor,
                  letterSpacing: 1.5,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: AXTheme.getPanel(
                isActive: true,
                isManual: _isManualMode,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _triggerAICamera,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AXTheme.cyanFlux),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.camera_alt,
                            color: AXTheme.cyanFlux,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "AUTO-FILL WITH AI CAMERA",
                            style: AXTheme.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildLabel("ORNAMENT NAME"),
                  _buildTextField(_nameCtrl, "e.g. Ring", capital: true),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("WEIGHT (g)"),
                            _buildTextField(
                              _weightCtrl,
                              "00.00",
                              isNumber: true,
                              enabled: _isManualMode,
                              color: _isManualMode
                                  ? AXTheme.manual
                                  : (_scaleConnected
                                        ? AXTheme.cyanFlux
                                        : Colors.white24),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildLabel("PURITY"),
                                if (_isManualMode)
                                  GestureDetector(
                                    onTap: () => setState(
                                      () => _isKaratMode = !_isKaratMode,
                                    ),
                                    child: Text(
                                      _isKaratMode ? "K" : "%",
                                      style: TextStyle(
                                        color: AXTheme.manual,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                else
                                  Text(
                                    _isKaratMode ? "K" : "%",
                                    style: const TextStyle(
                                      color: Colors.white24,
                                    ),
                                  ),
                              ],
                            ),
                            _buildTextField(
                              _purityCtrl,
                              "00.0",
                              isNumber: true,
                              enabled: _isManualMode,
                              color: _isManualMode
                                  ? AXTheme.manual
                                  : (_xrfConnected
                                        ? AXTheme.cyanFlux
                                        : Colors.white24),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildLabel("NOTES (OPTIONAL)"),
                  _buildTextField(
                    _descCtrl,
                    "Any remarks...",
                    maxLines: 2,
                    capital: true,
                  ),
                  const SizedBox(height: 20),
                  CyberButton(
                    text: "ADD TO LIST",
                    onTap: _addItem,
                    isManual: _isManualMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            CyberButton(
              text: "PROCEED TO AGREEMENT",
              onTap: _items.isNotEmpty
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AgreementScreen(
                          items: _items,
                          totalWeight: _totalWeight,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab(String label, bool isSelected, Color color) {
    return GestureDetector(
      onTap: _toggleMode,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? color : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AXTheme.body.copyWith(
              color: isSelected ? color : Colors.white24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHardwareSquare(
    IconData icon,
    String label,
    bool connected,
    bool scanning,
    VoidCallback onTap,
  ) {
    Color color = connected
        ? AXTheme.success
        : (scanning ? AXTheme.warning : AXTheme.danger);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: AXTheme.panel,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (scanning)
              const SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AXTheme.warning,
                ),
              )
            else
              Icon(icon, size: 35, color: color),
            const SizedBox(height: 10),
            Text(label, style: AXTheme.heading.copyWith(fontSize: 12)),
            const SizedBox(height: 5),
            Text(
              scanning ? "SCANNING..." : (connected ? "ONLINE" : "OFFLINE"),
              style: AXTheme.body.copyWith(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint, {
    bool isNumber = false,
    bool enabled = true,
    int maxLines = 1,
    Color? color,
    bool capital = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: ctrl,
        enabled: enabled,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        textCapitalization: capital
            ? TextCapitalization.sentences
            : TextCapitalization.none,
        maxLines: maxLines,
        style: isNumber
            ? AXTheme.digital.copyWith(color: color ?? Colors.white)
            : AXTheme.body.copyWith(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white12),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 2),
      child: Text(
        text,
        style: AXTheme.body.copyWith(fontSize: 9, color: Colors.white38),
      ),
    );
  }

  Widget _buildItemCard(int index, Map item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AXTheme.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['name'], style: AXTheme.heading.copyWith(fontSize: 14)),
              if (item['desc'] != null && item['desc'].isNotEmpty)
                Text(
                  item['desc'],
                  style: AXTheme.body.copyWith(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
          Row(
            children: [
              Text(
                "${item['weight']}g • ${item['purity']}${item['unit']}",
                style: AXTheme.body.copyWith(
                  color: AXTheme.cyanFlux,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AXTheme.danger,
                  size: 20,
                ),
                onPressed: () => setState(() {
                  _items.removeAt(index);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- SCREEN 5: AGREEMENT ---
class AgreementScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double totalWeight;
  const AgreementScreen({
    super.key,
    required this.items,
    required this.totalWeight,
  });
  @override
  State<AgreementScreen> createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> {
  final double _ratePerGram = 7245.0;
  double get _totalValue => widget.totalWeight * _ratePerGram;
  List<Offset?> _points = [];
  bool _isSigned = false;
  String get _weightBreakdown => widget.items
      .map((e) => "${e['weight']}g (${e['purity']}${e['unit']})")
      .join(" + ");
  void _finishDeal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PayoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AXTheme.cyanFlux),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "DIGITAL HANDSHAKE",
          style: AXTheme.heading.copyWith(fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AXTheme.getPanel(isActive: true),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "NET WEIGHT PROFILE",
                              style: AXTheme.body.copyWith(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _weightBreakdown,
                              style: AXTheme.body.copyWith(
                                fontSize: 10,
                                color: Colors.white30,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${widget.totalWeight.toStringAsFixed(2)} g",
                        style: AXTheme.value.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "EST. VALUE",
                        style: AXTheme.body.copyWith(
                          color: AXTheme.mutedGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "₹ ${_totalValue.toStringAsFixed(0)}",
                        style: AXTheme.digital.copyWith(
                          fontSize: 24,
                          color: AXTheme.mutedGold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "TERMS OF TRANSFER",
              style: AXTheme.heading.copyWith(
                fontSize: 14,
                color: AXTheme.cyanFlux,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 150,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: SingleChildScrollView(
                child: Text(
                  "1. I affirm that I am the legal owner of the items listed above.\n\n2. I understand that the items will be melted for final purity check, and I cannot claim them back in original form.\n\n3. I declare these items are not stolen or involved in any illegal activity.\n\n4. I accept the estimated value, subject to final purity test.",
                  style: AXTheme.body.copyWith(
                    height: 1.5,
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "CUSTOMER SIGNATURE",
                  style: AXTheme.heading.copyWith(fontSize: 14),
                ),
                if (_points.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() {
                      _points.clear();
                      _isSigned = false;
                    }),
                    child: Text(
                      "CLEAR",
                      style: AXTheme.body.copyWith(
                        color: AXTheme.danger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AXTheme.panel,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _isSigned ? AXTheme.success : Colors.white24,
                ),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) {
                  setState(() {
                    _points.add(details.localPosition);
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _points.add(details.localPosition);
                  });
                },
                onPanEnd: (details) => setState(() {
                  _points.add(null);
                  _isSigned = true;
                }),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CustomPaint(
                    painter: SignaturePainter(_points),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
            if (!_isSigned)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  "Sign with finger above",
                  style: AXTheme.body.copyWith(
                    fontSize: 10,
                    color: Colors.white30,
                  ),
                ),
              ),
            const SizedBox(height: 40),
            CyberButton(
              text: "LOCK DEAL & GENERATE PAYOUT",
              onTap: _isSigned ? _finishDeal : null,
            ),
          ],
        ),
      ),
    );
  }
}

// --- SCREEN 6: PAYOUT (PHASE 7.1 - SETTLEMENT DESK) ---
class PayoutScreen extends StatefulWidget {
  const PayoutScreen({super.key});
  @override
  State<PayoutScreen> createState() => _PayoutScreenState();
}

class _PayoutScreenState extends State<PayoutScreen> {
  int _step = 0;
  bool _kycDone = false;
  bool _bankDone = false;
  final TextEditingController _manualOtpCtrl = TextEditingController();

  void _sendRequestToCustomer() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Request Link Sent to Customer SMS/WhatsApp"),
      ),
    );
    await Future.delayed(const Duration(seconds: 3));
    if (mounted)
      setState(() {
        _kycDone = true;
        _bankDone = true;
      });
  }

  void _openManualEntryForm() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AXTheme.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: AXTheme.cyanFlux),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),
                  Text(
                    "FO MANUAL FILL",
                    style: AXTheme.heading.copyWith(color: AXTheme.cyanFlux),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(Icons.close, color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "To reduce risk, Customer OTP is required before FO fills sensitive data.",
                style: AXTheme.body.copyWith(
                  fontSize: 11,
                  color: Colors.white54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _manualOtpCtrl,
                textAlign: TextAlign.center,
                style: AXTheme.digital.copyWith(fontSize: 24),
                decoration: const InputDecoration(
                  hintText: "Enter OTP",
                  hintStyle: TextStyle(color: Colors.white24),
                ),
              ),
              const SizedBox(height: 20),
              CyberButton(
                text: "VERIFY OTP",
                onTap: () {
                  if (_manualOtpCtrl.text.isNotEmpty) {
                    Navigator.pop(ctx);
                    _showDetailedInputForm();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailedInputForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: 700,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AXTheme.panel,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                indicatorColor: AXTheme.cyanFlux,
                labelColor: AXTheme.cyanFlux,
                unselectedLabelColor: Colors.white24,
                tabs: [
                  Tab(text: "KYC DETAILS"),
                  Tab(text: "BANK DETAILS"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: CyberButton(
                                  text: "SCAN AADHAR",
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CyberButton(
                                  text: "SCAN PAN",
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "- OR ENTER MANUALLY -",
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField("Aadhar Number"),
                          const SizedBox(height: 10),
                          _buildTextField("PAN Number"),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: CyberButton(
                                  text: "UPI ID",
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CyberButton(
                                  text: "ACCOUNT NO",
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildTextField("Account Number"),
                          const SizedBox(height: 10),
                          _buildTextField("IFSC Code"),
                          const SizedBox(height: 10),
                          _buildTextField("Holder Name"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CyberButton(
                text: "SUBMIT & VERIFY",
                isSuccess: true,
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _kycDone = true;
                    _bankDone = true;
                    _step = 1;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        style: AXTheme.body,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
        ),
      ),
    );
  }

  void _requestCustomerApproval() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Approval Request Sent...")));
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _step = 2);
  }

  void _initiateTransfer() async {
    setState(() => _step = 3);
    await Future.delayed(const Duration(seconds: 3));
    setState(() => _step = 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const SizedBox(),
        title: Text(
          "SETTLEMENT DESK",
          style: AXTheme.heading.copyWith(fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_step == 0) ...[
              Text(
                "COMPLIANCE CHECK",
                style: AXTheme.heading.copyWith(color: AXTheme.warning),
              ),
              const SizedBox(height: 30),
              _buildCheckRow("KYC VERIFICATION", _kycDone),
              const SizedBox(height: 15),
              _buildCheckRow("BANK ACCOUNT", _bankDone),
              const SizedBox(height: 40),
              CyberButton(
                text: "SEND REQUEST TO CUSTOMER",
                onTap: _sendRequestToCustomer,
              ),
              const SizedBox(height: 15),
              Text(
                "- OR -",
                style: AXTheme.body.copyWith(color: Colors.white24),
              ),
              const SizedBox(height: 15),
              CyberButton(
                text: "FILL MANUALLY (WITH OTP)",
                isManual: true,
                onTap: _openManualEntryForm,
              ),
            ] else if (_step == 1 || _step == 2) ...[
              Text(
                "TOTAL PAYABLE",
                style: AXTheme.body.copyWith(
                  letterSpacing: 2,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "₹ 3,89,564",
                style: AXTheme.digital.copyWith(
                  fontSize: 40,
                  color: AXTheme.mutedGold,
                ),
              ),
              const SizedBox(height: 40),
              if (_step == 1) ...[
                Text(
                  "WAITING FOR APPROVAL...",
                  style: AXTheme.body.copyWith(
                    color: AXTheme.warning,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                CyberButton(
                  text: "CUSTOMER: APPROVE & ACCEPT",
                  onTap: _requestCustomerApproval,
                ),
                const SizedBox(height: 20),
                Opacity(
                  opacity: 0.5,
                  child: CyberButton(text: "INITIATE TRANSFER", onTap: null),
                ),
              ] else ...[
                Text(
                  "APPROVED BY CUSTOMER",
                  style: AXTheme.body.copyWith(
                    color: AXTheme.success,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                CyberButton(
                  text: "INITIATE TRANSFER",
                  onTap: _initiateTransfer,
                ),
              ],
            ] else if (_step == 3) ...[
              const CircularProgressIndicator(color: AXTheme.cyanFlux),
              const SizedBox(height: 20),
              Text(
                "ENCRYPTING TRANSACTION...",
                style: AXTheme.body.copyWith(letterSpacing: 2),
              ),
            ] else ...[
              const Icon(Icons.check_circle, size: 80, color: AXTheme.success),
              const SizedBox(height: 20),
              Text(
                "PAYMENT SUCCESSFUL",
                style: AXTheme.heading.copyWith(color: AXTheme.success),
              ),
              const SizedBox(height: 10),
              Text("REF ID: TXN-8829-X99", style: AXTheme.value),
              const SizedBox(height: 50),
              CyberButton(
                text: "COMPLETE MISSION",
                isSuccess: true,
                onTap: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RadarDashboardScreen(),
                  ),
                  (route) => false,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCheckRow(String label, bool isDone) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AXTheme.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDone ? AXTheme.success : AXTheme.danger),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AXTheme.body),
          Icon(
            isDone ? Icons.check_circle : Icons.cancel,
            color: isDone ? AXTheme.success : AXTheme.danger,
          ),
        ],
      ),
    );
  }
}
