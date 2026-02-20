import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core_theme.dart';
import 'boot_screen.dart'; // Log out hokar wapas yahan aayega

class ProfileHandoverScreen extends StatefulWidget {
  const ProfileHandoverScreen({super.key});
  @override
  State<ProfileHandoverScreen> createState() => _ProfileHandoverScreenState();
}

class _ProfileHandoverScreenState extends State<ProfileHandoverScreen> {
  int _handoverStep = 0; // 0: Profile, 1: Admin OTP, 2: Final Handover

  void _initiateHandover() {
    setState(() => _handoverStep = 1);
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController adminOtpCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: _handoverStep == 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AXTheme.cyanFlux),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          _handoverStep == 0 ? "FO PROFILE & OPS" : "END SHIFT HANDOVER",
          style: AXTheme.heading.copyWith(fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- STEP 0: PROFILE VIEW ---
            if (_handoverStep == 0) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AXTheme.getPanel(isActive: true),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AXTheme.cyanFlux,
                      child: Icon(Icons.person, size: 50, color: Colors.black),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "AARVIIND (FO)",
                      style: AXTheme.heading.copyWith(fontSize: 20),
                    ),
                    Text(
                      "ID: AX-1042 • NAVI MUMBAI HUB",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const Divider(color: Colors.white24, height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              "TARGET",
                              style: AXTheme.terminal.copyWith(fontSize: 10),
                            ),
                            Text(
                              "500g",
                              style: AXTheme.digital.copyWith(fontSize: 20),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "ACHIEVED",
                              style: AXTheme.terminal.copyWith(fontSize: 10),
                            ),
                            Text(
                              "142g",
                              style: AXTheme.digital.copyWith(
                                fontSize: 20,
                                color: AXTheme.success,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "POUCHES",
                              style: AXTheme.terminal.copyWith(fontSize: 10),
                            ),
                            Text(
                              "3",
                              style: AXTheme.digital.copyWith(
                                fontSize: 20,
                                color: AXTheme.warning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Icon(
                Icons.warning_amber_rounded,
                color: AXTheme.warning,
                size: 40,
              ),
              const SizedBox(height: 10),
              Text(
                "END OF SHIFT?",
                style: AXTheme.heading.copyWith(color: AXTheme.warning),
              ),
              const SizedBox(height: 10),
              Text(
                "Empty your secure locker and handover all asset pouches with thermal receipts to the Hub Admin.",
                textAlign: TextAlign.center,
                style: AXTheme.body,
              ),
              const SizedBox(height: 20),
              CyberButton(
                text: "INITIATE ADMIN HANDOVER",
                isWarning: true,
                onTap: _initiateHandover,
              ),
            ],

            // --- STEP 1: ADMIN OTP TO UNLOCK FO'S LOCKER ---
            if (_handoverStep == 1) ...[
              const Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: AXTheme.cyanFlux,
              ),
              const SizedBox(height: 20),
              Text("HUB ADMIN AUTHORIZATION", style: AXTheme.heading),
              const SizedBox(height: 10),
              Text(
                "Admin must enter their PIN to unlock FO's mobile locker.",
                textAlign: TextAlign.center,
                style: AXTheme.body,
              ),
              const SizedBox(height: 30),
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
                  hintText: "ENTER ADMIN PIN (1234)",
                  hintStyle: TextStyle(color: Colors.white24),
                ),
              ),
              const SizedBox(height: 20),
              CyberButton(
                text: "UNLOCK FO LOCKER",
                onTap: () {
                  if (adminOtpCtrl.text == "1234") {
                    setState(() => _handoverStep = 2);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AXTheme.danger,
                        content: Text("INVALID ADMIN PIN"),
                      ),
                    );
                  }
                },
              ),
            ],

            // --- STEP 2: HANDOVER CONFIRM & LOGOUT ---
            if (_handoverStep == 2) ...[
              const Icon(Icons.inventory, size: 80, color: AXTheme.success),
              const SizedBox(height: 20),
              Text(
                "LOCKER UNLOCKED",
                style: AXTheme.heading.copyWith(color: AXTheme.success),
              ),
              const SizedBox(height: 10),
              Text(
                "Please physically hand over 3 pouches to the Admin.",
                textAlign: TextAlign.center,
                style: AXTheme.body,
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: AXTheme.warning),
                ),
                child: Text(
                  "By clicking below, Admin confirms receipt of all assets and FO duty will be officially closed.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AXTheme.warning, fontSize: 10),
                ),
              ),
              const SizedBox(height: 20),
              CyberButton(
                text: "CONFIRM HANDOVER & LOG OUT",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AXTheme.success,
                      content: Text("DUTY CLOSED SUCCESSFULLY!"),
                    ),
                  );
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
