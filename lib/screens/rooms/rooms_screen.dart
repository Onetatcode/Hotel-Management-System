import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/enums.dart';
import '../../models/room.dart';
import '../../state/auth_providers.dart';
import '../../state/data_providers.dart';
import '../../widgets/error_state.dart';
import '../../widgets/status_badge.dart';
import 'room_form_dialog.dart';

class RoomsScreen extends ConsumerWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(roomsControllerProvider);
    final profile = ref.watch(staffProfileProvider);
    final isAdmin = profile.asData?.value?.isAdmin ?? false;
    final controller = ref.read(roomsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.refresh(roomsControllerProvider),
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add room',
              onPressed: () => _addRoom(context, ref),
            ),
        ],
      ),
      body: rooms.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(
          message: 'Failed to load rooms.',
          onRetry: () => ref.refresh(roomsControllerProvider.future),
        ),
        data: (list) => list.isEmpty
            ? const Center(child: Text('No rooms yet — add one with + .'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final room = list[index];
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
                                  'Room ${room.roomNumber}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              StatusBadge(status: room.status.wire),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('${room.roomType} · Capacity ${room.capacity}'),
                          Text(
                            '\$${room.ratePerNight.toStringAsFixed(2)} / night',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              DropdownButton<RoomStatus>(
                                value: room.status,
                                isDense: true,
                                onChanged: (value) {
                                  if (value != null) {
                                    controller.setStatus(room.id, value);
                                  }
                                },
                                items: RoomStatus.values
                                    .map((s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s.wire.replaceAll('_', ' ')),
                                        ))
                                    .toList(),
                              ),
                              if (isAdmin) ...[
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: 'Edit',
                                  onPressed: () => _editRoom(context, ref, room),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Delete',
                                  onPressed: () => _deleteRoom(context, ref, room),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _addRoom(BuildContext context, WidgetRef ref) async {
    final result = await showRoomFormDialog(context);
    if (result == null) return;
    try {
      await ref.read(roomsControllerProvider.notifier).create(
            roomNumber: result.roomNumber,
            roomType: result.roomType,
            ratePerNight: result.ratePerNight,
            capacity: result.capacity,
          );
    } catch (e) {
      if (context.mounted) _showError(context, 'Add failed: $e');
    }
  }

  Future<void> _editRoom(BuildContext context, WidgetRef ref, Room room) async {
    final result = await showRoomFormDialog(context, room: room);
    if (result == null) return;
    try {
      await ref.read(roomsControllerProvider.notifier).save(room.copyWith(
            roomType: result.roomType,
            ratePerNight: result.ratePerNight,
            capacity: result.capacity,
            status: result.status,
          ));
    } catch (e) {
      if (context.mounted) _showError(context, 'Update failed: $e');
    }
  }

  Future<void> _deleteRoom(BuildContext context, WidgetRef ref, Room room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete room?'),
        content: Text('Room ${room.roomNumber} will be permanently removed. '
            'Rooms with bookings cannot be deleted.'),
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
      await ref.read(roomsControllerProvider.notifier).remove(room.id);
    } catch (e) {
      if (context.mounted) _showError(context, 'Delete failed: $e');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
