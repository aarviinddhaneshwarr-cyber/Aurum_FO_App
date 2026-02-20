import 'package:flutter/material.dart';
import 'core_theme.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

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
          "TRANSACTION LEDGER",
          style: AXTheme.heading.copyWith(fontSize: 16),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildLedgerCard(
            "AX-9988-ABC",
            "John Doe",
            "485000",
            "26.00g",
            "2026-02-20 04:19 AM",
            true,
          ),
          _buildLedgerCard(
            "AX-9987-XYZ",
            "Ravi Sharma",
            "112000",
            "15.20g",
            "2026-02-19 02:10 PM",
            true,
          ),
          _buildLedgerCard(
            "AX-9986-LMN",
            "Amit Patel",
            "0",
            "0.00g",
            "2026-02-19 11:05 AM",
            false,
          ), // Cancelled
        ],
      ),
    );
  }

  Widget _buildLedgerCard(
    String txn,
    String cust,
    String amt,
    String weight,
    String time,
    bool isSuccess,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: isSuccess
              ? AXTheme.success.withOpacity(0.5)
              : AXTheme.danger.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TXN: $txn",
                style: AXTheme.terminal.copyWith(
                  color: isSuccess ? AXTheme.cyanFlux : AXTheme.danger,
                ),
              ),
              Icon(
                isSuccess ? Icons.check_circle : Icons.cancel,
                color: isSuccess ? AXTheme.success : AXTheme.danger,
                size: 16,
              ),
            ],
          ),
          const Divider(color: Colors.white12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Customer: $cust", style: AXTheme.body),
              Text(weight, style: AXTheme.value),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: TextStyle(color: Colors.white30, fontSize: 10)),
              Text(
                isSuccess ? "₹ $amt" : "ABORTED",
                style: AXTheme.digital.copyWith(
                  fontSize: 14,
                  color: isSuccess ? AXTheme.success : AXTheme.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
