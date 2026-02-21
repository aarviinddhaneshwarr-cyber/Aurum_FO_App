import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math' as math;

import 'core_theme.dart';
import 'kyc_screen.dart';

class FundTransferScreen extends StatefulWidget {
  final double payoutAmount;
  const FundTransferScreen({super.key, required this.payoutAmount});

  @override
  State<FundTransferScreen> createState() => _FundTransferScreenState();
}

class _FundTransferScreenState extends State<FundTransferScreen> {
  int _step = 0;
  final bool _isGeofenceLocked = true;
  bool _sosActive = false;

  final TextEditingController _foPinCtrl = TextEditingController();

  String get _authTier {
    if (widget.payoutAmount <= 300000) return "FO_TIER";
    if (widget.payoutAmount <= 1200000) return "ADMIN_TIER";
    return "CFO_TIER";
  }

  String get _tierTitle {
    if (_authTier == "FO_TIER") return "L1: FIELD OFFICER VERIFICATION";
    if (_authTier == "ADMIN_TIER") return "L2: ADMIN AUTHORIZATION REQ.";
    return "L3: CFO DUAL-AUTHORIZATION REQ.";
  }

  // 💰 INDIAN CURRENCY FORMATTER (E.g. 7,58,189)
  String _formatIndianCurrency(double value) {
    String result = value.toInt().toString();
    if (result.length <= 3) return result;
    String lastThree = result.substring(result.length - 3);
    String otherNumbers = result.substring(0, result.length - 3);
    if (otherNumbers.isNotEmpty) {
      otherNumbers = otherNumbers.replaceAll(
        RegExp(r'\B(?=(\d{2})+(?!\d))'),
        ',',
      );
    }
    return '$otherNumbers,$lastThree';
  }

  // 🚨 Stealth SOS Trigger
  void _triggerSilentSOS() {
    setState(() => _sosActive = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.black,
        content: Text(
          "ENCRYPTION UPDATED",
          style: TextStyle(color: Colors.white24, fontSize: 10),
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _startBiometricScan() {
    if (!_isGeofenceLocked) return;
    setState(() => _step = 1);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _requestApproval();
    });
  }

  void _requestApproval() {
    setState(() => _step = 2);

    int delay = _authTier == "FO_TIER"
        ? 2
        : (_authTier == "ADMIN_TIER" ? 4 : 5);

    Future.delayed(Duration(seconds: delay), () {
      if (!mounted) return;
      setState(() => _step = 3);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AXTheme.success,
          content: Text(
            _authTier == "FO_TIER"
                ? "VERIFIED. ENTER FO PIN."
                : "REMOTE APPROVAL RECEIVED. ENTER FO PIN.",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    });
  }

  void _verifyAndTransfer() {
    if (_foPinCtrl.text.length == 4) {
      setState(() => _step = 4);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AXTheme.danger,
          content: Text("INVALID FO PIN ENTRY"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: _step == 4
            ? const SizedBox()
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AXTheme.cyanFlux),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          "SECURE FUND TRANSFER",
          style: AXTheme.heading.copyWith(fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  40,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // 🟢 GEOFENCE INDICATOR
                  FadeInDown(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 15,
                      ),
                      decoration: BoxDecoration(
                        color: _isGeofenceLocked
                            ? AXTheme.success.withOpacity(0.1)
                            : AXTheme.danger.withOpacity(0.1),
                        border: Border.all(
                          color: _isGeofenceLocked
                              ? AXTheme.success
                              : AXTheme.danger,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isGeofenceLocked ? Icons.gps_fixed : Icons.gps_off,
                            color: _isGeofenceLocked
                                ? AXTheme.success
                                : AXTheme.danger,
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isGeofenceLocked
                                ? "GEOFENCE LOCKED: SECURE PREMISES"
                                : "OUT OF BOUNDS: TRANSFER DISABLED",
                            style: TextStyle(
                              color: _isGeofenceLocked
                                  ? AXTheme.success
                                  : AXTheme.danger,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // AMOUNT PANEL
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: AXTheme.getPanel(isActive: _step == 4),
                    child: Column(
                      children: [
                        Text("APPROVED NET PAYOUT", style: AXTheme.terminal),
                        const SizedBox(height: 10),
                        Text(
                          // 👈 FIX: Applying the Indian Currency Formatter here
                          "₹ ${_formatIndianCurrency(widget.payoutAmount)}",
                          style: AXTheme.digital.copyWith(
                            fontSize: 32,
                            color: _step == 4
                                ? AXTheme.success
                                : AXTheme.mutedGold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _authTier == "CFO_TIER"
                                ? AXTheme.danger.withOpacity(0.2)
                                : AXTheme.cyanFlux.withOpacity(0.2),
                            border: Border.all(
                              color: _authTier == "CFO_TIER"
                                  ? AXTheme.danger
                                  : AXTheme.cyanFlux,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            _tierTitle,
                            style: TextStyle(
                              color: _authTier == "CFO_TIER"
                                  ? AXTheme.danger
                                  : AXTheme.cyanFlux,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  if (_step == 0) ...[
                    const Spacer(),
                    const Icon(
                      Icons.fingerprint_rounded,
                      size: 80,
                      color: Colors.white24,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Verify Biometrics to authorize protocol.",
                      style: AXTheme.body,
                    ),
                    const Spacer(),
                    CyberButton(
                      text: "SCAN BIOMETRICS & PROCEED",
                      onTap: _startBiometricScan,
                      isWarning: false,
                    ),
                  ],

                  if (_step == 1) ...[
                    const Spacer(),
                    const CircularProgressIndicator(color: AXTheme.cyanFlux),
                    const SizedBox(height: 20),
                    Text(
                      "VERIFYING IDENTITY...",
                      style: AXTheme.heading.copyWith(color: AXTheme.cyanFlux),
                    ),
                    const Spacer(),
                  ],

                  if (_step == 2) ...[
                    const Spacer(),
                    const CircularProgressIndicator(color: AXTheme.mutedGold),
                    const SizedBox(height: 20),
                    Text(
                      _authTier == "FO_TIER"
                          ? "VERIFYING LOCAL PROTOCOL..."
                          : "AWAITING REMOTE APPROVAL...",
                      style: AXTheme.heading.copyWith(color: AXTheme.mutedGold),
                    ),
                    const Spacer(),
                  ],

                  if (_step == 3) ...[
                    const Spacer(),
                    FadeInUp(
                      child: Column(
                        children: [
                          Icon(
                            _authTier == "FO_TIER"
                                ? Icons.lock_open
                                : Icons.cloud_done,
                            color: AXTheme.success,
                            size: 40,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _authTier == "FO_TIER"
                                ? "READY FOR DISBURSAL"
                                : "REMOTE APPROVAL GRANTED",
                            style: AXTheme.heading.copyWith(
                              color: AXTheme.success,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "ENTER YOUR FO SECURE PIN TO FINALIZE",
                            style: AXTheme.body,
                          ),
                          const SizedBox(height: 15),

                          _buildOtpField(_foPinCtrl, "FO SECURE PIN (4-Digit)"),

                          const SizedBox(height: 30),
                          CyberButton(
                            text: "CONFIRM & INITIATE TRANSFER",
                            onTap: _verifyAndTransfer,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],

                  if (_step == 4) ...[
                    const Spacer(),
                    FadeIn(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AXTheme.success,
                            size: 100,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "TRANSFER SUCCESSFUL",
                            style: AXTheme.heading.copyWith(
                              color: AXTheme.success,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Transaction ID: TXN${math.Random().nextInt(99999999)}\nFunds routed to Customer Account.",
                            style: AXTheme.body,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),

                          SizedBox(
                            width: double.infinity,
                            child: MagicalNeonButton(
                              text: "PRINT BARCODE",
                              icon: Icons.print,
                              isDone: false,
                              activeColor: AXTheme.cyanFlux,
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const BarcodeScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],

                  if (_step < 4) ...[
                    GestureDetector(
                      onLongPress: _triggerSilentSOS,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "SECURE ENCRYPTION v2.0",
                          style: TextStyle(
                            color: Colors.white12,
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      textAlign: TextAlign.center,
      style: AXTheme.digital.copyWith(fontSize: 24, letterSpacing: 10),
      keyboardType: TextInputType.number,
      obscureText: true,
      obscuringCharacter: '●',
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.white24,
          fontSize: 14,
          letterSpacing: 2,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white12),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AXTheme.cyanFlux),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.black,
      ),
    );
  }
}
