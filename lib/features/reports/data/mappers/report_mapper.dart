import '../../domain/entities/ticket_volume_report.dart';
import '../dtos/ticket_volume_report_dto.dart';
import '../../domain/entities/staff_performance_report.dart';
import '../../domain/entities/processing_time_report.dart';
import '../dtos/staff_performance_report_dto.dart';
import '../dtos/processing_time_report_dto.dart';

extension TicketVolumeReportMapper on TicketVolumeReportDto {
  // Chuyển từ DTO sang Entity
  TicketVolumeReport toEntity() {
    return TicketVolumeReport(
      date: date,
      totalTickets: totalTickets,
      resolvedTickets: resolvedTickets,
      pendingTickets: pendingTickets,
    );
  }
}

// Hỗ trợ map một List các DTOs sang List Entities
extension TicketVolumeReportListMapper on List<TicketVolumeReportDto> {
  List<TicketVolumeReport> toEntityList() {
    return map((dto) => dto.toEntity()).toList();
  }
}

extension StaffPerformanceReportMapper on StaffPerformanceReportDto {
  StaffPerformanceReport toEntity() {
    return StaffPerformanceReport(
      staffId: staffId,
      staffName: staffName,
      assignedTickets: assignedTickets,
      resolvedTickets: resolvedTickets,
    );
  }
}

extension StaffPerformanceReportListMapper on List<StaffPerformanceReportDto> {
  List<StaffPerformanceReport> toEntityList() {
    return map((dto) => dto.toEntity()).toList();
  }
}

// --- Bổ sung Processing Time Mapper ---
extension ProcessingTimeReportMapper on ProcessingTimeReportDto {
  ProcessingTimeReport toEntity() {
    return ProcessingTimeReport(
      categoryName: categoryName,
      averageHours: averageHours,
    );
  }
}

extension ProcessingTimeReportListMapper on List<ProcessingTimeReportDto> {
  List<ProcessingTimeReport> toEntityList() {
    return map((dto) => dto.toEntity()).toList();
  }
}