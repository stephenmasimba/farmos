import 'package:intl/intl.dart';

class Fmt {
  Fmt._();

  static final _date = DateFormat('dd MMM yyyy');
  static final _dateTime = DateFormat('dd MMM yyyy, HH:mm');
  static final _time = DateFormat('HH:mm');
  static final _monthYear = DateFormat('MMM yyyy');
  static final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final _compact = NumberFormat.compact();
  static final _percent = NumberFormat.percentPattern();

  static String date(DateTime? d) => d == null ? '—' : _date.format(d);
  static String dateTime(DateTime? d) => d == null ? '—' : _dateTime.format(d);
  static String time(DateTime? d) => d == null ? '—' : _time.format(d);
  static String monthYear(DateTime? d) => d == null ? '—' : _monthYear.format(d);

  static String currency(num? amount) =>
      amount == null ? '—' : _currency.format(amount);

  static String compact(num? value) =>
      value == null ? '—' : _compact.format(value);

  static String percent(double? value) =>
      value == null ? '—' : _percent.format(value);

  static String weight(num? kg) => kg == null ? '—' : '${kg.toStringAsFixed(1)} kg';
  static String area(num? ha) => ha == null ? '—' : '${ha.toStringAsFixed(2)} ha';
  static String temp(num? c) => c == null ? '—' : '${c.toStringAsFixed(1)} °C';
  static String rainfall(num? mm) => mm == null ? '—' : '${mm.toStringAsFixed(1)} mm';
  static String windSpeed(num? kph) => kph == null ? '—' : '${kph.toStringAsFixed(0)} km/h';

  /// "2 hours ago", "3 days ago", etc.
  static String timeAgo(DateTime? dt) {
    if (dt == null) return '—';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _date.format(dt);
  }

  static DateTime? parseIso(String? s) {
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }
}
