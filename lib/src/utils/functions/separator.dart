import 'package:intl/intl.dart';

String formatCurrency(num amount) {
  final formatter = NumberFormat('#,##0', 'fr_FR');
  return formatter.format(amount);
}
