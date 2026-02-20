import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

// अपनी थीम और बाकी स्क्रीन्स को जोड़ रहे हैं
import 'core_theme.dart';
import 'valuation_screen.dart';
import 'ledger_screen.dart';
import 'support_screen.dart';
import 'profile_handover_screen.dart';

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
      "note": "Address Verified. VIP Client.",
    },
    {
      "name": "MEERA IYER",
      "address": "Villa 9, Palm Greens, Thane",
      "dist": "12 KM",
      "priority": false,
      "status": "SCHEDULED",
      "note": "KYC Pending.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
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
          side: const BorderSide(color: AXTheme.danger, width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning, color: AXTheme.danger, size: 30),
            const SizedBox(width: 10),
            Text(
              "PANIC ALERT",
              style: AXTheme.heading.copyWith(color: AXTheme.danger),
            ),
          ],
        ),
        content: Text(
          "Silent Alarm Triggered.\nLive Audio/Video Feed sent to HQ.",
          style: AXTheme.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "FALSE ALARM",
              style: AXTheme.body.copyWith(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToValuation(Map<String, dynamic> task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ValuationScreen(taskData: task)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ==========================================
      // NEW: SLIDING NAVIGATION DRAWER (MENU)
      // ==========================================
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: Container(
          decoration: BoxDecoration(
            border: const Border(
              right: BorderSide(color: AXTheme.cyanFlux, width: 2),
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: AXTheme.panel),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AXTheme.cyanFlux,
                      child: Icon(Icons.person, color: Colors.black, size: 40),
                    ),
                    const SizedBox(height: 10),
                    Text("AARVIIND (FO)", style: AXTheme.heading),
                    Text(
                      "ID: AX-1042",
                      style: AXTheme.terminal.copyWith(
                        color: AXTheme.mutedGold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(Icons.inventory, "FO PROFILE & HANDOVER", () {
                Navigator.pop(context); // Close Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileHandoverScreen(),
                  ),
                );
              }),
              _buildDrawerItem(
                Icons.account_balance_wallet,
                "TRANSACTION LEDGER",
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LedgerScreen()),
                  );
                },
              ),
              _buildDrawerItem(Icons.headset_mic, "SUPPORT & SOS LOGS", () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SupportScreen()),
                );
              }),
            ],
          ),
        ),
      ),

      // ==========================================
      // EXISTING COCKPIT UI (UNCHANGED)
      // ==========================================
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: GridPainter()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ), // Thoda adjust kiya taaki Menu icon fit ho
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // NEW MENU BUTTON TO OPEN DRAWER
                          Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(
                                Icons.menu,
                                color: AXTheme.cyanFlux,
                              ),
                              onPressed: () =>
                                  Scaffold.of(context).openDrawer(),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "AURUM X",
                                style: AXTheme.brand.copyWith(fontSize: 18),
                              ),
                              Text("UNIT: FO-007", style: AXTheme.terminal),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildStatusBadge("GPS", true),
                          const SizedBox(width: 5),
                          _buildStatusBadge("BODY CAM", true),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.battery_charging_full,
                            color: AXTheme.success,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _radarController,
                        builder: (_, __) => CustomPaint(
                          size: const Size(220, 220),
                          painter: RadarPainter(
                            _radarController.value * 2 * math.pi,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${_tasks.length}",
                            style: AXTheme.digital.copyWith(
                              fontSize: 40,
                              color: Colors.white,
                            ),
                          ),
                          Text("TARGETS", style: AXTheme.terminal),
                        ],
                      ),
                      Positioned(
                        top: 60,
                        right: 80,
                        child: _buildBlinkingDot(),
                      ),
                      Positioned(
                        bottom: 80,
                        left: 90,
                        child: _buildBlinkingDot(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "MISSION MANIFEST",
                      style: AXTheme.terminal.copyWith(
                        letterSpacing: 2,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
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
                          decoration: AXTheme.getPanel(
                            isActive: task['priority'],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    task['name'],
                                    style: AXTheme.heading.copyWith(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: task['priority']
                                          ? AXTheme.cyanFlux
                                          : Colors.white10,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      task['dist'],
                                      style: AXTheme.terminal.copyWith(
                                        color: task['priority']
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                task['address'],
                                style: AXTheme.body.copyWith(
                                  fontSize: 11,
                                  color: Colors.white60,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(color: Colors.white10),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.support_agent,
                                    size: 14,
                                    color: AXTheme.mutedGold,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "HQ NOTE: ${task['note']}",
                                    style: AXTheme.body.copyWith(
                                      fontSize: 11,
                                      color: AXTheme.mutedGold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(
                                    child: CyberButton(
                                      text: "CALL",
                                      isWarning: true,
                                      onTap: () => _callCustomer(task['name']),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: CyberButton(
                                      text: "ENGAGE",
                                      isManual: !task['priority'],
                                      onTap: task['priority']
                                          ? () => _navigateToValuation(task)
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: PanicButton(onPanicTriggered: _triggerPanic),
          ),
        ],
      ),
    );
  }

  // DRAWER MENU ITEM HELPER
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AXTheme.cyanFlux),
      title: Text(title, style: AXTheme.body),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap,
    );
  }

  Widget _buildStatusBadge(String text, bool isOnline) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: isOnline ? AXTheme.success : AXTheme.danger),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8,
          color: isOnline ? AXTheme.success : AXTheme.danger,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBlinkingDot() {
    return BlinkingWidget(
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AXTheme.warning,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AXTheme.warning, blurRadius: 5)],
        ),
      ),
    );
  }
}
