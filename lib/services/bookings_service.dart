import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/booking.dart';
import '../models/enums.dart';
import '../models/room.dart';

class BookingsService {
  BookingsService({this._client});

  final SupabaseClient? _client;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  static String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static const _joinSelect = '*, rooms(room_number), guests(full_name)';

  Future<List<Booking>> listBookings() async {
    final rows = await _supabase
        .from('bookings')
        .select(_joinSelect)
        .order('check_in_date', ascending: false);
    return rows.map((b) => Booking.fromJson(b)).toList();
  }

  Future<Booking> createBooking({
    required String roomId,
    required String guestId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required double totalPrice,
    String? createdBy,
  }) async {
    final row = await _supabase.from('bookings').insert({
      'room_id': roomId,
      'guest_id': guestId,
      'check_in_date': _dateOnly(checkInDate),
      'check_out_date': _dateOnly(checkOutDate),
      'total_price': totalPrice,
      'created_by': createdBy,
    }).select(_joinSelect).single();
    return Booking.fromJson(row);
  }

  Future<Booking> updateBooking(Booking booking) async {
    final json = booking.toJson()
      ..remove('id')
      ..remove('created_by');
    final row = await _supabase
        .from('bookings')
        .update(json)
        .eq('id', booking.id)
        .select(_joinSelect)
        .single();
    return Booking.fromJson(row);
  }

  /// Marks the booking cancelled; frees the room if it was checked in.
  Future<void> cancelBooking(Booking booking) async {
    await _supabase
        .from('bookings')
        .update({'status': BookingStatus.cancelled.wire})
        .eq('id', booking.id);
    if (booking.status == BookingStatus.checkedIn) {
      await _supabase
          .rpc('update_room_status', params: {
            'p_room_id': booking.roomId,
            'p_status': RoomStatus.available.wire,
          });
    }
  }

  /// Check-in: booking -> checked_in, room -> occupied.
  Future<void> checkInBooking(Booking booking) async {
    await _supabase
        .from('bookings')
        .update({'status': BookingStatus.checkedIn.wire})
        .eq('id', booking.id);
    await _supabase
        .rpc('update_room_status', params: {
          'p_room_id': booking.roomId,
          'p_status': RoomStatus.occupied.wire,
        });
  }

  /// Check-out: booking -> checked_out, room -> cleaning (housekeeping
  /// will flip it back to available).
  Future<void> checkOutBooking(Booking booking) async {
    await _supabase
        .from('bookings')
        .update({'status': BookingStatus.checkedOut.wire})
        .eq('id', booking.id);
    await _supabase
        .rpc('update_room_status', params: {
          'p_room_id': booking.roomId,
          'p_status': RoomStatus.cleaning.wire,
        });
  }

  /// Rooms that have no active booking overlapping [checkInDate, checkOutDate)
  /// and are not physically out of service. Active bookings are those with
  /// status booked or checked_in.
  Future<List<Room>> listAvailableRooms(
    DateTime checkInDate,
    DateTime checkOutDate,
  ) async {
    final [rooms, active] = await Future.wait([
      _supabase.from('rooms').select().order('room_number'),
      _supabase
          .from('bookings')
          .select('room_id')
          .inFilter('status', ['booked', 'checked_in'])
          .lt('check_in_date', _dateOnly(checkOutDate))
          .gt('check_out_date', _dateOnly(checkInDate)),
    ]);
    final blocked = active.map((b) => b['room_id'] as String).toSet();
    return rooms
        .map((r) => Room.fromJson(r))
        .where((room) =>
            room.status != RoomStatus.outOfService && !blocked.contains(room.id))
        .toList();
  }
}
