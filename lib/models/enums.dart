// Wire values mirror the Postgres enums in supabase/migrations/0001_schema.sql.

enum RoomStatus {
  available,
  occupied,
  cleaning,
  outOfService;

  String get wire => switch (this) {
        RoomStatus.available => 'available',
        RoomStatus.occupied => 'occupied',
        RoomStatus.cleaning => 'cleaning',
        RoomStatus.outOfService => 'out_of_service',
      };

  static RoomStatus fromWire(String value) => switch (value) {
        'occupied' => RoomStatus.occupied,
        'cleaning' => RoomStatus.cleaning,
        'out_of_service' => RoomStatus.outOfService,
        _ => RoomStatus.available,
      };
}

enum BookingStatus {
  booked,
  checkedIn,
  checkedOut,
  cancelled;

  String get wire => switch (this) {
        BookingStatus.booked => 'booked',
        BookingStatus.checkedIn => 'checked_in',
        BookingStatus.checkedOut => 'checked_out',
        BookingStatus.cancelled => 'cancelled',
      };

  static BookingStatus fromWire(String value) => switch (value) {
        'checked_in' => BookingStatus.checkedIn,
        'checked_out' => BookingStatus.checkedOut,
        'cancelled' => BookingStatus.cancelled,
        _ => BookingStatus.booked,
      };
}

enum PaymentStatus {
  unpaid,
  paid;

  String get wire => switch (this) {
        PaymentStatus.unpaid => 'unpaid',
        PaymentStatus.paid => 'paid',
      };

  static PaymentStatus fromWire(String value) => switch (value) {
        'paid' => PaymentStatus.paid,
        _ => PaymentStatus.unpaid,
      };
}

enum StaffRole {
  admin,
  frontDesk;

  String get wire => switch (this) {
        StaffRole.admin => 'admin',
        StaffRole.frontDesk => 'front_desk',
      };

  static StaffRole fromWire(String value) => switch (value) {
        'admin' => StaffRole.admin,
        _ => StaffRole.frontDesk,
      };
}
