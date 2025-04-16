import 'dart:async';
import 'package:flutter/material.dart';
import 'lot_size_logic.dart';
import '../../../core/services/exchange_service.dart';

class LotSizeScreen extends StatefulWidget {
  const LotSizeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LotSizeScreenState createState() => _LotSizeScreenState();
}

class _LotSizeScreenState extends State<LotSizeScreen> {
  final balanceController = TextEditingController();
  final riskController = TextEditingController();
  final stopLossController = TextEditingController();

  final List<String> pairs = [
    'EURUSD',
    'USDJPY',
    'GBPUSD',
    'USDCHF',
    'AUDUSD',
    'USDCAD',
    'NZDUSD',
    'XAUUSD',
  ];

  String selectedPair = 'EURUSD';
  double? liveRate;
  DateTime? lastUpdated;
  String result = '';
  bool isLoading = false;

  late final Timer _timer;

  @override
  void initState() {
    super.initState();

    calculateLotSize(); // Call on startup

    // 🕒 Auto-update every 60 min only if inputs are filled
    _timer = Timer.periodic(Duration(minutes: 60), (_) {
      if (balanceController.text.isNotEmpty &&
          riskController.text.isNotEmpty &&
          stopLossController.text.isNotEmpty) {
        calculateLotSize();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    balanceController.dispose();
    riskController.dispose();
    stopLossController.dispose();
    super.dispose();
  }

  void calculateLotSize() async {
    final balance = double.tryParse(balanceController.text);
    final riskPercent = double.tryParse(riskController.text);
    final stopLoss = double.tryParse(stopLossController.text);

    if (balance == null ||
        riskPercent == null ||
        stopLoss == null ||
        stopLoss == 0) {
      setState(() {
        result = '❌ Please enter valid numbers. Stop loss cannot be zero.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      result = '';
    });

    final base = selectedPair.substring(0, 3);
    final quote = selectedPair.substring(3);

    try {
      final rateResult = await ExchangeService.fetchRate(base, quote);
      final rate = rateResult.rate;
      final timestamp = rateResult.timestamp;

      final lot = LotSizeCalculator.calculateLotSize(
        balance: balance,
        riskPercent: riskPercent,
        stopLossPips: stopLoss,
        pair: selectedPair,
        rate: rate,
      );

      setState(() {
        liveRate = rate;
        lastUpdated = timestamp;
        result = 'Recommended Lot Size: ${lot.toStringAsFixed(3)} lots';
      });
    } catch (e) {
      setState(() {
        result = '❌ Failed to fetch rate: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatRelativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes == 1) return '1 minute ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours == 1) return '1 hour ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lot Size Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButton<String>(
              value: selectedPair,
              isExpanded: true,
              items:
                  pairs
                      .map(
                        (pair) =>
                            DropdownMenuItem(value: pair, child: Text(pair)),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedPair = value!;
                });
              },
            ),
            if (liveRate != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live rate: ${liveRate!.toStringAsFixed(4)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (lastUpdated != null)
                    Text(
                      'Updated: ${_formatRelativeTime(lastUpdated!)}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                ],
              ),
            SizedBox(height: 10),
            TextField(
              controller: balanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Account Balance (USD)'),
            ),
            TextField(
              controller: riskController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Risk %'),
            ),
            TextField(
              controller: stopLossController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Stop Loss (pips)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : calculateLotSize,
              child:
                  isLoading
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text('Calculate'),
            ),
            SizedBox(height: 20),
            Text(result, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
