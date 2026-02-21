import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';

import 'core_theme.dart';
import 'kyc_screen.dart'; // 👈 FIX: We only need this import now!

class AgreementScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double totalWeight;
  final double avgPurity;
  const AgreementScreen({
    super.key,
    required this.items,
    required this.totalWeight,
    required this.avgPurity,
  });
  @override
  State<AgreementScreen> createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> {
  late List<Map<String, dynamic>> _finalItems;
  double _chargePercent = 12.0;
  final double _discountPercent = 3.0;
  final double _goldRate = 7245.0;

  @override
  void initState() {
    super.initState();
    _finalItems = List.from(widget.items);
  }

  double get _grossValuation {
    double total = 0.0;
    for (var item in _finalItems) {
      double w = double.parse(item['weight']);
      double p = double.parse(item['purity']);
      double purityInKarat = item['unit'] == '%' ? (p / 100.0) * 24.0 : p;
      total += w * (purityInKarat / 24.0) * _goldRate;
    }
    return total;
  }

  double get _chargeAmount => _grossValuation * (_chargePercent / 100);
  double get _discountAmount => _grossValuation * (_discountPercent / 100);
  double get _netPayout => _grossValuation - _chargeAmount + _discountAmount;

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

  void _showNegotiationDialog() {
    double tempCharge = _chargePercent;
    TextEditingController otpCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          String authRequired = "";
          if (tempCharge < 9.0) {
            authRequired = "CFO APPROVAL REQUIRED";
          } else if (tempCharge < 11.5) {
            authRequired = "ADMIN APPROVAL REQUIRED";
          }
          return Dialog(
            backgroundColor: AXTheme.panel,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AXTheme.manual),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "NEGOTIATION OVERRIDE",
                    style: AXTheme.heading.copyWith(color: AXTheme.manual),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Current Charges: ${tempCharge.toStringAsFixed(1)}%",
                    style: AXTheme.value,
                  ),
                  Slider(
                    value: tempCharge,
                    min: 6.0,
                    max: 12.0,
                    divisions: 12,
                    activeColor: AXTheme.manual,
                    onChanged: (v) => setDialogState(() => tempCharge = v),
                  ),
                  if (authRequired.isNotEmpty)
                    Text(
                      authRequired,
                      style: AXTheme.body.copyWith(
                        color: AXTheme.warning,
                        fontSize: 10,
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (tempCharge < 11.5)
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
                        hintText: "ENTER OTP (4-DIGIT)",
                        hintStyle: TextStyle(color: Colors.white24),
                      ),
                    ),
                  const SizedBox(height: 20),
                  CyberButton(
                    text: "AUTHORIZE CHANGE",
                    isManual: true,
                    onTap: () {
                      bool authorized = false;
                      if (tempCharge >= 11.5) {
                        authorized = true;
                      } else if (tempCharge >= 9.0 && otpCtrl.text == "1111") {
                        authorized = true;
                      } else if (tempCharge < 9.0 && otpCtrl.text == "2222") {
                        authorized = true;
                      }

                      if (authorized) {
                        setState(() => _chargePercent = tempCharge);
                        Navigator.pop(ctx);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AXTheme.danger,
                            content: Text("INVALID OTP"),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmRemove(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AXTheme.panel,
        title: Text(
          "REMOVE ITEM?",
          style: AXTheme.heading.copyWith(color: AXTheme.danger),
        ),
        content: Text("Confirm deletion from deal.", style: AXTheme.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _finalItems.remove(item));
              Navigator.pop(ctx);
            },
            child: const Text(
              "REMOVE",
              style: TextStyle(color: AXTheme.danger),
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
          "DEAL SUMMARY",
          style: AXTheme.heading.copyWith(fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: AXTheme.getPanel(isActive: true),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        "ITEMS",
                        style: AXTheme.terminal.copyWith(fontSize: 10),
                      ),
                      Text(
                        "${_finalItems.length}",
                        style: AXTheme.digital.copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 25, color: Colors.white24),
                  Column(
                    children: [
                      Text(
                        "WEIGHT",
                        style: AXTheme.terminal.copyWith(fontSize: 10),
                      ),
                      Text(
                        "${widget.totalWeight.toStringAsFixed(2)} g",
                        style: AXTheme.digital.copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 25, color: Colors.white24),
                  Column(
                    children: [
                      Text(
                        "AVG PURITY",
                        style: AXTheme.terminal.copyWith(fontSize: 10),
                      ),
                      Text(
                        "${widget.avgPurity.toStringAsFixed(1)} K",
                        style: AXTheme.digital.copyWith(
                          fontSize: 18,
                          color: AXTheme.mutedGold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AXTheme.getPanel(isActive: true),
              child: Column(
                children: [
                  _buildRow(
                    "Gross Valuation",
                    "₹ ${_formatIndianCurrency(_grossValuation)}",
                    Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _showNegotiationDialog,
                        child: Text(
                          "Aurum Charges (${_chargePercent.toStringAsFixed(1)}%)",
                          style: AXTheme.body,
                        ),
                      ),
                      Text(
                        "- ₹ ${_formatIndianCurrency(_chargeAmount)}",
                        style: AXTheme.value.copyWith(color: AXTheme.danger),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildRow(
                    "Priority Waiver (3%)",
                    "+ ₹ ${_formatIndianCurrency(_discountAmount)}",
                    AXTheme.success,
                  ),
                  const Divider(color: Colors.white24, height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "NET PAYOUT",
                        style: AXTheme.heading.copyWith(fontSize: 16),
                      ),
                      Text(
                        "₹ ${_formatIndianCurrency(_netPayout)}",
                        style: AXTheme.digital.copyWith(
                          fontSize: 22,
                          color: AXTheme.mutedGold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Text("ITEMIZED BREAKDOWN", style: AXTheme.terminal),
            const SizedBox(height: 10),
            if (_finalItems.isEmpty)
              Center(
                child: Text(
                  "NO ITEMS LEFT IN DEAL",
                  style: AXTheme.body.copyWith(color: AXTheme.danger),
                ),
              ),
            ..._finalItems.map((item) {
              double p = double.parse(item['purity']);
              double purityInKarat = item['unit'] == '%'
                  ? (p / 100.0) * 24.0
                  : p;
              double val =
                  double.parse(item['weight']) *
                  (purityInKarat / 24.0) *
                  _goldRate;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: AXTheme.body.copyWith(fontSize: 12),
                        ),
                        Text(
                          "${item['weight']}g @ ${item['purity']}${item['unit']}",
                          style: AXTheme.value.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "₹${_formatIndianCurrency(val)}",
                          style: AXTheme.digital.copyWith(
                            fontSize: 12,
                            color: AXTheme.success,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _confirmRemove(item),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AXTheme.danger,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 30),

            Text("DIGITAL CONSENT", style: AXTheme.terminal),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Detailed breakdown & T&C will be securely transmitted to the Customer's App for E-Signature verification.",
                style: AXTheme.body.copyWith(
                  fontSize: 11,
                  color: Colors.white54,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 👈 FIX: Changed the Navigation route back to KYCStatusDashboard with real amount!
            CyberButton(
              text: "TRANSMIT DEAL TO CUSTOMER >",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AXTheme.cyanFlux,
                    content: Text("AGREEMENT TRANSMITTED TO CUSTOMER APP"),
                  ),
                );

                // Now it passes the real amount to the KYC Dashboard
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        KYCStatusDashboard(payoutAmount: _netPayout),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String val, Color c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AXTheme.body),
        Text(val, style: AXTheme.value.copyWith(color: c)),
      ],
    );
  }
}
