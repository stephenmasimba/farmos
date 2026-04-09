import 'package:workmanager/workmanager.dart';

import 'sync_service.dart';
import 'vaccination_reminder_service.dart';

const backgroundSyncTaskName = 'farmos_background_sync';
const vaccinationReminderTaskName = 'check_vaccinations';

@pragma('vm:entry-point')
void backgroundSyncDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == backgroundSyncTaskName) {
      final syncService = await SyncService.create();
      await syncService.syncPending();
    } else if (task == vaccinationReminderTaskName) {
      await VaccinationReminderService.init();
      final reminderService = await VaccinationReminderService.create();
      await reminderService.checkAndSendReminders();
    }
    return true;
  });
}

class BackgroundSync {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    await Workmanager().initialize(
      backgroundSyncDispatcher,
      isInDebugMode: false,
    );

    await Workmanager().registerPeriodicTask(
      'farmos_sync',
      backgroundSyncTaskName,
      frequency: const Duration(minutes: 30),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );

    await Workmanager().registerPeriodicTask(
      'vaccination_reminder',
      vaccinationReminderTaskName,
      frequency: const Duration(hours: 24),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );

    _initialized = true;
  }

  static Future<void> runNow() {
    return Workmanager().registerOneOffTask(
      'farmos_sync_now',
      backgroundSyncTaskName,
    );
  }
}
