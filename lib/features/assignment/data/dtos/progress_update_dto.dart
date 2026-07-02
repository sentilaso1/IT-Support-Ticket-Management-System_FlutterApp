class ProgressUpdateDto {
  const ProgressUpdateDto({
    this.id,
    required this.ticketId,
    required this.staffId,
    required this.message,
    required this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int ticketId;
  final int staffId;
  final String message;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory ProgressUpdateDto.fromMap(Map<String, Object?> map) {
    return ProgressUpdateDto(
      id: map['id'] as int?,
      ticketId: map['ticketId'] as int,
      staffId: map['staffId'] as int,
      message: map['message'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] == null
          ? null
          : DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'ticketId': ticketId,
      'staffId': staffId,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
