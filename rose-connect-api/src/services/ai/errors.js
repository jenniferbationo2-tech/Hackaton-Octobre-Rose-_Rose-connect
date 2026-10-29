/** Échec du fournisseur d'IA : le client bascule sur ses réponses préparées. */
export class AiUnavailableError extends Error {}

/** Format imposé à la réponse du modèle, commun à tous les fournisseurs. */
export const ANSWER_SCHEMA = {
  type: 'object',
  properties: {
    status: {
      type: 'string',
      enum: [
        'answered',
        'insufficient_information',
        'personal_medical_request',
        'out_of_scope',
      ],
    },
    answer: { type: 'string' },
    cited_passage_ids: { type: 'array', items: { type: 'string' } },
  },
  required: ['status', 'answer', 'cited_passage_ids'],
};

/** Lit le JSON renvoyé par le modèle ; lève AiUnavailableError s'il est inexploitable. */
export const parseAnswer = (text) => {
  try {
    const parsed = JSON.parse(text ?? '');
    if (typeof parsed.answer !== 'string' || !Array.isArray(parsed.cited_passage_ids)) {
      throw new Error('format');
    }
    return parsed;
  } catch {
    throw new AiUnavailableError('Réponse illisible');
  }
};
