class ProcessingTimeReportDto {
  final String categoryName;
  final double averageHours;

  ProcessingTimeReportDto({
    required this.categoryName,
    required this.averageHours,
  });

  factory ProcessingTimeReportDto.fromMap(Map<String, dynamic> map) {
    return ProcessingTimeReportDto(
      categoryName: map['category_name'] as String? ?? 'Unknown',
      // SQFlite đôi khi trả về int thay vì double nếu số tròn, nên cần ép kiểu an toàn
      averageHours: (map['average_hours'] as num?)?.toDouble() ?? 0.0,
    );
  }
}