import { fileURLToPath } from 'node:url';

/** Configuration lue depuis les variables d'environnement (.env). */
const toInt = (value, fallback) => {
  const n = Number.parseInt(value ?? '', 10);
  return Number.isFinite(n) && n > 0 ? n : fallback;
};

// Fournisseur d'IA : 'gemini' ou 'claude'. Chacun lit sa propre clé.
const AI_PROVIDERS = {
  gemini: {
    keyVar: 'GEMINI_API_KEY',
    defaultModel: 'gemini-3.8-flash',
    // Utilisé si le modèle principal est saturé (503) ou hors quota (429).
    defaultFallbackModel: 'gemini-3.5-flash-lite',
  },
  claude: { keyVar: 'ANTHROPIC_API_KEY', defaultModel: 'claude-opus-5-5' },
};
const provider = AI_PROVIDERS[process.env.AI_PROVIDER] ? process.env.AI_PROVIDER : 'gemini';

export const config = {
  port: toInt(process.env.PORT, 3000),
  ai: {
    provider,
    keyVar: AI_PROVIDERS[provider].keyVar,
    configured: Boolean(process.env[AI_PROVIDERS[provider].keyVar]),
    model: process.env.AI_MODEL || AI_PROVIDERS[provider].defaultModel,
    fallbackModel:
      process.env.AI_FALLBACK_MODEL || AI_PROVIDERS[provider].defaultFallbackModel || null,
    // Par tentative : deux tentatives au plus restent sous les 30 s de l'app.
    timeoutMs: 12_000,
  },
  corsOrigins: (process.env.CORS_ORIGIN ?? '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean),
  assistantRateLimit: toInt(process.env.ASSISTANT_RATE_LIMIT, 10),
  // Dossier de la version web de l'app (flutter build web). Par défaut, celui
  // du projet Flutter voisin ; ignoré s'il n'existe pas.
  webDir:
    process.env.WEB_DIR ??
    fileURLToPath(new URL('../../rose_connect/build/web', import.meta.url)),
};
