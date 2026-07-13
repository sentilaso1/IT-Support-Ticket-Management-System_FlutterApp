class TicketVolumeReport {
  final String date;
  final int totalTickets;
  final int resolvedTickets;
  final int pendingTickets;

  TicketVolumeReport({
    required this.date,
    required this.totalTickets,
    required this.resolvedTickets,
    required this.pendingTickets,
  });
}