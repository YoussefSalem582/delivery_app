import { stitch } from '@google/stitch-sdk';
import { mkdir, writeFile } from 'node:fs/promises';
import path from 'node:path';

const PROJECT_ID = '13507971777862616201';
const OUTPUT_DIR = path.resolve('design/stitch/screens/design-system');

async function main() {
  const project = stitch.project(PROJECT_ID);
  await mkdir(OUTPUT_DIR, { recursive: true });

  const systems = await project.listDesignSystems();
  const ds = systems[0];
  const designSystem = ds?.data?.designSystem;

  await writeFile(
    path.join(OUTPUT_DIR, 'design-system.json'),
    JSON.stringify(ds?.data ?? {}, null, 2),
  );

  const listResult = await stitch.callTool('list_design_systems', {
    projectId: PROJECT_ID,
  });
  const listText = listResult?.content?.map((c) => c.text).join('\n') ?? '';
  await writeFile(path.join(OUTPUT_DIR, 'list-design-systems.txt'), listText);

  console.log('Saved design-system.json');
  console.log('Top-level data keys:', Object.keys(ds?.data ?? {}));
  if (designSystem) {
    console.log('designSystem keys:', Object.keys(designSystem));
  }
}

main().catch(console.error);
