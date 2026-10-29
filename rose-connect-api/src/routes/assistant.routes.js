import { Router } from 'express';
import { z } from 'zod';

import { validateBody } from '../middlewares/validate.js';
import { assistantLimiter } from '../middlewares/rateLimit.js';
import { AiUnavailableError } from '../services/ai/index.js';
import { AppError, ok } from '../utils/response.js';

const chatSchema = z.object({
  question: z
    .string({ error: 'La question est obligatoire.' })
    .trim()
    .min(1, 'La question est vide.')
    .max(500, 'La question est trop longue (500 caractères maximum).'),
  history: z
    .array(
      z.object({
        role: z.enum(['user', 'assistant']),
        content: z.string().trim().min(1).max(2000),
      }),
    )
    .max(6, 'Historique trop long.')
    .default([]),
});

export const assistantRoutes = ({ assistant, rateLimit }) => {
  const router = Router();

  router.post(
    '/chat',
    assistantLimiter(rateLimit),
    validateBody(chatSchema),
    async (req, res) => {
      const { question, history } = req.body;
      // La conversation doit commencer par un message de l'utilisatrice.
      const firstUser = history.findIndex((m) => m.role === 'user');
      const cleanHistory = firstUser === -1 ? [] : history.slice(firstUser);
      try {
        const data = await assistant.answer({ question, history: cleanHistory });
        ok(res, data);
      } catch (error) {
        if (error instanceof AiUnavailableError) {
          throw new AppError(
            503,
            'AI_UNAVAILABLE',
            'L’assistant est momentanément indisponible.',
          );
        }
        throw error;
      }
    },
  );

  return router;
};
