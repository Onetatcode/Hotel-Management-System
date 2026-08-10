import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/booking.dart';
import '../../models/enums.dart';
import '../../state/data_providers.dart';
import '../../widgets/status_badge.dart';
import 'booking_form_sheet.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  BookingStatus? _statusFilter;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(bookingsControllerProvider);
    final filter = BookingFilter(
      status: _statusFilter,
      guestQuery: _searchController.text,
    );
    final visible = ref.watch(filteredBookingsProvider(filter));
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showBookingFormSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('New Booking'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by guest',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                _filterChip(context, null, 'All'),
                for (final status in BookingStatus.values)
                  _filterChip(context, status, status.wire.replaceAll('_', ' ')),
              ],
            ),
          ),
          Expanded(
            child: bookings.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load bookings: $e')),
              data: (_) => visible.isEmpty
                  ? const Center(child: Text('No bookings match the filters.'))
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.refresh(bookingsControllerProvider.future),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _BookingCard(
                          booking: visible[index],
                          dateFormat: dateFormat,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(BuildContext context, BookingStatus? status, String label) {
    final selected = _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _statusFilter = status),
      ),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  const _BookingCard({required this.booking, required this.dateFormat});

  final Booking booking;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(bookingsControllerProvider.notifier);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.guestName ?? 'Guest',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                StatusBadge(status: booking.status.wire),
              ],
            ),
            const SizedBox(height: 8),
            Text('Room ${booking.roomNumber ?? '—'}'),
            Text(
              '${dateFormat.format(booking.checkInDate)} → '
              '${dateFormat.format(booking.checkOutDate)} '
              '(${booking.nights} nights)',
            ),
            Text('\$${booking.totalPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(status: booking.paymentStatus.wire),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (booking.status == BookingStatus.booked) ...[
                  OutlinedButton(
                    onPressed: () => _run(
                      context,
                      () => controller.checkIn(booking),
                    ),
                    child: const Text('Check In'),
                  ),
                  OutlinedButton(
                    onPressed: () => _run(
                      context,
                      () => controller.cancel(booking),
                    ),
                    child: const Text('Cancel'),
                  ),
                  OutlinedButton(
                    onPressed: () => showBookingFormSheet(context, booking: booking),
                    child: const Text('Edit'),
                  ),
                ],
                if (booking.status == BookingStatus.checkedIn) ...[
                  FilledButton(
                    onPressed: () => _run(
                      context,
                      () => controller.checkOut(booking),
                    ),
                    child: const Text('Check Out'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action failed: $e')),
        );
      }
    }
  }
}
