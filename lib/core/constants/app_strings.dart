import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/locale_provider.dart';
import 'strings/app_strings_en.dart';
import 'strings/app_strings_vi.dart';

class AppStrings {
  static Map<String, String> _mapFor(String languageCode) {
    return languageCode == 'vi' ? appStringsVi : appStringsEn;
  }

  static String languageCodeOf(BuildContext context) {
    return context.read<LocaleProvider>().languageCode;
  }

  static String t(BuildContext context, String key, [Map<String, String>? params]) {
    return tCode(languageCodeOf(context), key, params);
  }

  static String tCode(String languageCode, String key, [Map<String, String>? params]) {
    var text = _mapFor(languageCode)[key] ?? appStringsEn[key] ?? key;
    if (params != null) {
      params.forEach((k, v) => text = text.replaceAll('{$k}', v));
    }
    return text;
  }

  static String timeAgo(BuildContext context, DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return t(context, 'justNow');
    if (diff.inHours < 1) return t(context, 'ago', {'time': '${diff.inMinutes}m'});
    if (diff.inHours < 24) return t(context, 'ago', {'time': '${diff.inHours}h'});
    return t(context, 'ago', {'time': '${diff.inDays}d'});
  }

  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static String formatDate(DateTime time) {
    return '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}/${time.year}';
  }
}
