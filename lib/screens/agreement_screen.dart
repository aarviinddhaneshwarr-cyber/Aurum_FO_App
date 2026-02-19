import 'package:flutter/material.dart';

// अपनी थीम और डिज़ाइन वाली फाइल को जोड़ रहे हैं
import 'core_theme.dart';
// अगली स्क्रीन (KYC Dashboard) की फाइल को जोड़ रहे हैं
import 'kyc_screen.dart';

class AgreementScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double totalWeight;
  final double avgPurity;
  const AgreementScreen(
      {super.key,
      required this.items,
      required this.totalWeight,
      required this.avgPurity});
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
      total += w * (p / 24.0) * _goldRate;
    }
    return total;
  }

  double get _chargeAmount => _grossValuation * (_chargePercent / 100);
  double get _discountAmount => _grossValuation * (_discountPercent / 100);
  double get _netPayout => _grossValuation - _chargeAmount + _discountAmount;

  void _showNegotiationDialog() {
    double tempCharge = _chargePercent;
    TextEditingController otpCtrl = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(builder: (context, setDialogState) {
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
                      side: const BorderSide(color: AXTheme.manual)),
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text("NEGOTIATION OVERRIDE",
                            style: AXTheme.heading
                                .copyWith(color: AXTheme.manual)),
                        const SizedBox(height: 20),
                        Text(
                            "Current Charges: ${tempCharge.toStringAsFixed(1)}%",
                            style: AXTheme.value),
                        Slider(
                            value: tempCharge,
                            min: 6.0,
                            max: 12.0,
                            divisions: 12,
                            activeColor: AXTheme.manual,
                            onChanged: (v) =>
                                setDialogState(() => tempCharge = v)),
                        if (authRequired.isNotEmpty)
                          Text(authRequired,
                              style: AXTheme.body.copyWith(
                                  color: AXTheme.warning, fontSize: 10)),
                        const SizedBox(height: 10),
                        if (tempCharge < 11.5)
                          TextField(
                              controller: otpCtrl,
                              textAlign: TextAlign.center,
                              style: AXTheme.input,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  hintText: "ENTER OTP",
                                  hintStyle: TextStyle(color: Colors.white24))),
                        const SizedBox(height: 20),
                        CyberButton(
                            text: "AUTHORIZE CHANGE",
                            isManual: true,
                            onTap: () {
                              bool authorized = false;
                              if (tempCharge >= 11.5) {
                                authorized = true;
                              } else if (tempCharge >= 9.0 &&
                                  otpCtrl.text == "1111") {
                                authorized = true;
                              } else if (tempCharge < 9.0 &&
                                  otpCtrl.text == "2222") {
                                authorized = true;
                              }
                              if (authorized) {
                                setState(() => _chargePercent = tempCharge);
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    backgroundColor: AXTheme.success,
                                    content: Text(
                                        "CHARGES UPDATED TO ${tempCharge.toStringAsFixed(1)}%")));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        backgroundColor: AXTheme.danger,
                                        content: Text(
                                            "INVALID OTP OR UNAUTHORIZED")));
                              }
                            })
                      ])));
            }));
  }

  void _confirmRemove(Map<String, dynamic> item) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
                backgroundColor: AXTheme.panel,
                title: Text("REMOVE ITEM?",
                    style: AXTheme.heading.copyWith(color: AXTheme.danger)),
                content:
                    Text("Confirm deletion from deal.", style: AXTheme.body),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("CANCEL",
                          style: TextStyle(color: Colors.white))),
                  TextButton(
                      onPressed: () {
                        setState(() => _finalItems.remove(item));
                        Navigator.pop(ctx);
                      },
                      child: const Text("REMOVE",
                          style: TextStyle(color: AXTheme.danger)))
                ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AXTheme.cyanFlux),
                onPressed: () => Navigator.pop(context)),
            title: Text("CUSTOMER AGREEMENT",
                style: AXTheme.heading.copyWith(fontSize: 16))),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  padding: const EdgeInsets.all(15),
                  decoration: AXTheme.getPanel(isActive: true),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [
                          Text("ITEMS",
                              style: AXTheme.terminal.copyWith(fontSize: 10)),
                          Text("${_finalItems.length}",
                              style: AXTheme.digital.copyWith(fontSize: 18))
                        ]),
                        Container(width: 1, height: 25, color: Colors.white24),
                        Column(children: [
                          Text("WEIGHT",
                              style: AXTheme.terminal.copyWith(fontSize: 10)),
                          Text("${widget.totalWeight.toStringAsFixed(2)} g",
                              style: AXTheme.digital.copyWith(fontSize: 18))
                        ]),
                        Container(width: 1, height: 25, color: Colors.white24),
                        Column(children: [
                          Text("AVG PURITY",
                              style: AXTheme.terminal.copyWith(fontSize: 10)),
                          Text("${widget.avgPurity.toStringAsFixed(1)} K",
                              style: AXTheme.digital.copyWith(
                                  fontSize: 18, color: AXTheme.mutedGold))
                        ]),
                        Container(width: 1, height: 25, color: Colors.white24),
                        Column(children: [
                          Text("RATE",
                              style: AXTheme.terminal.copyWith(fontSize: 10)),
                          Text("₹7245",
                              style: AXTheme.digital.copyWith(
                                  fontSize: 18, color: AXTheme.success))
                        ]),
                      ])),
              const SizedBox(height: 20),
              Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AXTheme.getPanel(isActive: true),
                  child: Column(children: [
                    _buildRow(
                        "Gross Valuation",
                        "₹ ${_grossValuation.toStringAsFixed(0)}",
                        Colors.white),
                    const SizedBox(height: 10),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                              onTap: _showNegotiationDialog,
                              child: Text(
                                  "Aurum Charges (${_chargePercent.toStringAsFixed(1)}%)",
                                  style: AXTheme.body)),
                          Text("- ₹ ${_chargeAmount.toStringAsFixed(0)}",
                              style:
                                  AXTheme.value.copyWith(color: AXTheme.danger))
                        ]),
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            "(Onsite Spectrometry • Secure Logistics • Refining & Melt-Loss • Compliance)",
                            style:
                                TextStyle(color: Colors.white30, fontSize: 8))),
                    const SizedBox(height: 10),
                    _buildRow(
                        "Priority Waiver (3%)",
                        "+ ₹ ${_discountAmount.toStringAsFixed(0)}",
                        AXTheme.success),
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            "(Conditional Benefit for High-Integrity Assets)",
                            style:
                                TextStyle(color: Colors.white30, fontSize: 8))),
                    const Divider(color: Colors.white24, height: 30),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("NET PAYOUT",
                              style: AXTheme.heading.copyWith(fontSize: 16)),
                          Text("₹ ${_netPayout.toStringAsFixed(0)}",
                              style: AXTheme.digital.copyWith(
                                  fontSize: 22, color: AXTheme.mutedGold))
                        ]),
                  ])),
              const SizedBox(height: 20),
              Text("ITEMIZED BREAKDOWN", style: AXTheme.terminal),
              const SizedBox(height: 10),
              if (_finalItems.isEmpty)
                Center(
                    child: Text("NO ITEMS LEFT IN DEAL",
                        style: AXTheme.body.copyWith(color: AXTheme.danger))),
              ..._finalItems.map((item) {
                double val = double.parse(item['weight']) *
                    (double.parse(item['purity']) / 24.0) *
                    _goldRate;
                return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'],
                                    style: AXTheme.body.copyWith(fontSize: 12)),
                                Text("${item['weight']}g @ ${item['purity']}K",
                                    style: AXTheme.value.copyWith(fontSize: 10))
                              ]),
                          Row(children: [
                            Text("₹${val.toStringAsFixed(0)}",
                                style: AXTheme.digital.copyWith(
                                    fontSize: 12, color: AXTheme.success)),
                            const SizedBox(width: 10),
                            GestureDetector(
                                onTap: () => _confirmRemove(item),
                                child: const Icon(Icons.delete_outline,
                                    size: 18, color: AXTheme.danger))
                          ])
                        ]));
              }).toList(),
              const SizedBox(height: 30),
              Text("TERMS & SIGNATURE", style: AXTheme.terminal),
              const SizedBox(height: 10),
              Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.white10),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                      "I confirm ownership of assets and agree to the valuation.",
                      style: AXTheme.body
                          .copyWith(fontSize: 11, color: Colors.white54))),
              const SizedBox(height: 20),
              const FastSignaturePad(),
            ])));
  }

  Widget _buildRow(String label, String val, Color c) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: AXTheme.body),
      Text(val, style: AXTheme.value.copyWith(color: c))
    ]);
  }
}

// --- OPTIMIZED SIGNATURE WIDGET ---
class FastSignaturePad extends StatefulWidget {
  const FastSignaturePad({super.key});
  @override
  State<FastSignaturePad> createState() => _FastSignaturePadState();
}

class _FastSignaturePadState extends State<FastSignaturePad> {
  List<Offset?> _points = [];
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AXTheme.cyanFlux.withOpacity(0.3))),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                onPanStart: (d) => setState(() => _points.add(d.localPosition)),
                onPanUpdate: (d) =>
                    setState(() => _points.add(d.localPosition)),
                onPanEnd: (d) => setState(() => _points.add(null)),
                child: CustomPaint(
                    painter: SignaturePainter(points: _points),
                    size: Size.infinite),
              ))),
      Align(
          alignment: Alignment.centerRight,
          child: TextButton(
              onPressed: () => setState(() => _points = []),
              child: const Text("CLEAR SIGNATURE",
                  style: TextStyle(color: AXTheme.danger, fontSize: 10)))),
      const SizedBox(height: 10),
      CyberButton(
          text: "CONFIRM DEAL & WAIT FOR ACCEPTANCE",
          onTap: () {
            if (_points.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  backgroundColor: AXTheme.danger,
                  content: Text("SIGNATURE REQUIRED")));
              return;
            }
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CustomerWaitScreen()));
          })
    ]);
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

// ==========================================
// CUSTOMER WAIT SCREEN
// ==========================================

class CustomerWaitScreen extends StatefulWidget {
  const CustomerWaitScreen({super.key});
  @override
  State<CustomerWaitScreen> createState() => _CustomerWaitScreenState();
}

class _CustomerWaitScreenState extends State<CustomerWaitScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _simulateCustomerAccept() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: AXTheme.success,
        content: Text("CUSTOMER APPROVED & ACCEPTED")));
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const KYCStatusDashboard()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      FadeTransition(
          opacity: _ctrl,
          child: const Icon(Icons.phonelink_ring,
              size: 80, color: AXTheme.warning)),
      const SizedBox(height: 30),
      Text("AWAITING CUSTOMER ACCEPTANCE",
          style: AXTheme.heading.copyWith(color: AXTheme.warning)),
      const SizedBox(height: 10),
      Text("Details sent to Customer App.\nWaiting for 'APPROVED & ACCEPT'...",
          style: AXTheme.body, textAlign: TextAlign.center),
      const SizedBox(height: 50),
      CyberButton(
          text: "[SIMULATE] CUSTOMER ACCEPTS", onTap: _simulateCustomerAccept)
    ])));
  }
}
