import 'package:intl/intl.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/settings.dart';
import 'typography.dart';

/// Durée courte : « 1:10 », « 1:02:03 ».
String formatDuration(int milliseconds) {
  final total = (milliseconds / 1000).floor().clamp(0, 359999);
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  if (h > 0) {
    return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '$m:${s.toString().padLeft(2, '0')}';
}

/// Durée lue par un lecteur d'écran : « 4 minutes 10 secondes ».
String formatDurationSpoken(int milliseconds, AppLocalizations l10n) {
  final total = (milliseconds / 1000).round().clamp(0, 359999);
  final m = total ~/ 60;
  final s = total % 60;
  final parts = <String>[];
  if (m > 0) {
    parts.add('$m ${m == 1 ? l10n.unitMinuteOne : l10n.unitMinuteOther}');
  }
  if (s > 0 || m == 0) {
    parts.add('$s ${s == 1 ? l10n.unitSecondOne : l10n.unitSecondOther}');
  }
  return parts.join(' ');
}

/// Rognage précis : « 1:17,4 ».
String formatTrimTime(int milliseconds) {
  final clamped = milliseconds.clamp(0, 1 << 62);
  final m = clamped ~/ 60000;
  final s = (clamped % 60000) / 1000;
  final secs = NumberFormat('00.0', 'fr_FR').format(s).replaceAll('.', ',');
  return '$m:$secs';
}

/// Secondes avec une décimale française : « 5,0 s ».
String formatSeconds(int milliseconds) {
  final value = (milliseconds / 1000).toStringAsFixed(1).replaceAll('.', ',');
  return typo('$value s');
}

String formatPercent(num value) => typo('${value.round()} %');

String formatPixels(int width, int height) =>
    typo('$width$nbspChar×$nbspChar$height');

String formatBytes(int bytes) {
  if (bytes < 1024) return typo('$bytes${nbspChar}o');
  final kb = bytes / 1024;
  if (kb < 1024) return typo('${_decimal(kb)}${nbspChar}Ko');
  final mb = kb / 1024;
  if (mb < 1024) return typo('${_decimal(mb)}${nbspChar}Mo');
  final gb = mb / 1024;
  return typo('${_decimal(gb)}${nbspChar}Go');
}

String formatBytesPrecise(int bytes) {
  final formatter = NumberFormat('#,##0', 'fr_FR');
  if (bytes < 1024 * 1024) {
    return typo(
      '${formatter.format(bytes / 1024).replaceAll('.', ',')}${nbspChar}Ko',
    );
  }
  final mb = bytes / (1024 * 1024);
  if (mb < 1024) {
    return typo('${formatter.format(mb).replaceAll('.', ',')}${nbspChar}Mo');
  }
  return typo(
    '${(mb / 1024).toStringAsFixed(1).replaceAll('.', ',')}${nbspChar}Go',
  );
}

String _decimal(double value) {
  if (value >= 100) return value.toStringAsFixed(0);
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1).replaceAll('.', ',');
}

/// Mois abrégé traduit (1 = janvier). Les libellés vivent dans les ARB.
String monthShort(int month, AppLocalizations l10n) => switch (month) {
  1 => l10n.monthJan,
  2 => l10n.monthFeb,
  3 => l10n.monthMar,
  4 => l10n.monthApr,
  5 => l10n.monthMay,
  6 => l10n.monthJun,
  7 => l10n.monthJul,
  8 => l10n.monthAug,
  9 => l10n.monthSep,
  10 => l10n.monthOct,
  11 => l10n.monthNov,
  _ => l10n.monthDec,
};

/// Date de projet : « il y a 2 h », « Hier », « 12 oct. ».
String formatModified(DateTime date, AppLocalizations l10n, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final diff = current.difference(date);
  if (diff.inMinutes < 1) return l10n.modifiedJustNow;
  if (diff.inHours < 1) return l10n.modifiedMinutesAgo(diff.inMinutes);
  if (diff.inHours < 24 &&
      date.day == current.day &&
      date.month == current.month) {
    return l10n.modifiedHoursAgo(diff.inHours);
  }
  final yesterday = current.subtract(const Duration(days: 1));
  if (date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day) {
    return l10n.dateYesterday;
  }
  return '${date.day} ${monthShort(date.month, l10n)}';
}

/// Titre par défaut : « Projet du 19 oct. ».
String defaultProjectTitle(DateTime date, AppLocalizations l10n) {
  return l10n.importDefaultName('${date.day} ${monthShort(date.month, l10n)}');
}

/// Date et heure de prise de vue : « 18 oct., 14:32 ».
String formatCaptureDate(DateTime date, AppLocalizations l10n) {
  return '${date.day} ${monthShort(date.month, l10n)}, '
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}

String formatLanguageName(AppLanguage language) =>
    language == AppLanguage.fr ? 'Français' : 'English';

/// Durée écoulée lue par une personne : « 3 min 07 s ».
String formatClock(Duration elapsed, AppLocalizations l10n) {
  final h = elapsed.inHours;
  final m = elapsed.inMinutes.remainder(60);
  final s = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (h > 0) {
    return typo(
      '$h ${l10n.unitHoursShort} '
      '${m.toString().padLeft(2, '0')} ${l10n.unitMinutesShort}',
    );
  }
  return typo(
    '$m ${l10n.unitMinutesShort} '
    '$s ${l10n.unitSecondsShort}',
  );
}
