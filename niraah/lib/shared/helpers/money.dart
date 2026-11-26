import 'package:intl/intl.dart';

/// "₹1,499" or "₹1,499.50" from paise, as the plans screen shows amounts. Every amount from the server includes GST
/// (spec 004, spec 008 "Background" 4).
String rupees(int paise) => NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: paise % 100 == 0 ? 0 : 2).format(paise / 100);
