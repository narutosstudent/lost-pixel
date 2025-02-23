import path from 'node:path';
import { Browser } from 'playwright';
import { mapLimit } from 'async';
import { log } from '../log';
import { getBrowser, sleep } from '../utils';
import { config } from '../config';
import { ShotItem } from '../types';
import { resizeViewportToFullscreen, waitForNetworkRequests } from './utils';

const takeScreenShot = async ({
  browser,
  shotItem,
  logger,
}: {
  browser: Browser;
  shotItem: ShotItem;
  logger: (message: string, ...rest: unknown[]) => void;
}) => {
  const context = await browser.newContext(shotItem.browserConfig);
  const page = await context.newPage();

  page.on('pageerror', (exception) => {
    logger('[pageerror] Uncaught exception:', exception);
  });

  page.on('console', async (message) => {
    const values = [];

    try {
      for (const arg of message.args()) {
        // eslint-disable-next-line no-await-in-loop
        values.push(await arg.jsonValue());
      }
    } catch (error: unknown) {
      logger(`[console] Error while collecting console output`, error);
    }

    const logMessage = `[console] ${String(values.shift())}`;
    logger(logMessage, ...values);
  });

  try {
    await page.goto(shotItem.url);
  } catch (error: unknown) {
    if (error instanceof Error && error.name === 'TimeoutError') {
      logger(`Timeout while loading page: ${shotItem.url}`);
    } else {
      logger('Page loading failed', error);
    }
  }

  try {
    await page.waitForLoadState('load', {
      timeout: config.timeouts.loadState,
    });
  } catch {
    logger(`Timeout while waiting for page load state: ${shotItem.url}`);
  }

  try {
    await waitForNetworkRequests({
      page,
      logger,
      ignoreUrls: ['/__webpack_hmr'],
    });
  } catch {
    logger(`Timeout while waiting for all network requests: ${shotItem.url}`);
  }

  if (config.beforeScreenshot) {
    await config.beforeScreenshot(page, {
      shotMode: shotItem.shotMode,
      id: shotItem.id,
      shotName: shotItem.shotName,
    });
  }

  let fullScreenMode = true;

  await sleep(shotItem?.waitBeforeScreenshot ?? config.waitBeforeScreenshot);

  try {
    await resizeViewportToFullscreen({ page });
    fullScreenMode = false;
  } catch {
    log(`Could not resize viewport to fullscreen: ${shotItem.shotName}`);
  }

  try {
    await page.screenshot({
      path: shotItem.filePathCurrent,
      fullPage: fullScreenMode,
      animations: 'disabled',
    });
  } catch (error: unknown) {
    logger('Error when taking screenshot', error);
  }

  await context.close();

  const videoPath = await page.video()?.path();

  if (videoPath) {
    const dirname = path.dirname(videoPath);
    const ext = videoPath.split('.').pop() ?? 'webm';
    const newVideoPath = `${dirname}/${shotItem.shotName}.${ext}`;
    await page.video()?.saveAs(newVideoPath);
    await page.video()?.delete();

    logger(
      `Video of '${shotItem.shotName}' recorded and saved to '${newVideoPath}`,
    );
  }
};

export const takeScreenShots = async (shotItems: ShotItem[]) => {
  const browser = await getBrowser().launch();
  const total = shotItems.length;

  await mapLimit<[number, ShotItem], void>(
    shotItems.entries(),
    config.shotConcurrency,
    async (item: [number, ShotItem]) => {
      const [index, shotItem] = item;
      const logger = (message: string, ...rest: unknown[]) => {
        log(`[${index + 1}/${total}] ${message}`, ...rest);
      };

      logger(`Taking screenshot of '${shotItem.shotName}'`);

      const startTime = Date.now();
      await takeScreenShot({ browser, shotItem, logger });
      const endTime = Date.now();
      const elapsedTime = Number((endTime - startTime) / 1000).toFixed(3);

      logger(
        `Screenshot of '${shotItem.shotName}' taken and saved to '${shotItem.filePathCurrent}' in ${elapsedTime}s`,
      );
    },
  );

  await browser.close();
};
