import { createApp } from './app.js';
import { config } from './config.js';

const app = createApp();

app.listen(config.port, '0.0.0.0', () => {
  console.log(`ROSE Connect API sur http://localhost:${config.port}/api`);
  console.log(
    config.ai.configured
      ? `Assistant IA actif : ${config.ai.provider} (${config.ai.model})`
      : `Assistant IA inactif : ${config.ai.keyVar} absente (réponses préparées côté app)`,
  );
});
