import 'package:flutter_test/flutter_test.dart';
import 'package:graceedit/core/l10n/generated/app_localizations_en.dart';
import 'package:graceedit/core/l10n/generated/app_localizations_fr.dart';

/// Non-régression des pluriels à zéro : en français, CLDR met 0 au
/// singulier, donc chaque pluriel atteignable avec 0 doit déclarer un cas
/// `=0` explicite (trouvé sur appareil : « 1 vidéo » avec une liste vide).
void main() {
  final fr = AppLocalizationsFr();
  final en = AppLocalizationsEn();

  test('compteurs à zéro', () {
    expect(fr.importVideos(0), '0 vidéo');
    expect(en.importVideos(0), '0 videos');
    expect(fr.projectsSelectedCount(0), '0 sélectionné');
    expect(en.projectsSelectedCount(0), '0 selected');
    expect(fr.projectsCount(0), 'Aucun projet');
    expect(en.projectsCount(0), 'No projects');
    expect(fr.homeProjectCount(0), 'Aucun projet');
    expect(en.homeProjectCount(0), 'No projects');
    expect(fr.importMediaCount(0), 'Aucun média');
    expect(en.importMediaCount(0), 'No media');
  });

  test('compteurs à un et plusieurs', () {
    expect(fr.importVideos(1), '1 vidéo');
    expect(fr.importVideos(3), '3 vidéos');
    expect(fr.projectsSelectedCount(1), '1 sélectionné');
    expect(fr.projectsSelectedCount(2), '2 sélectionnés');
    expect(fr.projectsCount(1), '1 projet');
    expect(fr.projectsCount(2), '2 projets');
    expect(
      fr.projectsDeleteBody(1),
      'Il restera 30 jours dans la corbeille, puis sera supprimé.',
    );
    expect(
      fr.projectsDeleteBody(2),
      'Ils resteront 30 jours dans la corbeille, puis seront supprimés.',
    );
  });
}
