import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/booking.dart';
import '../../models/guest.dart';
import '../../state/data_providers.dart';
import '../../widgets/status_badge.dart';
import 'guest_form_dialog.dart';

class GuestsScreen extends ConsumerStatefulWidget {
  const GuestsScreen({super.key});

  @override
  ConsumerState<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends ConsumerState<GuestsScreen> {
  final _searchController = TextEditingController();
  String? _query;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guests = ref.watch(guestsControllerProvider);
    final bookings = ref.watch(bookingsControllerProvider).asData?.value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add guest',
            onPressed: () => _addOrEdit(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search guests',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: guests.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load guests: $e')),
              data: (list) {
                final query = _query?.trim().toLowerCase() ?? '';
                final visible = query.isEmpty
                    ? list
                    : list
                        .where((g) =>
                            g.fullName.toLowerCase().contains(query) ||
                            (g.contactEmail?.toLowerCase().contains(query) ??
                                false))
                        .toList();
                if (visible.isEmpty) {
                  return const Center(child: Text('No guests found.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final guest = visible[index];
                    final history = bookings
                        .where((b) => b.guestId == guest.id)
                        .toList();
                    return _GuestCard(
                      guest: guest,
                      history: history,
                      onEdit: () => _addOrEdit(context, ref, guest: guest),
                      onDelete: () => _delete(context, ref, guest),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addOrEdit(BuildContext context, WidgetRef ref, {Guest? guest}) async {
    final result = await showGuestFormDialog(context, guest: guest);
    if (result == null) return;
    try {
      final controller = ref.read(guestsControllerProvider.notifier);
      if (guest == null) {
        await controller.create(
          fullName: result.fullName,
          contactEmail: result.contactEmail,
          contactPhone: result.contactPhone,
          idNumber: result.idNumber,
        );
      } else {
        await controller.save(guest.copyWith(
          fullName: result.fullName,
          contactEmail: result.contactEmail,
          contactPhone: result.contactPhone,
          idNumber: result.idNumber,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Guest guest) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete guest?'),
        content: Text('${guest.fullName} will be permanently removed. '
            'Guests with bookings cannot be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(guestsControllerProvider.notifier).remove(guest.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }
}

class _GuestCard extends StatelessWidget {
  const _GuestCard({
    required this.guest,
    required this.history,
    required this.onEdit,
    required this.onDelete,
  });

  final Guest guest;
  final List<Booking> history;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    return Card(
      child: ExpansionTile(
        title: Text(guest.fullName),
        subtitle: Text([
          if (guest.contactEmail != null) guest.contactEmail!,
          if (guest.contactPhone != null) guest.contactPhone!,
          if (guest.idNumber != null) 'ID: ${guest.idNumber}',
        ].join(' · ')),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: onDelete,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: history.isEmpty
                  ? const [Text('No bookings yet.')]
                  : [
                      Text(
                        'Booking history (${history.length})',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      for (final b in history)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Room ${b.roomNumber ?? '—'} · '
                                  '${dateFormat.format(b.checkInDate)} → '
                                  '${dateFormat.format(b.checkOutDate)}',
                                ),
                              ),
                              StatusBadge(status: b.status.wire),
                            ],
                          ),
                        ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}
