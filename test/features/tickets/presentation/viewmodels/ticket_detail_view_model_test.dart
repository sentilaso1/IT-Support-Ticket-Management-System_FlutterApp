import 'package:flutter_test/flutter_test.dart';
import 'package:it_ticket_support_management/features/tickets/application/services/i_ticket_service.dart';
import 'package:it_ticket_support_management/features/tickets/domain/entities/ticket.dart';
import 'package:it_ticket_support_management/features/tickets/domain/entities/ticket_status_note.dart';
import 'package:it_ticket_support_management/features/tickets/presentation/viewmodels/ticket_detail_view_model.dart';

void main() {
  group('TicketDetailViewModel', () {
    test('loads the ticket and status history', () async {
      final service = _TicketService(notes: [_note()]);
      final viewModel = TicketDetailViewModel(service);

      await viewModel.loadTicket(10);

      expect(viewModel.status, TicketDetailStatus.success);
      expect(viewModel.ticket?.title, 'VPN issue');
      expect(viewModel.statusNotes.single.note, 'Assigned to network team');
    });

    test('updates status, forwards audit data, and refreshes notes', () async {
      final service = _TicketService(notes: [_note()]);
      final viewModel = TicketDetailViewModel(service);

      final success = await viewModel.updateTicketStatus(
        ticketId: 10,
        status: 'Cancelled',
        changedByUserId: 1,
        changedByRole: 'admin',
        note: 'Duplicate request',
      );

      expect(success, isTrue);
      expect(viewModel.ticket?.status, 'Cancelled');
      expect(service.changedByUserId, 1);
      expect(service.changedByRole, 'admin');
      expect(service.note, 'Duplicate request');
      expect(service.notesRequests, 1);
    });

    test('clears the loaded ticket after deletion', () async {
      final service = _TicketService();
      final viewModel = TicketDetailViewModel(service);
      await viewModel.loadTicket(10);

      expect(await viewModel.deleteTicket(10), isTrue);
      expect(viewModel.ticket, isNull);
      expect(service.deletedId, 10);
    });

    test('reports a load failure', () async {
      final service = _TicketService(error: StateError('unavailable'));
      final viewModel = TicketDetailViewModel(service);

      await viewModel.loadTicket(10);

      expect(viewModel.status, TicketDetailStatus.failure);
      expect(viewModel.errorMessage, contains('unavailable'));
    });
  });
}

Ticket _ticket({String status = 'Assigned'}) => Ticket(
  id: 10,
  title: 'VPN issue',
  description: 'Cannot connect',
  status: status,
  createdAt: DateTime(2026),
);

TicketStatusNote _note() => TicketStatusNote(
  fromStatus: 'Submitted',
  toStatus: 'Assigned',
  note: 'Assigned to network team',
  changedAt: DateTime(2026),
);

class _TicketService implements ITicketService {
  _TicketService({this.notes = const [], this.error});

  final List<TicketStatusNote> notes;
  final Object? error;
  int notesRequests = 0;
  int? changedByUserId;
  String? changedByRole;
  String? note;
  int? deletedId;

  @override
  Future<Ticket?> getTicketById(int id) async {
    if (error != null) throw error!;
    return _ticket();
  }

  @override
  Future<List<TicketStatusNote>> getStatusNotesByTicketId(int ticketId) async {
    notesRequests++;
    return notes;
  }

  @override
  Future<Ticket> updateTicketStatus({
    required int ticketId,
    required String status,
    int? changedByUserId,
    String? changedByRole,
    String? note,
    String? solutionSummary,
  }) async {
    this.changedByUserId = changedByUserId;
    this.changedByRole = changedByRole;
    this.note = note;
    return _ticket(status: status);
  }

  @override
  Future<void> deleteTicket(int id) async => deletedId = id;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
