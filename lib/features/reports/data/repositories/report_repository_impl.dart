import '../../domain/repositories/i_report_repository.dart';
import '../../domain/entities/ticket_volume_report.dart';
import '../../domain/entities/staff_performance_report.dart';
import '../../domain/entities/processing_time_report.dart';
import '../datasources/i_report_local_data_source.dart';
import '../mappers/report_mapper.dart'; 

class ReportRepositoryImpl implements IReportRepository {
  final IReportLocalDataSource localDataSource;

  ReportRepositoryImpl({required this.localDataSource});

  @override
  Future<List<TicketVolumeReport>> getTicketVolumeReport(String startDate, String endDate) async {
    // 1. Gọi Data Source lấy dữ liệu thô (DTOs)
    final dtos = await localDataSource.getTicketVolumeReport(startDate, endDate);
    
    // 2. Dùng extension từ ReportMapper để chuyển sang Entities
    return dtos.toEntityList(); 
  }

  @override
  Future<List<StaffPerformanceReport>> getStaffPerformanceReport() async {
    final dtos = await localDataSource.getStaffPerformanceReport();
    return dtos.toEntityList();
  }

  @override
  Future<List<ProcessingTimeReport>> getProcessingTimeReport() async {
    final dtos = await localDataSource.getProcessingTimeReport();
    return dtos.toEntityList();
  }
}