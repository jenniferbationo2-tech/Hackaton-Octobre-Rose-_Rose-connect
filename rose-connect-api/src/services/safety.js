import { normalize } from './text.js';


/**
 * Détection d'urgence par règles fixes (faq.json), jamais par le modèle :
 * une expression présente telle quelle, ou tous les mots d'une combinaison.
 */
export const createUrgencyDetector = ({ keywords = [], combinations = [] }) => {
  const phrases = keywords.map((k) => ` ${normalize(k)} `);
  return (question) => {
    const text = ` ${normalize(question)} `;
    if (phrases.some((p) => text.includes(p))) return true;
    const words = new Set(normalize(question).split(' '));
    return combinations.some((combo) => combo.every((w) => words.has(w)));
  };
};

// Formulations interdites dans une réponse : diagnostic, pourcentage de
// risque personnel, posologie. Contrôle de dernier recours après le modèle.
// Les motifs s'appliquent au texte en minuscules, sans accents.
// Les affirmations sur « vous » ou « c'est » ne sont visées qu'en tête de
// phrase et hors tournure conditionnelle (« si vous avez… », « …que c'est… »).
const START = String.raw`(?:^|[.!?:;]\s|\n)`;
const FORBIDDEN = [
  new RegExp(`(?<!\\bsi )(?<!\\bque )\\bvous (avez (un |le )?|souffrez d'un |etes atteinte? d'un )cancer\\b`),
  new RegExp(`(?<!\\bsi )(?<!\\bque )\\bvous n'?\\s?avez (pas|aucun) (de |le )?cancer\\b`),
  new RegExp(`(?<!\\bque )(?<!\\bsi )\\b(ce|ca|cela) n'?\\s?est (pas|surement pas|certainement pas) un cancer\\b`),
  new RegExp(`${START}(c'?\\s?est|ca|cela est) (un|surement un|certainement un|probablement un) cancer\\b`),
  /\d+\s?% (de )?(risque|chances?|probabilite)/,
  /\b(risque|probabilite) (de|d'environ) \d+\s?%/,
  /\b\d+\s?(mg|milligrammes?|comprimes?)\b/,
];

const forGuard = (text) =>
  text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[’`]/g, "'")
    .replace(/\s+/g, ' ');

export const containsForbiddenClaim = (answer) => {
  const text = forGuard(answer);
  return FORBIDDEN.some((re) => re.test(text));
};
