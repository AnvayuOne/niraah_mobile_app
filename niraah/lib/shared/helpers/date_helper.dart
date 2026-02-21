import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

class DateHelper {
  const DateHelper._();

  static String format(DateTime dateTime, {String? pattern}) {
    return DateFormat(pattern ?? AppConstants.dateFormat).format(dateTime);
  }
}
