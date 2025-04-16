import 'package:forex_calculator/Core/Services/exchange_service.dart';

class PipValueCalculator {
  // Method to calculate the pip value for a given asset and lot size
  static Future<double> calculatePipValue({
    required double lotSize,
    required String asset,
    double? customPip,
    double? customRate,
  }) async {
    // Fetch exchange rate from service or use the custom rate
    double exchangeRate;
    try {
      exchangeRate = customRate ?? await ExchangeService.getRate(asset);
    } catch (e) {
      throw Exception("Failed to fetch exchange rate for $asset: $e");
    }

    // If exchange rate is invalid, throw an error
    if (exchangeRate <= 0) {
      throw Exception("Invalid exchange rate received for $asset");
    }

    // Adjust pip size based on asset type
    double pipSize;
    if (asset.endsWith('JPY')) {
      // For JPY pairs, pip size is 0.01
      pipSize = 0.01; // pip size for JPY pairs
    } else {
      // For other currency pairs, pip size is 0.0001
      pipSize = 0.0001; // pip size for non-JPY pairs
    }

    // Round the lot size to avoid excessive precision
    lotSize = (lotSize * 1000).roundToDouble() / 1000;

    // Calculate the pip value
    double pipValue;

    // Use custom pip value if provided, otherwise calculate based on asset type
    if (customPip != null && customPip > 0) {
      pipValue = (customPip * pipSize * lotSize * 100000) / exchangeRate;
    } else {
      // Default pip value calculation for other pairs
      pipValue = (pipSize * lotSize * 100000) / exchangeRate;
    }

    // Return the pip value
    return pipValue;
  }
}
