import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const load = (file) => JSON.parse(readFileSync(join(here, file), 'utf8'));

/** Contenus chargés une fois au démarrage et gardés en mémoire. */
export const education = load('education.json').items;
export const faq = load('faq.json');
export const knowledgeExtra = load('knowledge-extra.json').items;
