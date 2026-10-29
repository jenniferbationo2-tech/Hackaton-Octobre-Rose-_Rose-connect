/**
 * Journal minimal : méthode, chemin, statut, durée.
 * N'enregistre jamais le corps des requêtes (questions des utilisatrices).
 */
export const requestLogger = (req, res, next) => {
  const start = process.hrtime.bigint();
  res.on('finish', () => {
    const ms = Number(process.hrtime.bigint() - start) / 1e6;
    // Chemin complet, sans paramètres de requête.
    const path = req.originalUrl.split('?')[0];
    console.log(`${req.method} ${path} ${res.statusCode} ${ms.toFixed(0)}ms`);
  });
  next();
};
