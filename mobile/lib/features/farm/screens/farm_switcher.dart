import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/farm.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';

final _managedFarmsProvider = FutureProvider.autoDispose<List<Farm>>((ref) {
  return ref.read(farmServiceProvider).listManagedFarms();
});

final _ownedFarmsProvider = FutureProvider.autoDispose<List<Farm>>((ref) {
  return ref.read(farmServiceProvider).listOwnedFarms();
});

final _selectedFarmProvider =
    StateProvider.autoDispose<int?>((ref) => null);

class FarmSwitcher extends ConsumerWidget {
  const FarmSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final managed = ref.watch(_managedFarmsProvider);
    final owned = ref.watch(_ownedFarmsProvider);
    final selectedId = ref.watch(_selectedFarmProvider);
    final user = ref.watch(authProvider).user;

    if (user == null || (user.farmId == null)) {
      return const SizedBox.shrink();
    }

    return managed.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(8),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (farms) {
        if (farms.isEmpty) {
          return const SizedBox.shrink();
        }

        final allFarms = [...farms];
        owned.whenData((o) {
          allFarms.addAll(o);
        });

        final currentFarm =
            allFarms.firstWhereOrNull((f) => f.id == (selectedId ?? user.farmId));

        return GestureDetector(
          onTap: () => _showFarmMenu(context, ref, allFarms),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accent, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.agriculture, size: 16, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  currentFarm?.name ?? 'Select Farm',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 4),
                Icon(Icons.expand_more, size: 14, color: AppColors.accent),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFarmMenu(
    BuildContext context,
    WidgetRef ref,
    List<Farm> farms,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select Farm',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...farms.map(
            (farm) => ListTile(
              leading: const Icon(Icons.agriculture),
              title: Text(farm.name),
              subtitle: farm.totalAreaHa != null
                  ? Text('${farm.totalAreaHa} ha')
                  : null,
              onTap: () async {
                await ref.read(farmServiceProvider).updateFarmPreference(farm.id);
                ref.invalidate(_managedFarmsProvider);
                ref.invalidate(_ownedFarmsProvider);
                ref.read(_selectedFarmProvider.notifier).state = farm.id;
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension on List<Farm> {
  Farm? firstWhereOrNull(bool Function(Farm) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }
}
