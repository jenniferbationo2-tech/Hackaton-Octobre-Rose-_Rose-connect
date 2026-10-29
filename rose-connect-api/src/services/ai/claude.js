import Anthropic from '@anthropic-ai/sdk';

import { config } from '../../config.js';
import { AiUnavailableError, ANSWER_SCHEMA, parseAnswer } from './errors.js';

let client;
const getClient = () => {
  // Clé lue par le SDK dans ANTHROPIC_API_KEY ; elle ne quitte jamais le serveur.
  client ??= new Anthropic({ timeout: config.ai.timeoutMs, maxRetries: 1 });
  return client;
};

/** Appelle Claude et renvoie { status, answer, cited_passage_ids }. */
export const generateWithClaude = async ({ system, messages }) => {
  let response;
  try {
    response = await getClient().beta.messages.create({
      model: config.ai.model,
      max_tokens: 16000,
      // Si le modèle décline par prudence, l'API réessaie avec le modèle de
      // repli recommandé au lieu de renvoyer un refus.
      betas: ['server-side-fallback-2026-07-01'],
      fallbacks: 'default',
      system,
      messages,
      output_config: {
        // Réponses courtes de type conversation : effort bas, latence réduite.
        effort: 'low',
        format: {
          type: 'json_schema',
          schema: { ...ANSWER_SCHEMA, additionalProperties: false },
        },
      },
    });
  } catch (error) {
    if (error instanceof Anthropic.APIError) {
      // Ni la clé ni le contenu de la question ne sont journalisés.
      console.error('[ia:claude]', error.constructor.name, error.status ?? '');
      throw new AiUnavailableError('Fournisseur IA indisponible');
    }
    throw error;
  }

  if (response.stop_reason === 'refusal') {
    console.warn('[ia:claude] refus', response.stop_details?.category ?? '');
    throw new AiUnavailableError('Réponse refusée par le modèle');
  }
  if (response.stop_reason === 'max_tokens') {
    throw new AiUnavailableError('Réponse tronquée');
  }
  return parseAnswer(response.content.find((block) => block.type === 'text')?.text);
};
