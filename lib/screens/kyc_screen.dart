import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';

import 'core_theme.dart';
import 'boot_screen.dart';
import 'fund_transfer_screen.dart';

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
// 9. TRULY DYNAMIC DASHBOARD
// ==========================================

class KYCStatusDashboard extends StatefulWidget {
  const KYCStatusDashboard({super.key});
  @override
  State<KYCStatusDashboard> createState() => _KYCStatusDashboardState();
}

class _KYCStatusDashboardState extends State<KYCStatusDashboard> {
  // Status: "PENDING", "COMPLETED_BY_CUSTOMER", "COMPLETED_BY_FO"
  String _valStatus = "COMPLETED_BY_CUSTOMER";
  String _kycStatus = "PENDING";
  String _bankStatus = "PENDING";

  int get _completedCount =>
      (_valStatus != "PENDING" ? 1 : 0) +
      (_kycStatus != "PENDING" ? 1 : 0) +
      (_bankStatus != "PENDING" ? 1 : 0);

  void _openVerificationHub() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const KYCPaymentScreen()),
    ).then((val) {
      if (val == true) {
        setState(() {
          if (_kycStatus == "PENDING") _kycStatus = "COMPLETED_BY_FO";
          if (_bankStatus == "PENDING") _bankStatus = "COMPLETED_BY_FO";
        });
      }
    });
  }

  void _releasePayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FundTransferScreen(payoutAmount: 485000),
      ),
    );
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
        _valStatus = "COMPLETED_BY_CUSTOMER";
        _kycStatus = "COMPLETED_BY_CUSTOMER";
        _bankStatus = "COMPLETED_BY_CUSTOMER";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AXTheme.success,
          content: Text("ALL ACTIONS COMPLETED BY CUSTOMER!"),
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

              _buildDynamicCard(
                "CUSTOMER VALUATION",
                _valStatus,
                _resendValuationRequest,
              ),
              const SizedBox(height: 15),
              _buildDynamicCard(
                "IDENTITY (KYC)",
                _kycStatus,
                _openVerificationHub,
              ),
              const SizedBox(height: 15),
              _buildDynamicCard(
                "BANKING DETAILS",
                _bankStatus,
                _openVerificationHub,
              ),

              const Spacer(),

              if (_completedCount == 3)
                CyberButton(
                  text: "PROCEED TO FUND TRANSFER",
                  onTap: _releasePayment,
                )
              else
                Text(
                  "FO ACTION REQUIRED OR AWAITING CUSTOMER",
                  style: AXTheme.terminal,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicCard(
    String title,
    String status,
    VoidCallback onFoAction,
  ) {
    bool isPending = status == "PENDING";
    bool isCust = status == "COMPLETED_BY_CUSTOMER";

    Color borderColor = isPending
        ? Colors.white12
        : (isCust
              ? AXTheme.success.withOpacity(0.5)
              : AXTheme.cyanFlux.withOpacity(0.5));
    Color textColor = isPending
        ? AXTheme.warning
        : (isCust ? AXTheme.success : AXTheme.cyanFlux);
    String subtitle = isPending
        ? "ACTION REQUIRED"
        : (isCust ? "DONE BY CUSTOMER" : "DONE BY FO (MANUAL)");

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AXTheme.heading.copyWith(fontSize: 14)),
              Text(
                subtitle,
                style: TextStyle(
                  color: textColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (isPending)
            CyberButton(
              text: title.contains("VALUATION")
                  ? "RESEND REQUEST"
                  : "FO COMPLETE NOW",
              onTap: onFoAction,
              isWarning: title.contains("VALUATION"),
            )
          else
            Icon(Icons.check_circle, color: textColor, size: 30),
        ],
      ),
    );
  }
}

// ==========================================
// 10. KYC & BANKING ENTRY
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
    if (panCtrl.text.length != 10) return;
    if (aadhaarCtrl.text.length != 12) return;
    setState(() => _kycVerified = true);
  }

  void _verifyBank() {
    if (accCtrl.text.length < 9) return;
    if (ifscCtrl.text.length != 11) return;
    setState(() => _bankVerified = true);
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
                              textCapitalization: TextCapitalization.characters,
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
                              textCapitalization: TextCapitalization.characters,
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
// CUSTOM BLINKING TEXT (100% Guaranteed Error Free)
// ==========================================
class BlinkingWarningText extends StatefulWidget {
  final String text;
  final Color color;
  const BlinkingWarningText({
    super.key,
    required this.text,
    required this.color,
  });
  @override
  State<BlinkingWarningText> createState() => _BlinkingWarningTextState();
}

class _BlinkingWarningTextState extends State<BlinkingWarningText>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    // 1200ms duration for a premium, smooth "breathing" blink
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Text(
        widget.text,
        style: AXTheme.body.copyWith(
          color: widget.color,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ==========================================
// 11. BARCODE & LOCKER SCREEN
// ==========================================

class BarcodeScreen extends StatefulWidget {
  const BarcodeScreen({super.key});
  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  int _step = 0;
  bool _isPrinted = false;
  TextEditingController adminOtpCtrl = TextEditingController();
  TextEditingController foOtpCtrl = TextEditingController();
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
            if (_step == 0) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "AURUM X",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const Text(
                      "SECURE LOGISTICS RECEIPT",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "- - - - - - - - - - - - - - - - -",
                      style: TextStyle(color: Colors.black, letterSpacing: 2),
                    ),
                    const SizedBox(height: 10),
                    const Icon(Icons.qr_code_2, size: 80, color: Colors.black),
                    const SizedBox(height: 5),
                    const Text(
                      "AURUM-X-9988",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "- - - - - - - - - - - - - - - - -",
                      style: TextStyle(color: Colors.black, letterSpacing: 2),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "TXN ID:",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "AX-9988-ABC",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "FO OFFICER:",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Aarviind (ID: 1042)",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "CUSTOMER:",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "John Doe",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "VALUATION:",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "AUTO SYNC",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "ASSET:",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "26.00g @ 23.1K",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "E-SIGNED:",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "YES (Verified)",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    const Text(
                      "TIMESTAMP: 2026-02-20 04:19 AM IST",
                      style: TextStyle(color: Colors.black54, fontSize: 9),
                    ),
                    const Text(
                      "LOC: NAVI MUMBAI, MH, INDIA",
                      style: TextStyle(color: Colors.black54, fontSize: 9),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // SOPHISTICATED CUSTOM BLINKING (GUARANTEED NO ERROR)
              if (!_isPrinted)
                BlinkingWarningText(
                  text: "Print & Paste Barcode on Pouch",
                  color: AXTheme.warning,
                ),

              if (_isPrinted)
                Text(
                  "BARCODE PRINTED SUCCESSFULLY",
                  style: AXTheme.body.copyWith(
                    color: AXTheme.success,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),

              const SizedBox(height: 30),

              if (!_isPrinted)
                SizedBox(
                  width: double.infinity,
                  child: MagicalNeonButton(
                    text: "PRINT BARCODE",
                    icon: Icons.print,
                    isDone: false,
                    activeColor: AXTheme.cyanFlux,
                    onTap: _printBarcode,
                  ),
                )
              else
                CyberButton(
                  text: "BARCODE PASTED >",
                  onTap: _nextStep,
                  isManual: true,
                ),
            ],

            if (_step == 1) ...[
              const Icon(Icons.lock_open, size: 80, color: AXTheme.cyanFlux),
              const SizedBox(height: 20),
              Text("OPEN SECURE LOCKER", style: AXTheme.heading),
              const SizedBox(height: 20),
              TextField(
                controller: adminOtpCtrl,
                textAlign: TextAlign.center,
                style: AXTheme.input,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: const InputDecoration(
                  hintText: "ENTER ADMIN OTP (1234)",
                  hintStyle: TextStyle(color: Colors.white24),
                ),
              ),
              const SizedBox(height: 20),
              CyberButton(
                text: "UNLOCK VAULT",
                onTap: () {
                  if (adminOtpCtrl.text == "1234") {
                    _nextStep();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AXTheme.danger,
                        content: Text("WRONG ADMIN OTP"),
                      ),
                    );
                  }
                },
              ),
            ],

            if (_step == 2) ...[
              const Icon(Icons.lock, size: 60, color: AXTheme.success),
              const SizedBox(height: 10),
              Text("SEAL VAULT & CLOSE TASK", style: AXTheme.heading),
              const SizedBox(height: 20),

              TextField(
                controller: foOtpCtrl,
                textAlign: TextAlign.center,
                style: AXTheme.input,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: const InputDecoration(
                  hintText: "ENTER FO OTP TO LOCK (0000)",
                  hintStyle: TextStyle(color: Colors.white24),
                ),
              ),
              const SizedBox(height: 20),

              Text("FO SIGNATURE", style: AXTheme.terminal),
              const SizedBox(height: 10),
              Container(
                height: 150,
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
                text: "LOCK VAULT & RELOGIN",
                isWarning: true,
                onTap: () {
                  if (foOtpCtrl.text != "0000") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AXTheme.danger,
                        content: Text("FO OTP REQUIRED TO LOCK"),
                      ),
                    );
                    return;
                  }
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
