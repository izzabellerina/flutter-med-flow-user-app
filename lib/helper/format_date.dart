class FormatDate {
  /// Parse date string in YYYYMMDD format to DD/MM/YYYY
  static String parseDateYYYYMMDD(String dateStr) {
    if (dateStr.length < 8) return dateStr;
    final year = dateStr.substring(0, 4);
    final month = dateStr.substring(4, 6);
    final day = dateStr.substring(6, 8);
    return '$day/$month/$year';
  }

  /// Parse date string in YYYYMMDD format to DateTime
  static DateTime? parseDateYYYYMMDDToDateTime(String dateStr) {
    if (dateStr.length < 8) return null;
    try {
      final year = int.parse(dateStr.substring(0, 4));
      final month = int.parse(dateStr.substring(4, 6));
      final day = int.parse(dateStr.substring(6, 8));
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }
}
