import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/room.dart';
import '../../state/data_providers.dart';
import '../../widgets/neumorphic_card.dart';
import '../../widgets/status_badge.dart';

class AvailabilityScreen extends ConsumerStatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  ConsumerState<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends ConsumerState<AvailabilityScreen> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  List<Room>? _results;
  bool _searching = false;

  Future<void> _pickDate({required bool isCheckIn}) async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? (_checkIn ?? first)
          : (_checkOut ?? first.add(const Duration(days: 1))),
      firstDate: isCheckIn
          ? first
          : (_checkIn ?? first).add(const Duration(days: 1)),
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
  }

  Future<void> _search() async {
    final inDate = _checkIn;
    final outDate = _checkOut;
    if (inDate == null || outDate == null) return;
    setState(() => _searching = true);
    try {
      final results = await ref
          .read(bookingsServiceProvider)
          .listAvailableRooms(inDate, outDate);
      if (mounted) setState(() => _results = results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    return Scaffold(
      appBar: AppBar(title: const Text('Availability Search')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NeumorphicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                  FilledButton(
                    onPressed:
                        (_checkIn == null || _checkOut == null || _searching)
                            ? null
                            : _search,
                    child: _searching
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Search Availability'),
                  ),
                ],
              ),
          ),
          const SizedBox(height: 16),
          if (_results != null)
            _results!.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No rooms available for the selected dates.',
                      ),
                    ),
                  )
                : Text(
                    '${_results!.length} room(s) available',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
          ...?_results?.map(
            (room) => NeumorphicCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                title: Text('Room ${room.roomNumber}'),
                subtitle: Text(
                    '${room.roomType} · capacity ${room.capacity} · \$${room.ratePerNight.toStringAsFixed(2)}/night'),
                trailing: StatusBadge(status: room.status.wire),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
