import { AppError } from '../utils/response.js';

/** Valide req.body avec un schéma zod ; remplace le corps par la version nettoyée. */
export const validateBody = (schema) => (req, _res, next) => {
  const result = schema.safeParse(req.body ?? {});
  if (!result.success) {
    const message = result.error.issues[0]?.message ?? 'Requête invalide.';
    return next(new AppError(400, 'VALIDATION_ERROR', message));
  }
  req.body = result.data;
  next();
};
