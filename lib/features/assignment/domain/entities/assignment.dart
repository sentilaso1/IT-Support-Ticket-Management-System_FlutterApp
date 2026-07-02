class Assignment {
  const Assignment({
    required this.id,
    required this.ticketId,
    required this.staffId,
    this.assignedByUserId,
    required this.assignedAt,
    this.note,
    required this.isActive,
    required this.ticketTitle,
    required this.ticketDescription,
    required this.issueType,
    required this.priority,
    required this.status,
    required this.ticketCreatedAt,
    this.ticketUpdatedAt,
    this.lastProgressMessage,
  });

  final int id;
  final int ticketId;
  final int staffId;
  final int? assignedByUserId;
  final DateTime assignedAt;
  final String? note;
  final bool isActive;
  final String ticketTitle;
  final String ticketDescription;
  final String issueType;
  final String priority;
  final String status;
  final DateTime ticketCreatedAt;
  final DateTime? ticketUpdatedAt;
  final String? lastProgressMessage;

  bool get isClosed => status.toLowerCase() == 'closed';
}
