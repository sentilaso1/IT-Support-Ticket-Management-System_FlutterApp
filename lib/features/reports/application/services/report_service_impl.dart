import 'i_report_service.dart';
import '../../domain/repositories/i_report_repository.dart';
import '../../domain/entities/ticket_volume_report.dart';
import '../../domain/entities/staff_performance_report.dart';
import '../../domain/entities/processing_time_report.dart';

class ReportServiceImpl implements IReportService {
  final IReportRepository repository;

  ReportServiceImpl({required this.repository});

  @override
  Future<List<TicketVolumeReport>> getTicketVolumeReport(String startDate, String endDate) async {
    // Logic nghiệp vụ: Validate đầu vào trước khi gọi Database
    if (startDate.isEmpty || endDate.isEmpty) {
      throw Exception('Ngày bắt đầu và ngày kết thúc không được để trống.');
    }
    
    // Nếu ngày tháng hợp lệ, gọi xuống Repository
    return await repository.getTicketVolumeReport(startDate, endDate);
  }

  @override
  Future<List<StaffPerformanceReport>> getStaffPerformanceReport() async {
    // Có thể thêm logic kiểm tra quyền Admin ở đây nếu ứng dụng yêu cầu
    return await repository.getStaffPerformanceReport();
  }

  @override
  Future<List<ProcessingTimeReport>> getProcessingTimeReport() async {
    return await repository.getProcessingTimeReport();
  }
}