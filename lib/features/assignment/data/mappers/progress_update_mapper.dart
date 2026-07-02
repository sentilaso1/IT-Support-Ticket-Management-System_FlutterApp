import '../../domain/entities/progress_update.dart';
import '../dtos/progress_update_dto.dart';

class ProgressUpdateMapper {
  const ProgressUpdateMapper();

  ProgressUpdate mapToEntity(ProgressUpdateDto dto) {
    return ProgressUpdate(
      id: dto.id ?? 0,
      ticketId: dto.ticketId,
      staffId: dto.staffId,
      message: dto.message,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
}
