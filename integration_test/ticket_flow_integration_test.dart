import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:it_ticket_support_management/features/tickets/application/services/i_ticket_service.dart';
import 'package:it_ticket_support_management/features/tickets/domain/entities/ticket.dart';
import 'package:it_ticket_support_management/features/tickets/presentation/viewmodels/create_ticket_view_model.dart';
import 'package:it_ticket_support_management/features/tickets/presentation/viewmodels/ticket_list_view_model.dart';
import 'package:it_ticket_support_management/features/tickets/presentation/views/create_ticket_page.dart';
import 'package:it_ticket_support_management/features/tickets/presentation/views/ticket_list_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('requester creates a ticket and sees it in their ticket list', (
    tester,
  ) async {
    final service = _WorkflowTicketService();
    await _useLargeViewport(tester);
    await tester.pumpWidget(_TicketWorkflowApp(service: service));

    await tester.tap(find.text('Create first ticket'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateTicketPage), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Title'),
      'Cannot access payroll',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Description'),
      'Payroll portal returns an access denied message.',
    );
    final submit = find.widgetWithText(FilledButton, 'Create ticket');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.byType(TicketListPage), findsOneWidget);
    expect(find.text('Cannot access payroll'), findsOneWidget);
    expect(find.text('Submitted'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(service.createCalls, 1);
    expect(service.requesterLoads, 1);
    expect(service.lastRequesterId, 7);
  });
}

class _TicketWorkflowApp extends StatefulWidget {
  const _TicketWorkflowApp({required this.service});

  final _WorkflowTicketService service;

  @override
  State<_TicketWorkflowApp> createState() => _TicketWorkflowAppState();
}

class _TicketWorkflowAppState extends State<_TicketWorkflowApp> {
  bool _showList = false;

  Future<void> _createTicket(BuildContext context) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateTicketPage(
          requesterId: 7,
          viewModel: CreateTicketViewModel(widget.service),
        ),
      ),
    );
    if (created == true && mounted) {
      setState(() => _showList = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _showList
          ? TicketListPage(
              requesterId: 7,
              viewModel: TicketListViewModel(widget.service),
            )
          : Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () => _createTicket(context),
                    child: const Text('Create first ticket'),
                  ),
                ),
              ),
            ),
    );
  }
}

Future<void> _useLargeViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _WorkflowTicketService implements ITicketService {
  final List<Ticket> _tickets = [];
  int createCalls = 0;
  int requesterLoads = 0;
  int? lastRequesterId;

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
    createCalls++;
    final ticket = Ticket(
      id: createCalls,
      title: title,
      description: description,
      issueType: issueType,
      priority: priority,
      requestedId: requesterId,
      categoryId: categoryId,
      attachmentUrl: attachmentUrl,
      createdAt: DateTime(2026, 7, 13),
    );
    _tickets.add(ticket);
    return ticket;
  }

  @override
  Future<List<Ticket>> getTicketsByRequester(int requesterId) async {
    requesterLoads++;
    lastRequesterId = requesterId;
    return _tickets
        .where((ticket) => ticket.requestedId == requesterId)
        .toList(growable: false);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
