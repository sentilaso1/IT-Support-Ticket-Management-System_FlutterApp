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
    required int progressPercent,
    required String status,
  }) async {
    _status = UpdateProgressStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _assignmentService.addProgressUpdate(
        ticketId: ticketId,
        staffId: staffId,
        message: message,
        progressPercent: progressPercent,
      );
      await _assignmentService.updateTicketStatus(
        ticketId: ticketId,
        staffId: staffId,
        status: status,
        note: message,
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
