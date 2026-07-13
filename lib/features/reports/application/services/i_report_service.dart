import '../../domain/entities/ticket_volume_report.dart';
import '../../domain/entities/staff_performance_report.dart';
import '../../domain/entities/processing_time_report.dart';

abstract class IReportService {
  /// Lấy báo cáo số lượng ticket trong một khoảng thời gian
  Future<List<TicketVolumeReport>> getTicketVolumeReport(String startDate, String endDate);
  
  /// Lấy báo cáo hiệu suất xử lý của nhân viên
  Future<List<StaffPerformanceReport>> getStaffPerformanceReport();
  
  /// Lấy báo cáo thời gian xử lý trung bình theo danh mục
  Future<List<ProcessingTimeReport>> getProcessingTimeReport();
}