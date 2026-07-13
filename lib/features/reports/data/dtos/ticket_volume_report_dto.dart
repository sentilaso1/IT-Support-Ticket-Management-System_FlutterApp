class TicketVolumeReportDto {
  final String date;
  final int totalTickets;
  final int resolvedTickets;
  final int pendingTickets;

  TicketVolumeReportDto({
    required this.date,
    required this.totalTickets,
    required this.resolvedTickets,
    required this.pendingTickets,
  });

  // Factory constructor để map dữ liệu từ SQLite
  factory TicketVolumeReportDto.fromMap(Map<String, dynamic> map) {
    return TicketVolumeReportDto(
      date: map['date'] as String? ?? '',
      totalTickets: map['total_tickets'] as int? ?? 0,
      resolvedTickets: map['resolved_tickets'] as int? ?? 0,
      pendingTickets: map['pending_tickets'] as int? ?? 0,
    );
  }
}