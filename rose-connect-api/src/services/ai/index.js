import { config } from '../../config.js';
import { generateWithClaude } from './claude.js';
import { AiUnavailableError } from './errors.js';
import { generateWithGemini } from './gemini.js';

export { AiUnavailableError } from './errors.js';

const providers = {
  claude: generateWithClaude,
  gemini: generateWithGemini,
};

const notConfigured = async () => {
  throw new AiUnavailableError(`Clé API absente pour ${config.ai.provider}`);
};

/** Fournisseur choisi par AI_PROVIDER ; même interface pour tous. */
export const generateAnswer = config.ai.configured
  ? providers[config.ai.provider]
  : notConfigured;
