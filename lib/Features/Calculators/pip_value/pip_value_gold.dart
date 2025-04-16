class PipValueGold {
  static Future<double> calculateGoldPipValue({
    required double lotSize,
    required double customPip,
  }) async {
    double pipValuePerPip = 0.10 * lotSize * 100;

    return pipValuePerPip * customPip;
  }
}
