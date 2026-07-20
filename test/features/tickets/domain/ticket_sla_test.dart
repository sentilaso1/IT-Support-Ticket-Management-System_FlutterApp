import 'package:flutter_test/flutter_test.dart';
import 'package:it_ticket_support_management/core/enums/sla_status.dart';
import 'package:it_ticket_support_management/features/tickets/domain/entities/ticket.dart';

void main() {
  group('Ticket resolution SLA', () {
    final createdAt = DateTime(2026, 7, 17, 8);
    final dueAt = DateTime(2026, 7, 18, 8);

    test('is on track before 75 percent of the deadline', () {
      final ticket = _ticket(createdAt: createdAt, resolutionDueAt: dueAt);

      expect(
        ticket.resolutionSlaStatusAt(DateTime(2026, 7, 18, 1, 59)),
        SlaStatus.onTrack,
      );
    });

    test('is at risk after 75 percent of the deadline', () {
      final ticket = _ticket(createdAt: createdAt, resolutionDueAt: dueAt);

      expect(
        ticket.resolutionSlaStatusAt(DateTime(2026, 7, 18, 2)),
        SlaStatus.atRisk,
      );
    });

    test('is breached at the deadline', () {
      final ticket = _ticket(createdAt: createdAt, resolutionDueAt: dueAt);

      expect(ticket.resolutionSlaStatusAt(dueAt), SlaStatus.breached);
    });

    test('keeps met result after on-time resolution', () {
      final ticket = _ticket(
        createdAt: createdAt,
        resolutionDueAt: dueAt,
        status: 'Resolved',
        slaCompletedAt: DateTime(2026, 7, 18, 7, 30),
      );

      expect(
        ticket.resolutionSlaStatusAt(DateTime(2026, 7, 19)),
        SlaStatus.met,
      );
    });

    test('keeps breached result after late resolution', () {
      final ticket = _ticket(
        createdAt: createdAt,
        resolutionDueAt: dueAt,
        status: 'Resolved',
        slaCompletedAt: DateTime(2026, 7, 18, 9),
      );

      expect(
        ticket.resolutionSlaStatusAt(DateTime(2026, 7, 19)),
        SlaStatus.breachedResolved,
      );
    });

    test('cancelled ticket is exempt', () {
      final ticket = _ticket(
        createdAt: createdAt,
        resolutionDueAt: dueAt,
        status: 'Cancelled',
      );

      expect(
        ticket.resolutionSlaStatusAt(DateTime(2026, 7, 19)),
        SlaStatus.exempt,
      );
    });
  });

  group('Ticket response SLA', () {
    test('uses the first assignment as the response milestone', () {
      final ticket = _ticket(
        createdAt: DateTime(2026, 7, 17, 8),
        responseDueAt: DateTime(2026, 7, 17, 12),
        firstRespondedAt: DateTime(2026, 7, 17, 10),
      );

      expect(ticket.responseSlaStatusAt(DateTime(2026, 7, 18)), SlaStatus.met);
    });

    test('reports a late first response', () {
      final ticket = _ticket(
        createdAt: DateTime(2026, 7, 17, 8),
        responseDueAt: DateTime(2026, 7, 17, 12),
        firstRespondedAt: DateTime(2026, 7, 17, 13),
      );

      expect(
        ticket.responseSlaStatusAt(DateTime(2026, 7, 18)),
        SlaStatus.breachedResolved,
      );
    });
  });
}

Ticket _ticket({
  required DateTime createdAt,
  DateTime? responseDueAt,
  DateTime? resolutionDueAt,
  DateTime? firstRespondedAt,
  DateTime? slaCompletedAt,
  String status = 'Submitted',
}) {
  return Ticket(
    title: 'VPN issue',
    description: 'Cannot connect to the company VPN.',
    status: status,
    createdAt: createdAt,
    responseDueAt: responseDueAt,
    resolutionDueAt: resolutionDueAt,
    firstRespondedAt: firstRespondedAt,
    slaCompletedAt: slaCompletedAt,
  );
}
