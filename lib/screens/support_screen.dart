import 'package:flutter/material.dart';
import 'core_theme.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

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
          "SUPPORT & SOS LOGS",
          style: AXTheme.heading.copyWith(fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AXTheme.getPanel(isActive: true),
              child: Row(
                children: [
                  const Icon(
                    Icons.headset_mic,
                    color: AXTheme.cyanFlux,
                    size: 40,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("IT COMMAND CENTER", style: AXTheme.heading),
                      Text(
                        "+91 8000 999 888",
                        style: AXTheme.digital.copyWith(
                          fontSize: 18,
                          color: AXTheme.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text("RECENT PANIC (SOS) LOGS", style: AXTheme.terminal),
            const SizedBox(height: 10),
            _buildSosLog(
              "2026-02-15 08:30 PM",
              "LOCATION MISMATCH ALERT",
              "RESOLVED",
            ),
            _buildSosLog(
              "2026-02-10 11:45 AM",
              "BIOMETRIC FAILURE OVERRIDE",
              "RESOLVED",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSosLog(String time, String reason, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: AXTheme.warning),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reason,
                style: TextStyle(
                  color: AXTheme.warning,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(time, style: TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
          Text(
            status,
            style: TextStyle(
              color: AXTheme.success,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
