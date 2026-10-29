/// Typographie française : espace insécable avant « ? ! : ; » et à
/// l'intérieur des guillemets, pour éviter qu'un signe se retrouve seul
/// en début de ligne.
String frenchSpacing(String text) => text
    .replaceAllMapped(RegExp(r' ([?!:;»])'), (m) => ' ${m[1]}')
    .replaceAll('« ', '« ');
