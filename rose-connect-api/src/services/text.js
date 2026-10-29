/** Outils de traitement du français : normalisation, mots vides, synonymes. */

const STOP_WORDS = new Set(
  `le la les un une des de du d l au aux et ou a en dans sur sous pour par avec
  je j tu il elle on nous vous ils elles me m te t se s mon ma mes ton ta tes son sa ses
  est sont ai as avez ont etre ce cet cette ces qui que qu quoi quel quels quelle quelles
  comment pourquoi ne pas plus si y c n faut peut peux bonjour svp merci tres bien aussi
  cancer sein seins`.split(/\s+/),
);

// Formulations courantes ramenées au terme employé dans les fiches.
const SYNONYMS = new Map([
  ['grosseur', 'boule'], ['masse', 'boule'], ['nodule', 'boule'], ['bosse', 'boule'],
  ['symptome', 'signe'], ['indice', 'signe'],
  ['mammo', 'mammographie'], ['radio', 'mammographie'],
  ['echo', 'echographie'],
  ['docteur', 'medecin'],
  ['hereditaire', 'famille'], ['genetique', 'famille'],
  ['prevenir', 'reduire'], ['prevention', 'reduire'], ['eviter', 'reduire'],
  ['soigner', 'traitement'], ['guerir', 'traitement'], ['chimio', 'chimiotherapie'],
  ['autopalpation', 'palper'], ['palpation', 'palper'],
  ['aider', 'aide'], ['soutenir', 'aide'], ['soutien', 'aide'], ['accompagner', 'aide'],
  ['soeur', 'proche'], ['mere', 'proche'], ['amie', 'proche'], ['tante', 'proche'],
  ['fille', 'proche'], ['epouse', 'proche'], ['femme', 'proche'],
  ['attrape', 'contagieux'], ['attraper', 'contagieux'], ['contagion', 'contagieux'],
  ['transmet', 'contagieux'], ['transmettre', 'contagieux'], ['transmissible', 'contagieux'],
]);

export const normalize = (text) =>
  text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/œ/g, 'oe')
    .replace(/æ/g, 'ae')
    .replace(/[^a-z0-9]+/g, ' ')
    .trim();

/** Racine simple : retire le pluriel (s, x) des mots assez longs. */
const stem = (word) =>
  word.length > 4 && /[sx]$/.test(word) ? word.slice(0, -1) : word;

export const tokenize = (text) =>
  normalize(text)
    .split(' ')
    .filter((w) => w && !STOP_WORDS.has(w))
    .map((w) => stem(w))
    .map((w) => SYNONYMS.get(w) ?? w);
