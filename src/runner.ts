import { checkDifferences } from './checkDifferences';
import { collect } from './collect';
import { createShots } from './createShots';
import { createShotsFolders, getEventData, log, isUpdateMode } from './utils';
import { config, configure } from './config';
import { sendResultToAPI } from './upload';
import { sendInitToAPI } from './sendInit';

(async () => {
  await configure();
  try {
    if (config.setPendingStatusCheck && config.generateOnly) {
      await sendInitToAPI();
    }
    if (isUpdateMode()) {
      log(
        'Running lost-pixel in update mode. Baseline screenshots will be updated',
      );
    }

    createShotsFolders();
    const shotItems = await createShots();
    await checkDifferences(shotItems);

    if (!config.generateOnly) {
      const comparisons = await collect();
      await sendResultToAPI({
        success: true,
        comparisons,
        event: getEventData(config.eventFilePath),
      });
    }
  } catch (error) {
    if (error instanceof Error) {
      log(error.message);
    } else {
      log(error);
    }

    if (!config.generateOnly) {
      await sendResultToAPI({
        success: false,
        event: getEventData(config.eventFilePath),
      });
    }

    process.exit(1);
  }
})();
