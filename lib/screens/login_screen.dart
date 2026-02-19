import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// अपनी थीम और डिज़ाइन वाली फाइल को जोड़ रहे हैं
import 'core_theme.dart';
// अगली स्क्रीन (Dashboard) की फाइल को जोड़ रहे हैं
import 'dashboard_screen.dart';

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

  void _startShift() async {
    if (_idCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: AXTheme.danger,
          content: Text("OFFICER ID REQUIRED!")));
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const RadarDashboardScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    inputFormatters: [UpperCaseTextFormatter()],
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
                    onTap: (_isBioVerified &&
                            _isBondSigned &&
                            _idCtrl.text.isNotEmpty)
                        ? _startShift
                        : null,
                    isManual: !(_isBioVerified &&
                        _isBondSigned &&
                        _idCtrl.text.isNotEmpty))
          ]))
    ]));
  }
}
