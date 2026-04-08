import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_config.dart';
import '../../../core/models/reports.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';

final _reportTypesProvider = FutureProvider.autoDispose<List<String>>((ref) {
  return ref.read(reportsServiceProvider).getTypes();
});

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = ref.watch(_reportTypesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: types.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(_reportTypesProvider),
        ),
        data: (list) => list.isEmpty
            ? const EmptyState(
                icon: Icons.summarize_rounded,
                title: 'No report types available',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, i) =>
                    _ReportTypeCard(type: list[i]),
              ),
      ),
    );
  }
}

class _ReportTypeCard extends ConsumerStatefulWidget {
  const _ReportTypeCard({required this.type});

  final String type;

  @override
  ConsumerState<_ReportTypeCard> createState() => _ReportTypeCardState();
}

class _ReportTypeCardState extends ConsumerState<_ReportTypeCard> {
  String _format = 'csv';
  bool _loading = false;

  Future<void> _generate() async {
    setState(() => _loading = true);
    try {
      final link = await ref.read(reportsServiceProvider).generate(
            type: widget.type.toLowerCase(),
            format: _format,
          );
      if (!mounted) return;
      _openDownloadLink(link);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openDownloadLink(ReportDownloadLink link) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Report Ready'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your report has been generated.'),
            const SizedBox(height: 8),
            Text('Expires: ${link.expiresAt}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.onSurfaceVariant)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final uri = Uri.parse(link.url).hasScheme
                  ? Uri.parse(link.url)
                  : Uri.parse('${AppConfig.baseUrl}${link.url}');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri,
                    mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description_rounded,
                    color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '${widget.type} Report',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Format: ',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant)),
                ChoiceChip(
                  label: const Text('CSV'),
                  selected: _format == 'csv',
                  onSelected: (_) => setState(() => _format = 'csv'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('PDF (HTML)'),
                  selected: _format == 'pdf',
                  onSelected: (_) => setState(() => _format = 'pdf'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _generate,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.receipt_long_rounded),
                label: Text(_loading ? 'Generating…' : 'Generate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
