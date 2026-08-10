import 'enums.dart';

class Room {
  const Room({
    required this.id,
    required this.roomNumber,
    required this.roomType,
    required this.ratePerNight,
    required this.capacity,
    required this.status,
  });

  final String id;
  final String roomNumber;
  final String roomType;
  final double ratePerNight;
  final int capacity;
  final RoomStatus status;

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        id: json['id'] as String,
        roomNumber: json['room_number'] as String,
        roomType: json['room_type'] as String,
        ratePerNight: (json['rate_per_night'] as num).toDouble(),
        capacity: json['capacity'] as int,
        status: RoomStatus.fromWire(json['status'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'room_number': roomNumber,
        'room_type': roomType,
        'rate_per_night': ratePerNight,
        'capacity': capacity,
        'status': status.wire,
      };

  /// Mutable-field copy (id/room_number stay fixed).
  Room copyWith({
    String? roomType,
    double? ratePerNight,
    int? capacity,
    RoomStatus? status,
  }) =>
      Room(
        id: id,
        roomNumber: roomNumber,
        roomType: roomType ?? this.roomType,
        ratePerNight: ratePerNight ?? this.ratePerNight,
        capacity: capacity ?? this.capacity,
        status: status ?? this.status,
      );
}
