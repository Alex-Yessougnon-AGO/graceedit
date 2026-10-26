import 'package:flutter_test/flutter_test.dart';
import 'package:graceedit/core/l10n/generated/app_localizations_en.dart';
import 'package:graceedit/core/l10n/generated/app_localizations_fr.dart';
import 'package:graceedit/core/models/settings.dart';
import 'package:graceedit/core/utils/formatters.dart';
import 'package:graceedit/core/utils/typography.dart';

void main() {
  final l10n = AppLocalizationsFr();

  group('formatDuration', () {
    test('minutes et secondes', () {
      expect(formatDuration(0), '0:00');
      expect(formatDuration(70000), '1:10');
      expect(formatDuration(59000), '0:59');
    });

    test('heures au-delà de 60 minutes', () {
      expect(formatDuration(3723000), '1:02:03');
    });

    test('les valeurs négatives sont ramenées à zéro', () {
      expect(formatDuration(-500), '0:00');
    });
  });

  group('formatDurationSpoken', () {
    test('français', () {
      expect(formatDurationSpoken(0, l10n), '0 secondes');
      expect(formatDurationSpoken(1000, l10n), '1 seconde');
      expect(formatDurationSpoken(30000, l10n), '30 secondes');
      expect(formatDurationSpoken(250000, l10n), '4 minutes 10 secondes');
    });

    test('anglais', () {
      expect(formatDurationSpoken(1000, AppLocalizationsEn()), '1 second');
      expect(
        formatDurationSpoken(250000, AppLocalizationsEn()),
        '4 minutes 10 seconds',
      );
    });
  });

  group('formatTrimTime', () {
    test('une décimale séparée par une virgule', () {
      expect(formatTrimTime(0), '0:00,0');
      expect(formatTrimTime(77400), '1:17,4');
      expect(formatTrimTime(3000), '0:03,0');
    });
  });

  group('formatSeconds', () {
    test('virgule décimale et insécable', () {
      expect(formatSeconds(5000), '5,0${nbspChar}s');
      expect(formatSeconds(1550), '1,6${nbspChar}s');
    });
  });

  group('formatPercent', () {
    test('arrondi et insécable', () {
      expect(formatPercent(45.4), '45$nbspChar%');
      expect(formatPercent(100), '100$nbspChar%');
    });
  });

  group('formatPixels', () {
    test('insécables autour du signe de multiplication', () {
      expect(formatPixels(1080, 1920), '1080$nbspChar×${nbspChar}1920');
    });
  });

  group('formatBytes', () {
    test('octets, kilo, méga, giga', () {
      expect(formatBytes(0), '0${nbspChar}o');
      expect(formatBytes(1023), '1023${nbspChar}o');
      expect(formatBytes(1024), '1${nbspChar}Ko');
      expect(formatBytes(1024 * 1024), '1${nbspChar}Mo');
      expect(formatBytes(1024 * 1024 * 1024), '1${nbspChar}Go');
    });

    test('une décimale seulement quand c’est utile', () {
      expect(formatBytes((1.5 * 1024 * 1024).round()), '1,5${nbspChar}Mo');
      expect(formatBytes(512 * 1024 * 1024), '512${nbspChar}Mo');
    });

    test('formatBytesPrecise arrondit au plus juste', () {
      expect(formatBytesPrecise(5 * 1024 * 1024), '5${nbspChar}Mo');
      expect(formatBytesPrecise(3 * 1024 * 1024 * 1024), '3,0${nbspChar}Go');
    });
  });

  group('formatClock', () {
    test('durée écoulée lisible', () {
      expect(
        formatClock(Duration.zero, l10n),
        '0${nbspChar}min 00${nbspChar}s',
      );
      expect(
        formatClock(const Duration(seconds: 42), l10n),
        '0${nbspChar}min 42${nbspChar}s',
      );
      expect(
        formatClock(const Duration(minutes: 3, seconds: 7), l10n),
        '3${nbspChar}min 07${nbspChar}s',
      );
      expect(
        formatClock(const Duration(hours: 1, minutes: 5, seconds: 9), l10n),
        '1${nbspChar}h 05${nbspChar}min',
      );
    });
  });

  group('formatModified', () {
    final now = DateTime(2026, 10, 24, 12);

    test('à l’instant', () {
      expect(
        formatModified(
          now.subtract(const Duration(seconds: 20)),
          l10n,
          now: now,
        ),
        l10n.modifiedJustNow,
      );
    });

    test('il y a quelques minutes et quelques heures', () {
      expect(
        formatModified(
          now.subtract(const Duration(minutes: 5)),
          l10n,
          now: now,
        ),
        'il y a 5 min',
      );
      expect(
        formatModified(now.subtract(const Duration(hours: 2)), l10n, now: now),
        l10n.modifiedHoursAgo(2),
      );
    });

    test('hier', () {
      expect(
        formatModified(DateTime(2026, 10, 23, 9), l10n, now: now),
        l10n.dateYesterday,
      );
    });

    test('date ancienne abrégée', () {
      expect(formatModified(DateTime(2026, 3, 4), l10n, now: now), '4 mars');
    });
  });

  group('defaultProjectTitle', () {
    test('reprend le jour et le mois', () {
      expect(
        defaultProjectTitle(DateTime(2026, 10, 19), l10n),
        l10n.importDefaultName('19 oct.'),
      );
    });
  });

  group('formatCaptureDate', () {
    test('jour, mois et heure sur deux chiffres', () {
      expect(
        formatCaptureDate(DateTime(2026, 10, 18, 14, 32), l10n),
        '18 oct., 14:32',
      );
      expect(
        formatCaptureDate(DateTime(2026, 1, 2, 9, 5), l10n),
        '2 janv., 09:05',
      );
    });
  });

  group('formatLanguageName', () {
    test('nom natif de la langue', () {
      expect(formatLanguageName(AppLanguage.fr), 'Français');
      expect(formatLanguageName(AppLanguage.en), 'English');
    });
  });
}
