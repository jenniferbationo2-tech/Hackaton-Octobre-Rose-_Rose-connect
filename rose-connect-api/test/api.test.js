import assert from 'node:assert/strict';
import { after, before, describe, it } from 'node:test';

import { createApp } from '../src/app.js';
import { AiUnavailableError } from '../src/services/ai/index.js';

/** Démarre l'API sur un port libre avec un modèle simulé. */
const startServer = async (generate) => {
  const app = createApp({ generate, logRequests: false });
  const server = await new Promise((resolve) => {
    const s = app.listen(0, () => resolve(s));
  });
  const base = `http://127.0.0.1:${server.address().port}/api`;
  return {
    base,
    close: () => new Promise((resolve) => server.close(resolve)),
    post: (path, body) =>
      fetch(`${base}${path}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: typeof body === 'string' ? body : JSON.stringify(body),
      }),
  };
};

describe('API', () => {
  let api;
  let lastCall;
  let nextResult;

  before(async () => {
    api = await startServer(async (args) => {
      lastCall = args;
      if (nextResult instanceof Error) throw nextResult;
      return nextResult;
    });
  });
  after(() => api.close());

  it('GET /health', async () => {
    const res = await fetch(`${api.base}/health`);
    const body = await res.json();
    assert.equal(res.status, 200);
    assert.equal(body.data.status, 'ok');
  });

  it('GET /education et /education/:id', async () => {
    const list = await (await fetch(`${api.base}/education`)).json();
    assert.ok(list.data.length >= 5);
    const one = await fetch(`${api.base}/education/signes-sein`);
    assert.equal(one.status, 200);
    const missing = await fetch(`${api.base}/education/inconnu`);
    assert.equal(missing.status, 404);
    assert.equal((await missing.json()).error.code, 'NOT_FOUND');
  });

  it('refuse une question vide, trop longue ou un JSON invalide', async () => {
    for (const body of [{}, { question: '   ' }, { question: 'a'.repeat(501) }, '{oops']) {
      const res = await api.post('/assistant/chat', body);
      assert.equal(res.status, 400);
      assert.equal((await res.json()).error.code, 'VALIDATION_ERROR');
    }
  });

  it('répond à partir des passages cités uniquement', async () => {
    nextResult = {
      status: 'answered',
      answer: 'La plupart des boules du sein ne sont pas des cancers. Consultez.',
      cited_passage_ids: ['idees-recues#1', 'passage-invente#9'],
    };
    const res = await api.post('/assistant/chat', {
      question: 'Une boule dans le sein, c’est toujours un cancer ?',
    });
    const { data } = await res.json();
    assert.equal(res.status, 200);
    assert.equal(data.urgent, false);
    assert.equal(data.sources.length, 1);
    assert.match(data.sources[0].label, /Organisation mondiale de la Santé/);
    assert.match(data.disclaimer, /diagnostic/);
    // Les passages retrouvés sont bien transmis au modèle.
    const userTurn = lastCall.messages.at(-1).content;
    assert.match(userTurn, /<document id="idees-recues#1">/);
  });

  it('traite l’urgence sans appeler le modèle', async () => {
    lastCall = undefined;
    const res = await api.post('/assistant/chat', {
      question: 'J’ai de la fièvre et mon sein est rouge et chaud',
    });
    const { data } = await res.json();
    assert.equal(data.urgent, true);
    assert.equal(lastCall, undefined);
  });

  it('bloque une réponse contenant un diagnostic', async () => {
    nextResult = {
      status: 'answered',
      answer: 'Rassurez-vous, vous n’avez pas de cancer.',
      cited_passage_ids: [],
    };
    const { data } = await (
      await api.post('/assistant/chat', { question: 'J’ai une boule, est-ce grave ?' })
    ).json();
    assert.equal(data.status, 'guarded');
    assert.doesNotMatch(data.answer, /n’avez pas de cancer/);
  });

  it('renvoie 503 AI_UNAVAILABLE si le modèle échoue', async () => {
    nextResult = new AiUnavailableError('panne');
    const res = await api.post('/assistant/chat', { question: 'Quels sont les signes ?' });
    assert.equal(res.status, 503);
    assert.equal((await res.json()).error.code, 'AI_UNAVAILABLE');
  });

  it('transmet l’historique en commençant par l’utilisatrice', async () => {
    nextResult = { status: 'answered', answer: 'Réponse.', cited_passage_ids: [] };
    await api.post('/assistant/chat', {
      question: 'Et pour l’échographie ?',
      history: [
        { role: 'assistant', content: 'Bonjour' },
        { role: 'user', content: 'Comment se passe une mammographie ?' },
        { role: 'assistant', content: 'Une radiographie des seins.' },
      ],
    });
    assert.equal(lastCall.messages[0].role, 'user');
    assert.equal(lastCall.messages.length, 3);
  });

  it('route inconnue : 404 au format commun', async () => {
    const res = await fetch(`${api.base}/inconnue`);
    assert.equal(res.status, 404);
    assert.equal((await res.json()).success, false);
  });
});
