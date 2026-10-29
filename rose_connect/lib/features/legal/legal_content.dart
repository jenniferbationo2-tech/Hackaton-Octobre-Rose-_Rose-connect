import '../../core/constants/app_info.dart';

class LegalSection {
  const LegalSection(this.title, this.paragraphs);

  final String title;
  final List<String> paragraphs;
}

class LegalDocument {
  const LegalDocument({
    required this.title,
    required this.intro,
    required this.sections,
  });

  final String title;
  final String intro;
  final List<LegalSection> sections;
}

// Textes à faire relire par l'équipe avant publication. Ils décrivent le
// fonctionnement réel de l'application : toute évolution du traitement des
// données (comptes, stockage des conversations…) doit y être répercutée.

const privacyPolicy = LegalDocument(
  title: 'Politique de confidentialité',
  intro:
      'Cette politique explique quelles données ROSE Connect utilise, pourquoi, '
      'et comment vous gardez le contrôle. Nous collectons le strict minimum.',
  sections: [
    LegalSection('Qui sommes-nous ?', [
      'ROSE Connect est édité par ${AppInfo.editor}. '
          'Pour toute question sur vos données : ${AppInfo.contactEmail}.',
    ]),
    LegalSection('Un compte facultatif', [
      'Les contenus éducatifs, l’assistant, le questionnaire d’orientation et le quiz '
          'sont accessibles sans inscription.',
      'Si vous créez un compte, nous enregistrons votre prénom ou pseudonyme, votre '
          'adresse e-mail ou votre numéro de téléphone, et votre mot de passe sous une '
          'forme chiffrée (haché) qui ne permet pas de le relire. Ces informations servent '
          'uniquement à vous connecter et à personnaliser l’application. Votre e-mail ou '
          'numéro n’est jamais affiché aux autres utilisatrices.',
      'Aucune information médicale n’est associée à votre compte : vos réponses au '
          'questionnaire et vos questions à l’assistant n’y sont pas rattachées.',
      'Vous pouvez supprimer votre compte à tout moment depuis « Mon espace ». '
          'Les données du compte sont alors effacées.',
    ]),
    LegalSection('Questionnaire d’orientation', [
      'Vos réponses au questionnaire restent sur votre téléphone. Elles ne sont pas '
          'envoyées à nos serveurs et sont effacées lorsque vous quittez le questionnaire.',
    ]),
    LegalSection('Assistant', [
      'Lorsque vous posez une question à l’assistant, le texte de votre question est '
          'transmis à notre serveur, puis à un fournisseur de service d’intelligence '
          'artificielle chargé de formuler la réponse. Ce fournisseur peut être situé '
          'hors du Burkina Faso et, selon l’offre utilisée, conserver ces questions pour '
          'améliorer ses services.',
      'Nous ne conservons pas vos conversations. Nos journaux techniques '
          'n’enregistrent pas le contenu de vos questions.',
      'N’indiquez pas dans vos questions d’informations permettant de vous identifier '
          'ou d’identifier une autre personne (nom, téléphone, adresse).',
    ]),
    LegalSection('Quiz', [
      'Votre score est calculé sur votre téléphone. Il mesure uniquement vos '
          'connaissances et n’est pas conservé par nos serveurs.',
    ]),
    LegalSection('Espace communauté', [
      'Si vous publiez dans la communauté, nous enregistrons le pseudonyme que vous '
          'choisissez, vos messages, leur date et les signalements éventuels. '
          'Ces informations sont visibles par les autres utilisatrices, sauf les signalements.',
      'Choisissez un pseudonyme qui ne révèle pas votre identité. Les messages '
          'contraires aux règles de la communauté peuvent être masqués par la modération.',
    ]),
    LegalSection('Données stockées sur votre téléphone', [
      'L’application enregistre localement quelques préférences, par exemple votre choix '
          'd’utiliser l’application avec ou sans compte, et votre session de connexion. '
          'Vous pouvez les effacer en vous déconnectant ou en supprimant les données de '
          'l’application.',
    ]),
    LegalSection('Ce que nous ne faisons pas', [
      'Nous n’affichons pas de publicité, nous n’utilisons pas de traceurs publicitaires '
          'et nous ne vendons ni ne louons aucune donnée.',
    ]),
    LegalSection('Sécurité', [
      'Les échanges entre l’application et notre serveur sont chiffrés (HTTPS). '
          'Les clés d’accès aux services tiers sont conservées uniquement sur le serveur.',
    ]),
    LegalSection('Vos droits', [
      'Conformément à la loi n° 001-2021/AN du 30 mars 2021 portant protection des '
          'personnes à l’égard du traitement des données à caractère personnel, vous '
          'disposez d’un droit d’accès, de rectification, d’opposition et de suppression '
          'de vos données. Pour l’exercer, écrivez-nous à ${AppInfo.contactEmail}.',
      'Vous pouvez également adresser une réclamation à la Commission de l’Informatique '
          'et des Libertés (CIL) du Burkina Faso.',
    ]),
    LegalSection('Public concerné', [
      'ROSE Connect s’adresse aux personnes majeures. Les contenus restent informatifs '
          'et ne remplacent pas l’avis d’un professionnel de santé.',
    ]),
    LegalSection('Modifications', [
      'Cette politique peut évoluer avec l’application. La date de dernière mise à jour '
          'figure en haut de cette page.',
    ]),
  ],
);

const termsOfUse = LegalDocument(
  title: 'Conditions générales d’utilisation',
  intro:
      'En utilisant ROSE Connect, vous acceptez les présentes conditions. '
      'Merci de les lire attentivement.',
  sections: [
    LegalSection('Objet', [
      'ROSE Connect est une application gratuite d’information, de sensibilisation et '
          'd’orientation sur le cancer du sein et la santé féminine, éditée par ${AppInfo.editor}.',
    ]),
    LegalSection('Compte', [
      'La création d’un compte est facultative et réservée aux personnes de 18 ans ou plus. '
          'Vous êtes responsable de la confidentialité de votre mot de passe. Vous pouvez '
          'supprimer votre compte à tout moment depuis « Mon espace ».',
    ]),
    LegalSection('Pas un service médical', [
      'Les informations proposées sont générales. Elles ne constituent ni un diagnostic, '
          'ni une prescription, ni un avis médical personnalisé, et ne remplacent pas une '
          'consultation ou un examen par un professionnel de santé.',
      'Si vous remarquez un changement inhabituel de votre sein, consultez un professionnel '
          'de santé. En cas de symptôme grave ou soudain, rendez-vous sans attendre dans '
          'un service d’urgence.',
    ]),
    LegalSection('Assistant', [
      'L’assistant s’appuie sur une base documentaire et sur un service d’intelligence '
          'artificielle. Malgré les précautions prises, une réponse peut être incomplète '
          'ou inexacte. Vérifiez toute information importante auprès d’un professionnel de santé.',
    ]),
    LegalSection('Questionnaire et quiz', [
      'Le questionnaire d’orientation n’est pas un test de dépistage. Son résultat ne '
          'permet ni de confirmer ni d’exclure une maladie.',
      'Le score du quiz mesure vos connaissances et n’indique rien sur votre état de santé.',
    ]),
    LegalSection('Règles de la communauté', [
      'En publiant, vous vous engagez à rester bienveillante et respectueuse, à ne pas '
          'publier d’informations permettant d’identifier une personne, à ne pas poser ni '
          'confirmer de diagnostic pour une autre utilisatrice, et à ne pas publier de '
          'contenu publicitaire, injurieux ou illégal.',
      'La communauté n’est pas un service d’urgence. Les messages contraires à ces règles '
          'peuvent être masqués sans préavis.',
    ]),
    LegalSection('Sources', [
      'Les contenus éducatifs sont rédigés à partir de sources identifiées, citées sur '
          'chaque fiche, et relus par l’équipe avant publication.',
    ]),
    LegalSection('Disponibilité', [
      'L’application est un prototype. Certaines fonctions, notamment l’assistant et la '
          'communauté, nécessitent une connexion internet et peuvent être momentanément '
          'indisponibles.',
    ]),
    LegalSection('Responsabilité', [
      'L’éditeur met tout en œuvre pour proposer des informations fiables et à jour, '
          'sans pouvoir garantir leur exhaustivité. Les décisions relatives à votre santé '
          'doivent être prises avec un professionnel de santé.',
    ]),
    LegalSection('Propriété intellectuelle', [
      'Le nom, le logo et les contenus originaux de ROSE Connect appartiennent à leurs '
          'auteurs. Les contenus cités restent la propriété de leurs sources.',
    ]),
    LegalSection('Données personnelles', [
      'Le traitement de vos données est décrit dans la politique de confidentialité, '
          'accessible depuis le menu de l’application.',
    ]),
    LegalSection('Droit applicable', [
      'Les présentes conditions sont soumises au droit burkinabè.',
      'Contact : ${AppInfo.contactEmail}.',
    ]),
  ],
);
