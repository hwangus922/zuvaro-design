import { chromium } from 'playwright';
import { fileURLToPath } from 'url';
import path from 'path';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const mockups = path.join(__dirname, 'mockups');
const publicDir = path.join(root, 'public');

const shots = [
  ['missions-original-style.html', 'MissionsUI.png'],
  ['leaderboard-original-style.html', 'LeaderboardUI.png'],
  // ProofUI.png unchanged — restore from scripts/originals/public/ if needed
];

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 2 });

for (const [html, png] of shots) {
  const file = path.join(mockups, html);
  await page.goto(`file://${file}`);
  await page.waitForTimeout(200);
  await page.screenshot({ path: path.join(publicDir, png), type: 'png' });
  console.log(`Wrote ${png}`);
}

await browser.close();
