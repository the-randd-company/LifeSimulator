// lib/utils/money_formatter.dart

/// Formats money in a compact way with k (thousands) and m (millions) suffixes
/// Examples: 204, 1.234k, 1.5m, 2.750m
String formatMoneyCompact(double amount, {int decimalPlaces = 3}) {
  if (amount.abs() < 1000) {
    // For amounts less than 1000, show as whole number if possible, otherwise with decimals
    return amount.truncateToDouble() == amount ? 
        amount.toInt().toString() : 
        amount.toStringAsFixed(decimalPlaces).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  } else if (amount.abs() < 1000000) {
    // Thousands format (1.234k)
    double thousands = amount / 1000;
    String formatted = thousands.toStringAsFixed(decimalPlaces);
    // Remove trailing zeros and decimal point if needed
    formatted = formatted.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
    return '${formatted}k';
  } else {
    // Millions format (1.234m)
    double millions = amount / 1000000;
    String formatted = millions.toStringAsFixed(decimalPlaces);
    // Remove trailing zeros and decimal point if needed
    formatted = formatted.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
    return '${formatted}m';
  }
}

/// Alternative version with more control over formatting
String formatMoneyCompactAdvanced(double amount, {
  int thousandDecimalPlaces = 3,
  int millionDecimalPlaces = 3,
  bool showWholeNumbers = true,
}) {
  final absAmount = amount.abs();
  
  if (absAmount < 1000) {
    if (showWholeNumbers && amount.truncateToDouble() == amount) {
      return amount.toInt().toString();
    }
    // For small amounts, show up to 2 decimal places if needed
    return amount.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  } else if (absAmount < 1000000) {
    double thousands = amount / 1000;
    String formatted = thousands.toStringAsFixed(thousandDecimalPlaces);
    formatted = formatted.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
    return '${formatted}k';
  } else {
    double millions = amount / 1000000;
    String formatted = millions.toStringAsFixed(millionDecimalPlaces);
    formatted = formatted.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
    return '${formatted}m';
  }
}