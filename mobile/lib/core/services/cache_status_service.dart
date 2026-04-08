import 'package:flutter_riverpod/flutter_riverpod.dart';

class CacheStatusRecord {
  const CacheStatusRecord({
    required this.showingOfflineData,
    this.lastUpdatedAt,
    this.lastCheckedAt,
  });

  final bool showingOfflineData;
  final DateTime? lastUpdatedAt;
  final DateTime? lastCheckedAt;
}

class CacheStatusService extends StateNotifier<Map<String, CacheStatusRecord>> {
  CacheStatusService() : super(const {});

  void markFresh(String key, {DateTime? lastUpdatedAt}) {
    state = {
      ...state,
      key: CacheStatusRecord(
        showingOfflineData: false,
        lastUpdatedAt: lastUpdatedAt ?? DateTime.now(),
        lastCheckedAt: DateTime.now(),
      ),
    };
  }

  void markOffline(String key, {DateTime? lastUpdatedAt}) {
    final previous = state[key];
    state = {
      ...state,
      key: CacheStatusRecord(
        showingOfflineData: true,
        lastUpdatedAt: lastUpdatedAt ?? previous?.lastUpdatedAt,
        lastCheckedAt: DateTime.now(),
      ),
    };
  }
}

CacheStatusRecord? latestOfflineStatus(
  Map<String, CacheStatusRecord> statuses,
  List<String> keys,
) {
  CacheStatusRecord? latest;
  for (final key in keys) {
    final status = statuses[key];
    if (status == null || !status.showingOfflineData) continue;
    if (latest == null) {
      latest = status;
      continue;
    }
    final latestAt = latest.lastUpdatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final currentAt = status.lastUpdatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    if (currentAt.isAfter(latestAt)) {
      latest = status;
    }
  }
  return latest;
}