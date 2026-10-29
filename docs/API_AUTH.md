# API d'authentification ROSE Connect

Contrat attendu par l'application Flutter (`lib/features/auth/auth_service.dart`).
Le compte est **facultatif** : toutes les routes de contenu restent publiques.

Tant que l'API n'est pas branchée, l'application enregistre les comptes sur le
téléphone. Elle bascule sur l'API dès qu'on la lance avec
`--dart-define=API_URL=http://<ip>:3000/api`.

## Format commun

Toutes les réponses utilisent l'enveloppe du projet :

```json
{ "success": true, "data": { ... } }
{ "success": false, "error": { "code": "CODE", "message": "Message lisible en français" } }
```

Le `message` d'erreur est affiché tel quel à l'utilisatrice.

## Identifiant

`identifier` est **déjà normalisé** par l'application :

- e-mail en minuscules : `aicha@mail.bf`
- ou numéro burkinabè au format `+226XXXXXXXX` (8 chiffres)

## Routes

### POST /api/auth/register

```json
{ "firstName": "Aïcha", "identifier": "+22670123456", "password": "motdepasse1" }
```

| Champ | Règle |
|---|---|
| firstName | 2 à 30 caractères, nettoyé (pas de HTML) |
| identifier | e-mail ou `+226` suivi de 8 chiffres |
| password | 8 caractères minimum, haché avec bcrypt ou argon2, jamais stocké en clair |

Réponse 201 :

```json
{ "success": true, "data": {
  "token": "<JWT>",
  "user": { "id": "665f...", "firstName": "Aïcha", "identifier": "+22670123456" }
} }
```

Erreurs : `400 VALIDATION_ERROR`, `409 ACCOUNT_EXISTS` (message : « Un compte existe déjà avec cet identifiant. Connectez-vous. »).

### POST /api/auth/login

```json
{ "identifier": "+22670123456", "password": "motdepasse1" }
```

Réponse 200 : même format que `register`.

Erreur : `401 INVALID_CREDENTIALS`, message « Identifiant ou mot de passe incorrect. ». Utiliser le même message que le compte existe ou non.

### DELETE /api/auth/me

En-tête `Authorization: Bearer <JWT>`. Supprime le compte et ses données
(pseudonyme, messages de la communauté ou anonymisation).

Réponse 200 : `{ "success": true, "data": null }`. Erreur : `401 UNAUTHORIZED`.

## Sécurité

- Limiter les tentatives : 5 essais de connexion par 15 minutes et par IP, sinon `429 RATE_LIMITED`.
- JWT signé avec un secret dans `.env` (`JWT_SECRET`), durée de validité 30 jours.
- Ne jamais journaliser les mots de passe ni les corps de requête.
- Le JWT sert aussi aux routes de publication de la communauté (`POST /api/community/...`).
