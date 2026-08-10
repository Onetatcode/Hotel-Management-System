import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/enums.dart';
import '../models/room.dart';

class RoomsService {
  RoomsService({this._client});

  final SupabaseClient? _client;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  Future<List<Room>> listRooms() async {
    final rows = await _supabase.from('rooms').select().order('room_number');
    return rows.map((r) => Room.fromJson(r)).toList();
  }

  Future<Room> createRoom({
    required String roomNumber,
    required String roomType,
    required double ratePerNight,
    required int capacity,
  }) async {
    final row = await _supabase.from('rooms').insert({
      'room_number': roomNumber,
      'room_type': roomType,
      'rate_per_night': ratePerNight,
      'capacity': capacity,
    }).select().single();
    return Room.fromJson(row);
  }

  Future<Room> updateRoom(Room room) async {
    final json = room.toJson()
      ..remove('id')
      ..remove('room_number');
    final row =
        await _supabase.from('rooms').update(json).eq('id', room.id).select().single();
    return Room.fromJson(row);
  }

  Future<void> deleteRoom(String id) =>
      _supabase.from('rooms').delete().eq('id', id);

  /// Status-only change via the security-definer RPC (any staff member).
  Future<void> updateStatus(String roomId, RoomStatus status) =>
      _supabase.rpc('update_room_status', params: {
        'p_room_id': roomId,
        'p_status': status.wire,
      });
}
