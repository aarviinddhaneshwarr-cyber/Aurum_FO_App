import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math' as math;

import 'core_theme.dart';
// Barcode स्क्रीन पर जाने के लिए kyc_screen को इम्पोर्ट कर रहे हैं
import 'kyc_screen.dart';

class FundTransferScreen extends StatefulWidget {
  final double payoutAmount;
  const FundTransferScreen({super.key, required this.payoutAmount});

  @override
  State<FundTransferScreen> createState() => _FundTransferScreenState();
}

class _FundTransferScreenState extends State<FundTransferScreen> {
  int _step = 0; // 0: Init, 1: Waiting Approval, 2: Enter OTP, 3: Success
  final TextEditingController _otp1Ctrl = TextEditingController();
  final TextEditingController _otp2Ctrl = TextEditingController();

  // ==========================================
  // 3-TIER AUTHORIZATION LOGIC
  // ==========================================
  String get _authTier {
    if (widget.payoutAmount <= 300000) return "FO_TIER"; // 0 - 3 Lakh
    if (widget.payoutAmount <= 1200000) return "ADMIN_TIER"; // 3L - 12 Lakh
    return "CFO_TIER"; // 12L - 90 Lakh
  }

  String get _tierTitle {
    if (_authTier == "FO_TIER") return "L1: FIELD OFFICER VERIFICATION";
    if (_authTier == "ADMIN_TIER") return "L2: ADMIN AUTHORIZATION REQ.";
    return "L3: CFO DUAL-AUTHORIZATION REQ.";
  }

  void _requestApproval() {
    setState(() => _step = 1);

    int delay = _authTier == "FO_TIER"
        ? 1
        : (_authTier == "ADMIN_TIER" ? 3 : 4);

    // सिम्युलेट कर रहे हैं कि सर्वर से अप्रूवल आ रहा है
    Future.delayed(Duration(seconds: delay), () {
      setState(() => _step = 2);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AXTheme.success,
          content: Text(
            _authTier == "FO_TIER"
                ? "OTP SENT TO YOUR DEVICE"
                : "APPROVAL RECEIVED. ENTER OTP.",
          ),
        ),
      );
    });
  }

  void _verifyAndTransfer() {
    bool isSuccess = false;
    if (_authTier == "FO_TIER" || _authTier == "ADMIN_TIER") {
      if (_otp1Ctrl.text.length == 4) isSuccess = true;
    } else {
      if (_otp1Ctrl.text.length == 4 && _otp2Ctrl.text.length == 4)
        isSuccess = true;
    }

    if (isSuccess) {
      setState(() => _step = 3); // Move to Success State
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AXTheme.danger,
          content: Text("INVALID OTP ENTRY"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: _step == 3
            ? const SizedBox()
            : IconButton(
                // Success के बाद Back बटन गायब
                icon: const Icon(Icons.arrow_back_ios, color: AXTheme.cyanFlux),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          "SECURE FUND TRANSFER",
          style: AXTheme.heading.copyWith(fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // AMOUNT DISPLAY CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AXTheme.getPanel(isActive: _step == 3),
              child: Column(
                children: [
                  Text("APPROVED NET PAYOUT", style: AXTheme.terminal),
                  const SizedBox(height: 10),
                  Text(
                    "₹ ${widget.payoutAmount.toStringAsFixed(0)}",
                    style: AXTheme.digital.copyWith(
                      fontSize: 32,
                      color: _step == 3 ? AXTheme.success : AXTheme.mutedGold,
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

            // STEP 0: REQUEST BUTTON
            if (_step == 0) ...[
              const Spacer(),
              const Icon(Icons.security, size: 80, color: Colors.white24),
              const SizedBox(height: 20),
              Text(
                "Select action to initiate bank transfer.",
                style: AXTheme.body,
              ),
              const Spacer(),
              CyberButton(
                text: _authTier == "FO_TIER"
                    ? "GENERATE TRANSFER OTP"
                    : "REQUEST SERVER APPROVAL",
                onTap: _requestApproval,
                isWarning: _authTier == "CFO_TIER",
              ),
            ],

            // STEP 1: WAITING LOADER
            if (_step == 1) ...[
              const Spacer(),
              const CircularProgressIndicator(color: AXTheme.cyanFlux),
              const SizedBox(height: 20),
              Text(
                _authTier == "FO_TIER"
                    ? "GENERATING SECURE OTP..."
                    : "AWAITING REMOTE APPROVAL...",
                style: AXTheme.heading.copyWith(color: AXTheme.cyanFlux),
              ),
              const Spacer(),
            ],

            // STEP 2: OTP ENTRY
            if (_step == 2) ...[
              FadeInUp(
                child: Column(
                  children: [
                    Text("AUTHORIZATION REQUIRED", style: AXTheme.heading),
                    const SizedBox(height: 20),
                    _buildOtpField(
                      _otp1Ctrl,
                      _authTier == "FO_TIER"
                          ? "FO OTP (4-Digit)"
                          : "ADMIN OTP (4-Digit)",
                    ),

                    if (_authTier == "CFO_TIER") ...[
                      const SizedBox(height: 15),
                      _buildOtpField(_otp2Ctrl, "CFO OTP (4-Digit)"),
                    ],

                    const SizedBox(height: 30),
                    CyberButton(
                      text: "CONFIRM & INITIATE TRANSFER",
                      onTap: _verifyAndTransfer,
                    ),
                  ],
                ),
              ),
            ],

            // STEP 3: PAYMENT SUCCESS & PRINT BARCODE (Magical Button)
            if (_step == 3) ...[
              Expanded(
                child: FadeIn(
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

                      // जादुई प्रिंट बारकोड बटन
                      MagicalNeonButton(
                        text: "PRINT BARCODE",
                        icon: Icons.print,
                        isDone: false,
                        activeColor: AXTheme.cyanFlux,
                        onTap: () {
                          // Barcode Screen पर भेज रहे हैं
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BarcodeScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
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
