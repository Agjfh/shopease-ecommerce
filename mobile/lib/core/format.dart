import 'package:intl/intl.dart';

final _egp = NumberFormat.currency(locale: 'en_US', symbol: 'EGP ', decimalDigits: 0);

String money(double value) => _egp.format(value);
