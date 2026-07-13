import 'package:flutter_test/flutter_test.dart';
import 'package:it_ticket_support_management/features/tickets/application/services/i_ticket_service.dart';
import 'package:it_ticket_support_management/features/tickets/domain/entities/ticket.dart';
import 'package:it_ticket_support_management/features/tickets/presentation/viewmodels/create_ticket_view_model.dart';

void main() {
  group('CreateTicketViewModel', () {
    test('creates a ticket and forwards all form values', () async {
      final service = _TicketService();
      final viewModel = CreateTicketViewModel(service);

      final success = await viewModel.createTicket(
        title: 'VPN unavailable',
        description: 'Connection times out',
        issueType: 'Network',
        priority: 'High',
        requesterId: 7,
        categoryId: 1,
        attachmentUrl: 'vpn.png',
      );

      expect(success, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.createdTicket?.id, 10);
      expect(service.title, 'VPN unavailable');
      expect(service.description, 'Connection times out');
      expect(service.issueType, 'Network');
      expect(service.priority, 'High');
      expect(service.requesterId, 7);
      expect(service.categoryId, 1);
      expect(service.attachmentUrl, 'vpn.png');
    });

    test('reports failure, clears stale result, and can clear error', () async {
      final service = _TicketService();
      final viewModel = CreateTicketViewModel(service);
      await viewModel.createTicket(title: 'First', description: 'Works');
      service.error = StateError('database unavailable');

      expect(
        await viewModel.createTicket(title: 'Second', description: 'Fails'),
        isFalse,
      );
      expect(viewModel.createdTicket, isNull);
      expect(viewModel.errorMessage, contains('database unavailable'));
      viewModel.clearError();
      expect(viewModel.errorMessage, isNull);
    });
  });
}

class _TicketService implements ITicketService {
  Object? error;
  String? title;
  String? description;
  String? issueType;
  String? priority;
  int? requesterId;
  int? categoryId;
  String? attachmentUrl;

  @override
  Future<Ticket> createTicket({
    required String title,
    required String description,
    String issueType = 'Other',
    String priority = 'Medium',
    int? requesterId,
    int? categoryId,
    String? attachmentUrl,
  }) async {
    if (error != null) throw error!;
    this.title = title;
    this.description = description;
    this.issueType = issueType;
    this.priority = priority;
    this.requesterId = requesterId;
    this.categoryId = categoryId;
    this.attachmentUrl = attachmentUrl;
    return Ticket(
      id: 10,
      title: title,
      description: description,
      issueType: issueType,
      priority: priority,
      requestedId: requesterId,
      categoryId: categoryId,
      attachmentUrl: attachmentUrl,
      createdAt: DateTime(2026),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
