import { rateLimit } from 'express-rate-limit';

const limitHandler = (message) => (_req, res) =>
  res.status(429).json({ success: false, error: { code: 'RATE_LIMITED', message } });

export const globalLimiter = rateLimit({
  windowMs: 60_000,
  limit: 120,
  standardHeaders: 'draft-8',
  legacyHeaders: false,
  handler: limitHandler('Trop de requêtes. Patientez un instant puis réessayez.'),
});

export const assistantLimiter = (perMinute) =>
  rateLimit({
    windowMs: 60_000,
    limit: perMinute,
    standardHeaders: 'draft-8',
    legacyHeaders: false,
    handler: limitHandler(
      'Vous avez posé beaucoup de questions en peu de temps. Patientez une minute puis réessayez.',
    ),
  });
