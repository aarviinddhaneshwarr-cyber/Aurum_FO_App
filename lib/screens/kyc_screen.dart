import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';

import 'core_theme.dart';
import 'boot_screen.dart';
import 'fund_transfer_screen.dart';

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
// 9. THE TRUE DYNAMIC DASHBOARD (SPLIT SIMULATOR)
// ==========================================

class KYCStatusDashboard extends StatefulWidget {
  const KYCStatusDashboard({super.key});
  @override
  State<KYCStatusDashboard> createState() => _KYCStatusDashboardState();
}

class _KYCStatusDashboardState extends State<KYCStatusDashboard> {
  String _valStatus = "WAITING_CUST";
  String _kycStatus = "PENDING_FO";
  String _bankStatus = "PENDING_FO";

  int get _completedCount =>
      (_valStatus.contains("COMPLETED") ? 1 : 0) +
      (_kycStatus.contains("COMPLETED") ? 1 : 0) +
      (_bankStatus.contains("COMPLETED") ? 1 : 0);

  // --- DEVELOPER SCENARIO SIMULATOR (UPDATED) ---
  void _setScenario(String action) {
    setState(() {
      if (action == "WAIT") {
        _valStatus = "WAITING_CUST";
        _kycStatus = "PENDING_FO";
        _bankStatus = "PENDING_FO";
      } else if (action == "ACCEPTED") {
        _valStatus = "COMPLETED_CUST";
      } else if (action == "KYC") {
        _kycStatus = "COMPLETED_CUST";
      } else if (action == "BANK") {
        _bankStatus = "COMPLETED_CUST";
      }
    });
  }

  void _openVerificationHub() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const KYCPaymentScreen()),
    ).then((val) {
      if (val == true) {
        setState(() {
          if (_kycStatus == "PENDING_FO") _kycStatus = "COMPLETED_FO";
          if (_bankStatus == "PENDING_FO") _bankStatus = "COMPLETED_FO";
        });
      }
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AXTheme.panel,
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
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // --- SCENARIO SIMULATOR (SPLIT FIX) ---
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  children: [
                    Text(
                      "DEVELOPER TESTER (TAP TO SIMULATE CUST ACTIONS)",
                      style: TextStyle(fontSize: 8, color: AXTheme.warning),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () => _setScenario("WAIT"),
                          child: Text(
                            "[ WAIT ]",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _setScenario("ACCEPTED"),
                          child: Text(
                            "[ ACCEPTED ]",
                            style: TextStyle(
                              color: AXTheme.success,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _setScenario("KYC"),
                          child: Text(
                            "[ KYC DONE ]",
                            style: TextStyle(
                              color: AXTheme.cyanFlux,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _setScenario("BANK"),
                          child: Text(
                            "[ BANK DONE ]",
                            style: TextStyle(
                              color: AXTheme.cyanFlux,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "$_completedCount OF 3 COMPLETED",
                  style: AXTheme.digital.copyWith(
                    color: _completedCount == 3
                        ? AXTheme.success
                        : AXTheme.warning,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 1. VALUATION CARD
              _buildDynamicCard("CUSTOMER VALUATION", _valStatus, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("PING SENT TO CUSTOMER APP")),
                );
              }, true),
              const SizedBox(height: 15),

              // 2. KYC CARD
              _buildDynamicCard(
                "IDENTITY (KYC)",
                _kycStatus,
                _openVerificationHub,
                false,
              ),
              const SizedBox(height: 15),

              // 3. BANK CARD
              _buildDynamicCard(
                "BANKING DETAILS",
                _bankStatus,
                _openVerificationHub,
                false,
              ),

              const Spacer(),

              // FINAL PAYMENT BUTTON
              if (_completedCount == 3)
                CyberButton(
                  text: "PROCEED TO FUND TRANSFER",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const FundTransferScreen(payoutAmount: 485000),
                    ),
                  ),
                )
              else
                Text("AWAITING CUSTOMER OR FO ACTION", style: AXTheme.terminal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicCard(
    String title,
    String status,
    VoidCallback onAction,
    bool isValuation,
  ) {
    bool isWaitingCust = status == "WAITING_CUST";
    bool isPendingFO = status == "PENDING_FO";
    bool isCustDone = status == "COMPLETED_CUST";
    bool isFODone = status == "COMPLETED_FO";

    Color borderColor = isCustDone
        ? AXTheme.success
        : (isFODone ? AXTheme.cyanFlux : Colors.white12);
    Color textColor = isCustDone
        ? AXTheme.success
        : (isFODone ? AXTheme.cyanFlux : AXTheme.warning);

    String subtitle = "";
    if (isWaitingCust)
      subtitle = "WAITING FOR CUST. ACCEPTANCE...";
    else if (isPendingFO)
      subtitle = "FO ACTION REQUIRED";
    else if (isCustDone)
      subtitle = "DONE BY CUSTOMER (VERIFIED)";
    else if (isFODone)
      subtitle = "DONE BY FO (SYNCED)";

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AXTheme.heading.copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          if (isWaitingCust)
            Row(
              children: [
                const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AXTheme.warning,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_active,
                    color: AXTheme.cyanFlux,
                    size: 20,
                  ),
                  onPressed: onAction,
                  tooltip: "Ping Customer",
                ),
              ],
            )
          else if (isPendingFO)
            SizedBox(
              width: 120,
              child: CyberButton(text: "COMPLETE NOW", onTap: onAction),
            )
          else
            Icon(Icons.check_circle, color: textColor, size: 25),
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

  void _verifyKYC() {
    if (panCtrl.text.length != 10 || aadhaarCtrl.text.length != 12) return;
    setState(() => _kycVerified = true);
  }

  void _verifyBank() {
    if (accCtrl.text.length < 9 || ifscCtrl.text.length != 11) return;
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
}

// ==========================================
// CUSTOM BLINKING TEXT
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

  void _nextStep() => setState(() => _step++);

  void _printBarcode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AXTheme.cyanFlux,
        content: Text("SENDING COMMAND TO THERMAL PRINTER..."),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isPrinted = true);
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
                          "YES (TXN: AX-9988-ABC)",
                          style: TextStyle(color: Colors.black, fontSize: 11),
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
                  if (adminOtpCtrl.text == "1234")
                    _nextStep();
                  else
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AXTheme.danger,
                        content: Text("WRONG ADMIN OTP"),
                      ),
                    );
                },
              ),
            ],

            if (_step == 2) ...[
              const Icon(Icons.lock, size: 60, color: AXTheme.success),
              const SizedBox(height: 10),
              Text("SEAL VAULT & CLOSE TASK", style: AXTheme.heading),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "By entering your PIN, you digitally confirm that the asset pouch has been physically secured in the vault.",
                  textAlign: TextAlign.center,
                  style: AXTheme.body.copyWith(
                    fontSize: 10,
                    color: Colors.white54,
                  ),
                ),
              ),
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
                  hintText: "ENTER FO PIN TO LOCK (0000)",
                  hintStyle: TextStyle(color: Colors.white24),
                ),
              ),

              const SizedBox(height: 30),
              CyberButton(
                text: "LOCK VAULT & RELOGIN",
                isWarning: true,
                onTap: () {
                  if (foOtpCtrl.text != "0000") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AXTheme.danger,
                        content: Text("FO PIN REQUIRED TO LOCK"),
                      ),
                    );
                    return;
                  }
                  // Vault Lock hote hi FO ka ek pura task complete. Wapas boot/login screen par.
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
