import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';

class AddLivestockScreen extends ConsumerStatefulWidget {
  const AddLivestockScreen({super.key});

  @override
  ConsumerState<AddLivestockScreen> createState() => _AddLivestockScreenState();
}

class _AddLivestockScreenState extends ConsumerState<AddLivestockScreen> {
  final _form = GlobalKey<FormState>();
  final _batchCodeCtrl = TextEditingController();
  final _animalTypeCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  DateTime? _birthDate;
  DateTime? _acquisitionDate;
  DateTime? _harvestDate;
  String _status = 'active';
  bool _loading = false;

  @override
  void dispose() {
    _batchCodeCtrl.dispose();
    _animalTypeCtrl.dispose();
    _breedCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final qty = int.parse(_quantityCtrl.text.trim());
      await ref.read(livestockServiceProvider).create({
        'batch_code': _batchCodeCtrl.text.trim(),
        'animal_type': _animalTypeCtrl.text.trim(),
        'breed': _breedCtrl.text.trim(),
        'initial_quantity': qty,
        'current_quantity': qty,
        'status': _status,
        if (_birthDate != null) 'birth_date': _birthDate!.toIso8601String(),
        if (_acquisitionDate != null)
          'acquisition_date': _acquisitionDate!.toIso8601String(),
        if (_harvestDate != null)
          'expected_harvest_date': _harvestDate!.toIso8601String(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate(String label, Function(DateTime) onPicked) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (d != null) onPicked(d);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Livestock Batch')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _batchCodeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Batch Code *',
                  hintText: 'e.g. BC-2026-001',
                ),
                validator: (v) => Validators.required(v, label: 'Batch code'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _animalTypeCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Animal Type *'),
                      validator: (v) =>
                          Validators.required(v, label: 'Animal type'),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _breedCtrl,
                      decoration: const InputDecoration(labelText: 'Breed *'),
                      validator: (v) => Validators.required(v, label: 'Breed'),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityCtrl,
                decoration:
                    const InputDecoration(labelText: 'Initial Quantity *'),
                keyboardType: TextInputType.number,
                validator: (v) => Validators.positiveNumber(v, label: 'Quantity'),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['active', 'sold', 'harvested', 'deceased']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Dates', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              _DatePicker(
                label: 'Birth Date',
                value: _birthDate,
                onPicked: (d) => setState(() => _birthDate = d),
              ),
              const SizedBox(height: 8),
              _DatePicker(
                label: 'Acquisition Date',
                value: _acquisitionDate,
                onPicked: (d) => setState(() => _acquisitionDate = d),
              ),
              const SizedBox(height: 8),
              _DatePicker(
                label: 'Expected Harvest Date',
                value: _harvestDate,
                onPicked: (d) => setState(() => _harvestDate = d),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save Batch'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  const _DatePicker({
    required this.label,
    required this.value,
    required this.onPicked,
  });

  final String label;
  final DateTime? value;
  final Function(DateTime) onPicked;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2035),
        );
        if (d != null) onPicked(d);
      },
      icon: const Icon(Icons.calendar_today_rounded, size: 16),
      label: Text(value != null ? '$label: ${Fmt.date(value)}' : label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
