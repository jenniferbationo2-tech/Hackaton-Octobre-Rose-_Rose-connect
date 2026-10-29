import { Router } from 'express';

import { notFound, ok } from '../utils/response.js';

export const educationRoutes = ({ items }) => {
  const router = Router();
  const published = items.filter((item) => item.published !== false);

  router.get('/', (req, res) => {
    const { category } = req.query;
    ok(
      res,
      typeof category === 'string'
        ? published.filter((item) => item.category === category)
        : published,
    );
  });

  router.get('/:id', (req, res) => {
    const item = published.find((i) => i.id === req.params.id);
    if (!item) throw notFound('Contenu introuvable.');
    ok(res, item);
  });

  return router;
};
