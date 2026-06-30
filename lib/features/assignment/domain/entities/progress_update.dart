class ProgressUpdate {
  const ProgressUpdate({
    required this.id,
    required this.ticketId,
    required this.staffId,
    required this.message,
    this.progressPercent,
    required this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int ticketId;
  final int staffId;
  final String message;
  final int? progressPercent;
  final DateTime createdAt;
  final DateTime? updatedAt;
}
