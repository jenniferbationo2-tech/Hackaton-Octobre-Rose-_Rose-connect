import { buildPassages, createRetriever } from './knowledge.js';
import { buildUserTurn, SYSTEM_PROMPT } from './prompt.js';
import { containsForbiddenClaim, createUrgencyDetector } from './safety.js';

export const DISCLAIMER = 'Cette réponse ne constitue pas un diagnostic médical.';

const GUARDED_ANSWER =
  'Je ne peux pas répondre à cette question de façon sûre. Seul un professionnel ' +
  'de santé peut examiner votre situation. N’hésitez pas à consulter un médecin, ' +
  'une sage-femme ou un centre de santé.';

/**
 * Pipeline : urgence (règles fixes) → recherche de passages → modèle →
 * contrôle de la réponse → sources citées.
 * `generate` est injecté pour pouvoir tester sans appeler l'API.
 */
export const createAssistant = ({ items, faq, generate }) => {
  const retriever = createRetriever(buildPassages(items));
  const isUrgent = createUrgencyDetector({
    keywords: faq.urgent?.keywords,
    combinations: faq.urgent?.combinations,
  });

  return {
    async answer({ question, history = [] }) {
      if (isUrgent(question)) {
        return {
          answer: faq.urgent.answer,
          sources: [],
          disclaimer: DISCLAIMER,
          urgent: true,
          status: 'urgent',
        };
      }

      const passages = retriever.search(question).map((r) => r.passage);
      const messages = [
        ...history.map((m) => ({ role: m.role, content: m.content })),
        { role: 'user', content: buildUserTurn(question, passages) },
      ];

      const result = await generate({ system: SYSTEM_PROMPT, messages });

      if (containsForbiddenClaim(result.answer)) {
        console.warn('[assistant] réponse bloquée par le contrôle de sortie');
        return {
          answer: GUARDED_ANSWER,
          sources: [],
          disclaimer: DISCLAIMER,
          urgent: false,
          status: 'guarded',
        };
      }

      // Seuls les passages réellement fournis et cités deviennent des sources.
      const cited = new Set(result.cited_passage_ids);
      const sources = [];
      const seen = new Set();
      for (const p of passages) {
        if (!cited.has(p.id) || !p.source) continue;
        const key = `${p.source.label}|${p.source.url ?? ''}`;
        if (seen.has(key)) continue;
        seen.add(key);
        sources.push({ label: p.source.label, url: p.source.url ?? null });
      }

      return {
        answer: result.answer.trim(),
        sources,
        disclaimer: DISCLAIMER,
        urgent: false,
        status: result.status,
      };
    },
  };
};
