import '../dtos/ticket_volume_report_dto.dart';
import '../dtos/staff_performance_report_dto.dart';
import '../dtos/processing_time_report_dto.dart';

abstract class IReportLocalDataSource {
  /// Lấy thống kê số lượng ticket theo từng ngày trong một khoảng thời gian
  Future<List<TicketVolumeReportDto>> getTicketVolumeReport(String startDate, String endDate);
  
  /// Lấy thống kê hiệu suất xử lý công việc của từng nhân viên (Staff/Admin)
  Future<List<StaffPerformanceReportDto>> getStaffPerformanceReport();
  
  /// Lấy thống kê thời gian xử lý trung bình theo từng danh mục sự cố
  Future<List<ProcessingTimeReportDto>> getProcessingTimeReport();
}