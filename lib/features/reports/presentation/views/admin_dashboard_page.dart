import 'package:flutter/material.dart';
// Lưu ý: Import file view model của bạn và thư viện quản lý state (như Provider)
// import 'package:provider/provider.dart'; 
import '../viewmodels/admin_dashboard_view_model.dart';
import '../../domain/entities/processing_time_report.dart';
import '../../domain/entities/staff_performance_report.dart';
import 'package:provider/provider.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Fetch dữ liệu ngay khi mở màn hình (ví dụ: 30 ngày gần nhất)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Đoạn này tùy thuộc vào cách nhóm bạn inject dependency (GetIt, Provider, v.v.)
       context.read<AdminDashboardViewModel>().loadDashboardData('2026-07-01', '2026-08-01');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Nếu dùng Provider:
     final viewModel = context.watch<AdminDashboardViewModel>();
    
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Reload lại dữ liệu
            },
          )
        ],
      ),
      // Bọc nội dung bằng ListBuilder hoặc AnimatedBuilder tuỳ state management
      body: _buildBody(viewModel), 
    );
  }

  // Thêm tham số truyền vào
Widget _buildBody(AdminDashboardViewModel viewModel) {

  // Dùng trạng thái thật từ viewModel
  if (viewModel.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  // Dùng thông báo lỗi thật từ viewModel
  if (viewModel.errorMessage != null) {
    return Center(
      child: Text(viewModel.errorMessage!, style: const TextStyle(color: Colors.red)),
    );
  }

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('System Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        // Truyền viewModel xuống các hàm con đã viết ở bước trước
        _buildSummaryCards(viewModel),
        
        const SizedBox(height: 24),
        const Text('Staff Workload', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        // Truyền list dữ liệu thật
        _buildStaffWorkloadList(viewModel.performanceReports),

        const SizedBox(height: 24),
        const Text('Average Processing Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        // Truyền list dữ liệu thật
        _buildProcessingTimeChart(viewModel.processingTimeReports),
      ],
    ),
  );
}

  // Khung Widget cho Task 14, 15

  Widget _buildSummaryCards(AdminDashboardViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            title: 'Total Tickets',
            value: viewModel.totalTicketsOverall.toString(),
            color: Colors.blueAccent,
            icon: Icons.confirmation_number,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            title: 'Resolved',
            value: viewModel.totalResolvedOverall.toString(),
            color: Colors.green,
            icon: Icons.check_circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            title: 'Pending',
            value: viewModel.totalPendingOverall.toString(),
            color: Colors.orange,
            icon: Icons.pending_actions,
          ),
        ),
      ],
    );
  }

  // Widget con hỗ trợ vẽ thẻ (Card)
  Widget _buildInfoCard({required String title, required String value, required Color color, required IconData icon}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  // Khung Widget cho Task 18
  Widget _buildStaffWorkloadList(List<StaffPerformanceReport> reports) {
    if (reports.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No staff workload data available.'),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: reports.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final report = reports[index];
          // Tránh lỗi chia cho 0
          final double progress = report.assignedTickets == 0 
              ? 0 
              : (report.resolvedTickets / report.assignedTickets);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(report.staffName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${report.resolvedTickets} / ${report.assignedTickets} completed', 
                         style: const TextStyle(color: Colors.black54, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    color: progress >= 1.0 ? Colors.green : Colors.blue,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Khung Widget cho Task 19
  Widget _buildProcessingTimeChart(List<ProcessingTimeReport> reports) {
    if (reports.isEmpty) {
      return const Text('No processing time data available.');
    }

    // Tìm giá trị cao nhất để làm mốc 100% cho biểu đồ
    double maxHours = 0;
    for (var r in reports) {
      if (r.averageHours > maxHours) maxHours = r.averageHours;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: reports.map((report) {
            final double percentage = maxHours == 0 ? 0 : (report.averageHours / maxHours);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  // Tên danh mục (chiếm 30% chiều rộng)
                  Expanded(
                    flex: 3,
                    child: Text(
                      report.categoryName, 
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Thanh biểu đồ (chiếm 70% chiều rộng)
                  Expanded(
                    flex: 7,
                    child: Row(
                      children: [
                        Flexible(
                          child: FractionallySizedBox(
                            widthFactor: percentage > 0 ? percentage : 0.01,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.purple[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${report.averageHours.toStringAsFixed(1)} h', 
                             style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}