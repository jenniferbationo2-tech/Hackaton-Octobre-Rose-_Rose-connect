# ROSE Connect API

API REST de l'application ROSE Connect : contenus éducatifs et assistant
conversationnel (RAG sur des fiches vérifiées + Claude).

## Démarrer

```bash
npm install
cp .env.example .env      # puis renseigner ANTHROPIC_API_KEY
npm run dev               # http://localhost:3000/api
```

Sans clé API, le serveur démarre quand même : l'assistant traite les urgences
et renvoie `503 AI_UNAVAILABLE` pour le reste, ce qui fait basculer
l'application sur ses réponses préparées.

Pour tester depuis un téléphone sur le même réseau Wi-Fi :

```bash
flutter run --dart-define=API_URL=http://<IP-du-PC>:3000/api
```

## Version web (iPhone, navigateur)

Le serveur sert aussi la version web de l'application, à la racine :

```bash
npm run build:web   # compile l'app Flutter pour le web (API sur /api)
npm run dev         # http://localhost:3000 : app web + API
```

Sur un téléphone connecté au même Wi-Fi : `http://<IP-du-PC>:3000`
(`ipconfig` donne l'IP). Sur iPhone, Safari → Partager → « Sur l'écran
d'accueil » pour l'ouvrir en plein écran.

## Commandes

| Commande | Rôle |
|---|---|
| `npm run dev` | Serveur avec rechargement automatique |
| `npm test` | Tests automatiques (sans appel à Claude) |
| `npm run eval` | Évaluation de l'assistant avec le vrai modèle (coût réel, faible). `-- --verbose` affiche les réponses |
| `npm run sync-content` | Copie `education.json` et `faq.json` depuis l'app Flutter |
| `npm run build:web` | Compile la version web de l'app, servie par ce serveur |

## Routes

| Méthode | Route | Rôle |
|---|---|---|
| GET | `/api/health` | État du serveur |
| GET | `/api/education` | Fiches publiées (`?category=` facultatif) |
| GET | `/api/education/:id` | Une fiche, 404 sinon |
| POST | `/api/assistant/chat` | `{ question, history? }` → `{ answer, sources, disclaimer, urgent, status }` |

Authentification : voir `../docs/API_AUTH.md` (à implémenter).

## Fonctionnement de l'assistant

1. **Validation** : question de 1 à 500 caractères, 6 messages d'historique au plus.
2. **Urgence** : règles fixes de `faq.json`. Une situation urgente reçoit une
   consigne prédéfinie, sans appel au modèle.
3. **Recherche** : les fiches sont découpées en passages et les 4 plus
   pertinents sont retrouvés par mots-clés (BM25).
4. **Modèle** : Claude répond uniquement à partir de ces passages, au format
   JSON imposé (`status`, `answer`, `cited_passage_ids`).
5. **Contrôle** : une réponse contenant un diagnostic, un pourcentage de risque
   ou une posologie est remplacée par un message prudent.
6. **Sources** : seuls les passages fournis et réellement cités sont renvoyés.

Aucune conversation n'est conservée. Les journaux n'enregistrent ni les
questions ni la clé API.

## Contenus

- `src/data/education.json`, `src/data/faq.json` : copiés depuis l'app Flutter.
- `src/data/knowledge-extra.json` : fiches réservées à l'assistant (examens,
  traitements, dépistage, connaître ses seins, accompagner une proche).

Toutes les fiches sont à relire par l'équipe (`"reviewed": false`).
