import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/hr.dart';

class HrService {
  const HrService(this._api);

  final ApiClient _api;

  Future<List<HrSop>> listSops() async {
    final list = await _api.getList(ApiEndpoints.hrSops);
    return list.map((e) => HrSop.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createSop({
    required String title,
    required String role,
    required String content,
  }) async {
    await _api.post(ApiEndpoints.hrSops, data: {
      'title': title,
      'role': role,
      'content': content,
    });
  }

  Future<List<HrTask>> listTasks() async {
    final list = await _api.getList(ApiEndpoints.hrTasks);
    return list.map((e) => HrTask.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createTask({
    required String title,
    required DateTime dueDate,
    int? assignedTo,
  }) async {
    await _api.post(ApiEndpoints.hrTasks, data: {
      'title': title,
      'due_date': _formatDate(dueDate),
      if (assignedTo != null) 'assigned_to': assignedTo,
    });
  }

  Future<List<HrSchedule>> listSchedules() async {
    final list = await _api.getList(ApiEndpoints.hrSchedules);
    return list
        .map((e) => HrSchedule.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createSchedule({
    required int userId,
    required String role,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    await _api.post(ApiEndpoints.hrSchedules, data: {
      'user_id': userId,
      'role': role,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
    });
  }

  Future<List<HrSopExecution>> listExecutions() async {
    final list = await _api.getList(ApiEndpoints.hrSopExecutions);
    return list
        .map((e) => HrSopExecution.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> runSop({
    required int sopId,
    required String status,
    String? notes,
  }) async {
    await _api.post(ApiEndpoints.hrSopRun, data: {
      'sop_id': sopId,
      'status': status,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }

  Future<List<dynamic>> listPayroll({int? farmId}) async {
    return _api.getList(
      ApiEndpoints.hrPayroll,
      params: farmId != null ? {'farm_id': farmId} : null,
    );
  }

  Future<void> createPayroll({
    required int farmId,
    required int employeeId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime payDate,
    required double grossAmount,
    required double netAmount,
    required String status,
    String? notes,
  }) async {
    await _api.post(ApiEndpoints.hrPayroll, data: {
      'farm_id': farmId,
      'employee_id': employeeId,
      'period_start': _formatDate(periodStart),
      'period_end': _formatDate(periodEnd),
      'pay_date': _formatDate(payDate),
      'gross_amount': grossAmount,
      'net_amount': netAmount,
      'status': status,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }

  Future<List<dynamic>> listBenefits({int? farmId}) async {
    return _api.getList(
      ApiEndpoints.hrBenefits,
      params: farmId != null ? {'farm_id': farmId} : null,
    );
  }

  Future<void> createBenefit({
    required int farmId,
    required String name,
    required String benefitType,
    String? coverage,
    bool isActive = true,
  }) async {
    await _api.post(ApiEndpoints.hrBenefits, data: {
      'farm_id': farmId,
      'name': name,
      'benefit_type': benefitType,
      'coverage': coverage,
      'active': isActive ? 1 : 0,
    });
  }

  Future<List<dynamic>> listCertifications({int? farmId}) async {
    return _api.getList(
      ApiEndpoints.hrCertifications,
      params: farmId != null ? {'farm_id': farmId} : null,
    );
  }

  Future<void> createCertification({
    required int farmId,
    int? employeeId,
    required String title,
    required DateTime awardedOn,
    DateTime? expiryDate,
    String status = 'active',
    String? notes,
  }) async {
    await _api.post(ApiEndpoints.hrCertifications, data: {
      'farm_id': farmId,
      if (employeeId != null) 'employee_id': employeeId,
      'title': title,
      'awarded_on': _formatDate(awardedOn),
      if (expiryDate != null) 'expiry_date': _formatDate(expiryDate),
      'status': status,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }

  Future<List<dynamic>> listContractors({int? farmId}) async {
    return _api.getList(
      ApiEndpoints.hrContractors,
      params: farmId != null ? {'farm_id': farmId} : null,
    );
  }

  Future<void> createContractor({
    required int farmId,
    required String name,
    required String serviceArea,
    required double hourlyRate,
    bool isActive = true,
    String? notes,
  }) async {
    await _api.post(ApiEndpoints.hrContractors, data: {
      'farm_id': farmId,
      'name': name,
      'service_area': serviceArea,
      'hourly_rate': hourlyRate,
      'active': isActive ? 1 : 0,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }

  Future<Map<String, dynamic>> getWorkforceSnapshot({int? farmId}) async {
    final payroll = await listPayroll(farmId: farmId);
    final benefits = await listBenefits(farmId: farmId);
    final certifications = await listCertifications(farmId: farmId);
    final contractors = await listContractors(farmId: farmId);
    final enrollments = await listBenefitEnrollments(farmId: farmId);
    final trainings = await listTrainingCourses(farmId: farmId);
    return {
      'payroll_count': payroll.length,
      'benefit_count': benefits.length,
      'enrollment_count': enrollments.length,
      'certification_count': certifications.length,
      'contractor_count': contractors.length,
      'training_course_count': trainings.length,
    };
  }

  Future<List<HrAttendance>> listAttendance({
    required int farmId,
    int? userId,
    DateTime? from,
    DateTime? to,
  }) async {
    final params = <String, dynamic>{
      'farm_id': farmId,
      if (userId != null) 'user_id': userId,
      if (from != null) 'from': _formatDate(from),
      if (to != null) 'to': _formatDate(to),
    };
    final list = await _api.getList(ApiEndpoints.hrAttendance, params: params);
    return list
        .map((e) => HrAttendance.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> clockIn({
    required int farmId,
    int? userId,
    int? scheduleId,
    DateTime? clockIn,
    String source = 'manual',
    String? notes,
  }) async {
    await _api.post(ApiEndpoints.hrClockIn, data: {
      'farm_id': farmId,
      if (userId != null) 'user_id': userId,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (clockIn != null) 'clock_in': _formatDateTime(clockIn),
      'source': source,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }

  Future<void> clockOut({
    required int farmId,
    int? userId,
    DateTime? clockOut,
  }) async {
    await _api.post(ApiEndpoints.hrClockOut, data: {
      'farm_id': farmId,
      if (userId != null) 'user_id': userId,
      if (clockOut != null) 'clock_out': _formatDateTime(clockOut),
    });
  }

  Future<List<HrCompensation>> listCompensation({required int farmId}) async {
    final list = await _api.getList(
      ApiEndpoints.hrCompensation,
      params: {'farm_id': farmId},
    );
    return list
        .map((e) => HrCompensation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCompensation({
    required int farmId,
    required int employeeId,
    required String payType,
    double hourlyRate = 0,
    double salaryAmount = 0,
    String currency = 'USD',
    DateTime? effectiveFrom,
    bool active = true,
  }) async {
    await _api.post(ApiEndpoints.hrCompensation, data: {
      'farm_id': farmId,
      'employee_id': employeeId,
      'pay_type': payType,
      'hourly_rate': hourlyRate,
      'salary_amount': salaryAmount,
      'currency': currency,
      'effective_from': _formatDate(effectiveFrom ?? DateTime.now()),
      'active': active ? 1 : 0,
    });
  }

  Future<List<HrBenefitEnrollment>> listBenefitEnrollments({
    required int farmId,
  }) async {
    final list = await _api.getList(
      ApiEndpoints.hrBenefitEnrollments,
      params: {'farm_id': farmId},
    );
    return list
        .map((e) => HrBenefitEnrollment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> enrollBenefit({
    required int farmId,
    required int benefitId,
    required int employeeId,
    DateTime? startDate,
    DateTime? endDate,
    double employeeDeduction = 0,
    double employerContribution = 0,
  }) async {
    await _api.post(ApiEndpoints.hrBenefitEnrollments, data: {
      'farm_id': farmId,
      'benefit_id': benefitId,
      'employee_id': employeeId,
      'start_date': _formatDate(startDate ?? DateTime.now()),
      if (endDate != null) 'end_date': _formatDate(endDate),
      'employee_deduction': employeeDeduction,
      'employer_contribution': employerContribution,
    });
  }

  Future<Map<String, dynamic>> runPayroll({
    required int farmId,
    required DateTime periodStart,
    required DateTime periodEnd,
    DateTime? payDate,
    double taxRate = 0,
    double maxHoursPerDay = 12,
  }) async {
    return _api.post(ApiEndpoints.hrPayrollRun, data: {
      'farm_id': farmId,
      'period_start': _formatDate(periodStart),
      'period_end': _formatDate(periodEnd),
      'pay_date': _formatDate(payDate ?? periodEnd),
      'tax_rate': taxRate,
      'max_hours_per_day': maxHoursPerDay,
    });
  }

  Future<List<HrContractorLog>> listContractorLogs({required int farmId}) async {
    final list = await _api.getList(
      ApiEndpoints.hrContractorLogs,
      params: {'farm_id': farmId},
    );
    return list
        .map((e) => HrContractorLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createContractorLog({
    required int farmId,
    required int contractorId,
    required DateTime workDate,
    required double hours,
    required double hourlyRate,
    String? description,
  }) async {
    await _api.post(ApiEndpoints.hrContractorLogs, data: {
      'farm_id': farmId,
      'contractor_id': contractorId,
      'work_date': _formatDate(workDate),
      'hours': hours,
      'hourly_rate': hourlyRate,
      if (description != null && description.isNotEmpty) 'description': description,
    });
  }

  Future<List<HrTrainingCourse>> listTrainingCourses({required int farmId}) async {
    final list = await _api.getList(
      ApiEndpoints.hrTrainingCourses,
      params: {'farm_id': farmId},
    );
    return list
        .map((e) => HrTrainingCourse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createTrainingCourse({
    required int farmId,
    required String title,
    String? description,
    String? competencyArea,
    int recurrenceDays = 0,
    bool active = true,
  }) async {
    await _api.post(ApiEndpoints.hrTrainingCourses, data: {
      'farm_id': farmId,
      'title': title,
      if (description != null && description.isNotEmpty) 'description': description,
      if (competencyArea != null && competencyArea.isNotEmpty)
        'competency_area': competencyArea,
      'recurrence_days': recurrenceDays,
      'active': active ? 1 : 0,
    });
  }

  Future<List<HrTrainingRecord>> listTrainingRecords({
    required int farmId,
    int? employeeId,
    int? expiringDays,
  }) async {
    final params = <String, dynamic>{
      'farm_id': farmId,
      if (employeeId != null) 'employee_id': employeeId,
      if (expiringDays != null) 'expiring_days': expiringDays,
    };
    final list = await _api.getList(ApiEndpoints.hrTrainingRecords, params: params);
    return list
        .map((e) => HrTrainingRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createTrainingRecord({
    required int farmId,
    required int courseId,
    required int employeeId,
    required DateTime completedOn,
    DateTime? expiryDate,
    String? notes,
  }) async {
    await _api.post(ApiEndpoints.hrTrainingRecords, data: {
      'farm_id': farmId,
      'course_id': courseId,
      'employee_id': employeeId,
      'completed_on': _formatDate(completedOn),
      if (expiryDate != null) 'expiry_date': _formatDate(expiryDate),
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }

  String _formatDate(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatDateTime(DateTime value) {
    final dt = value.toLocal();
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm:$ss';
  }
}
