import { stitch } from '@google/stitch-sdk';
import { mkdir, writeFile } from 'node:fs/promises';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import path from 'node:path';

const execFileAsync = promisify(execFile);

const PROJECT_ID = '13507971777862616201';
const OUTPUT_DIR = path.resolve('design/stitch');

const SCREENS = [
  { slug: 'design-system', title: 'Design System', id: 'asset-stub-assets-09dd73e0a1f944569d356b8d9303fd8f-1779878399307' },
  { slug: 'home-dark', title: 'Home (Dark Mode)', id: '53f1d312790a474f8439e5a5dfa4c143' },
  { slug: 'home-light', title: 'Home (Light Mode)', id: '464789107fd64015adee3aecd2efad66' },
  { slug: 'ride-selection', title: 'Ride Selection', id: '704b6bca68664685b367389178d5bcba' },
  { slug: 'trip-history-1', title: 'Trip History', id: 'c08879569c904aa6ad90b26357566e0e' },
  { slug: 'splash', title: 'Splash Screen', id: 'e5175406c2d34bdb8f875897919ce178' },
  { slug: 'login', title: 'Login Screen', id: 'c21a65556e5a444fbf39ed7b5c126f52' },
  { slug: 'main-map', title: 'Main Map View', id: '72305331c20e4dbbae6be771782938bf' },
  { slug: 'ride-request-sheet', title: 'Ride Request Sheet', id: 'ddf4f1cb1118472b883b5a7e78a3c137' },
  { slug: 'trip-history-2', title: 'Trip History', id: 'ba9e9f3971804c6091629023ba50d8e2' },
  { slug: 'trip-details', title: 'Trip Details', id: 'ae83d0eeec70420fae375ae3ae1969fb' },
  { slug: 'live-tracking', title: 'Live Tracking', id: '5ba5dcb9d3b64d7a9d532e56961ae1d1' },
  { slug: 'profile-settings', title: 'Profile & Settings', id: 'acb11d2709d8438683ecfd13db757582' },
];

async function download(url, dest) {
  await execFileAsync('curl', ['-L', '-sS', '-o', dest, url], { maxBuffer: 50 * 1024 * 1024 });
}

async function main() {
  const project = stitch.project(PROJECT_ID);
  const metadata = {
    projectId: PROJECT_ID,
    projectTitle: 'Nokta Mobile Design System',
    screens: {},
  };

  await mkdir(OUTPUT_DIR, { recursive: true });

  for (const entry of SCREENS) {
    const screenDir = path.join(OUTPUT_DIR, 'screens', entry.slug);
    await mkdir(screenDir, { recursive: true });

    process.stdout.write(`Fetching ${entry.title} (${entry.id})...\n`);

    try {
      const screen = await project.getScreen(entry.id);
      const htmlUrl = await screen.getHtml();
      const imageUrl = await screen.getImage();
      const fullImageUrl = imageUrl.includes('=') ? imageUrl : `${imageUrl}=w1280`;

      const htmlPath = path.join(screenDir, 'index.html');
      const imagePath = path.join(screenDir, 'screen.png');

      await download(htmlUrl, htmlPath);
      await download(fullImageUrl, imagePath);

      metadata.screens[entry.slug] = {
        title: entry.title,
        screenId: entry.id,
        htmlUrl,
        imageUrl: fullImageUrl,
        htmlPath: path.relative(process.cwd(), htmlPath),
        imagePath: path.relative(process.cwd(), imagePath),
      };

      process.stdout.write(`  OK: ${entry.slug}\n`);
    } catch (error) {
      metadata.screens[entry.slug] = {
        title: entry.title,
        screenId: entry.id,
        error: error?.message ?? String(error),
      };
      process.stderr.write(`  FAILED: ${entry.slug} - ${error?.message ?? error}\n`);
    }
  }

  await writeFile(
    path.join(OUTPUT_DIR, 'metadata.json'),
    JSON.stringify(metadata, null, 2),
    'utf8',
  );

  process.stdout.write(`Done. Assets saved to ${OUTPUT_DIR}\n`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
