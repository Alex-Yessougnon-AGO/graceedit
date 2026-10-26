/// Espace insécable (U+00A0).
const nbspChar = '\u00A0';

/// Applique les règles typographiques du produit :
/// - espace insécable entre un nombre et son unité ;
/// - espace insécable avant `? ! : ; %` ;
/// - espace insécable à l'intérieur des guillemets français « … ».
///
/// Une seule fonction pour tout le produit, testée dans
/// `test/core/typography_test.dart`.
String typo(String value) {
  var text = value;
  // Nombre + unité (Mo, Go, Ko, s, min, h, j, p, °, images/s).
  text = text.replaceAllMapped(
    RegExp(r'(\d)[ ](?=(?:%|Mo|Go|Ko|To|ms|s|min|h|j|p|°|images/s)\b)'),
    (m) => '${m[1]}$nbspChar',
  );
  // Avant les signes doubles.
  text = text.replaceAllMapped(RegExp(r'[ ]+(?=[?!:;%])'), (_) => nbspChar);
  // Guillemets français.
  text = text.replaceAllMapped(RegExp(r'«[ ]+'), (_) => '«$nbspChar');
  text = text.replaceAllMapped(RegExp(r'[ ]+»'), (_) => '$nbspChar»');
  return text;
}

/// Apostrophe typographique et points de suspension.
String polishPunctuation(String value) =>
    value.replaceAll("'", '’').replaceAll('...', '…');
