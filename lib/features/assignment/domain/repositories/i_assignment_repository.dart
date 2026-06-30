import '../entities/assignment.dart';
import '../entities/progress_update.dart';

abstract interface class IAssignmentRepository {
  Future<List<Assignment>> getAssignmentsForStaff(int staffId);

  Future<Assignment?> getAssignmentByTicket({
    required int ticketId,
    required int staffId,
  });

  Future<List<ProgressUpdate>> getProgressUpdates(int ticketId);

  Future<ProgressUpdate> addProgressUpdate({
    required int ticketId,
    required int staffId,
    required String message,
    int? progressPercent,
  });

  Future<void> updateTicketStatus({
    required int ticketId,
    required int staffId,
    required String status,
    String? note,
  });
}
