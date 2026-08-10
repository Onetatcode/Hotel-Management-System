import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/booking.dart';
import '../models/enums.dart';
import '../models/guest.dart';
import '../models/room.dart';
import '../services/bookings_service.dart';
import '../services/guests_service.dart';
import '../services/rooms_service.dart';

final roomsServiceProvider = Provider<RoomsService>((ref) {
  return RoomsService(client: Supabase.instance.client);
});

final guestsServiceProvider = Provider<GuestsService>((ref) {
  return GuestsService(client: Supabase.instance.client);
});

final bookingsServiceProvider = Provider<BookingsService>((ref) {
  return BookingsService(client: Supabase.instance.client);
});

// ---------- Rooms ----------

final roomsControllerProvider =
    AsyncNotifierProvider<RoomsController, List<Room>>(RoomsController.new);

class RoomsController extends AsyncNotifier<List<Room>> {
  @override
  Future<List<Room>> build() => ref.watch(roomsServiceProvider).listRooms();

  Future<void> create({
    required String roomNumber,
    required String roomType,
    required double ratePerNight,
    required int capacity,
  }) async {
    await ref.read(roomsServiceProvider).createRoom(
          roomNumber: roomNumber,
          roomType: roomType,
          ratePerNight: ratePerNight,
          capacity: capacity,
        );
    ref.invalidateSelf();
  }

  Future<void> save(Room room) async {
    await ref.read(roomsServiceProvider).updateRoom(room);
    ref.invalidateSelf();
  }

  Future<void> remove(String id) async {
    await ref.read(roomsServiceProvider).deleteRoom(id);
    ref.invalidateSelf();
  }

  Future<void> setStatus(String roomId, RoomStatus status) async {
    await ref.read(roomsServiceProvider).updateStatus(roomId, status);
    ref.invalidateSelf();
  }
}

// ---------- Guests ----------

final guestsControllerProvider =
    AsyncNotifierProvider<GuestsController, List<Guest>>(GuestsController.new);

class GuestsController extends AsyncNotifier<List<Guest>> {
  @override
  Future<List<Guest>> build() => ref.watch(guestsServiceProvider).listGuests();

  Future<void> create({
    required String fullName,
    String? contactEmail,
    String? contactPhone,
    String? idNumber,
  }) async {
    await ref.read(guestsServiceProvider).createGuest(
          fullName: fullName,
          contactEmail: contactEmail,
          contactPhone: contactPhone,
          idNumber: idNumber,
        );
    ref.invalidateSelf();
  }

  Future<void> save(Guest guest) async {
    await ref.read(guestsServiceProvider).updateGuest(guest);
    ref.invalidateSelf();
  }

  Future<void> remove(String id) async {
    await ref.read(guestsServiceProvider).deleteGuest(id);
    ref.invalidateSelf();
  }
}

// ---------- Bookings ----------

final bookingsControllerProvider =
    AsyncNotifierProvider<BookingsController, List<Booking>>(BookingsController.new);

class BookingsController extends AsyncNotifier<List<Booking>> {
  @override
  Future<List<Booking>> build() =>
      ref.watch(bookingsServiceProvider).listBookings();

  Future<void> create({
    required String roomId,
    required String guestId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required double totalPrice,
    String? createdBy,
  }) async {
    await ref.read(bookingsServiceProvider).createBooking(
          roomId: roomId,
          guestId: guestId,
          checkInDate: checkInDate,
          checkOutDate: checkOutDate,
          totalPrice: totalPrice,
          createdBy: createdBy,
        );
    ref.invalidateSelf();
  }

  Future<void> save(Booking booking) async {
    await ref.read(bookingsServiceProvider).updateBooking(booking);
    ref.invalidateSelf();
  }

  Future<void> cancel(Booking booking) async {
    await ref.read(bookingsServiceProvider).cancelBooking(booking);
    ref.invalidateSelf();
  }

  Future<void> checkIn(Booking booking) async {
    await ref.read(bookingsServiceProvider).checkInBooking(booking);
    ref.invalidateSelf();
  }

  Future<void> checkOut(Booking booking) async {
    await ref.read(bookingsServiceProvider).checkOutBooking(booking);
    ref.invalidateSelf();
  }
}

// ---------- Derived ----------

/// Filtered view of all bookings (client-side, backed by the controller).
final filteredBookingsProvider = Provider.family<List<Booking>, BookingFilter>(
  (ref, filter) {
    final bookings = ref.watch(bookingsControllerProvider).asData?.value ?? const [];
    return bookings.where(filter.matches).toList();
  },
);

class BookingFilter {
  const BookingFilter({this.status, this.guestQuery, this.checkInDate});

  final BookingStatus? status;
  final String? guestQuery;
  final DateTime? checkInDate;

  bool matches(Booking booking) {
    if (status != null && booking.status != status) return false;
    final query = guestQuery?.trim().toLowerCase();
    if (query != null &&
        query.isNotEmpty &&
        !(booking.guestName?.toLowerCase().contains(query) ?? false)) {
      return false;
    }
    if (checkInDate != null &&
        !booking.checkInDate.isAtSameMomentAs(checkInDate!)) {
      return false;
    }
    return true;
  }
}
