import { AppError } from '../utils/response.js';

export const routeNotFound = (_req, _res, next) =>
  next(new AppError(404, 'NOT_FOUND', 'Route introuvable.'));

/**
 * Gestionnaire central : jamais de pile d'appels ni de détail technique
 * (fournisseur d'IA, base de données) dans la réponse au client.
 */
// eslint-disable-next-line no-unused-vars
export const errorHandler = (err, _req, res, _next) => {
  if (err instanceof AppError) {
    return res
      .status(err.status)
      .json({ success: false, error: { code: err.code, message: err.message } });
  }
  // JSON mal formé ou corps trop volumineux (express.json).
  if (err?.type === 'entity.parse.failed') {
    return res.status(400).json({
      success: false,
      error: { code: 'VALIDATION_ERROR', message: 'Le corps de la requête est invalide.' },
    });
  }
  if (err?.type === 'entity.too.large') {
    return res.status(413).json({
      success: false,
      error: { code: 'VALIDATION_ERROR', message: 'La requête est trop volumineuse.' },
    });
  }
  console.error('[erreur]', err?.name, err?.message);
  return res.status(500).json({
    success: false,
    error: { code: 'SERVER_ERROR', message: 'Une erreur est survenue. Réessayez plus tard.' },
  });
};
