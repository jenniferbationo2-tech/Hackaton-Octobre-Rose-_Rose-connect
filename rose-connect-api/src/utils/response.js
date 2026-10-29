/** Enveloppe commune des réponses : { success, data } ou { success, error }. */
export const ok = (res, data, status = 200) =>
  res.status(status).json({ success: true, data });

/** Erreur prévue, renvoyée telle quelle au client (message en français). */
export class AppError extends Error {
  constructor(status, code, message) {
    super(message);
    this.status = status;
    this.code = code;
  }
}

export const notFound = (message = 'Ressource introuvable.') =>
  new AppError(404, 'NOT_FOUND', message);
