import { existsSync } from 'node:fs';
import { join } from 'node:path';

import cors from 'cors';
import express from 'express';
import helmet from 'helmet';

import { config } from './config.js';
import { education, faq, knowledgeExtra } from './data/index.js';
import { errorHandler, routeNotFound } from './middlewares/errors.js';
import { requestLogger } from './middlewares/logger.js';
import { globalLimiter } from './middlewares/rateLimit.js';
import { assistantRoutes } from './routes/assistant.routes.js';
import { educationRoutes } from './routes/education.routes.js';
import { createAssistant } from './services/assistant.js';
import { generateAnswer } from './services/ai/index.js';
import { ok } from './utils/response.js';

/** Construit l'application ; `generate` peut être remplacé dans les tests. */
export const createApp = ({ generate = generateAnswer, logRequests = true } = {}) => {
  const app = express();
  const assistant = createAssistant({
    items: [...education, ...knowledgeExtra],
    faq,
    generate,
  });

  app.set('trust proxy', 1);
  // CSP désactivée : l'application web Flutter charge ses propres scripts
  // et son moteur de rendu. Les autres protections de helmet restent actives.
  app.use(helmet({ contentSecurityPolicy: false }));
  app.use(cors(config.corsOrigins.length ? { origin: config.corsOrigins } : {}));
  app.use(express.json({ limit: '10kb' }));
  if (logRequests) app.use(requestLogger);
  app.use('/api', globalLimiter);

  app.get('/api/health', (_req, res) =>
    ok(res, { status: 'ok', ai: config.ai.configured, provider: config.ai.provider }),
  );
  app.use('/api/education', educationRoutes({ items: education }));
  app.use(
    '/api/assistant',
    assistantRoutes({ assistant, rateLimit: config.assistantRateLimit }),
  );

  // Version web de l'application (flutter build web), servie à la racine.
  // L'application appelle alors l'API sur la même adresse : /api.
  const webDir = config.webDir;
  if (webDir && existsSync(join(webDir, 'index.html'))) {
    app.use(express.static(webDir, { index: 'index.html' }));
    app.use((req, res, next) => {
      if (req.method !== 'GET' || req.path.startsWith('/api')) return next();
      res.sendFile(join(webDir, 'index.html'));
    });
  }

  app.use(routeNotFound);
  app.use(errorHandler);
  return app;
};
