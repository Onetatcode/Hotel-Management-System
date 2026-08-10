import 'enums.dart';

class Booking {
  const Booking({
    required this.id,
    required this.roomId,
    required this.guestId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.status,
    required this.totalPrice,
    required this.paymentStatus,
    this.createdBy,
    this.createdAt,
    this.roomNumber,
    this.guestName,
  });

  final String id;
  final String roomId;
  final String guestId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final BookingStatus status;
  final double totalPrice;
  final PaymentStatus paymentStatus;
  final String? createdBy;
  final DateTime? createdAt;
  final String? roomNumber;
  final String? guestName;

  int get nights => checkOutDate.difference(checkInDate).inDays;

  factory Booking.fromJson(Map<String, dynamic> json) {
    final room = json['rooms'] as Map<String, dynamic>?;
    final guest = json['guests'] as Map<String, dynamic>?;
    return Booking(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      guestId: json['guest_id'] as String,
      checkInDate: DateTime.parse(json['check_in_date'] as String),
      checkOutDate: DateTime.parse(json['check_out_date'] as String),
      status: BookingStatus.fromWire(json['status'] as String),
      totalPrice: (json['total_price'] as num).toDouble(),
      paymentStatus: PaymentStatus.fromWire(json['payment_status'] as String),
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      roomNumber: room?['room_number'] as String?,
      guestName: guest?['full_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'room_id': roomId,
        'guest_id': guestId,
        'check_in_date': _dateOnly(checkInDate),
        'check_out_date': _dateOnly(checkOutDate),
        'status': status.wire,
        'total_price': totalPrice,
        'payment_status': paymentStatus.wire,
        'created_by': createdBy,
      };

  Booking copyWith({
    String? roomId,
    String? guestId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    BookingStatus? status,
    double? totalPrice,
    PaymentStatus? paymentStatus,
    String? roomNumber,
    String? guestName,
  }) =>
      Booking(
        id: id,
        roomId: roomId ?? this.roomId,
        guestId: guestId ?? this.guestId,
        checkInDate: checkInDate ?? this.checkInDate,
        checkOutDate: checkOutDate ?? this.checkOutDate,
        status: status ?? this.status,
        totalPrice: totalPrice ?? this.totalPrice,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        createdBy: createdBy,
        createdAt: createdAt,
        roomNumber: roomNumber ?? this.roomNumber,
        guestName: guestName ?? this.guestName,
      );
}

String _dateOnly(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
