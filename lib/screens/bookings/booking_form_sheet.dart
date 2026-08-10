import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/booking.dart';
import '../../models/enums.dart';
import '../../models/room.dart';
import '../../state/data_providers.dart';
import '../../state/auth_providers.dart';

/// Create/edit booking. When [booking] is null the form creates a new one.
Future<void> showBookingFormSheet(
  BuildContext context, {
  Booking? booking,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: BookingFormSheet(booking: booking),
    ),
  );
}

class BookingFormSheet extends ConsumerStatefulWidget {
  const BookingFormSheet({super.key, this.booking});

  final Booking? booking;

  @override
  ConsumerState<BookingFormSheet> createState() => _BookingFormSheetState();
}

class _BookingFormSheetState extends ConsumerState<BookingFormSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _guestId;
  String? _roomId;
  DateTime? _checkIn;
  DateTime? _checkOut;
  PaymentStatus _paymentStatus = PaymentStatus.unpaid;
  List<Room> _availableRooms = const [];
  bool _loadingRooms = false;
  bool _saving = false;

  Booking? get _editing => widget.booking;

  @override
  void initState() {
    super.initState();
    final b = _editing;
    if (b != null) {
      _guestId = b.guestId;
      _roomId = b.roomId;
      _checkIn = b.checkInDate;
      _checkOut = b.checkOutDate;
      _paymentStatus = b.paymentStatus;
    }
  }

  Future<void> _loadAvailableRooms() async {
    final inDate = _checkIn;
    final outDate = _checkOut;
    if (inDate == null || outDate == null) return;
    setState(() => _loadingRooms = true);
    try {
      final rooms = await ref
          .read(bookingsServiceProvider)
          .listAvailableRooms(inDate, outDate);
      final current = _editing;
      if (current != null &&
          !rooms.any((r) => r.id == current.roomId)) {
        final full = await ref.read(roomsServiceProvider).listRooms();
        final currentRoom =
            full.where((r) => r.id == current.roomId).toList();
        rooms.addAll(currentRoom);
      }
      setState(() {
        _availableRooms = rooms;
        if (_roomId != null &&
            !rooms.any((r) => r.id == _roomId)) {
          _roomId = null;
        }
        _loadingRooms = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingRooms = false);
    }
  }

  Future<void> _pickDate({required bool isCheckIn}) async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day);
    final initial = isCheckIn
        ? (_checkIn ?? first)
        : (_checkOut ?? (_checkIn ?? first).add(const Duration(days: 1)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: isCheckIn ? first : (_checkIn ?? first).add(const Duration(days: 1)),
      lastDate: first.add(const Duration(days: 365 * 2)),
      helpText: isCheckIn ? 'Check-in date' : 'Check-out date',
    );
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        if (_checkOut != null && !_checkOut!.isAfter(_checkIn!)) {
          _checkOut = _checkIn!.add(const Duration(days: 1));
        }
      } else {
        _checkOut = picked;
      }
    });
    await _loadAvailableRooms();
  }

  double? get _computedTotal {
    final room = _availableRooms.where((r) => r.id == _roomId).firstOrNull;
    if (room == null || _checkIn == null || _checkOut == null) return null;
    final nights = _checkOut!.difference(_checkIn!).inDays;
    if (nights <= 0) return null;
    return room.ratePerNight * nights;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final total = _computedTotal;
    if (total == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select check-in, check-out and a room.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final controller = ref.read(bookingsControllerProvider.notifier);
      final editing = _editing;
      if (editing == null) {
        final profile = ref.read(staffProfileProvider).asData?.value;
        await controller.create(
          roomId: _roomId!,
          guestId: _guestId!,
          checkInDate: _checkIn!,
          checkOutDate: _checkOut!,
          totalPrice: total,
          createdBy: profile?.id,
        );
      } else {
        await controller.save(editing.copyWith(
          roomId: _roomId,
          guestId: _guestId,
          checkInDate: _checkIn,
          checkOutDate: _checkOut,
          totalPrice: total,
          paymentStatus: _paymentStatus,
        ));
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final guests = ref.watch(guestsControllerProvider);
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _editing == null ? 'New Booking' : 'Edit Booking',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              guests.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Failed to load guests: $e'),
                data: (list) => DropdownButtonFormField<String>(
                  initialValue: _guestId,
                  decoration: const InputDecoration(labelText: 'Guest'),
                  items: list
                      .map((g) => DropdownMenuItem(
                            value: g.id,
                            child: Text(g.fullName),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _guestId = v),
                  validator: (v) => v == null ? 'Select a guest' : null,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(isCheckIn: true),
                      child: Text(
                        _checkIn == null
                            ? 'Check-in'
                            : dateFormat.format(_checkIn!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(isCheckIn: false),
                      child: Text(
                        _checkOut == null
                            ? 'Check-out'
                            : dateFormat.format(_checkOut!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _roomId,
                decoration: InputDecoration(
                  labelText: 'Room',
                  suffixIcon: _loadingRooms
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
                items: _availableRooms
                    .map((r) => DropdownMenuItem(
                          value: r.id,
                          child: Text(
                            '${r.roomNumber} — ${r.roomType} (\$${r.ratePerNight.toStringAsFixed(2)}/night)',
                          ),
                        ))
                    .toList(),
                onChanged: _loadingRooms
                    ? null
                    : (v) => setState(() => _roomId = v),
              ),
              const SizedBox(height: 8),
              Text(
                _checkIn == null || _checkOut == null
                    ? 'Pick dates to see available rooms.'
                    : _availableRooms.isEmpty && !_loadingRooms
                        ? 'No rooms available for the selected dates.'
                        : 'Showing rooms free for the selected dates.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (_computedTotal != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Total: \$${_computedTotal!.toStringAsFixed(2)}'
                  ' (${_checkOut!.difference(_checkIn!).inDays} nights)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<PaymentStatus>(
                initialValue: _paymentStatus,
                decoration: const InputDecoration(labelText: 'Payment'),
                items: PaymentStatus.values
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.wire.replaceAll('_', ' ')),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _paymentStatus = v ?? _paymentStatus),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_editing == null ? 'Create Booking' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
