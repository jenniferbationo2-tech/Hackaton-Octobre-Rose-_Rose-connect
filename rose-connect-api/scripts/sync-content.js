// Copie les contenus validés de l'application Flutter vers l'API.
// Source unique : rose_connect/assets/data. À relancer après chaque relecture.
//   npm run sync-content
import { copyFileSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const appData = join(root, '..', 'rose_connect', 'assets', 'data');
const apiData = join(root, 'src', 'data');

for (const file of ['education.json', 'faq.json']) {
  const from = join(appData, file);
  if (!existsSync(from)) {
    console.error(`Introuvable : ${from}`);
    process.exitCode = 1;
    continue;
  }
  copyFileSync(from, join(apiData, file));
  console.log(`Copié : ${file}`);
}
