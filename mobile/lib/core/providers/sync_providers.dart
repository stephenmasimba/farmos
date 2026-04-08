import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';
import '../services/sync_service.dart';

final pendingSyncCountProvider = FutureProvider.autoDispose<int>((ref) async {
  return ref.read(syncServiceProvider).getPendingCount();
});

final pendingSyncItemsProvider =
    FutureProvider.autoDispose<List<SyncQueueItem>>((ref) async {
  return ref.read(syncServiceProvider).getPendingItems();
});

final cacheDiagnosticsProvider =
    FutureProvider.autoDispose<List<CacheDiagnosticItem>>((ref) async {
  return ref.read(syncServiceProvider).getCacheDiagnostics();
});

final pendingModuleChangesProvider =
    FutureProvider.autoDispose.family<int, String>((ref, pathPrefix) async {
  final items =
      await ref.read(syncServiceProvider).getPendingItemsByPathPrefix(pathPrefix);
  return items.length;
});
