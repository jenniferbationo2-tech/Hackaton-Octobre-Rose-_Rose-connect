# Enregistrements audio : guide

Les enregistrements permettent aux femmes qui ne lisent pas le français
d'écouter l'essentiel de l'application. Un bouton « Écouter » apparaît
automatiquement dès que le fichier correspondant est présent.

## Comment enregistrer

1. Sur l'iPhone, ouvrez l'application **Dictaphone**.
2. Installez-vous dans un **endroit calme** (pas de ventilateur, de télévision ni
   de rue), le téléphone à environ 20 cm de la bouche.
3. Parlez **lentement et simplement**, comme à une voisine. Pas besoin de
   traduire mot à mot : l'important est que le **sens** soit exact.
4. **Un message = un enregistrement.** Laissez une seconde de silence au début
   et à la fin.
5. Renommez chaque enregistrement avec **exactement** le nom indiqué (sans
   accent ni espace), par exemple `orientation-q1`.
6. Envoyez les fichiers sur le PC (par e-mail, WhatsApp ou iCloud.com) et
   placez-les dans :

   | Langue | Dossier |
   |---|---|
   | Dioula | `rose_connect/assets/audio/dyu/` |
   | Français (facultatif) | `rose_connect/assets/audio/fr/` |

   Formats acceptés : `.m4a` (celui du Dictaphone), `.mp3`, `.aac` ou `.wav`.
7. Relancez l'application (redémarrage complet, ou `npm run build:web` pour la
   version web).

Faites relire, ou plutôt réécouter, les messages par une personne du domaine
de la santé qui parle dioula : les mots médicaux doivent être justes.

## Les 14 messages

### Fiches (bouton à côté de « L'essentiel »)

| Fichier | Ce qu'il faut dire |
|---|---|
| `edu-cancer-du-sein` | Le cancer du sein, c'est quand des cellules du sein se multiplient de façon anormale. Repéré tôt, il se soigne mieux. Il touche surtout les femmes, rarement les hommes. La plupart des boules du sein ne sont pas des cancers, mais il faut les montrer à un soignant. |
| `edu-signes-sein` | Les signes à surveiller : une boule ou un épaississement dans le sein ou sous l'aisselle ; un changement de taille ou de forme du sein ; une peau qui se creuse ou qui rougit ; un mamelon qui change ou qui rentre ; un écoulement inhabituel du mamelon. Ces signes sont souvent sans douleur. Si vous en voyez un, allez consulter. |
| `edu-facteurs-risque` | Certaines choses augmentent le risque : l'âge, des cas de cancer du sein dans la famille, l'alcool, le tabac et le surpoids. Bouger régulièrement aide à se protéger. Avoir un risque ne veut pas dire qu'on aura la maladie. |
| `edu-pourquoi-consulter` | Allez voir un soignant dès qu'un changement apparaît, même s'il ne fait pas mal. Il examinera vos seins et vos aisselles. Consulter ne veut pas dire que vous êtes malade : c'est le meilleur moyen d'être rassurée ou soignée à temps. |

### Questionnaire

| Fichier | Ce qu'il faut dire |
|---|---|
| `orientation-intro` | Nous allons faire le point sur ce que vous avez remarqué. Il y a 5 questions, cela prend une minute, et rien n'est enregistré. Ce n'est pas un examen : il ne dit pas si vous avez un cancer. Pour répondre, touchez le rond avec la coche pour dire oui, la croix pour dire non, et le point d'interrogation si vous ne savez pas. |
| `orientation-q1` | Avez-vous remarqué récemment une nouvelle boule dans un sein ou sous l'aisselle ? Qu'elle fasse mal ou non. |
| `orientation-q2` | Avez-vous remarqué un changement inhabituel de la peau du sein ? Par exemple une peau qui se creuse, qui rougit, ou qui ressemble à une peau d'orange. |
| `orientation-q3` | Avez-vous remarqué un changement récent du mamelon, ou un liquide qui coule du mamelon ? Par exemple un mamelon qui rentre, ou un liquide clair ou avec du sang. |
| `orientation-q4` | Avez-vous remarqué qu'un sein a changé de taille ou de forme ? Un changement nouveau, différent d'avant. |
| `orientation-q5` | En ce moment, avez-vous de la fièvre avec un sein rouge, chaud, gonflé et qui fait très mal ? |

### Résultats du questionnaire

| Fichier | Ce qu'il faut dire |
|---|---|
| `orientation-result-urgent` | Ce que vous décrivez demande un avis médical rapide. Allez aujourd'hui même dans un centre de santé ou aux urgences. |
| `orientation-result-change` | Vous avez remarqué un changement inhabituel. Il peut avoir plusieurs causes. Prenez rendez-vous avec un soignant pour qu'il vous examine. |
| `orientation-result-unsure` | Si vous avez un doute sur un changement de votre sein, un soignant peut vous aider à faire le point. |
| `orientation-result-none` | Vous n'avez signalé aucun des changements proposés. Ce questionnaire ne peut pas exclure une maladie : si quelque chose vous inquiète, consultez un soignant. |

## Pour plus tard

Les mêmes noms de fichiers servent pour toute nouvelle langue (mooré :
`assets/audio/mos/`, à déclarer dans `pubspec.yaml` et dans
`ListenLanguage`, fichier `lib/core/audio/audio.dart`).
