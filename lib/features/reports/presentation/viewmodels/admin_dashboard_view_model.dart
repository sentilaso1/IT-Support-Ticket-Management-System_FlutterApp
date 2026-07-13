import 'package:flutter/material.dart';
import '../../application/services/i_report_service.dart';
import '../../domain/entities/ticket_volume_report.dart';
import '../../domain/entities/staff_performance_report.dart';
import '../../domain/entities/processing_time_report.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  final IReportService reportService;

  AdminDashboardViewModel({required this.reportService});

  // Trạng thái giao diện
  bool isLoading = false;
  String? errorMessage;

  // Dữ liệu báo cáo
  List<TicketVolumeReport> volumeReports = [];
  List<StaffPerformanceReport> performanceReports = [];
  List<ProcessingTimeReport> processingTimeReports = [];

  // Các biến tổng hợp nhanh (Cho Task 14, 15)
  int totalTicketsOverall = 0;
  int totalResolvedOverall = 0;
  int totalPendingOverall = 0;

  /// Hàm khởi chạy để load toàn bộ dữ liệu Dashboard
  Future<void> loadDashboardData(String startDate, String endDate) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners(); // Báo UI hiện vòng xoay loading

    try {
      // Dùng Future.wait để gọi 3 API/Query cùng lúc giúp tăng tốc độ
      final results = await Future.wait([
        reportService.getTicketVolumeReport(startDate, endDate),
        reportService.getStaffPerformanceReport(),
        reportService.getProcessingTimeReport(),
      ]);

      volumeReports = results[0] as List<TicketVolumeReport>;
      performanceReports = results[1] as List<StaffPerformanceReport>;
      processingTimeReports = results[2] as List<ProcessingTimeReport>;

      // Tính toán số liệu tổng hợp
      _calculateTotals();

    } catch (e) {
      errorMessage = 'Lỗi tải dữ liệu: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners(); // Báo UI tắt loading và vẽ dữ liệu
    }
  }

  void _calculateTotals() {
    totalTicketsOverall = 0;
    totalResolvedOverall = 0;
    totalPendingOverall = 0;
    for (var report in volumeReports) {
      totalTicketsOverall += report.totalTickets;
      totalResolvedOverall += report.resolvedTickets;
      totalPendingOverall += report.pendingTickets;
    }
  }
}