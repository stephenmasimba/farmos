import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/field_map.dart';
import '../../../core/models/field.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';

// Simple map implementation using Canvas - can be replaced with flutter_map or Google Maps
final _fieldBoundaryProvider = FutureProvider.autoDispose
    .family<FieldBoundary?, int>((ref, fieldId) async {
  try {
    return await ref.read(fieldMapServiceProvider).getFieldBoundary(fieldId);
  } catch (e) {
    return null;
  }
});

class FieldMapScreen extends ConsumerStatefulWidget {
  const FieldMapScreen({required this.field, super.key});

  final Field field;

  @override
  ConsumerState<FieldMapScreen> createState() => _FieldMapScreenState();
}

class _FieldMapScreenState extends ConsumerState<FieldMapScreen> {
  final _drawingPoints = <GeoPoint>[];
  bool _isDrawing = false;

  @override
  Widget build(BuildContext context) {
    final boundary = ref.watch(_fieldBoundaryProvider(widget.field.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.field.name} - Map'),
        actions: [
          if (_isDrawing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveBoundary,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: boundary.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Error: $err')),
              data: (data) {
                final points = _isDrawing ? _drawingPoints : (data?.boundaryPoints ?? []);
                return GestureDetector(
                  onLongPress: _isDrawing ? _addPoint : null,
                  child: Container(
                    color: Colors.grey[100],
                    child: CustomPaint(
                      painter: FieldMapPainter(points: points),
                      size: Size.infinite,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.field.areaSizeHa != null)
                  Text('Field Area: ${widget.field.areaSizeHa} ha'),
                const SizedBox(height: 8),
                if (_isDrawing) ...[
                  Text('Points: ${_drawingPoints.length}'),
                  const SizedBox(height: 8),
                ],
                if (!_isDrawing)
                  ElevatedButton.icon(
                    onPressed: _startDrawing,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Boundary'),
                  ),
                if (_isDrawing) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isDrawing = false;
                              _drawingPoints.clear();
                            });
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Cancel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[400],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveBoundary,
                          icon: const Icon(Icons.check),
                          label: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startDrawing() {
    setState(() => _isDrawing = true);
  }

  void _addPoint() {
    // In a real app, this would be triggered by tapping on the map
    // and would include actual latitude/longitude coordinates
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tap to add boundary points')),
    );
  }

  Future<void> _saveBoundary() async {
    if (_drawingPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Need at least 3 points')),
      );
      return;
    }

    try {
      await ref
          .read(fieldMapServiceProvider)
          .saveBoundary(widget.field.id, _drawingPoints);
      setState(() => _isDrawing = false);
      ref.invalidate(_fieldBoundaryProvider(widget.field.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boundary saved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }
}

class FieldMapPainter extends CustomPainter {
  FieldMapPainter({required this.points});

  final List<GeoPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = AppColors.accent.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    if (points.length > 1) {
      final path = Path();
      // Convert GeoPoints to screen coordinates
      // This is simplified - real app would use proper map projection
      for (int i = 0; i < points.length; i++) {
        final p = points[i];
        final x = (p.latitude + 90) * (size.width / 180);
        final y = (p.longitude + 180) * (size.height / 360);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, paint);

      // Draw points
      for (final point in points) {
        final x = (point.latitude + 90) * (size.width / 180);
        final y = (point.longitude + 180) * (size.height / 360);
        canvas.drawCircle(Offset(x, y), 6, paint);
      }
    }
  }

  @override
  bool shouldRepaint(FieldMapPainter oldDelegate) =>
      points.length != oldDelegate.points.length;
}
