import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart'; // Blinking Effect के लिए
import 'dart:math' as math;

import 'core_theme.dart';
import 'boot_screen.dart';
import 'fund_transfer_screen.dart'; // आपका नया Payment System यहाँ लिंक हो गया है!

// ==========================================
// CUSTOM ADVANCED FORMATTERS (PAN & IFSC)
// ==========================================

class AdvancedPanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.toUpperCase();
    if (newText.length > 10) return oldValue;
    for (int i = 0; i < newText.length; i++) {
      String char = newText[i];
      if (i < 5 && !RegExp(r'[A-Z]').hasMatch(char)) return oldValue;
      if (i >= 5 && i < 9 && !RegExp(r'[0-9]').hasMatch(char)) return oldValue;
      if (i == 9 && !RegExp(r'[A-Z]').hasMatch(char)) return oldValue;
    }
    return newValue.copyWith(text: newText);
  }
}

class AdvancedIfscFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.toUpperCase();
    if (newText.length > 11) return oldValue;
    for (int i = 0; i < newText.length; i++) {
      String char = newText[i];
      if (i < 4 && !RegExp(r'[A-Z]').hasMatch(char)) return oldValue;
      if (i == 4 && char != '0') return oldValue;
      if (i > 4 && !RegExp(r'[A-Z0-9]').hasMatch(char)) return oldValue;
    }
    return newValue.copyWith(text: newText);
  }
}

// ==========================================
// 9. DYNAMIC KYC STATUS DASHBOARD
// ==========================================

class KYCStatusDashboard extends StatefulWidget {
  const KYCStatusDashboard({super.key});
  @override
  State<KYCStatusDashboard> createState() => _KYCStatusDashboardState();
}

class _KYCStatusDashboardState extends State<KYCStatusDashboard> {
  // तीनों का स्टेटस अब डायनामिक है। टेस्टिंग के लिए शुरू में Pending रख रहे हैं।
  bool _valDone = false;
  bool _kycDone = false;
  bool _bankDone = false;

  int get _completedCount =>
      (_valDone ? 1 : 0) + (_kycDone ? 1 : 0) + (_bankDone ? 1 : 0);

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
    // अब यह सीधे आपकी 3-Tier Payment Screen पर जाएगा (डेटा के साथ)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FundTransferScreen(payoutAmount: 485000),
      ),
    ); // Dummy amount
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AXTheme.panel,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AXTheme.danger),
            ),
            title: Text(
              "WARNING: ABORT TRANSACTION?",
              style: AXTheme.heading.copyWith(color: AXTheme.danger),
            ),
            content: Text(
              "Going back will cancel the current payout process. Are you sure?",
              style: AXTheme.body,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  "CANCEL",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  "YES, ABORT",
                  style: TextStyle(color: AXTheme.danger),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  void _syncServerStatus() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AXTheme.cyanFlux,
        content: Text("SYNCING WITH SERVER..."),
      ),
    );
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        // सिम्युलेट कर रहे हैं कि कस्टमर ने सब कुछ अप्रूव कर दिया
        _valDone = true;
        _kycDone = true;
        _bankDone = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AXTheme.success,
          content: Text("STATUS UPDATED FROM SERVER!"),
        ),
      );
    });
  }

  void _resendValuationRequest() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AXTheme.cyanFlux,
        content: Text("AGREEMENT RESENT TO CUSTOMER"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AXTheme.cyanFlux),
            onPressed: () => _onWillPop().then((val) {
              if (val) Navigator.pop(context);
            }),
          ),
          title: Text(
            "TRANSACTION DASHBOARD",
            style: AXTheme.heading.copyWith(fontSize: 14),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.sync, color: AXTheme.cyanFlux),
              onPressed: _syncServerStatus,
              tooltip: "Sync Server Status",
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "$_completedCount OF 3 DONE",
                  style: AXTheme.digital.copyWith(
                    color: _completedCount == 3
                        ? AXTheme.success
                        : AXTheme.warning,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              _buildStatusCard(
                "CUSTOMER VALUATION",
                _valDone,
                _resendValuationRequest,
                btnText: "RESEND REQUEST",
                overrideText: "APPROVED & ACCEPTED",
              ),
              const SizedBox(height: 15),

              _buildStatusCard(
                "IDENTITY (KYC)",
                _kycDone,
                _openVerificationHub,
                btnText: "COMPLETE NOW",
              ),
              const SizedBox(height: 15),

              _buildStatusCard(
                "BANKING DETAILS",
                _bankDone,
                _openVerificationHub,
                btnText: "COMPLETE NOW",
              ),
              const Spacer(),

              if (_completedCount == 3)
                CyberButton(
                  text: "PROCEED TO FUND TRANSFER",
                  onTap: _releasePayment,
                )
              else
                Text("AWAITING PENDING ACTIONS", style: AXTheme.terminal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    String title,
    bool isDone,
    VoidCallback onTap, {
    required String btnText,
    String? overrideText,
  }) {
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
                isDone
                    ? (overrideText ?? "VERIFIED & SYNCED")
                    : "PENDING - ACTION REQUIRED",
                style: TextStyle(
                  color: isDone ? AXTheme.success : AXTheme.warning,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          if (!isDone)
            CyberButton(
              text: btnText,
              onTap: onTap,
              isWarning: title.contains("VALUATION"),
            )
          else
            const Icon(Icons.check_circle, color: AXTheme.success, size: 30),
        ],
      ),
    );
  }
}

// ==========================================
// 10. KYC & BANKING ENTRY (NO PAYMENT HERE)
// ==========================================

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

  TextEditingController panCtrl = TextEditingController();
  TextEditingController aadhaarCtrl = TextEditingController();
  TextEditingController accCtrl = TextEditingController();
  TextEditingController ifscCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AXTheme.panel,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AXTheme.warning),
            ),
            title: Text(
              "LEAVE VERIFICATION?",
              style: AXTheme.heading.copyWith(color: AXTheme.warning),
            ),
            content: Text("Unsaved data will be lost.", style: AXTheme.body),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  "CANCEL",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  "LEAVE",
                  style: TextStyle(color: AXTheme.warning),
                ),
              ),
            ],
          ),
        )) ??
        false;
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
    if (panCtrl.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AXTheme.danger,
          content: Text("PAN MUST BE EXACTLY 10 CHARACTERS"),
        ),
      );
      return;
    }
    if (aadhaarCtrl.text.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AXTheme.danger,
          content: Text("AADHAAR MUST BE EXACTLY 12 DIGITS"),
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
          content: Text("INVALID ACCOUNT NUMBER (MIN 9 DIGITS)"),
        ),
      );
      return;
    }
    if (ifscCtrl.text.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AXTheme.danger,
          content: Text("IFSC MUST BE EXACTLY 11 CHARACTERS"),
        ),
      );
      return;
    }
    setState(() => _bankVerified = true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AXTheme.cyanFlux),
            onPressed: () => _onWillPop().then((val) {
              if (val) Navigator.pop(context);
            }),
          ),
          title: Text(
            "DATA ENTRY VAULT",
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
                                textCapitalization:
                                    TextCapitalization.characters,
                                inputFormatters: [AdvancedPanFormatter()],
                                style: AXTheme.body,
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
                              SizedBox(
                                width: double.infinity,
                                child: MagicalNeonButton(
                                  text: _kycVerified
                                      ? "VERIFIED"
                                      : "VERIFY IDENTITY",
                                  icon: Icons.verified_user,
                                  isDone: _kycVerified,
                                  activeColor: AXTheme.cyanFlux,
                                  onTap: _verifyKYC,
                                ),
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
                                  LengthLimitingTextInputFormatter(18),
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
                                textCapitalization:
                                    TextCapitalization.characters,
                                inputFormatters: [AdvancedIfscFormatter()],
                                style: AXTheme.body,
                                decoration: const InputDecoration(
                                  labelText: "IFSC CODE (SBIN000...)",
                                  filled: true,
                                  fillColor: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: MagicalNeonButton(
                                  text: _bankVerified
                                      ? "VERIFIED"
                                      : "VERIFY ACCOUNT",
                                  icon: Icons.account_balance,
                                  isDone: _bankVerified,
                                  activeColor: AXTheme.cyanFlux,
                                  onTap: _verifyBank,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (_kycVerified && _bankVerified)
                          CyberButton(
                            text: "SAVE & SYNC DETAILS",
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: AXTheme.success,
                                  content: Text("DETAILS SYNCED TO SERVER"),
                                ),
                              );
                              Navigator.pop(context, true);
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

// ==========================================
// 11. BARCODE & LOCKER SCREEN (PRINTER FIX)
// ==========================================

class BarcodeScreen extends StatefulWidget {
  const BarcodeScreen({super.key});
  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  int _step = 0;
  bool _isPrinted = false; // Barcode Printer Flag
  TextEditingController otpCtrl = TextEditingController();
  List<Offset?> _signPoints = [];

  void _nextStep() {
    setState(() => _step++);
  }

  void _printBarcode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AXTheme.cyanFlux,
        content: Text("SENDING COMMAND TO THERMAL PRINTER..."),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isPrinted = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AXTheme.success,
          content: Text("BARCODE PRINTED SUCCESSFULLY"),
        ),
      );
    });
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
            // ==========================================
            // BARCODE PRINTING STEP
            // ==========================================
            if (_step == 0) ...[
              const Icon(Icons.qr_code_2, size: 80, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                "AURUM-X-9988",
                style: AXTheme.digital.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 15),

              // DETAILED RECEIPT INFO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("TXN ID: AX-9988-ABC", style: AXTheme.terminal),
                    const Divider(color: Colors.white12),
                    Text(
                      "FO OFFICER: Aarviind (ID: 1042)",
                      style: AXTheme.body.copyWith(fontSize: 11),
                    ),
                    Text(
                      "CUSTOMER: John Doe",
                      style: AXTheme.body.copyWith(fontSize: 11),
                    ),
                    Text(
                      "VALUATION: AUTO SYNC",
                      style: AXTheme.body.copyWith(fontSize: 11),
                    ),
                    Text(
                      "ASSET: 26.00g @ 23.1K",
                      style: AXTheme.body.copyWith(fontSize: 11),
                    ),
                    Text(
                      "TIMESTAMP: 2026-02-20 03:51 AM IST",
                      style: AXTheme.body.copyWith(fontSize: 11),
                    ),
                    Text(
                      "LOC: NAVI MUMBAI, MH, INDIA",
                      style: AXTheme.body.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // BLINKING TEXT (Jab tak print nahi hota)
              Pulse(
                infinite: !_isPrinted, // Stops blinking once printed
                child: Text(
                  "Print & Paste Barcode on Pouch",
                  style: AXTheme.body.copyWith(
                    color: _isPrinted ? AXTheme.success : AXTheme.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // DYNAMIC PRINT BUTTON
              if (!_isPrinted)
                CyberButton(text: "PRINT BARCODE", onTap: _printBarcode)
              else
                CyberButton(
                  text: "BARCODE PASTED >",
                  onTap: _nextStep,
                  isManual: true,
                ), // Proceeds to locker
            ],

            // ==========================================
            // LOCKER STEP
            // ==========================================
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
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
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

            // ==========================================
            // FINAL CLOSURE STEP
            // ==========================================
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
                  child: const Text(
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
