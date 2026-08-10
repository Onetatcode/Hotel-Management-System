import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../models/room.dart';

/// Add/edit room dialog. Admin-only entry points; the caller enforces that.
Future<
    ({
      String roomNumber,
      String roomType,
      double ratePerNight,
      int capacity,
      RoomStatus status
    })?> showRoomFormDialog(BuildContext context, {Room? room}) {
  return showDialog(
    context: context,
    builder: (_) => RoomFormDialog(room: room),
  );
}

class RoomFormDialog extends StatefulWidget {
  const RoomFormDialog({super.key, this.room});

  final Room? room;

  @override
  State<RoomFormDialog> createState() => _RoomFormDialogState();
}

class _RoomFormDialogState extends State<RoomFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _numberController;
  late final TextEditingController _typeController;
  late final TextEditingController _rateController;
  late final TextEditingController _capacityController;
  late RoomStatus _status;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final room = widget.room;
    _numberController = TextEditingController(text: room?.roomNumber ?? '');
    _typeController = TextEditingController(text: room?.roomType ?? '');
    _rateController = TextEditingController(
        text: room != null ? room.ratePerNight.toStringAsFixed(2) : '');
    _capacityController =
        TextEditingController(text: room != null ? room.capacity.toString() : '');
    _status = room?.status ?? RoomStatus.available;
  }

  @override
  void dispose() {
    _numberController.dispose();
    _typeController.dispose();
    _rateController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    Navigator.of(context).pop((
      roomNumber: _numberController.text.trim(),
      roomType: _typeController.text.trim(),
      ratePerNight: double.parse(_rateController.text.trim()),
      capacity: int.parse(_capacityController.text.trim()),
      status: _status,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.room != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit Room' : 'Add Room'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _numberController,
                enabled: !isEditing,
                decoration: const InputDecoration(labelText: 'Room number'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Room type'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(
                  labelText: 'Rate per night',
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final value = double.tryParse(v?.trim() ?? '');
                  if (value == null) return 'Enter a number';
                  if (value < 0) return 'Must be >= 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: 'Capacity'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final value = int.tryParse(v?.trim() ?? '');
                  if (value == null || value <= 0) return 'Must be > 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RoomStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: RoomStatus.values
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.wire.replaceAll('_', ' ')),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _status = value ?? _status),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
