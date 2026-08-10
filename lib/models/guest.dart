class Guest {
  const Guest({
    required this.id,
    required this.fullName,
    this.contactEmail,
    this.contactPhone,
    this.idNumber,
  });

  final String id;
  final String fullName;
  final String? contactEmail;
  final String? contactPhone;
  final String? idNumber;

  factory Guest.fromJson(Map<String, dynamic> json) => Guest(
        id: json['id'] as String,
        fullName: json['full_name'] as String,
        contactEmail: json['contact_email'] as String?,
        contactPhone: json['contact_phone'] as String?,
        idNumber: json['id_number'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'contact_email': contactEmail,
        'contact_phone': contactPhone,
        'id_number': idNumber,
      };

  Guest copyWith({
    String? fullName,
    String? contactEmail,
    String? contactPhone,
    String? idNumber,
  }) =>
      Guest(
        id: id,
        fullName: fullName ?? this.fullName,
        contactEmail: contactEmail ?? this.contactEmail,
        contactPhone: contactPhone ?? this.contactPhone,
        idNumber: idNumber ?? this.idNumber,
      );
}
