import 'package:intl/intl.dart';

extension DateTimeFormatter on DateTime {

  static DateFormat format = DateFormat.yMMMd('ja');
  static DateFormat dbFormat = DateFormat('yyyy-MM-dd', 'ja');

  String formatToString() {
    return format.format(this);
  }

  String formatToSystemString() {
    return dbFormat.format(this);
  }
}
