import '../entities/ticket_volume_report.dart';
import '../entities/staff_performance_report.dart';
import '../entities/processing_time_report.dart';

abstract class IReportRepository {
  /// Lấy thống kê số lượng ticket
  Future<List<TicketVolumeReport>> getTicketVolumeReport(String startDate, String endDate);
  
  /// Lấy thống kê hiệu suất nhân viên
  Future<List<StaffPerformanceReport>> getStaffPerformanceReport();
  
  /// Lấy thống kê thời gian xử lý trung bình
  Future<List<ProcessingTimeReport>> getProcessingTimeReport();
}