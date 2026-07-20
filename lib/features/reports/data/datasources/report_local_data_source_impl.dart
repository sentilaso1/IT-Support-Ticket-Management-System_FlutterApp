import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/sla_persistence.dart';
import '../dtos/processing_time_report_dto.dart';
import '../dtos/staff_performance_report_dto.dart';
import '../dtos/ticket_volume_report_dto.dart';
import '../dtos/user_report_dto.dart';
import '../dtos/sla_summary_report_dto.dart';
import 'i_report_local_data_source.dart';

class ReportLocalDataSourceImpl implements IReportLocalDataSource {
  const ReportLocalDataSourceImpl({required this.database});

  final Database database;

  @override
  Future<SlaSummaryReportDto> getSlaSummaryReport(
    String startDate,
    String endDate,
  ) async {
    await SlaPersistence.refreshBreaches(database);
    final rows = await database.rawQuery(
      '''
      WITH clock(nowValue) AS (SELECT julianday(?))
      SELECT
        SUM(CASE WHEN LOWER(status) <> 'cancelled' THEN 1 ELSE 0 END)
          AS total_actionable,
        SUM(CASE WHEN slaExceptionReason IS NULL
          AND LOWER(status) <> 'cancelled'
          AND firstRespondedAt IS NOT NULL
          AND julianday(firstRespondedAt) <= julianday(responseDueAt)
          THEN 1 ELSE 0 END) AS response_met,
        SUM(CASE WHEN slaExceptionReason IS NULL
          AND LOWER(status) <> 'cancelled'
          AND (
            (firstRespondedAt IS NOT NULL
              AND julianday(firstRespondedAt) > julianday(responseDueAt))
            OR (firstRespondedAt IS NULL
              AND clock.nowValue >= julianday(responseDueAt))
          )
          THEN 1 ELSE 0 END) AS response_breached,
        SUM(CASE WHEN slaExceptionReason IS NULL
          AND LOWER(status) <> 'cancelled'
          AND slaCompletedAt IS NOT NULL
          AND julianday(slaCompletedAt) <= julianday(resolutionDueAt)
          THEN 1 ELSE 0 END) AS resolution_met,
        SUM(CASE WHEN slaExceptionReason IS NULL
          AND LOWER(status) <> 'cancelled'
          AND (
            (slaCompletedAt IS NOT NULL
              AND julianday(slaCompletedAt) > julianday(resolutionDueAt))
            OR (slaCompletedAt IS NULL
              AND clock.nowValue >= julianday(resolutionDueAt))
          )
          THEN 1 ELSE 0 END) AS resolution_breached,
        SUM(CASE WHEN slaCompletedAt IS NULL
          AND slaExceptionReason IS NULL
          AND clock.nowValue < julianday(resolutionDueAt)
          AND clock.nowValue >=
            julianday(createdAt) +
            ((julianday(resolutionDueAt) - julianday(createdAt)) * 0.75)
          THEN 1 ELSE 0 END) AS currently_at_risk,
        SUM(CASE WHEN slaCompletedAt IS NULL
          AND slaExceptionReason IS NULL
          AND clock.nowValue >= julianday(resolutionDueAt)
          THEN 1 ELSE 0 END) AS currently_breached,
        SUM(CASE WHEN slaExceptionReason IS NOT NULL
          OR LOWER(status) = 'cancelled' THEN 1 ELSE 0 END) AS exempt
      FROM ${AppDatabase.ticketsTable}
      CROSS JOIN clock
      WHERE DATE(createdAt) BETWEEN ? AND ?
      ''',
      [DateTime.now().toIso8601String(), startDate, endDate],
    );
    return SlaSummaryReportDto.fromMap(rows.first);
  }

  @override
  Future<List<TicketVolumeReportDto>> getTicketVolumeReport(
    String startDate,
    String endDate,
  ) async {
    final rows = await database.rawQuery(
      '''
      SELECT
        DATE(createdAt) AS date,
        COUNT(id) AS total_tickets,
        SUM(CASE WHEN LOWER(status) = 'submitted' THEN 1 ELSE 0 END)
          AS submitted_tickets,
        SUM(CASE WHEN LOWER(status) = 'assigned' THEN 1 ELSE 0 END)
          AS assigned_tickets,
        SUM(CASE WHEN LOWER(status) = 'processing' THEN 1 ELSE 0 END)
          AS processing_tickets,
        SUM(CASE WHEN LOWER(status) = 'resolved' THEN 1 ELSE 0 END)
          AS resolved_tickets,
        SUM(CASE WHEN LOWER(status) = 'closed' THEN 1 ELSE 0 END)
          AS closed_tickets,
        SUM(CASE WHEN LOWER(status) = 'cancelled' THEN 1 ELSE 0 END)
          AS cancelled_tickets
      FROM ${AppDatabase.ticketsTable}
      WHERE DATE(createdAt) BETWEEN ? AND ?
      GROUP BY DATE(createdAt)
      ORDER BY DATE(createdAt) DESC
      ''',
      [startDate, endDate],
    );
    return rows.map(TicketVolumeReportDto.fromMap).toList(growable: false);
  }

  @override
  Future<List<StaffPerformanceReportDto>> getStaffPerformanceReport(
    String startDate,
    String endDate,
  ) async {
    final rows = await database.rawQuery(
      '''
      SELECT
        u.id AS staff_id,
        u.fullName AS staff_name,
        COUNT(t.id) AS assigned_tickets,
        SUM(
          CASE WHEN LOWER(t.status) IN ('resolved', 'closed')
          THEN 1 ELSE 0 END
        ) AS resolved_tickets
      FROM ${AppDatabase.usersTable} u
      LEFT JOIN ${AppDatabase.ticketsTable} t
        ON u.id = t.assignedStaffId
        AND DATE(t.createdAt) BETWEEN ? AND ?
      WHERE LOWER(u.role) = 'staff'
      GROUP BY u.id, u.fullName
      ORDER BY resolved_tickets DESC, assigned_tickets DESC, u.fullName ASC
      ''',
      [startDate, endDate],
    );
    return rows.map(StaffPerformanceReportDto.fromMap).toList(growable: false);
  }

  @override
  Future<List<ProcessingTimeReportDto>> getProcessingTimeReport(
    String startDate,
    String endDate,
  ) async {
    final rows = await database.rawQuery(
      '''
      SELECT
        c.name AS category_name,
        COUNT(t.id) AS completed_tickets,
        AVG((julianday(t.resolvedAt) - julianday(t.createdAt)) * 24)
          AS average_hours
      FROM ${AppDatabase.ticketsTable} t
      JOIN ${AppDatabase.categoriesTable} c ON t.categoryId = c.id
      WHERE t.resolvedAt IS NOT NULL
        AND LOWER(t.status) IN ('resolved', 'closed')
        AND DATE(t.createdAt) BETWEEN ? AND ?
      GROUP BY c.id, c.name
      ORDER BY average_hours DESC, c.name ASC
      ''',
      [startDate, endDate],
    );
    return rows.map(ProcessingTimeReportDto.fromMap).toList(growable: false);
  }

  @override
  Future<List<UserReportDto>> getUserReport(
    String startDate,
    String endDate,
  ) async {
    final rows = await database.rawQuery(
      '''
      SELECT
        u.id AS user_id,
        u.fullName AS full_name,
        u.username AS username,
        u.role AS role,
        d.name AS department_name,
        u.isActive AS is_active,
        u.lastLoginAt AS last_login_at,
        COUNT(t.id) AS created_tickets,
        SUM(
          CASE WHEN LOWER(t.status) IN ('resolved', 'closed')
          THEN 1 ELSE 0 END
        ) AS completed_tickets
      FROM ${AppDatabase.usersTable} u
      LEFT JOIN ${AppDatabase.departmentsTable} d ON u.departmentId = d.id
      LEFT JOIN ${AppDatabase.ticketsTable} t
        ON u.id = t.createdByUserId
        AND DATE(t.createdAt) BETWEEN ? AND ?
      GROUP BY
        u.id,
        u.fullName,
        u.username,
        u.role,
        d.name,
        u.isActive,
        u.lastLoginAt
      ORDER BY u.role ASC, u.fullName ASC
      ''',
      [startDate, endDate],
    );
    return rows.map(UserReportDto.fromMap).toList(growable: false);
  }
}
