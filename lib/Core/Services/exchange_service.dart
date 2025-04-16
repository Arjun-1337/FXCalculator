import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeRateResult {
  final double rate;
  final DateTime timestamp;

  ExchangeRateResult({required this.rate, required this.timestamp});
}

class ExchangeService {
  static ExchangeRateResult? _cache;
  static String? _lastBase;
  static String? _lastQuote;

  static Future<ExchangeRateResult> fetchRate(String base, String quote) async {
    final baseLower = base.toLowerCase();
    final quoteLower = quote.toLowerCase();

    // ✅ Return cached result if it's valid (within 5 mins and same base/quote)
    if (_cache != null &&
        _lastBase == baseLower &&
        _lastQuote == quoteLower &&
        DateTime.now().difference(_cache!.timestamp).inMinutes < 5) {
      return _cache!;
    }

    final url =
        'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/$baseLower.json';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10)); // ✅ Timeout added

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data[baseLower] == null || data[baseLower][quoteLower] == null) {
          throw Exception(
            '❌ Rate not found for $base/$quote in response: ${data[baseLower]}',
          );
        }

        final rate = data[baseLower][quoteLower];
        final result = ExchangeRateResult(
          rate: (rate as num).toDouble(),
          timestamp: DateTime.now(),
        );

        // ✅ Save to cache
        _cache = result;
        _lastBase = baseLower;
        _lastQuote = quoteLower;

        return result;
      } else {
        throw Exception('❌ Failed to fetch rate: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('❌ Error fetching rate for $base/$quote: $e');
    }
  }

  // New method to handle 'getRate'
  static Future<double> getRate(String asset) async {
    if (asset.length != 6) {
      throw Exception('❌ Invalid asset format: $asset');
    }

    final base = asset.substring(0, 3);
    final quote = asset.substring(3, 6);

    final result = await fetchRate(base, quote);
    return result.rate;
  }
}
