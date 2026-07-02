import 'package:flutter/foundation.dart';

import '../../application/services/i_assignment_service.dart';
import '../../domain/entities/assignment.dart';
import '../../domain/entities/progress_update.dart';

enum UpdateProgressStatus { initial, loading, success, failure }

class UpdateProgressViewModel extends ChangeNotifier {
  UpdateProgressViewModel({
    required IAssignmentService assignmentService,
    required this.staffId,
    required this.ticketId,
  }) : _assignmentService = assignmentService;

  final IAssignmentService _assignmentService;
  final int staffId;
  final int ticketId;

  UpdateProgressStatus _status = UpdateProgressStatus.initial;
  String? _errorMessage;
  Assignment? _assignment;
  List<ProgressUpdate> _updates = const [];

  UpdateProgressStatus get status => _status;

  bool get isLoading => _status == UpdateProgressStatus.loading;

  String? get errorMessage => _errorMessage;

  Assignment? get assignment => _assignment;

  List<ProgressUpdate> get updates => List.unmodifiable(_updates);

  Future<void> load() async {
    _status = UpdateProgressStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _assignment = await _assignmentService.getAssignmentByTicket(
        ticketId: ticketId,
        staffId: staffId,
      );
      _updates = await _assignmentService.getProgressUpdates(ticketId);
      _status = UpdateProgressStatus.success;
    } catch (error) {
      _status = UpdateProgressStatus.failure;
      _errorMessage = error.toString();
    }

    notifyListeners();
  }

  Future<bool> submitUpdate({
    required String message,
    required String status,
    String? solutionSummary,
  }) async {
    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty) {
      _status = UpdateProgressStatus.failure;
      _errorMessage = 'Progress note is required.';
      notifyListeners();
      return false;
    }

    _status = UpdateProgressStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _assignmentService.updateTicketStatus(
        ticketId: ticketId,
        staffId: staffId,
        status: status,
        note: normalizedMessage,
        solutionSummary: solutionSummary,
      );
      await _assignmentService.addProgressUpdate(
        ticketId: ticketId,
        staffId: staffId,
        message: normalizedMessage,
      );
      _assignment = await _assignmentService.getAssignmentByTicket(
        ticketId: ticketId,
        staffId: staffId,
      );
      _updates = await _assignmentService.getProgressUpdates(ticketId);
      _status = UpdateProgressStatus.success;
      notifyListeners();
      return true;
    } catch (error) {
      _status = UpdateProgressStatus.failure;
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }
}
