import { GoogleGenAI } from '@google/genai';

import { config } from '../../config.js';
import { AiUnavailableError, ANSWER_SCHEMA, parseAnswer } from './errors.js';

let client;
const getClient = () => {
  // Clé lue dans GEMINI_API_KEY ; elle ne quitte jamais le serveur.
  client ??= new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
  return client;
};

/**
 * Historique et question regroupés dans un seul message : l'échange reste
 * sans état côté Google (store: false), comme le reste de l'application.
 */
const toInput = (messages) => {
  const last = messages.at(-1);
  const previous = messages.slice(0, -1);
  if (previous.length === 0) return last.content;
  const transcript = previous
    .map((m) => `${m.role === 'user' ? 'Utilisatrice' : 'Assistant'} : ${m.content}`)
    .join('\n');
  return `<historique>\n${transcript}\n</historique>\n\n${last.content}`;
};

/**
 * Saturation (503, 500, 504), quota atteint (429) ou délai dépassé :
 * un autre modèle peut répondre. Les erreurs de requête (400…) ne sont pas
 * réessayées, elles échoueraient aussi.
 */
const isCapacityError = (error) =>
  [429, 500, 503, 504].includes(error?.status) ||
  /Timeout|Connection/.test(error?.constructor?.name ?? '');

const callModel = (model, { system, messages }) =>
  getClient().interactions.create(
    {
      model,
      store: false,
      system_instruction: system,
      input: toInput(messages),
      response_format: {
        type: 'text',
        mime_type: 'application/json',
        schema: ANSWER_SCHEMA,
      },
      // Réponses courtes de type conversation : réflexion réduite.
      generation_config: { thinking_level: 'low' },
    },
    // Pas de nouvelle tentative sur le même modèle : on passe au modèle de
    // secours, ce qui garde le temps total sous la limite de l'app.
    { timeout: config.ai.timeoutMs, maxRetries: 0 },
  );

/**
 * Appelle Gemini et renvoie { status, answer, cited_passage_ids }.
 * Modèle principal, puis modèle de secours s'il est saturé ou hors quota.
 */
export const generateWithGemini = async (prompt) => {
  const models = [config.ai.model, config.ai.fallbackModel].filter(
    (m, i, all) => m && all.indexOf(m) === i,
  );

  for (const [i, model] of models.entries()) {
    try {
      const interaction = await callModel(model, prompt);
      return parseAnswer(interaction.output_text);
    } catch (error) {
      if (error instanceof AiUnavailableError) throw error;
      // Ni la clé ni le contenu de la question ne sont journalisés.
      console.error(`[ia:gemini] ${model}`, error?.constructor?.name, error?.status ?? '');
      const hasNext = i < models.length - 1;
      if (!(hasNext && isCapacityError(error))) {
        throw new AiUnavailableError('Fournisseur IA indisponible');
      }
    }
  }
  throw new AiUnavailableError('Fournisseur IA indisponible');
};
