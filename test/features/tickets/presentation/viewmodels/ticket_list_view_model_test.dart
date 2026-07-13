import 'package:flutter_test/flutter_test.dart';
import 'package:it_ticket_support_management/features/tickets/application/services/i_ticket_service.dart';
import 'package:it_ticket_support_management/features/tickets/domain/entities/ticket.dart';
import 'package:it_ticket_support_management/features/tickets/presentation/viewmodels/ticket_list_view_model.dart';

void main() {
  group('TicketListViewModel', () {
    test('loads tickets using requester and assignee filters', () async {
      final service = _TicketService([_ticket(1), _ticket(2)]);
      final viewModel = TicketListViewModel(service);

      await viewModel.loadTicketsByRequester(7);
      expect(viewModel.status, TicketListStatus.success);
      expect(service.requesterId, 7);
      expect(viewModel.tickets, hasLength(2));

      await viewModel.loadTicketsByAssignee(9);
      expect(service.assigneeId, 9);
    });

    test('removes a deleted ticket from the current list', () async {
      final service = _TicketService([_ticket(1), _ticket(2)]);
      final viewModel = TicketListViewModel(service);
      await viewModel.loadTickets();

      expect(await viewModel.deleteTicket(1), isTrue);
      expect(service.deletedId, 1);
      expect(viewModel.tickets.single.id, 2);
    });

    test('keeps existing data and exposes a load failure', () async {
      final service = _TicketService([_ticket(1)]);
      final viewModel = TicketListViewModel(service);
      await viewModel.loadTickets();
      service.error = StateError('offline');

      await viewModel.loadTickets();
      expect(viewModel.status, TicketListStatus.failure);
      expect(viewModel.tickets.single.id, 1);
      expect(viewModel.errorMessage, contains('offline'));
    });
  });
}

Ticket _ticket(int id) => Ticket(
  id: id,
  title: 'Ticket $id',
  description: 'Description $id',
  createdAt: DateTime(2026, 1, id),
);

class _TicketService implements ITicketService {
  _TicketService(this.tickets);

  final List<Ticket> tickets;
  Object? error;
  int? requesterId;
  int? assigneeId;
  int? deletedId;

  Future<List<Ticket>> _result() async {
    if (error != null) throw error!;
    return tickets;
  }

  @override
  Future<List<Ticket>> getTickets() => _result();

  @override
  Future<List<Ticket>> getTicketsByRequester(int requesterId) {
    this.requesterId = requesterId;
    return _result();
  }

  @override
  Future<List<Ticket>> getTicketsByAssignee(int assigneeId) {
    this.assigneeId = assigneeId;
    return _result();
  }

  @override
  Future<void> deleteTicket(int id) async {
    if (error != null) throw error!;
    deletedId = id;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
