import 'package:flutter/material.dart';
import 'package:forex_calculator/Features/Calculators/pip_value/pip_value_calculator.dart';
import 'package:forex_calculator/Features/Calculators/pip_value/pip_value_gold.dart';

class PipValueScreen extends StatefulWidget {
  const PipValueScreen({super.key});

  @override
  _PipValueScreenState createState() => _PipValueScreenState();
}

class _PipValueScreenState extends State<PipValueScreen> {
  final TextEditingController _lotSizeController = TextEditingController();
  final TextEditingController _pipSizeController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  double? _pipValue;
  String _errorMessage = '';
  String _selectedAsset = 'EURUSD';

  final List<String> _assets = [
    'EURUSD',
    'USDJPY',
    'GBPUSD',
    'USDCHF',
    'AUDUSD',
    'USDCAD',
    'NZDUSD',
    'XAUUSD',
  ];

  Future<void> _calculatePipValue() async {
    setState(() {
      _pipValue = null;
      _errorMessage = '';
    });

    try {
      double lotSize = double.parse(_lotSizeController.text);
      String asset = _selectedAsset;
      double? customPipSize =
          _pipSizeController.text.isNotEmpty
              ? double.tryParse(_pipSizeController.text)
              : null;
      double? customRate =
          _rateController.text.isNotEmpty
              ? double.tryParse(_rateController.text)
              : null;

      double result;

      if (asset == 'XAUUSD') {
        // Use default pip size 0.01 if not provided
        double pipSize = customPipSize ?? 0.01;

        result = await PipValueGold.calculateGoldPipValue(
          lotSize: lotSize,
          customPip: pipSize,
        );
      } else {
        result = await PipValueCalculator.calculatePipValue(
          lotSize: lotSize,
          asset: asset,
          customPip: customPipSize,
          customRate: customRate,
        );
      }

      setState(() {
        _pipValue = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pip Value Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _lotSizeController,
              decoration: const InputDecoration(labelText: 'Lot Size'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: _selectedAsset,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedAsset = newValue!;
                });
              },
              items:
                  _assets
                      .map<DropdownMenuItem<String>>(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
            ),
            TextField(
              controller: _pipSizeController,
              decoration: const InputDecoration(
                labelText: 'Custom Pip Size (e.g. 0.01)',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _rateController,
              decoration: const InputDecoration(
                labelText: 'Custom Exchange Rate (Optional)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculatePipValue,
              child: const Text('Calculate'),
            ),
            if (_pipValue != null) ...[
              const SizedBox(height: 20),
              Text(
                'Profit in \$ for Custom Pip Size: $_pipValue',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                _errorMessage,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
