import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'core_theme.dart';
import 'boot_screen.dart';

class KYCStatusDashboard extends StatefulWidget {
  const KYCStatusDashboard({super.key});
  @override
  State<KYCStatusDashboard> createState() => _KYCStatusDashboardState();
}

class _KYCStatusDashboardState extends State<KYCStatusDashboard> {
  bool _kycDone = false;
  bool _bankDone = false;

  void _openVerificationHub() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const KYCPaymentScreen()),
    ).then((val) {
      if (val == true) {
        setState(() {
          _kycDone = true;
          _bankDone = true;
        });
      }
    });
  }

  void _releasePayment() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AXTheme.panel,
        icon: const Icon(Icons.check_circle, color: AXTheme.success, size: 60),
        title: Text(
          "PAYMENT SUCCESSFUL",
          style: AXTheme.heading.copyWith(color: AXTheme.success),
        ),
        content: Text(
          "Funds Transferred.",
          style: AXTheme.body,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const BarcodeScreen()),
              );
            },
            child: const Text(
              "PRINT BARCODE",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          "TRANSACTION DASHBOARD",
          style: AXTheme.heading.copyWith(fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatusCard(
              "IDENTITY (KYC)",
              _kycDone,
              () => _openVerificationHub(),
            ),
            const SizedBox(height: 20),
            _buildStatusCard(
              "BANKING DETAILS",
              _bankDone,
              () => _openVerificationHub(),
            ),
            const Spacer(),
            if (_kycDone && _bankDone)
              CyberButton(text: "RELEASE PAYMENT", onTap: _releasePayment)
            else
              Text("PENDING ACTIONS", style: AXTheme.terminal),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, bool isDone, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AXTheme.getPanel(isActive: isDone),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AXTheme.heading.copyWith(fontSize: 14)),
              Text(
                isDone ? "VERIFIED & SYNCED" : "PENDING - ACTION REQUIRED",
                style: TextStyle(
                  color: isDone ? AXTheme.success : AXTheme.warning,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          if (!isDone)
            CyberButton(text: "COMPLETE NOW", onTap: onTap)
          else
            const Icon(Icons.check_circle, color: AXTheme.success, size: 30),
        ],
      ),
    );
  }
}

class KYCPaymentScreen extends StatefulWidget {
  const KYCPaymentScreen({super.key});
  @override
  State<KYCPaymentScreen> createState() => _KYCPaymentScreenState();
}

class _KYCPaymentScreenState extends State<KYCPaymentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _kycVerified = false;
  bool _bankVerified = false;
  bool _panScanned = false;
  bool _aadhaarScanned = false;

  final panValidator = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
  final ifscValidator = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

  TextEditingController panCtrl = TextEditingController();
  TextEditingController aadhaarCtrl = TextEditingController();
  TextEditingController accCtrl = TextEditingController();
  TextEditingController ifscCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _simulateFetch(String type) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AXTheme.panel,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AXTheme.cyanFlux),
              const SizedBox(height: 20),
              Text("FETCHING $type DATA...", style: AXTheme.body),
            ],
          ),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      setState(() {
        if (type == "DIGILOCKER") {
          panCtrl.text = "ABCDE1234F";
          aadhaarCtrl.text = "123456789012";
          _panScanned = true;
          _aadhaarScanned = true;
        } else if (type == "OCR_PAN") {
          panCtrl.text = "ABCDE1234F";
          _panScanned = true;
        } else if (type == "OCR_AADHAAR") {
          aadhaarCtrl.text = "123456789012";
          _aadhaarScanned = true;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AXTheme.success,
          content: Text("DATA FETCHED SUCCESSFULLY"),
        ),
      );
    });
  }

  void _verifyKYC() {
    if (!panValidator.hasMatch(panCtrl.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AXTheme.danger,
          content: Text("INVALID PAN FORMAT"),
        ),
      );
      return;
    }
    if (aadhaarCtrl.text.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AXTheme.danger,
          content: Text("AADHAAR MUST BE 12 DIGITS"),
        ),
      );
      return;
    }
    setState(() => _kycVerified = true);
  }

  void _verifyBank() {
    if (accCtrl.text.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AXTheme.danger,
          content: Text("INVALID ACCOUNT NUMBER"),
        ),
      );
      return;
    }
    if (!ifscValidator.hasMatch(ifscCtrl.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AXTheme.danger,
          content: Text("INVALID IFSC (5th char must be 0)"),
        ),
      );
      return;
    }
    setState(() => _bankVerified = true);
  }

  void _showCustomerOTPDialog() {
    TextEditingController otpCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AXTheme.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AXTheme.cyanFlux),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "CUSTOMER AUTHORIZATION",
                style: AXTheme.heading.copyWith(color: AXTheme.cyanFlux),
              ),
              const SizedBox(height: 10),
              Text(
                "Ask customer for OTP sent to their mobile to authorize this transaction.",
                style: AXTheme.body.copyWith(fontSize: 11),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: otpCtrl,
                textAlign: TextAlign.center,
                style: AXTheme.input,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "ENTER CUSTOMER OTP",
                  hintStyle: TextStyle(color: Colors.white24),
                ),
              ),
              const SizedBox(height: 20),
              CyberButton(
                text: "AUTHORIZE & PAY",
                onTap: () {
                  if (otpCtrl.text.length == 4) {
                    Navigator.pop(ctx);
                    _processFinalPayment();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processFinalPayment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AXTheme.panel,
        icon: const Icon(Icons.check_circle, color: AXTheme.success, size: 60),
        title: Text(
          "PAYMENT SUCCESSFUL",
          style: AXTheme.heading.copyWith(color: AXTheme.success),
        ),
        content: Text(
          "Transaction ID: TXN${math.Random().nextInt(999999)}\nFunds Transferred.",
          style: AXTheme.body,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: const Text(
              "PRINT BARCODE",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
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
          "PAYMENT GATEWAY",
          style: AXTheme.heading.copyWith(fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: AXTheme.cyanFlux,
            labelColor: AXTheme.cyanFlux,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: "IDENTITY VAULT"),
              Tab(text: "BANKING LAYER"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _simulateFetch("DIGILOCKER"),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.cloud_download,
                                    color: AXTheme.cyanFlux,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "DIGILOCKER FETCH",
                                        style: AXTheme.body,
                                      ),
                                      const Text(
                                        "Recommended • Fastest",
                                        style: TextStyle(
                                          color: Colors.white30,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.white54,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text("SCAN DOCUMENTS (OCR)", style: AXTheme.terminal),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _simulateFetch("OCR_PAN"),
                              child: _buildScanCard(
                                Icons.assignment_ind,
                                "SCAN PAN",
                                _panScanned,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _simulateFetch("OCR_AADHAAR"),
                              child: _buildScanCard(
                                Icons.fingerprint,
                                "SCAN AADHAAR",
                                _aadhaarScanned,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text("MANUAL ENTRY", style: AXTheme.terminal),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: AXTheme.getPanel(isActive: _kycVerified),
                        child: Column(
                          children: [
                            TextField(
                              controller: panCtrl,
                              inputFormatters: [
                                UpperCaseTextFormatter(),
                                FilteringTextInputFormatter.allow(
                                  RegExp("[A-Z0-9]"),
                                ),
                                LengthLimitingTextInputFormatter(10),
                              ],
                              style: AXTheme.body,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                labelText: "PAN NUMBER (ABCDE1234F)",
                                filled: true,
                                fillColor: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: aadhaarCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(12),
                              ],
                              style: AXTheme.body,
                              decoration: const InputDecoration(
                                labelText: "AADHAAR NUMBER (12 Digits)",
                                filled: true,
                                fillColor: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
                            MagicalNeonButton(
                              text: _kycVerified
                                  ? "VERIFIED"
                                  : "VERIFY IDENTITY",
                              icon: Icons.verified_user,
                              isDone: _kycVerified,
                              activeColor: AXTheme.cyanFlux,
                              onTap: _verifyKYC,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: AXTheme.getPanel(isActive: _bankVerified),
                        child: Column(
                          children: [
                            TextField(
                              controller: accCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: AXTheme.body,
                              decoration: const InputDecoration(
                                labelText: "ACCOUNT NUMBER",
                                filled: true,
                                fillColor: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: ifscCtrl,
                              inputFormatters: [
                                UpperCaseTextFormatter(),
                                FilteringTextInputFormatter.allow(
                                  RegExp("[A-Z0-9]"),
                                ),
                                LengthLimitingTextInputFormatter(11),
                              ],
                              style: AXTheme.body,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                labelText: "IFSC CODE (SBIN000...)",
                                filled: true,
                                fillColor: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
                            MagicalNeonButton(
                              text: _bankVerified
                                  ? "VERIFIED"
                                  : "VERIFY ACCOUNT",
                              icon: Icons.account_balance,
                              isDone: _bankVerified,
                              activeColor: AXTheme.cyanFlux,
                              onTap: _verifyBank,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (_kycVerified && _bankVerified)
                        CyberButton(
                          text: "REQUEST CUSTOMER OTP & PAY",
                          onTap: _showCustomerOTPDialog,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanCard(IconData icon, String label, bool isScanned) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isScanned ? AXTheme.success : Colors.white12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isScanned ? Icons.check_circle : icon,
            color: isScanned ? AXTheme.success : AXTheme.warning,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: isScanned ? AXTheme.success : Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class BarcodeScreen extends StatefulWidget {
  const BarcodeScreen({super.key});
  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  int _step = 0;
  TextEditingController otpCtrl = TextEditingController();
  List<Offset?> _signPoints = [];

  void _nextStep() {
    setState(() => _step++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          "SECURE HANDOVER",
          style: AXTheme.heading.copyWith(fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_step == 0) ...[
              const Icon(Icons.qr_code_2, size: 100, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                "AURUM-X-9988",
                style: AXTheme.digital.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text("Print & Paste on Pouch", style: AXTheme.body),
              const SizedBox(height: 40),
              CyberButton(text: "BARCODE PASTED >", onTap: _nextStep),
            ],
            if (_step == 1) ...[
              const Icon(Icons.lock_open, size: 80, color: AXTheme.cyanFlux),
              const SizedBox(height: 20),
              Text("LOCKER ACCESS", style: AXTheme.heading),
              const SizedBox(height: 20),
              TextField(
                controller: otpCtrl,
                textAlign: TextAlign.center,
                style: AXTheme.input,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "ENTER LOCKER OTP",
                  hintStyle: TextStyle(color: Colors.white24),
                ),
              ),
              const SizedBox(height: 20),
              CyberButton(
                text: "OPEN LOCKER",
                onTap: () {
                  if (otpCtrl.text == "1234") {
                    _nextStep();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AXTheme.danger,
                        content: Text("WRONG OTP"),
                      ),
                    );
                  }
                },
              ),
            ],
            if (_step == 2) ...[
              Text("CONFIRM LOCKER CLOSURE", style: AXTheme.heading),
              const SizedBox(height: 20),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AXTheme.cyanFlux),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: GestureDetector(
                    onPanUpdate: (d) =>
                        setState(() => _signPoints.add(d.localPosition)),
                    onPanEnd: (d) => setState(() => _signPoints.add(null)),
                    child: CustomPaint(
                      painter: SignaturePainter(points: _signPoints),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _signPoints = []),
                  child: Text(
                    "CLEAR",
                    style: TextStyle(color: AXTheme.danger, fontSize: 10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CyberButton(
                text: "CLOSE TASK & RELOGIN",
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SystemBootScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
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
