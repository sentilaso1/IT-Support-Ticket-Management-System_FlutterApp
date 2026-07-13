import 'package:sqflite/sqflite.dart';
import 'i_report_local_data_source.dart';
import '../dtos/ticket_volume_report_dto.dart';
import '../dtos/staff_performance_report_dto.dart';
import '../dtos/processing_time_report_dto.dart';

class ReportLocalDataSourceImpl implements IReportLocalDataSource {
  final Database database;

  ReportLocalDataSourceImpl({required this.database});

  @override
  Future<List<TicketVolumeReportDto>> getTicketVolumeReport(
    String startDate,
    String endDate,
  ) async {
    final String sql = '''
      SELECT 
        DATE(createdAt) as date,
        COUNT(id) as total_tickets,
        SUM(CASE WHEN LOWER(status) IN ('resolved', 'closed', 'processing', 'assigned', 'pending') THEN 1 ELSE 0 END) as resolved_tickets,
        SUM(CASE WHEN LOWER(status) = 'pending' THEN 1 ELSE 0 END) as pending_tickets
      FROM tickets
      WHERE DATE(createdAt) BETWEEN ? AND ?
      GROUP BY DATE(createdAt)
      ORDER BY DATE(createdAt) ASC
    ''';

    final List<Map<String, dynamic>> result = await database.rawQuery(sql, [
      startDate,
      endDate,
    ]);

    return result.map((map) => TicketVolumeReportDto.fromMap(map)).toList();
  }

 @override
  Future<List<StaffPerformanceReportDto>> getStaffPerformanceReport() async {
    // Hàm này bạn đã dán chuẩn rồi, giữ nguyên!
    final String sql = '''
      SELECT 
        u.id as staff_id,
        u.fullName as staff_name,
        COUNT(t.id) as assigned_tickets,
        SUM(CASE WHEN LOWER(t.status) IN ('resolved', 'closed') THEN 1 ELSE 0 END) as resolved_tickets
      FROM users u
      LEFT JOIN tickets t ON u.id = t.assignedStaffId
      WHERE u.role IN ('admin', 'staff')
      GROUP BY u.id, u.fullName
      ORDER BY resolved_tickets DESC
    ''';

    final List<Map<String, dynamic>> result = await database.rawQuery(sql);
    return result.map((map) => StaffPerformanceReportDto.fromMap(map)).toList();
  }

  @override
  Future<List<ProcessingTimeReportDto>> getProcessingTimeReport() async {
    // SỬA: Đổi tên cột CategoryName thành name, đổi ResolvedAt thành updatedAt
    final String sql = '''
      SELECT 
        c.name as category_name,
        AVG((julianday(t.updatedAt) - julianday(t.createdAt)) * 24) as average_hours
      FROM tickets t
      JOIN categories c ON t.categoryId = c.id
      WHERE LOWER(t.status) IN ('resolved', 'closed')
      GROUP BY c.id, c.name
      ORDER BY average_hours DESC
    ''';

    final List<Map<String, dynamic>> result = await database.rawQuery(sql);

    return result.map((map) => ProcessingTimeReportDto.fromMap(map)).toList();
  }
}