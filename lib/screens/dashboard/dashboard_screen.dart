import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/booking.dart';
import '../../models/enums.dart';
import '../../state/data_providers.dart';
import '../../widgets/error_state.dart';
import '../../widgets/info_card.dart';
import '../../widgets/status_badge.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingsControllerProvider);
    final rooms = ref.watch(roomsControllerProvider);
    final dateFormat = DateFormat('MMM d, yyyy');
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          bookings.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => const ErrorState(
              message: 'Failed to load dashboard data.',
            ),
            data: (list) {
              final arrivals = list
                  .where((b) =>
                      b.checkInDate.isAtSameMomentAs(todayDate) &&
                      b.status == BookingStatus.booked)
                  .toList();
              final departures = list
                  .where((b) =>
                      b.checkOutDate.isAtSameMomentAs(todayDate) &&
                      b.status == BookingStatus.checkedIn)
                  .toList();
              final active = list
                  .where((b) =>
                      b.status == BookingStatus.booked ||
                      b.status == BookingStatus.checkedIn)
                  .length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  rooms.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => Text(
                      'Room occupancy unavailable.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    data: (roomList) {
                      final occupied =
                          roomList.where((r) => r.status == RoomStatus.occupied).length;
                      return InfoCard(
                        icon: Icons.meeting_room_outlined,
                        title: 'Current Occupancy',
                        onTap: () => context.go('/rooms'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$occupied of ${roomList.length} rooms occupied',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: roomList.isEmpty
                                    ? 0
                                    : occupied / roomList.length,
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  InfoCard(
                    icon: Icons.login,
                    title: "Today's Arrivals (${arrivals.length})",
                    onTap: () => context.go('/bookings'),
                    child: arrivals.isEmpty
                        ? const Text('No arrivals today.')
                        : Column(
                            children: [
                              for (final b in arrivals) _row(context, b, dateFormat),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),
                  InfoCard(
                    icon: Icons.logout,
                    title: "Today's Departures (${departures.length})",
                    onTap: () => context.go('/bookings'),
                    child: departures.isEmpty
                        ? const Text('No departures today.')
                        : Column(
                            children: [
                              for (final b in departures) _row(context, b, dateFormat),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),
                  InfoCard(
                    icon: Icons.calendar_month_outlined,
                    title: 'Active Bookings',
                    onTap: () => context.go('/bookings'),
                    child: Text(
                      '$active booking(s) booked or checked in',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, Booking booking, DateFormat dateFormat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${booking.guestName ?? 'Guest'} — Room ${booking.roomNumber ?? '—'}'
              ' · ${dateFormat.format(booking.checkInDate)}',
            ),
          ),
          StatusBadge(status: booking.status.wire),
        ],
      ),
    );
  }
}
