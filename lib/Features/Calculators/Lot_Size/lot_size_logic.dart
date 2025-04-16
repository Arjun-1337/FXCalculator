// This file contains all lot size calculation logic
// Including automatic pip value estimation based on currency pair and rate

class LotSizeCalculator {
  /// Estimates pip value per 1 standard lot (100,000 units)
  /// based on currency pair and live exchange rate.
  static double estimatePipValuePerLot(String pair, double rate) {
    // Ensure pair has at least 6 characters like "EURUSD"
    if (pair.length < 6 || rate <= 0) {
      throw ArgumentError('Invalid pair or rate');
    }

    final quote = pair.substring(3, 6).toUpperCase();

    if (quote == 'JPY') {
      // JPY quote: 1 pip = 0.01 → 100,000 units = 1000
      return 1000 / rate;
    } else if (quote == 'USD') {
      // USD quote = fixed $10 per pip
      return 10.0;
    } else {
      // Cross pairs: use conversion to USD
      return 10 / rate;
    }
  }

  /// Calculates recommended lot size based on account balance,
  /// risk percentage, stop loss (in pips), pair and current rate.
  static double calculateLotSize({
    required double balance,
    required double riskPercent,
    required double stopLossPips,
    required String pair,
    required double rate,
  }) {
    // Basic input validation
    if (balance <= 0 || riskPercent <= 0 || stopLossPips <= 0 || rate <= 0) {
      throw ArgumentError('All inputs must be positive numbers');
    }

    final pipValue = estimatePipValuePerLot(pair, rate);
    final riskAmount = balance * (riskPercent / 100);

    return riskAmount / (pipValue * stopLossPips);
  }
}
