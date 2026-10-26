import 'package:flutter_test/flutter_test.dart';
import 'package:graceedit/core/utils/typography.dart';

void main() {
  group('typo — nombre + unité', () {
    test('insère une insécable avant les unités courtes', () {
      expect(typo('5 s'), '5${nbspChar}s');
      expect(typo('3 min'), '3${nbspChar}min');
      expect(typo('2 h'), '2${nbspChar}h');
      expect(typo('12 Mo'), '12${nbspChar}Mo');
      expect(typo('1,5 Go'), '1,5${nbspChar}Go');
      expect(typo('840 Ko'), '840${nbspChar}Ko');
    });

    test('un mot plus long ne déclenche rien', () {
      expect(typo('3 minutes'), '3 minutes');
      expect(typo('2 secondes'), '2 secondes');
    });

    test('sans chiffre devant, rien ne change', () {
      expect(typo('un peu de place'), 'un peu de place');
    });
  });

  group('typo — signes doubles', () {
    test('insère une insécable avant ? ! : ; %', () {
      expect(typo('Supprimer ?'), 'Supprimer$nbspChar?');
      expect(typo('Attention !'), 'Attention$nbspChar!');
      expect(typo('Note : oui'), 'Note$nbspChar: oui');
      expect(typo('Étape ; suivante'), 'Étape$nbspChar; suivante');
      expect(typo('50 %'), '50$nbspChar%');
    });

    test('supprime les espaces multiples avant un signe double', () {
      expect(typo('Vraiment   ?'), 'Vraiment$nbspChar?');
    });

    test('ne touche pas un signe collé', () {
      expect(typo('http://exemple'), 'http://exemple');
    });
  });

  group('typo — guillemets français', () {
    test('insère une insécable après « et avant »', () {
      expect(typo('« Projet »'), '«${nbspChar}Projet$nbspChar»');
    });

    test('accepte plusieurs espaces', () {
      expect(typo('«   Projet   »'), '«${nbspChar}Projet$nbspChar»');
    });
  });

  group('typo — idempotence', () {
    test('deux passages donnent le même résultat', () {
      const source = '« Projet » exporté en 12 Mo à 50 % : prêt !';
      final once = typo(source);
      expect(typo(once), once);
      expect(once.contains('  '), isFalse);
    });
  });

  group('ponctuation', () {
    test('apostrophe typographique et points de suspension', () {
      expect(polishPunctuation("l'écran"), 'l’écran');
      expect(polishPunctuation('Chargement...'), 'Chargement…');
    });
  });
}
