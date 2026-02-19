import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';

import 'core_theme.dart';
import 'agreement_screen.dart';

class ValuationScreen extends StatefulWidget {
  final Map<String, dynamic>? taskData;
  const ValuationScreen({super.key, this.taskData});
  @override
  State<ValuationScreen> createState() => _ValuationScreenState();
}

class _ValuationScreenState extends State<ValuationScreen> {
  bool _isManualMode = false;
  bool _isKaratMode = true;
  bool _aiDone = false;
  bool _scaleDone = false;
  bool _xrfDone = false;
  final List<Map<String, dynamic>> _items = [];

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _purityCtrl = TextEditingController();
  String _aiOriginalName = "";
  String _aiOriginalDesc = "";
  final double _goldRate = 7245.0;

  List<Map<String, dynamic>> get _displayItems =>
      _items.where((i) => i['isManual'] == _isManualMode).toList();

  double get _displayWeight => _displayItems.fold(
    0.0,
    (sum, item) => sum + double.parse(item['weight']),
  );

  double get _avgPurity {
    if (_displayItems.isEmpty) return 0.0;
    double totalFine = 0.0;
    for (var item in _displayItems) {
      double w = double.parse(item['weight']);
      double p = double.parse(item['purity']);
      double purityInKarat = item['unit'] == '%' ? (p / 100.0) * 24.0 : p;
      totalFine += (w * purityInKarat);
    }
    return _displayWeight == 0 ? 0.0 : (totalFine / _displayWeight);
  }

  void _addItem() {
    if (!_isManualMode) {
      if (!_aiDone || !_scaleDone || !_xrfDone) {
        _showError("SYNC PENDING: Check AI, Scale & XRF");
        return;
      }
    }
    if (_nameCtrl.text.isEmpty ||
        _weightCtrl.text.isEmpty ||
        _purityCtrl.text.isEmpty) {
      _showError("FIELDS EMPTY");
      return;
    }
    setState(() {
      double w = double.parse(_weightCtrl.text);
      double p = double.parse(_purityCtrl.text);
      double purityFraction = _isKaratMode ? (p / 24.0) : (p / 100.0);
      double price = w * purityFraction * _goldRate;

      _items.add({
        "name": _nameCtrl.text,
        "desc": _descCtrl.text,
        "weight": _weightCtrl.text,
        "purity": _purityCtrl.text,
        "unit": _isKaratMode ? "K" : "%",
        "isManual": _isManualMode,
        "aiOriginal": _aiOriginalName,
        "price": price,
      });
      _resetForm();
    });
  }

  void _resetForm() {
    _nameCtrl.clear();
    _descCtrl.clear();
    _weightCtrl.clear();
    _purityCtrl.clear();
    _aiOriginalName = "";
    _aiOriginalDesc = "";
    _aiDone = false;
    _scaleDone = false;
    _xrfDone = false;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AXTheme.danger,
        content: Text(msg, style: AXTheme.heading.copyWith(fontSize: 12)),
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
        content: Text("Confirm deletion from manifest.", style: AXTheme.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _items.remove(item));
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
              "WARNING: DATA LOSS",
              style: AXTheme.heading.copyWith(color: AXTheme.danger),
            ),
            content: Text(
              "Leaving this screen will clear all entered items. Are you sure?",
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
                  "EXIT & CLEAR",
                  style: TextStyle(color: AXTheme.danger),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  void _showHardwarePopup(String type) {
    String title = type == "AI"
        ? "ANALYZING ORNAMENT..."
        : (type == "SCALE" ? "CONNECTING SCALE..." : "CALIBRATING XRF...");
    IconData icon = type == "AI"
        ? Icons.qr_code_scanner
        : (type == "SCALE" ? Icons.line_weight : Icons.science);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: 400,
        decoration: const BoxDecoration(
          color: AXTheme.panel,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AXTheme.cyanFlux),
            const SizedBox(height: 20),
            Text(title, style: AXTheme.heading),
            const SizedBox(height: 20),
            CyberButton(
              text: "CAPTURE DATA",
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  if (type == "AI") {
                    _aiDone = true;
                    _aiOriginalName = "Gold Bangle";
                    _aiOriginalDesc = "Red stone setting";
                    _nameCtrl.text = _aiOriginalName;
                    _descCtrl.text = _aiOriginalDesc;
                  } else if (type == "SCALE") {
                    _scaleDone = true;
                    _weightCtrl.text = "12.50";
                  } else if (type == "XRF") {
                    _xrfDone = true;
                    _purityCtrl.text = "22.0";
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _triggerManualOverride() {
    TextEditingController otpCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
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
                "MANUAL OVERRIDE",
                style: AXTheme.heading.copyWith(color: AXTheme.manual),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: otpCtrl,
                textAlign: TextAlign.center,
                style: AXTheme.input,
                keyboardType: TextInputType.number,
                // ==========================================
                // STRICT 4 DIGIT LIMIT ADDED HERE
                // ==========================================
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: const InputDecoration(
                  hintText: "CODE (4-DIGIT)",
                  hintStyle: TextStyle(color: Colors.white24),
                ),
              ),
              const SizedBox(height: 20),
              CyberButton(
                text: "UNLOCK",
                isManual: true,
                onTap: () {
                  if (otpCtrl.text == "9999") {
                    Navigator.pop(ctx);
                    setState(() => _isManualMode = true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color activeColor = _isManualMode ? AXTheme.manual : AXTheme.cyanFlux;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: activeColor),
            onPressed: () => _onWillPop().then((val) {
              if (val) Navigator.pop(context);
            }),
          ),
          title: Text(
            _isManualMode ? "MANUAL ENTRY MODE" : "AUTO VALUATION MODE",
            style: AXTheme.heading.copyWith(color: activeColor, fontSize: 14),
          ),
          actions: [
            if (_isManualMode)
              IconButton(
                icon: const Icon(Icons.restore, color: Colors.white),
                onPressed: () => setState(() => _isManualMode = false),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: AXTheme.getPanel(
                  isActive: !_isManualMode,
                  isManual: _isManualMode,
                ),
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
                          "${_displayItems.length}",
                          style: AXTheme.digital.copyWith(fontSize: 20),
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
                          "${_displayWeight.toStringAsFixed(2)} g",
                          style: AXTheme.digital.copyWith(fontSize: 20),
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
                          "${_avgPurity.toStringAsFixed(1)} K",
                          style: AXTheme.digital.copyWith(
                            fontSize: 20,
                            color: AXTheme.mutedGold,
                          ),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 25, color: Colors.white24),
                    Column(
                      children: [
                        Text(
                          "RATE",
                          style: AXTheme.terminal.copyWith(fontSize: 10),
                        ),
                        Text(
                          "₹7245",
                          style: AXTheme.digital.copyWith(
                            fontSize: 20,
                            color: AXTheme.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_displayItems.isNotEmpty)
                ...List.generate(_displayItems.length, (index) {
                  final e = _displayItems[index];
                  return FadeIn(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AXTheme.panel,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isManualMode
                              ? AXTheme.manual.withOpacity(0.5)
                              : Colors.white10,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e['name'],
                                style: AXTheme.heading.copyWith(fontSize: 14),
                              ),
                              if (e['desc'] != null &&
                                  e['desc'].toString().isNotEmpty)
                                Text(
                                  e['desc'],
                                  style: AXTheme.body.copyWith(
                                    fontSize: 10,
                                    color: Colors.white54,
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "${e['weight']}g | ${e['purity']}${e['unit']}",
                                style: AXTheme.value.copyWith(fontSize: 12),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: () => _confirmRemove(e),
                                icon: const Icon(
                                  Icons.delete,
                                  color: AXTheme.danger,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: MagicalNeonButton(
                      text: "AI SCAN",
                      icon: Icons.qr_code_scanner,
                      isDone: _aiDone,
                      activeColor: activeColor,
                      onTap: () => _showHardwarePopup("AI"),
                    ),
                  ),
                  if (!_isManualMode) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: MagicalNeonButton(
                        text: "SCALE",
                        icon: Icons.line_weight,
                        isDone: _scaleDone,
                        activeColor: activeColor,
                        onTap: () => _showHardwarePopup("SCALE"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MagicalNeonButton(
                        text: "XRF",
                        icon: Icons.science,
                        isDone: _xrfDone,
                        activeColor: activeColor,
                        onTap: () => _showHardwarePopup("XRF"),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: AXTheme.getPanel(isManual: _isManualMode),
                child: Column(
                  children: [
                    _buildInputBox(
                      _nameCtrl,
                      "Item Name",
                      "Original: $_aiOriginalName",
                    ),
                    const SizedBox(height: 10),
                    _buildInputBox(
                      _descCtrl,
                      "Description",
                      "Original: $_aiOriginalDesc",
                      maxLines: 2,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildBorderedField(
                            _weightCtrl,
                            "Weight (g)",
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildBorderedField(
                                  _purityCtrl,
                                  "Purity",
                                  isNumber: true,
                                ),
                              ),
                              const SizedBox(width: 5),
                              GestureDetector(
                                onTap: _isManualMode
                                    ? () => setState(
                                        () => _isKaratMode = !_isKaratMode,
                                      )
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    border: Border.all(color: activeColor),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _isKaratMode ? "K" : "%",
                                    style: TextStyle(
                                      color: activeColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        if (!_isManualMode)
                          GestureDetector(
                            onTap: _triggerManualOverride,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AXTheme.manual),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.lock,
                                color: AXTheme.manual,
                              ),
                            ),
                          ),
                        if (_isManualMode)
                          GestureDetector(
                            onTap: () => setState(() => _isManualMode = false),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AXTheme.cyanFlux),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.autorenew,
                                color: AXTheme.cyanFlux,
                              ),
                            ),
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CyberButton(
                            text: _isManualMode
                                ? "SAVE MANUAL ENTRY"
                                : "ADD ITEM TO MANIFEST",
                            onTap: _addItem,
                            isManual: _isManualMode,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              if (_items.isNotEmpty)
                FadeInUp(
                  child: CyberButton(
                    text: "PROCEED TO AGREEMENT >",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AgreementScreen(
                          items: _displayItems,
                          totalWeight: _displayWeight,
                          avgPurity: _avgPurity,
                        ),
                      ),
                    ),
                    isManual: false,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBox(
    TextEditingController c,
    String h,
    String o, {
    int maxLines = 1,
  }) {
    bool e = o.isNotEmpty && c.text != o;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBorderedField(c, h, maxLines: maxLines),
        if (e)
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 2),
            child: Text(
              o,
              style: const TextStyle(
                color: AXTheme.warning,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBorderedField(
    TextEditingController c,
    String h, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    Color b = _isManualMode ? AXTheme.manual : AXTheme.cyanFlux;
    return TextField(
      controller: c,
      enabled:
          _isManualMode ||
          (_aiDone && (h.contains("Name") || h.contains("Desc"))),
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: isNumber ? [LengthLimitingTextInputFormatter(6)] : [],
      style: isNumber ? AXTheme.value : AXTheme.body,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: h,
        labelStyle: const TextStyle(color: Colors.white30, fontSize: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white12),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: b),
          borderRadius: BorderRadius.circular(10),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.black,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
      ),
    );
  }
}
