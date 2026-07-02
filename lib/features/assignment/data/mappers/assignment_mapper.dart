import '../../domain/entities/assignment.dart';
import '../dtos/assignment_dto.dart';

class AssignmentMapper {
  const AssignmentMapper();

  Assignment mapToEntity(AssignmentDto dto) {
    return Assignment(
      id: dto.id ?? 0,
      ticketId: dto.ticketId,
      staffId: dto.staffId,
      assignedByUserId: dto.assignedByUserId,
      assignedAt: dto.assignedAt,
      note: dto.note,
      isActive: dto.isActive,
      ticketTitle: dto.ticketTitle ?? 'Untitled ticket',
      ticketDescription: dto.ticketDescription ?? '',
      issueType: dto.issueType ?? 'General',
      priority: dto.priority ?? 'Medium',
      status: dto.status ?? 'Submitted',
      ticketCreatedAt: dto.ticketCreatedAt ?? dto.createdAt,
      ticketUpdatedAt: dto.ticketUpdatedAt,
      lastProgressMessage: dto.lastProgressMessage,
    );
  }
}
