import 'package:flutter_test/flutter_test.dart';

import 'package:hotelms/models/booking.dart';
import 'package:hotelms/models/enums.dart';
import 'package:hotelms/models/guest.dart';
import 'package:hotelms/models/room.dart';

void main() {
  group('Room', () {
    test('fromJson/toJson round trip', () {
      final json = {
        'id': 'r1',
        'room_number': '101',
        'room_type': 'Deluxe',
        'rate_per_night': 129.50,
        'capacity': 2,
        'status': 'available',
      };
      final room = Room.fromJson(json);
      expect(room.roomNumber, '101');
      expect(room.ratePerNight, 129.50);
      expect(room.status, RoomStatus.available);
      expect(room.toJson()['rate_per_night'], 129.5);
    });

    test('unknown status falls back to available', () {
      final room = Room.fromJson({
        'id': 'r1',
        'room_number': '101',
        'room_type': 'x',
        'rate_per_night': 10,
        'capacity': 1,
        'status': 'weird_value',
      });
      expect(room.status, RoomStatus.available);
    });

    test('copyWith only mutates provided fields', () {
      final room = Room.fromJson({
        'id': 'r1',
        'room_number': '101',
        'room_type': 'Standard',
        'rate_per_night': 80,
        'capacity': 2,
        'status': 'available',
      });
      final updated = room.copyWith(status: RoomStatus.cleaning);
      expect(updated.id, 'r1');
      expect(updated.roomNumber, '101');
      expect(updated.roomType, 'Standard');
      expect(updated.status, RoomStatus.cleaning);
    });
  });

  group('Guest', () {
    test('fromJson/toJson round trip with nulls', () {
      final guest = Guest.fromJson({
        'id': 'g1',
        'full_name': 'John Doe',
        'contact_email': null,
        'contact_phone': '+1 555',
        'id_number': null,
      });
      expect(guest.fullName, 'John Doe');
      expect(guest.contactEmail, isNull);
      expect(guest.contactPhone, '+1 555');
      expect(guest.toJson()['contact_phone'], '+1 555');
    });
  });

  group('Booking', () {
    final booking = Booking.fromJson({
      'id': 'b1',
      'room_id': 'r1',
      'guest_id': 'g1',
      'check_in_date': '2026-08-10',
      'check_out_date': '2026-08-13',
      'status': 'checked_in',
      'total_price': 388.5,
      'payment_status': 'paid',
      'created_by': 's1',
      'created_at': '2026-08-01T10:00:00Z',
      'rooms': {'room_number': '101'},
      'guests': {'full_name': 'John Doe'},
    });

    test('parses joins, dates and statuses', () {
      expect(booking.roomNumber, '101');
      expect(booking.guestName, 'John Doe');
      expect(booking.nights, 3);
      expect(booking.status, BookingStatus.checkedIn);
      expect(booking.paymentStatus, PaymentStatus.paid);
    });

    test('toJson emits schema column names and date-only strings', () {
      final json = booking.toJson();
      expect(json['check_in_date'], '2026-08-10');
      expect(json['status'], 'checked_in');
      expect(json.containsKey('room_number'), isFalse);
    });

    test('unknown booking status falls back to booked', () {
      final b = Booking.fromJson({
        'id': 'b2',
        'room_id': 'r1',
        'guest_id': 'g1',
        'check_in_date': '2026-08-10',
        'check_out_date': '2026-08-11',
        'status': 'nope',
        'total_price': 10,
        'payment_status': 'unpaid',
      });
      expect(b.status, BookingStatus.booked);
    });
  });

  group('Enums', () {
    test('wire strings match the SQL schema', () {
      expect(RoomStatus.outOfService.wire, 'out_of_service');
      expect(BookingStatus.checkedOut.wire, 'checked_out');
      expect(PaymentStatus.paid.wire, 'paid');
      expect(StaffRole.frontDesk.wire, 'front_desk');
    });
  });
}
