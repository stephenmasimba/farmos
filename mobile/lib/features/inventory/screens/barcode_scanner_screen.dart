import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/models/barcode_item.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

class BarcodeScanner extends ConsumerStatefulWidget {
  const BarcodeScanner({super.key});

  @override
  ConsumerState<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends ConsumerState<BarcodeScanner>
    with TickerProviderStateMixin {
  late final MobileScannerController controller;
  late final TabController _tabs;
  final _scannedItems = <ScannedInventoryAdjustment>[];
  BarcodeItem? _lastScanned;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Scan'),
            Tab(text: 'Review (${_scannedItems.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildScanTab(),
          _buildReviewTab(),
        ],
      ),
    );
  }

  Widget _buildScanTab() {
    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: _handleBarcode,
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_lastScanned != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _lastScanned!.itemName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_lastScanned!.category} • ${_lastScanned!.quantity} ${_lastScanned!.unit}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.flashlight_on),
                      label: const Text('Torch'),
                      onPressed: () {
                        controller.toggleTorch();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _scannedItems.isNotEmpty ? _submit : null,
                      child: Text(
                        'Submit (${_scannedItems.length})',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewTab() {
    if (_scannedItems.isEmpty) {
      return Center(
        child: Text(
          'No items scanned',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return ListView.builder(
      itemCount: _scannedItems.length,
      itemBuilder: (context, index) {
        final item = _scannedItems[index];
        return ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: Text('Item ID: ${item.itemId}'),
          subtitle: Text(
            '${item.scannedQuantity} • ${item.reason}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() => _scannedItems.removeAt(index));
            },
          ),
        );
      },
    );
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null || barcode.isEmpty) return;

    _isProcessing = true;

    try {
      final item =
          await ref.read(barcodeServiceProvider).lookupBarcode(barcode);
      setState(() {
        _lastScanned = item;
        _scannedItems.add(
          ScannedInventoryAdjustment(
            itemId: item.itemId,
            scannedQuantity: item.quantity,
            reason: 'restock',
          ),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barcode not found: $e')),
      );
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _submit() async {
    try {
      await ref
          .read(barcodeServiceProvider)
          .recordBulkAdjustments(_scannedItems);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventory updated')),
      );
      setState(() => _scannedItems.clear());
      _tabs.animateTo(0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submit failed: $e')),
      );
    }
  }
}

extension on List<BarcodeCapture> {
  BarcodeCapture? get firstOrNull {
    try {
      return first;
    } catch (e) {
      return null;
    }
  }
}

extension on List<Barcode>? {
  Barcode? get firstOrNull {
    try {
      return this?.first;
    } catch (e) {
      return null;
    }
  }
}
