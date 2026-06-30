import 'package:flutter/foundation.dart';

import '../../application/services/i_assignment_service.dart';
import '../../domain/entities/assignment.dart';

enum TechnicianQueueStatus { initial, loading, success, failure }

class TechnicianQueueViewModel extends ChangeNotifier {
  TechnicianQueueViewModel({
    required IAssignmentService assignmentService,
    required this.staffId,
  }) : _assignmentService = assignmentService;

  final IAssignmentService _assignmentService;
  final int staffId;

  TechnicianQueueStatus _status = TechnicianQueueStatus.initial;
  String? _errorMessage;
  List<Assignment> _assignments = const [];

  TechnicianQueueStatus get status => _status;

  bool get isLoading => _status == TechnicianQueueStatus.loading;

  String? get errorMessage => _errorMessage;

  List<Assignment> get assignments => List.unmodifiable(_assignments);

  Future<void> loadAssignments() async {
    _status = TechnicianQueueStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _assignments = await _assignmentService.getAssignmentsForStaff(staffId);
      _status = TechnicianQueueStatus.success;
    } catch (error) {
      _status = TechnicianQueueStatus.failure;
      _errorMessage = error.toString();
    }

    notifyListeners();
  }
}
