import assert from 'node:assert/strict';
import { describe, it } from 'node:test';

import { faq } from '../src/data/index.js';
import { containsForbiddenClaim, createUrgencyDetector } from '../src/services/safety.js';

describe('détection d’urgence', () => {
  const isUrgent = createUrgencyDetector(faq.urgent);

  it('repère les situations urgentes', () => {
    assert.ok(isUrgent('J’ai du mal à respirer'));
    assert.ok(isUrgent('je saigne beaucoup du mamelon'));
    assert.ok(isUrgent('Mon sein est rouge et chaud, et j’ai de la fièvre'));
  });

  it('ignore les questions ordinaires', () => {
    assert.ok(!isUrgent('Quels sont les signes du cancer du sein ?'));
    assert.ok(!isUrgent('Ma peau est un peu rouge, est-ce normal ?'));
  });
});

describe('contrôle des réponses', () => {
  it('bloque les diagnostics, pourcentages et posologies', () => {
    for (const answer of [
      'Vous avez un cancer du sein.',
      'Rassurez-vous : vous n’avez pas de cancer.',
      'D’après ce que vous décrivez, ce n’est pas un cancer.',
      'C’est probablement un cancer.',
      'Vous avez 30 % de risque de développer la maladie.',
      'Prenez 500 mg de paracétamol.',
    ]) {
      assert.ok(containsForbiddenClaim(answer), answer);
    }
  });

  it('laisse passer les formulations générales correctes', () => {
    for (const answer of [
      'Une boule ne signifie pas toujours que c’est un cancer.',
      'Si vous avez un cancer du sein, l’équipe médicale décide du traitement.',
      'La plupart des boules du sein ne sont pas des cancers.',
      'Seul un professionnel de santé peut dire si c’est un cancer.',
      'Seul un examen permet de confirmer que ce n’est pas un cancer.',
    ]) {
      assert.ok(!containsForbiddenClaim(answer), answer);
    }
  });
});
