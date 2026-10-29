import { tokenize } from './text.js';

/**
 * Découpe les fiches en passages : une section par intertitre,
 * une idée reçue par passage.
 */
export const buildPassages = (items) => {
  const passages = [];
  for (const item of items) {
    const source = item.sources?.[0] ?? null;
    let section = { heading: null, lines: [] };
    let index = 0;

    const flush = () => {
      if (section.lines.length === 0) return;
      passages.push({
        id: `${item.id}#${++index}`,
        itemId: item.id,
        title: section.heading ? `${item.title} : ${section.heading}` : item.title,
        text: section.lines.join('\n'),
        source,
      });
    };

    for (const block of item.blocks ?? []) {
      switch (block.type) {
        case 'heading':
          flush();
          section = { heading: block.text, lines: [] };
          break;
        case 'paragraph':
        case 'callout':
          section.lines.push(block.text);
          break;
        case 'bullets':
          section.lines.push(...block.items.map((i) => `• ${i}`));
          break;
        case 'myth':
          flush();
          section = { heading: null, lines: [] };
          passages.push({
            id: `${item.id}#${++index}`,
            itemId: item.id,
            title: `${item.title} : ${block.myth}`,
            text: `Idée reçue : ${block.myth}\nEn réalité : ${block.fact}`,
            source,
          });
          break;
        default:
          break;
      }
    }
    flush();
  }
  return passages;
};

/**
 * Recherche lexicale (BM25 simplifié). Suffisant pour une base de quelques
 * dizaines de passages ; pas besoin de base vectorielle pour le prototype.
 */
export const createRetriever = (passages, { k1 = 1.2, b = 0.75 } = {}) => {
  const docs = passages.map((p) => {
    const titleTokens = tokenize(p.title);
    const tokens = [...titleTokens, ...tokenize(p.text)];
    const tf = new Map();
    for (const t of tokens) tf.set(t, (tf.get(t) ?? 0) + 1);
    return { passage: p, tf, length: tokens.length, title: new Set(titleTokens) };
  });
  const avgLength = docs.reduce((s, d) => s + d.length, 0) / Math.max(docs.length, 1);
  const df = new Map();
  for (const d of docs) for (const t of d.tf.keys()) df.set(t, (df.get(t) ?? 0) + 1);
  const idf = (t) => {
    const n = df.get(t) ?? 0;
    return Math.log(1 + (docs.length - n + 0.5) / (n + 0.5));
  };

  return {
    /** Passages les plus pertinents, au-dessus d'un seuil minimal. */
    search(question, { limit = 4, minScore = 1.5 } = {}) {
      const terms = [...new Set(tokenize(question))];
      if (terms.length === 0) return [];
      return docs
        .map((d) => {
          let score = 0;
          for (const t of terms) {
            const f = d.tf.get(t);
            if (!f) continue;
            const norm = f + k1 * (1 - b + (b * d.length) / avgLength);
            score += idf(t) * ((f * (k1 + 1)) / norm) * (d.title.has(t) ? 1.5 : 1);
          }
          return { passage: d.passage, score };
        })
        .filter((r) => r.score >= minScore)
        .sort((a, b2) => b2.score - a.score)
        .slice(0, limit);
    },
  };
};
