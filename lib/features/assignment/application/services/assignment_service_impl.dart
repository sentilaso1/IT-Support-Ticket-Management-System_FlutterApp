import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/assignment.dart';
import '../../domain/entities/progress_update.dart';
import '../../domain/repositories/i_assignment_repository.dart';
import 'i_assignment_service.dart';

class AssignmentServiceImpl implements IAssignmentService {
  const AssignmentServiceImpl(this._assignmentRepository);

  final IAssignmentRepository _assignmentRepository;

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
    int? progressPercent,
  }) {
    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty) {
      throw const AppException('Progress note is required.');
    }

    if (progressPercent != null &&
        (progressPercent < 0 || progressPercent > 100)) {
      throw const AppException('Progress must be between 0 and 100.');
    }

    return _assignmentRepository.addProgressUpdate(
      ticketId: ticketId,
      staffId: staffId,
      message: normalizedMessage,
      progressPercent: progressPercent,
    );
  }

  @override
  Future<void> updateTicketStatus({
    required int ticketId,
    required int staffId,
    required String status,
    String? note,
  }) {
    final normalizedStatus = status.trim();
    if (normalizedStatus.isEmpty) {
      throw const AppException('Ticket status is required.');
    }

    return _assignmentRepository.updateTicketStatus(
      ticketId: ticketId,
      staffId: staffId,
      status: normalizedStatus,
      note: note?.trim().isEmpty ?? true ? null : note!.trim(),
    );
  }
}
