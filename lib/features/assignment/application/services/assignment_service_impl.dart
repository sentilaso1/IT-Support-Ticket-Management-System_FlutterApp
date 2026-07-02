import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/assignment.dart';
import '../../domain/entities/progress_update.dart';
import '../../domain/repositories/i_assignment_repository.dart';
import 'i_assignment_service.dart';

class AssignmentServiceImpl implements IAssignmentService {
  const AssignmentServiceImpl(this._assignmentRepository);

  final IAssignmentRepository _assignmentRepository;

  static const Map<String, Set<String>> _staffTransitions = {
    'Submitted': {'Assigned'},
    'Assigned': {'Processing', 'Resolved'},
    'Processing': {'Pending', 'Resolved'},
    'Pending': {'Processing'},
    'Resolved': {'Closed'},
  };

  @override
  Future<List<Assignment>> getAssignmentsForStaff(int staffId) {
    if (staffId <= 0) {
      throw const AppException('Staff id is required.');
    }

    return _assignmentRepository.getAssignmentsForStaff(staffId);
  }

  @override
  Future<Assignment?> getAssignmentByTicket({
    required int ticketId,
    required int staffId,
  }) {
    if (ticketId <= 0 || staffId <= 0) {
      throw const AppException('Ticket and staff are required.');
    }

    return _assignmentRepository.getAssignmentByTicket(
      ticketId: ticketId,
      staffId: staffId,
    );
  }

  @override
  Future<List<ProgressUpdate>> getProgressUpdates(int ticketId) {
    if (ticketId <= 0) {
      throw const AppException('Ticket id is required.');
    }

    return _assignmentRepository.getProgressUpdates(ticketId);
  }

  @override
  Future<ProgressUpdate> addProgressUpdate({
    required int ticketId,
    required int staffId,
    required String message,
  }) {
    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty) {
      throw const AppException('Progress note is required.');
    }

    return _assignmentRepository.addProgressUpdate(
      ticketId: ticketId,
      staffId: staffId,
      message: normalizedMessage,
    );
  }

  @override
  Future<void> updateTicketStatus({
    required int ticketId,
    required int staffId,
    required String status,
    String? note,
    String? solutionSummary,
  }) async {
    final normalizedStatus = status.trim();
    if (normalizedStatus.isEmpty) {
      throw const AppException('Ticket status is required.');
    }

    final assignment = await getAssignmentByTicket(
      ticketId: ticketId,
      staffId: staffId,
    );
    if (assignment == null) {
      throw const AppException('Assigned ticket was not found.');
    }

    final currentStatus = assignment.status.trim();
    final allowedStatuses = _staffTransitions[currentStatus] ?? const {};
    if (!allowedStatuses.contains(normalizedStatus)) {
      throw AppException(
        'Invalid status transition: $currentStatus -> $normalizedStatus.',
      );
    }

    final normalizedSolutionSummary = solutionSummary?.trim();
    if (normalizedStatus == 'Resolved' &&
        (normalizedSolutionSummary == null ||
            normalizedSolutionSummary.isEmpty)) {
      throw const AppException(
        'Solution summary is required when resolving a ticket.',
      );
    }

    return _assignmentRepository.updateTicketStatus(
      ticketId: ticketId,
      staffId: staffId,
      status: normalizedStatus,
      note: note?.trim().isEmpty ?? true ? null : note!.trim(),
      solutionSummary: normalizedSolutionSummary?.isEmpty ?? true
          ? null
          : normalizedSolutionSummary,
    );
  }
}
