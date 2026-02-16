import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

// ==========================================
// 1. CONFIG & THEME
// ==========================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const AurumFOApp());
}

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

class AurumFOApp extends StatelessWidget {
  const AurumFOApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aurum FO Protocol',
      theme:
          ThemeData.dark().copyWith(scaffoldBackgroundColor: AXTheme.titanium),
      home: const SystemBootScreen(),
    );
  }
}

// ==========================================
// 3. SYSTEM BOOT
// ==========================================

class SystemBootScreen extends StatefulWidget {
  const SystemBootScreen({super.key});
  @override
  State<SystemBootScreen> createState() => _SystemBootScreenState();
}

class _SystemBootScreenState extends State<SystemBootScreen> {
  int _gpsStatus = 0;
  int _btStatus = 0;
  int _camStatus = 0;
  int _bioStatus = 0;
  String _logText = "INITIALIZING TITANIUM KERNEL...";
  bool _allSystemsGo = false;
  bool _showOverride = false;

  @override
  void initState() {
    super.initState();
    _initiateBootSequence();
  }

  Future<void> _initiateBootSequence() async {
    setState(() {
      _allSystemsGo = false;
      _showOverride = false;
      _logText = "INITIALIZING...";
    });
    _updateLog("PINGING SATELLITES...", 1, 0, 0, 0);
    try {
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied)
        p = await Geolocator.requestPermission();
      bool isOn = await Geolocator.isLocationServiceEnabled();
      _gpsStatus = (p == LocationPermission.deniedForever || !isOn) ? 3 : 2;
    } catch (e) {
      _gpsStatus = 3;
    }
    setState(() {});

    _updateLog("SCANNING OPTICS...", _gpsStatus, 1, 0, 0);
    await Future.delayed(const Duration(milliseconds: 500));
    _btStatus = 2;
    try {
      final cams = await availableCameras();
      _camStatus = cams.isNotEmpty ? 2 : 3;
    } catch (e) {
      _camStatus = 3;
    }
    setState(() {});

    _updateLog("VERIFYING IDENTITY...", _gpsStatus, _btStatus, _camStatus, 1);
    try {
      final auth = LocalAuthentication();
      bool can =
          await auth.canCheckBiometrics || await auth.isDeviceSupported();
      _bioStatus = can ? 2 : 3;
    } catch (e) {
      _bioStatus = 3;
    }
    setState(() {});

    await Future.delayed(const Duration(milliseconds: 500));
    if (_gpsStatus == 2 && _camStatus == 2) {
      _updateLog("SYSTEMS OPTIMAL. READY.", _gpsStatus, _btStatus, _camStatus,
          _bioStatus);
      setState(() => _allSystemsGo = true);
    } else {
      _updateLog("CRITICAL HARDWARE FAILURE.", _gpsStatus, _btStatus,
          _camStatus, _bioStatus);
      setState(() {
        _allSystemsGo = false;
        _showOverride = true;
      });
    }
  }

  void _updateLog(String text, int g, int b, int c, int bi) {
    setState(() {
      _logText = text;
      _gpsStatus = g;
      _btStatus = b;
      _camStatus = c;
      _bioStatus = bi;
    });
  }

  void _adminOverride() {
    TextEditingController otpCtrl = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
            backgroundColor: AXTheme.panel,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AXTheme.manual)),
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text("ADMIN OVERRIDE",
                      style: AXTheme.heading.copyWith(color: AXTheme.manual)),
                  const SizedBox(height: 20),
                  TextField(
                      controller: otpCtrl,
                      textAlign: TextAlign.center,
                      style: AXTheme.input,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintText: "CODE (9999)",
                          hintStyle: TextStyle(color: Colors.white24))),
                  const SizedBox(height: 20),
                  CyberButton(
                      text: "FORCE UNLOCK",
                      isManual: true,
                      onTap: () {
                        if (otpCtrl.text == "9999") {
                          Navigator.pop(ctx);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const DutyLoginScreen()));
                        }
                      })
                ]))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(fit: StackFit.expand, children: [
      CustomPaint(painter: GridPainter()),
      SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(children: [
                const SizedBox(height: 40),
                Center(
                    child: FadeInDown(
                        child: Text("AURUM X", style: AXTheme.brand))),
                Center(
                    child: Text("SECURE TERMINAL v1.7",
                        style: AXTheme.terminal.copyWith(
                            letterSpacing: 2, color: Colors.white54))),
                const Spacer(),
                _buildStatus("GPS TRIANGULATION", Icons.gps_fixed, _gpsStatus),
                const SizedBox(height: 20),
                _buildStatus("BLUETOOTH LINK", Icons.bluetooth, _btStatus),
                const SizedBox(height: 20),
                _buildStatus("OPTICAL SENSORS", Icons.camera_alt, _camStatus),
                const SizedBox(height: 20),
                _buildStatus("BIOMETRIC CORE", Icons.fingerprint, _bioStatus),
                const Spacer(),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(
                                color: _allSystemsGo
                                    ? AXTheme.success
                                    : (_showOverride
                                        ? AXTheme.danger
                                        : AXTheme.cyanFlux.withOpacity(0.3))),
                            borderRadius: BorderRadius.circular(5)),
                        child: Text("> $_logText${_allSystemsGo ? '' : '_'}",
                            style: AXTheme.terminal.copyWith(
                                color: _showOverride
                                    ? AXTheme.danger
                                    : AXTheme.cyanFlux)))),
                const SizedBox(height: 30),
                if (_allSystemsGo)
                  Center(
                      child: FadeInUp(
                          child: CyberButton(
                              text: "ACCESS LOGIN",
                              onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const DutyLoginScreen()))))),
                if (_showOverride) ...[
                  FadeInUp(
                      child: CyberButton(
                          text: "RETRY SYSTEM LINK",
                          isWarning: true,
                          onTap: _initiateBootSequence)),
                  const SizedBox(height: 10),
                  FadeInUp(
                      child: CyberButton(
                          text: "ADMIN BYPASS",
                          isManual: true,
                          onTap: _adminOverride))
                ],
              ])))
    ]));
  }

  Widget _buildStatus(String l, IconData i, int s) {
    Color c = s == 1
        ? AXTheme.cyanFlux
        : (s == 2
            ? AXTheme.success
            : (s == 3 ? AXTheme.danger : Colors.white24));
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        Icon(i, color: c, size: 22),
        const SizedBox(width: 15),
        Text(l,
            style: AXTheme.status.copyWith(fontSize: 12, color: Colors.white70))
      ]),
      s == 1
          ? SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(strokeWidth: 2, color: c))
          : Text(s == 0 ? "WAITING" : (s == 2 ? "ONLINE" : "OFFLINE"),
              style: AXTheme.terminal
                  .copyWith(color: c, fontWeight: FontWeight.bold))
    ]);
  }
}

// ==========================================
// 4. DUTY LOGIN & 5. DASHBOARD
// ==========================================
class DutyLoginScreen extends StatefulWidget {
  const DutyLoginScreen({super.key});
  @override
  State<DutyLoginScreen> createState() => _DutyLoginScreenState();
}

class _DutyLoginScreenState extends State<DutyLoginScreen> {
  final TextEditingController _idCtrl = TextEditingController();
  bool _isBioVerified = false;
  bool _isBondSigned = false;
  bool _isLoading = false;
  final _upperCaseFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
    return TextEditingValue(
        text: newValue.text.toUpperCase(), selection: newValue.selection);
  });
  void _startShift() async {
    if (_idCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: AXTheme.danger,
          content: Text("OFFICER ID REQUIRED!")));
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted)
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const RadarDashboardScreen()));
  }

  @override
  Widget build(BuildContext context) {
    bool isFormValid =
        _isBioVerified && _isBondSigned && _idCtrl.text.isNotEmpty;
    return Scaffold(
        body: Stack(fit: StackFit.expand, children: [
      CustomPaint(painter: GridPainter()),
      SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 60),
            Center(
                child: Text("IDENTITY VERIFICATION",
                    style: AXTheme.heading
                        .copyWith(fontSize: 18, color: AXTheme.cyanFlux))),
            const SizedBox(height: 40),
            Text("OFFICER ID", style: AXTheme.terminal),
            const SizedBox(height: 10),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: AXTheme.getPanel(isActive: true),
                child: TextField(
                    controller: _idCtrl,
                    inputFormatters: [_upperCaseFormatter],
                    style: AXTheme.input,
                    onChanged: (val) => setState(() {}),
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "FO-XXXX",
                        hintStyle: TextStyle(color: Colors.white24)))),
            const SizedBox(height: 30),
            Text("BIOMETRIC AUTH", style: AXTheme.terminal),
            const SizedBox(height: 10),
            GestureDetector(
                onTap: () {
                  setState(() => _isBioVerified = true);
                },
                child: Container(
                    height: 80,
                    decoration: AXTheme.getPanel(isActive: _isBioVerified),
                    child: Center(
                        child: _isBioVerified
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    const Icon(Icons.check_circle,
                                        color: AXTheme.success, size: 30),
                                    const SizedBox(width: 15),
                                    Text("IDENTITY CONFIRMED",
                                        style: AXTheme.status
                                            .copyWith(color: AXTheme.success))
                                  ])
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    const Icon(Icons.fingerprint,
                                        color: AXTheme.cyanFlux, size: 40),
                                    const SizedBox(width: 15),
                                    Text("TAP TO SCAN",
                                        style: AXTheme.status
                                            .copyWith(color: AXTheme.cyanFlux))
                                  ])))),
            const SizedBox(height: 30),
            Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: AXTheme.danger.withOpacity(0.1),
                    border: Border.all(color: AXTheme.danger.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.gavel,
                            color: AXTheme.danger, size: 20),
                        const SizedBox(width: 10),
                        Text("DUTY DECLARATION",
                            style: AXTheme.heading
                                .copyWith(fontSize: 14, color: AXTheme.danger))
                      ]),
                      const SizedBox(height: 15),
                      Text(
                          "I hereby declare that I am sharing my live location and body-cam feed. I accept full liability for all assets.",
                          style:
                              AXTheme.body.copyWith(height: 1.5, fontSize: 11)),
                      const SizedBox(height: 20),
                      GestureDetector(
                          onTap: () {
                            setState(() => _isBondSigned = !_isBondSigned);
                          },
                          child: Row(children: [
                            Icon(
                                _isBondSigned
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: _isBondSigned
                                    ? AXTheme.success
                                    : Colors.white54),
                            const SizedBox(width: 10),
                            Text("I ACCEPT & E-SIGN",
                                style: TextStyle(
                                    color: _isBondSigned
                                        ? Colors.white
                                        : Colors.white54,
                                    fontWeight: FontWeight.bold))
                          ]))
                    ])),
            const SizedBox(height: 40),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AXTheme.cyanFlux))
                : CyberButton(
                    text: "START SHIFT",
                    onTap: isFormValid ? _startShift : null,
                    isManual: !isFormValid)
          ]))
    ]));
  }
}

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
      "dist": "2.4 KM",
      "priority": true,
      "status": "PENDING",
      "note": "Address Verified. VIP Client."
    },
    {
      "name": "MEERA IYER",
      "address": "Villa 9, Palm Greens, Thane",
      "dist": "12 KM",
      "priority": false,
      "status": "SCHEDULED",
      "note": "KYC Pending."
    }
  ];
  @override
  void initState() {
    super.initState();
    _radarController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  void _callCustomer(String name) {
    launchUrl(Uri.parse("tel:+919876543210"));
  }

  void _triggerPanic() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
                backgroundColor: AXTheme.panel,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: AXTheme.danger, width: 2)),
                title: Row(children: [
                  const Icon(Icons.warning, color: AXTheme.danger, size: 30),
                  const SizedBox(width: 10),
                  Text("PANIC ALERT",
                      style: AXTheme.heading.copyWith(color: AXTheme.danger))
                ]),
                content: Text(
                    "Silent Alarm Triggered.\nLive Audio/Video Feed sent to HQ.",
                    style: AXTheme.body),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text("FALSE ALARM",
                          style: AXTheme.body.copyWith(color: Colors.white54)))
                ]));
  }

  void _navigateToValuation(Map<String, dynamic> task) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => ValuationScreen(taskData: task)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(fit: StackFit.expand, children: [
      CustomPaint(painter: GridPainter()),
      SafeArea(
          child: Column(children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("AURUM X",
                            style: AXTheme.brand.copyWith(fontSize: 18)),
                        Text("UNIT: FO-007", style: AXTheme.terminal)
                      ]),
                  Row(children: [
                    _buildStatusBadge("GPS", true),
                    const SizedBox(width: 5),
                    _buildStatusBadge("BODY CAM", true),
                    const SizedBox(width: 5),
                    const Icon(Icons.battery_charging_full,
                        color: AXTheme.success, size: 20)
                  ])
                ])),
        const SizedBox(height: 10),
        SizedBox(
            height: 250,
            width: double.infinity,
            child: Stack(alignment: Alignment.center, children: [
              AnimatedBuilder(
                  animation: _radarController,
                  builder: (_, __) => CustomPaint(
                      size: const Size(220, 220),
                      painter:
                          RadarPainter(_radarController.value * 2 * math.pi))),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("${_tasks.length}",
                    style: AXTheme.digital
                        .copyWith(fontSize: 40, color: Colors.white)),
                Text("TARGETS", style: AXTheme.terminal)
              ]),
              Positioned(top: 60, right: 80, child: _buildBlinkingDot()),
              Positioned(bottom: 80, left: 90, child: _buildBlinkingDot())
            ])),
        const SizedBox(height: 10),
        Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text("MISSION MANIFEST",
                    style: AXTheme.terminal
                        .copyWith(letterSpacing: 2, color: Colors.white54)))),
        const SizedBox(height: 10),
        Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return FadeInUp(
                      delay: Duration(milliseconds: 200 * index),
                      child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(15),
                          decoration:
                              AXTheme.getPanel(isActive: task['priority']),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(task['name'],
                                          style: AXTheme.heading
                                              .copyWith(fontSize: 16)),
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                              color: task['priority']
                                                  ? AXTheme.cyanFlux
                                                  : Colors.white10,
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          child: Text(task['dist'],
                                              style: AXTheme.terminal.copyWith(
                                                  color: task['priority']
                                                      ? Colors.black
                                                      : Colors.white,
                                                  fontWeight: FontWeight.bold)))
                                    ]),
                                const SizedBox(height: 5),
                                Text(task['address'],
                                    style: AXTheme.body.copyWith(
                                        fontSize: 11, color: Colors.white60)),
                                const SizedBox(height: 10),
                                const Divider(color: Colors.white10),
                                const SizedBox(height: 5),
                                Row(children: [
                                  const Icon(Icons.support_agent,
                                      size: 14, color: AXTheme.mutedGold),
                                  const SizedBox(width: 8),
                                  Text("HQ NOTE: ${task['note']}",
                                      style: AXTheme.body.copyWith(
                                          fontSize: 11,
                                          color: AXTheme.mutedGold))
                                ]),
                                const SizedBox(height: 15),
                                Row(children: [
                                  Expanded(
                                      child: CyberButton(
                                          text: "CALL",
                                          isWarning: true,
                                          onTap: () =>
                                              _callCustomer(task['name']))),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: CyberButton(
                                          text: "ENGAGE",
                                          isManual: !task['priority'],
                                          onTap: task['priority']
                                              ? () => _navigateToValuation(task)
                                              : null))
                                ])
                              ])));
                }))
      ])),
      Positioned(
          bottom: 20,
          right: 20,
          child: PanicButton(onPanicTriggered: _triggerPanic))
    ]));
  }

  Widget _buildStatusBadge(String text, bool isOnline) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            border:
                Border.all(color: isOnline ? AXTheme.success : AXTheme.danger),
            borderRadius: BorderRadius.circular(3)),
        child: Text(text,
            style: TextStyle(
                fontSize: 8,
                color: isOnline ? AXTheme.success : AXTheme.danger,
                fontWeight: FontWeight.bold)));
  }

  Widget _buildBlinkingDot() {
    return BlinkingWidget(
        child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                color: AXTheme.warning,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AXTheme.warning, blurRadius: 5)
                ])));
  }
}

// ==========================================
// 6. VALUATION COCKPIT
// ==========================================

class ValuationScreen extends StatefulWidget {
  final Map<String, dynamic>? taskData;
  const ValuationScreen({super.key, this.taskData});
  @override
  State<ValuationScreen> createState() => _ValuationScreenState();
}

class _ValuationScreenState extends State<ValuationScreen> {
  bool _isManualMode = false;
  bool _isKaratMode = true;
  bool _aiDone = false;
  bool _scaleDone = false;
  bool _xrfDone = false;
  List<Map<String, dynamic>> _items = [];

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _purityCtrl = TextEditingController();
  String _aiOriginalName = "";
  String _aiOriginalDesc = "";

  List<Map<String, dynamic>> get _displayItems =>
      _items.where((i) => i['isManual'] == _isManualMode).toList();
  double get _displayWeight => _displayItems.fold(
      0.0, (sum, item) => sum + double.parse(item['weight']));
  double get _avgPurity {
    if (_displayItems.isEmpty) return 0.0;
    double totalFine = 0.0;
    for (var item in _displayItems) {
      totalFine +=
          (double.parse(item['weight']) * double.parse(item['purity']));
    }
    return _displayWeight == 0 ? 0.0 : (totalFine / _displayWeight);
  }

  void _addItem() {
    if (!_isManualMode) {
      if (!_aiDone || !_scaleDone || !_xrfDone) {
        _showError("SYNC PENDING: Check AI, Scale & XRF");
        return;
      }
    }
    if (_nameCtrl.text.isEmpty ||
        _weightCtrl.text.isEmpty ||
        _purityCtrl.text.isEmpty) {
      _showError("FIELDS EMPTY");
      return;
    }
    setState(() {
      _items.add({
        "name": _nameCtrl.text,
        "desc": _descCtrl.text,
        "weight": _weightCtrl.text,
        "purity": _purityCtrl.text,
        "unit": _isKaratMode ? "K" : "%",
        "isManual": _isManualMode,
        "aiOriginal": _aiOriginalName
      });
      _resetForm();
    });
  }

  void _resetForm() {
    _nameCtrl.clear();
    _descCtrl.clear();
    _weightCtrl.clear();
    _purityCtrl.clear();
    _aiOriginalName = "";
    _aiOriginalDesc = "";
    _aiDone = false;
    _scaleDone = false;
    _xrfDone = false;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AXTheme.danger,
        content: Text(msg, style: AXTheme.heading.copyWith(fontSize: 12))));
  }

  void _deleteItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    backgroundColor: AXTheme.panel,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: AXTheme.danger)),
                    title: Text("WARNING: DATA LOSS",
                        style: AXTheme.heading.copyWith(color: AXTheme.danger)),
                    content: Text(
                        "Leaving this screen will clear all entered items. Are you sure?",
                        style: AXTheme.body),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("CANCEL",
                              style: TextStyle(color: Colors.white))),
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("EXIT & CLEAR",
                              style: TextStyle(color: AXTheme.danger)))
                    ]))) ??
        false;
  }

  void _showHardwarePopup(String type) {
    String title = type == "AI"
        ? "ANALYZING ORNAMENT..."
        : (type == "SCALE" ? "CONNECTING SCALE..." : "CALIBRATING XRF...");
    IconData icon = type == "AI"
        ? Icons.qr_code_scanner
        : (type == "SCALE" ? Icons.line_weight : Icons.science);
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
            height: 400,
            decoration: const BoxDecoration(
                color: AXTheme.panel,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 80, color: AXTheme.cyanFlux),
              const SizedBox(height: 20),
              Text(title, style: AXTheme.heading),
              const SizedBox(height: 20),
              CyberButton(
                  text: "CAPTURE DATA",
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      if (type == "AI") {
                        _aiDone = true;
                        _aiOriginalName = "Gold Bangle";
                        _aiOriginalDesc = "Red stone setting";
                        _nameCtrl.text = _aiOriginalName;
                        _descCtrl.text = _aiOriginalDesc;
                      } else if (type == "SCALE") {
                        _scaleDone = true;
                        _weightCtrl.text = "12.50";
                      } else if (type == "XRF") {
                        _xrfDone = true;
                        _purityCtrl.text = "22.0";
                      }
                    });
                  })
            ])));
  }

  void _triggerManualOverride() {
    TextEditingController otpCtrl = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
            backgroundColor: AXTheme.panel,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AXTheme.manual)),
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text("MANUAL OVERRIDE",
                      style: AXTheme.heading.copyWith(color: AXTheme.manual)),
                  const SizedBox(height: 20),
                  TextField(
                      controller: otpCtrl,
                      textAlign: TextAlign.center,
                      style: AXTheme.input,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintText: "CODE (9999)",
                          hintStyle: TextStyle(color: Colors.white24))),
                  const SizedBox(height: 20),
                  CyberButton(
                      text: "UNLOCK",
                      isManual: true,
                      onTap: () {
                        if (otpCtrl.text == "9999") {
                          Navigator.pop(ctx);
                          setState(() => _isManualMode = true);
                        }
                      })
                ]))));
  }

  @override
  Widget build(BuildContext context) {
    Color activeColor = _isManualMode ? AXTheme.manual : AXTheme.cyanFlux;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: activeColor),
                  onPressed: () => _onWillPop().then((val) {
                        if (val) Navigator.pop(context);
                      })),
              title: Text(
                  _isManualMode ? "MANUAL ENTRY MODE" : "AUTO VALUATION MODE",
                  style: AXTheme.heading
                      .copyWith(color: activeColor, fontSize: 14)),
              actions: [
                if (_isManualMode)
                  IconButton(
                      icon: const Icon(Icons.restore, color: Colors.white),
                      onPressed: () => setState(() => _isManualMode = false))
              ]),
          body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AXTheme.getPanel(
                        isActive: !_isManualMode, isManual: _isManualMode),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(children: [
                            Text("ITEMS", style: AXTheme.terminal),
                            Text("${_displayItems.length}",
                                style: AXTheme.digital.copyWith(fontSize: 24))
                          ]),
                          Container(
                              width: 1, height: 30, color: Colors.white24),
                          Column(children: [
                            Text("WEIGHT", style: AXTheme.terminal),
                            Text("${_displayWeight.toStringAsFixed(2)} g",
                                style: AXTheme.digital.copyWith(
                                    fontSize: 24, color: AXTheme.mutedGold))
                          ])
                        ])),
                const SizedBox(height: 20),
                if (_displayItems.isNotEmpty)
                  ...List.generate(_displayItems.length, (index) {
                    final e = _displayItems[index];
                    return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: AXTheme.panel,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _isManualMode
                                    ? AXTheme.manual.withOpacity(0.5)
                                    : Colors.white10)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e['name'],
                                        style: AXTheme.heading
                                            .copyWith(fontSize: 14)),
                                    if (e['desc'] != null)
                                      Text(e['desc'],
                                          style: AXTheme.body.copyWith(
                                              fontSize: 10,
                                              color: Colors.white54))
                                  ]),
                              Row(children: [
                                Text(
                                    "${e['weight']}g | ${e['purity']}${e['unit']}",
                                    style:
                                        AXTheme.value.copyWith(fontSize: 12)),
                                const SizedBox(width: 10),
                                IconButton(
                                    onPressed: () => _deleteItem(index),
                                    icon: const Icon(Icons.delete,
                                        color: AXTheme.danger, size: 20))
                              ])
                            ]));
                  }),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                      child: MagicalNeonButton(
                          text: "AI SCAN",
                          icon: Icons.qr_code_scanner,
                          isDone: _aiDone,
                          activeColor: activeColor,
                          onTap: () => _showHardwarePopup("AI"))),
                  if (!_isManualMode) ...[
                    const SizedBox(width: 10),
                    Expanded(
                        child: MagicalNeonButton(
                            text: "SCALE",
                            icon: Icons.line_weight,
                            isDone: _scaleDone,
                            activeColor: activeColor,
                            onTap: () => _showHardwarePopup("SCALE"))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: MagicalNeonButton(
                            text: "XRF",
                            icon: Icons.science,
                            isDone: _xrfDone,
                            activeColor: activeColor,
                            onTap: () => _showHardwarePopup("XRF")))
                  ]
                ]),
                const SizedBox(height: 20),
                Container(
                    padding: const EdgeInsets.all(15),
                    decoration: AXTheme.getPanel(isManual: _isManualMode),
                    child: Column(children: [
                      _buildInputBox(
                          _nameCtrl, "Item Name", "Original: $_aiOriginalName"),
                      const SizedBox(height: 10),
                      _buildInputBox(_descCtrl, "Description",
                          "Original: $_aiOriginalDesc",
                          maxLines: 2),
                      const SizedBox(height: 15),
                      Row(children: [
                        Expanded(
                            child: _buildBorderedField(
                                _weightCtrl, "Weight (g)",
                                isNumber: true)),
                        const SizedBox(width: 15),
                        Expanded(
                            child: Row(children: [
                          Expanded(
                              child: _buildBorderedField(_purityCtrl, "Purity",
                                  isNumber: true)),
                          const SizedBox(width: 5),
                          GestureDetector(
                              onTap: _isManualMode
                                  ? () => setState(
                                      () => _isKaratMode = !_isKaratMode)
                                  : null,
                              child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      border: Border.all(color: activeColor),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text(_isKaratMode ? "K" : "%",
                                      style: TextStyle(
                                          color: activeColor,
                                          fontWeight: FontWeight.bold))))
                        ]))
                      ]),
                      const SizedBox(height: 20),
                      Row(children: [
                        if (!_isManualMode)
                          GestureDetector(
                              onTap: _triggerManualOverride,
                              child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: AXTheme.manual),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.lock,
                                      color: AXTheme.manual))),
                        if (_isManualMode)
                          GestureDetector(
                              onTap: () =>
                                  setState(() => _isManualMode = false),
                              child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: AXTheme.cyanFlux),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.autorenew,
                                      color: AXTheme.cyanFlux))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: CyberButton(
                                text: _isManualMode
                                    ? "SAVE MANUAL ENTRY"
                                    : "ADD ITEM TO MANIFEST",
                                onTap: _addItem,
                                isManual: _isManualMode))
                      ])
                    ])),
                const SizedBox(height: 30),
                if (_items.isNotEmpty)
                  FadeInUp(
                      child: CyberButton(
                          text: "PROCEED TO AGREEMENT >",
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AgreementScreen(
                                      items: _displayItems,
                                      totalWeight: _displayWeight,
                                      avgPurity: _avgPurity))),
                          isManual: false))
              ]))),
    );
  }

  Widget _buildInputBox(TextEditingController c, String h, String o,
      {int maxLines = 1}) {
    bool e = o.isNotEmpty && c.text != o;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildBorderedField(c, h, maxLines: maxLines),
      if (e)
        Padding(
            padding: const EdgeInsets.only(left: 5, top: 2),
            child: Text(o,
                style: const TextStyle(
                    color: AXTheme.warning,
                    fontSize: 10,
                    fontStyle: FontStyle.italic)))
    ]);
  }

  Widget _buildBorderedField(TextEditingController c, String h,
      {bool isNumber = false, int maxLines = 1}) {
    Color b = _isManualMode ? AXTheme.manual : AXTheme.cyanFlux;
    return TextField(
        controller: c,
        enabled: _isManualMode ||
            (_aiDone && (h.contains("Name") || h.contains("Desc"))),
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        inputFormatters: isNumber ? [LengthLimitingTextInputFormatter(6)] : [],
        style: isNumber ? AXTheme.value : AXTheme.body,
        maxLines: maxLines,
        decoration: InputDecoration(
            labelText: h,
            labelStyle: const TextStyle(color: Colors.white30, fontSize: 12),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white12),
                borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: b),
                borderRadius: BorderRadius.circular(10)),
            disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.black,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15)));
  }
}

// ==========================================
// 7. AGREEMENT SCREEN (FAST SIGNATURE WIDGET)
// ==========================================

class AgreementScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double totalWeight;
  final double avgPurity;
  const AgreementScreen(
      {super.key,
      required this.items,
      required this.totalWeight,
      required this.avgPurity});
  @override
  State<AgreementScreen> createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> {
  // MUTABLE LIST FOR AGREEMENT SCREEN
  late List<Map<String, dynamic>> _finalItems;
  double _chargePercent = 12.0;
  final double _discountPercent = 3.0;
  final double _goldRate = 7245.0;

  @override
  void initState() {
    super.initState();
    _finalItems = List.from(widget.items);
  }

  double get _grossValuation {
    double total = 0.0;
    for (var item in _finalItems) {
      double w = double.parse(item['weight']);
      double p = double.parse(item['purity']);
      total += w * (p / 24.0) * _goldRate;
    }
    return total;
  }

  double get _chargeAmount => _grossValuation * (_chargePercent / 100);
  double get _discountAmount => _grossValuation * (_discountPercent / 100);
  double get _netPayout => _grossValuation - _chargeAmount + _discountAmount;
  double get _totalWeight =>
      _finalItems.fold(0.0, (sum, item) => sum + double.parse(item['weight']));
  double get _avgPurity {
    if (_finalItems.isEmpty) return 0.0;
    double totalFine = 0.0;
    for (var item in _finalItems) {
      totalFine +=
          (double.parse(item['weight']) * double.parse(item['purity']));
    }
    return _totalWeight == 0 ? 0.0 : (totalFine / _totalWeight);
  }

  void _showNegotiationDialog() {
    double tempCharge = _chargePercent;
    TextEditingController otpCtrl = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(builder: (context, setDialogState) {
              String authRequired = "";
              if (tempCharge < 9.0)
                authRequired = "CFO APPROVAL REQUIRED";
              else if (tempCharge < 11.5)
                authRequired = "ADMIN APPROVAL REQUIRED";
              return Dialog(
                  backgroundColor: AXTheme.panel,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: AXTheme.manual)),
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text("NEGOTIATION OVERRIDE",
                            style: AXTheme.heading
                                .copyWith(color: AXTheme.manual)),
                        const SizedBox(height: 20),
                        Text(
                            "Current Charges: ${tempCharge.toStringAsFixed(1)}%",
                            style: AXTheme.value),
                        Slider(
                            value: tempCharge,
                            min: 6.0,
                            max: 12.0,
                            divisions: 12,
                            activeColor: AXTheme.manual,
                            onChanged: (v) =>
                                setDialogState(() => tempCharge = v)),
                        if (authRequired.isNotEmpty)
                          Text(authRequired,
                              style: AXTheme.body.copyWith(
                                  color: AXTheme.warning, fontSize: 10)),
                        const SizedBox(height: 10),
                        if (tempCharge < 11.5)
                          TextField(
                              controller: otpCtrl,
                              textAlign: TextAlign.center,
                              style: AXTheme.input,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  hintText: "ENTER OTP",
                                  hintStyle: TextStyle(color: Colors.white24))),
                        const SizedBox(height: 20),
                        CyberButton(
                            text: "AUTHORIZE CHANGE",
                            isManual: true,
                            onTap: () {
                              bool authorized = false;
                              if (tempCharge >= 11.5)
                                authorized = true;
                              else if (tempCharge >= 9.0 &&
                                  otpCtrl.text == "1111")
                                authorized = true;
                              else if (tempCharge < 9.0 &&
                                  otpCtrl.text == "2222") authorized = true;
                              if (authorized) {
                                setState(() => _chargePercent = tempCharge);
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    backgroundColor: AXTheme.success,
                                    content: Text(
                                        "CHARGES UPDATED TO ${tempCharge.toStringAsFixed(1)}%")));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        backgroundColor: AXTheme.danger,
                                        content: Text(
                                            "INVALID OTP OR UNAUTHORIZED")));
                              }
                            })
                      ])));
            }));
  }

  void _removeItem(int index) {
    setState(() {
      _finalItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AXTheme.cyanFlux),
                onPressed: () => Navigator.pop(context)),
            title: Text("CUSTOMER AGREEMENT",
                style: AXTheme.heading.copyWith(fontSize: 16))),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // SUMMARY CARD
              Text("PROVISIONAL ESTIMATION", style: AXTheme.terminal),
              const SizedBox(height: 10),
              Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AXTheme.getPanel(isActive: true),
                  child: Column(children: [
                    _buildRow(
                        "Gross Valuation",
                        "₹ ${_grossValuation.toStringAsFixed(0)}",
                        Colors.white),
                    const SizedBox(height: 10),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                              onTap: _showNegotiationDialog,
                              child: Text(
                                  "Aurum Charges (${_chargePercent.toStringAsFixed(1)}%)",
                                  style: AXTheme.body)),
                          Text("- ₹ ${_chargeAmount.toStringAsFixed(0)}",
                              style:
                                  AXTheme.value.copyWith(color: AXTheme.danger))
                        ]),
                    // DESCRIPTION TEXT FOR CHARGES
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            "(Onsite Spectrometry • Secure Logistics • Refining & Melt-Loss • Compliance)",
                            style:
                                TextStyle(color: Colors.white30, fontSize: 8))),
                    const SizedBox(height: 10),
                    _buildRow(
                        "Priority Waiver (3%)",
                        "+ ₹ ${_discountAmount.toStringAsFixed(0)}",
                        AXTheme.success),
                    // DESCRIPTION TEXT FOR DISCOUNT
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            "(Conditional Benefit for High-Integrity Assets)",
                            style:
                                TextStyle(color: Colors.white30, fontSize: 8))),
                    const Divider(color: Colors.white24, height: 30),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("NET PAYOUT",
                              style: AXTheme.heading.copyWith(fontSize: 16)),
                          Text("₹ ${_netPayout.toStringAsFixed(0)}",
                              style: AXTheme.digital.copyWith(
                                  fontSize: 22, color: AXTheme.mutedGold))
                        ]),
                  ])),
              const SizedBox(height: 20),

              // ITEMIZED LIST IN AGREEMENT (Requested Update)
              Text("ITEMIZED BREAKDOWN", style: AXTheme.terminal),
              const SizedBox(height: 10),
              if (_finalItems.isEmpty)
                Center(
                    child: Text("NO ITEMS LEFT IN DEAL",
                        style: AXTheme.body.copyWith(color: AXTheme.danger))),
              ...List.generate(_finalItems.length, (index) {
                var item = _finalItems[index];
                double val = double.parse(item['weight']) *
                    (double.parse(item['purity']) / 24.0) *
                    _goldRate;
                return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'],
                                    style: AXTheme.body.copyWith(fontSize: 12)),
                                Text("${item['weight']}g @ ${item['purity']}K",
                                    style: AXTheme.value.copyWith(fontSize: 10))
                              ]),
                          Row(children: [
                            Text("₹${val.toStringAsFixed(0)}",
                                style: AXTheme.digital.copyWith(
                                    fontSize: 12, color: AXTheme.success)),
                            const SizedBox(width: 10),
                            GestureDetector(
                                onTap: () => _removeItem(index),
                                child: const Icon(Icons.delete_outline,
                                    size: 18, color: AXTheme.danger))
                          ])
                        ]));
              }),

              const SizedBox(height: 30),
              Text("TERMS & SIGNATURE", style: AXTheme.terminal),
              const SizedBox(height: 10),
              Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.white10),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                      "I confirm ownership of assets and agree to the valuation.",
                      style: AXTheme.body
                          .copyWith(fontSize: 11, color: Colors.white54))),
              const SizedBox(height: 20),
              // FAST SIGNATURE PAD (ISOLATED)
              const FastSignaturePad(),
            ])));
  }

  Widget _buildRow(String label, String val, Color c) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: AXTheme.body),
      Text(val, style: AXTheme.value.copyWith(color: c))
    ]);
  }
}

// --- OPTIMIZED SIGNATURE WIDGET ---
class FastSignaturePad extends StatefulWidget {
  const FastSignaturePad({super.key});
  @override
  State<FastSignaturePad> createState() => _FastSignaturePadState();
}

class _FastSignaturePadState extends State<FastSignaturePad> {
  List<Offset?> _points = [];
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AXTheme.cyanFlux.withOpacity(0.3))),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                onPanStart: (d) => setState(() => _points.add(d.localPosition)),
                onPanUpdate: (d) =>
                    setState(() => _points.add(d.localPosition)),
                onPanEnd: (d) => setState(() => _points.add(null)),
                child: CustomPaint(
                    painter: SignaturePainter(points: _points),
                    size: Size.infinite),
              ))),
      Align(
          alignment: Alignment.centerRight,
          child: TextButton(
              onPressed: () => setState(() => _points = []),
              child: Text("CLEAR SIGNATURE",
                  style: TextStyle(color: AXTheme.danger, fontSize: 10)))),
      const SizedBox(height: 10),
      CyberButton(
          text: "CONFIRM DEAL & PAY",
          onTap: () {
            if (_points.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  backgroundColor: AXTheme.danger,
                  content: Text("SIGNATURE REQUIRED")));
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                backgroundColor: AXTheme.success,
                content: Text("PAYMENT INITIATED...")));
          })
    ]);
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  SignaturePainter({required this.points});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AXTheme.cyanFlux
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}

// --- GLOBAL HELPERS (REUSED) ---
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
    for (double i = 0; i < s.width; i += 40)
      c.drawLine(Offset(i, 0), Offset(i, s.height), p);
    for (double i = 0; i < s.height; i += 40)
      c.drawLine(Offset(0, i), Offset(s.width, i), p);
  }

  @override
  bool shouldRepaint(old) => false;
}
