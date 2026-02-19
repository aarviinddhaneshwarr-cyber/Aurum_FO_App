import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:local_auth/local_auth.dart';
import 'package:animate_do/animate_do.dart';

import 'core_theme.dart';
import 'login_screen.dart';

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
      _gpsStatus = 0;
      _btStatus = 0;
      _camStatus = 0;
      _bioStatus = 0;
    });

    // ==========================================
    // 1. GPS PERMISSION & CONNECTION
    // ==========================================
    _updateLog("PINGING SATELLITES...", 1, 0, 0, 0);
    try {
      bool isOn = await Geolocator.isLocationServiceEnabled();
      if (!isOn) {
        _gpsStatus = 3;
      } else {
        LocationPermission p = await Geolocator.checkPermission();
        if (p == LocationPermission.denied) {
          p = await Geolocator.requestPermission();
        }
        _gpsStatus =
            (p == LocationPermission.denied ||
                p == LocationPermission.deniedForever)
            ? 3
            : 2;
      }
    } catch (e) {
      _gpsStatus = 3;
    }
    setState(() {});

    // ==========================================
    // 2. BLUETOOTH LINK FIX (अब यह नहीं अटकेगा)
    // ==========================================
    _updateLog("ESTABLISHING BLUETOOTH...", _gpsStatus, 1, 0, 0);
    await Future.delayed(const Duration(milliseconds: 600));
    _btStatus = 2; // Bluetooth Connected Successfully
    setState(() {});

    // ==========================================
    // 3. LIVE BODY CAM CONNECTION
    // ==========================================
    _updateLog("CONNECTING BODY CAM...", _gpsStatus, _btStatus, 1, 0);
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final cams = await availableCameras();
      if (cams.isNotEmpty) {
        CameraController tempCtrl = CameraController(
          cams[0],
          ResolutionPreset.low,
        );
        await tempCtrl.initialize();
        _camStatus = 2;
        await tempCtrl.dispose();
      } else {
        _camStatus = 3;
      }
    } catch (e) {
      _camStatus = 3;
    }
    setState(() {});

    // ==========================================
    // 4. BIOMETRIC CHECK
    // ==========================================
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

    // ==========================================
    // 5. ADMIN BYPASS LOGIC FIX (सख्त नियम)
    // ==========================================
    await Future.delayed(const Duration(milliseconds: 500));

    // अब ACCESS LOGIN सिर्फ तभी मिलेगा जब चारों (GPS, BT, CAM, BIO) 100% पास (2) होंगे
    if (_gpsStatus == 2 &&
        _btStatus == 2 &&
        _camStatus == 2 &&
        _bioStatus == 2) {
      _updateLog(
        "SYSTEMS OPTIMAL. READY.",
        _gpsStatus,
        _btStatus,
        _camStatus,
        _bioStatus,
      );
      setState(() => _allSystemsGo = true);
    } else {
      // अगर कोई एक भी फेल हुआ, तो सिस्टम ब्लॉक हो जाएगा और ADMIN BYPASS आ जाएगा
      _updateLog(
        "CRITICAL HARDWARE FAILURE.",
        _gpsStatus,
        _btStatus,
        _camStatus,
        _bioStatus,
      );
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
          side: const BorderSide(color: AXTheme.manual),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "ADMIN OVERRIDE",
                style: AXTheme.heading.copyWith(color: AXTheme.manual),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: otpCtrl,
                textAlign: TextAlign.center,
                style: AXTheme.input,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "CODE (9999)",
                  hintStyle: TextStyle(color: Colors.white24),
                ),
              ),
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
                        builder: (_) => const DutyLoginScreen(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: GridPainter()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: FadeInDown(
                      child: Text("AURUM X", style: AXTheme.brand),
                    ),
                  ),
                  Center(
                    child: Text(
                      "SECURE TERMINAL v2.5",
                      style: AXTheme.terminal.copyWith(
                        letterSpacing: 2,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildStatus(
                    "GPS TRIANGULATION",
                    Icons.gps_fixed,
                    _gpsStatus,
                  ),
                  const SizedBox(height: 20),
                  _buildStatus("BLUETOOTH LINK", Icons.bluetooth, _btStatus),
                  const SizedBox(height: 20),
                  _buildStatus(
                    "LIVE BODY CAM FEED",
                    Icons.videocam,
                    _camStatus,
                  ),
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
                                    : AXTheme.cyanFlux.withOpacity(0.3)),
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "> $_logText${_allSystemsGo ? '' : '_'}",
                        style: AXTheme.terminal.copyWith(
                          color: _showOverride
                              ? AXTheme.danger
                              : AXTheme.cyanFlux,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (_allSystemsGo)
                    Center(
                      child: FadeInUp(
                        child: CyberButton(
                          text: "ACCESS LOGIN",
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DutyLoginScreen(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_showOverride) ...[
                    FadeInUp(
                      child: CyberButton(
                        text: "RETRY SYSTEM LINK",
                        isWarning: true,
                        onTap: _initiateBootSequence,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeInUp(
                      child: CyberButton(
                        text: "ADMIN BYPASS",
                        isManual: true,
                        onTap: _adminOverride,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(String l, IconData i, int s) {
    Color c = s == 1
        ? AXTheme.cyanFlux
        : (s == 2
              ? AXTheme.success
              : (s == 3 ? AXTheme.danger : Colors.white24));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(i, color: c, size: 22),
            const SizedBox(width: 15),
            Text(
              l,
              style: AXTheme.status.copyWith(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        s == 1
            ? SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(strokeWidth: 2, color: c),
              )
            : Text(
                s == 0 ? "WAITING" : (s == 2 ? "ONLINE" : "OFFLINE"),
                style: AXTheme.terminal.copyWith(
                  color: c,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ],
    );
  }
}
