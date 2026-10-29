import assert from 'node:assert/strict';
import { describe, it } from 'node:test';

import { education, knowledgeExtra } from '../src/data/index.js';
import { buildPassages, createRetriever } from '../src/services/knowledge.js';

const passages = buildPassages([...education, ...knowledgeExtra]);
const retriever = createRetriever(passages);
const topItem = (q) => retriever.search(q)[0]?.passage.itemId;

describe('découpage des fiches', () => {
  it('produit des passages identifiés et sourcés', () => {
    assert.ok(passages.length > 20);
    for (const p of passages) {
      assert.match(p.id, /^[a-z-]+#\d+$/);
      assert.ok(p.text.length > 0, p.id);
    }
    assert.equal(new Set(passages.map((p) => p.id)).size, passages.length);
  });
});

describe('recherche de passages', () => {
  const cases = [
    ['Une boule dans le sein, c’est forcément un cancer ?', 'idees-recues'],
    ['Quels sont les signes à surveiller ?', 'signes-sein'],
    ['J’ai trouvé une grosseur sous l’aisselle', 'signes-sein'],
    ['Comment se passe une mammographie ?', 'examens-sein'],
    ['À quoi sert une biopsie ?', 'examens-sein'],
    ['Le cancer du sein est-il héréditaire ?', 'facteurs-risque'],
    ['Comment aider ma sœur malade ?', 'accompagner-proche'],
    ['Comment faire l’autopalpation ?', 'connaitre-ses-seins'],
    ['Quels traitements existent ?', 'traitements'],
    ['Quand faut-il consulter un médecin ?', 'pourquoi-consulter'],
    ['ça s’attrape le cancer du sein ?', 'idees-recues'],
  ];
  for (const [question, expected] of cases) {
    it(`« ${question} » → ${expected}`, () => {
      const results = retriever.search(question).map((r) => r.passage.itemId);
      assert.ok(results.includes(expected), `obtenu : ${results.join(', ')}`);
    });
  }

  it('ne renvoie rien pour une question hors sujet', () => {
    assert.deepEqual(retriever.search('Quelle est la capitale du Japon ?'), []);
    assert.equal(topItem('   '), undefined);
  });
});
