import 'package:equatable/equatable.dart';

class HrSop extends Equatable {
  const HrSop({
    required this.id,
    required this.title,
    required this.role,
    required this.content,
  });

  final int id;
  final String title;
  final String role;
  final String content;

  factory HrSop.fromJson(Map<String, dynamic> json) {
    return HrSop(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      title: (json['title'] as String?) ?? '',
      role: (json['role'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
    );
  }

  @override
  List<Object?> get props => [id, title, role, content];
}

class HrTask extends Equatable {
  const HrTask({
    required this.id,
    required this.title,
    this.assignedTo,
    this.dueDate,
    required this.status,
  });

  final int id;
  final String title;
  final int? assignedTo;
  final DateTime? dueDate;
  final String status;

  factory HrTask.fromJson(Map<String, dynamic> json) {
    return HrTask(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      title: (json['title'] as String?) ?? '',
      assignedTo: int.tryParse((json['assigned_to'] ?? '').toString()),
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString())
          : null,
      status: (json['status'] as String?) ?? 'pending',
    );
  }

  @override
  List<Object?> get props => [id, title, assignedTo, dueDate, status];
}

class HrSchedule extends Equatable {
  const HrSchedule({
    required this.id,
    required this.userId,
    required this.role,
    this.startTime,
    this.endTime,
  });

  final int id;
  final int userId;
  final String role;
  final DateTime? startTime;
  final DateTime? endTime;

  factory HrSchedule.fromJson(Map<String, dynamic> json) {
    return HrSchedule(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      userId: int.tryParse((json['user_id'] ?? '0').toString()) ?? 0,
      role: (json['role'] as String?) ?? '',
      startTime: json['start_time'] != null
          ? DateTime.tryParse(json['start_time'].toString())
          : null,
      endTime: json['end_time'] != null
          ? DateTime.tryParse(json['end_time'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [id, userId, role, startTime, endTime];
}

class HrSopExecution extends Equatable {
  const HrSopExecution({
    required this.sopId,
    required this.status,
    this.notes,
    this.executedAt,
  });

  final int sopId;
  final String status;
  final String? notes;
  final DateTime? executedAt;

  factory HrSopExecution.fromJson(Map<String, dynamic> json) {
    return HrSopExecution(
      sopId: int.tryParse((json['sop_id'] ?? '0').toString()) ?? 0,
      status: (json['status'] as String?) ?? '',
      notes: json['notes'] as String?,
      executedAt: json['executed_at'] != null
          ? DateTime.tryParse(json['executed_at'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [sopId, status, notes, executedAt];
}

class HrAttendance extends Equatable {
  const HrAttendance({
    required this.id,
    required this.userId,
    this.scheduleId,
    this.clockIn,
    this.clockOut,
    this.source,
    this.notes,
  });

  final int id;
  final int userId;
  final int? scheduleId;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final String? source;
  final String? notes;

  factory HrAttendance.fromJson(Map<String, dynamic> json) {
    return HrAttendance(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      userId: int.tryParse((json['user_id'] ?? '0').toString()) ?? 0,
      scheduleId: int.tryParse((json['schedule_id'] ?? '').toString()),
      clockIn: json['clock_in'] != null
          ? DateTime.tryParse(json['clock_in'].toString())
          : null,
      clockOut: json['clock_out'] != null
          ? DateTime.tryParse(json['clock_out'].toString())
          : null,
      source: json['source'] as String?,
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, userId, clockIn, clockOut];
}

class HrCompensation extends Equatable {
  const HrCompensation({
    required this.id,
    required this.employeeId,
    required this.payType,
    required this.hourlyRate,
    required this.salaryAmount,
    required this.currency,
    this.effectiveFrom,
    required this.active,
  });

  final int id;
  final int employeeId;
  final String payType;
  final double hourlyRate;
  final double salaryAmount;
  final String currency;
  final DateTime? effectiveFrom;
  final bool active;

  factory HrCompensation.fromJson(Map<String, dynamic> json) {
    return HrCompensation(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      employeeId: int.tryParse((json['employee_id'] ?? '0').toString()) ?? 0,
      payType: (json['pay_type'] as String?) ?? 'hourly',
      hourlyRate: double.tryParse((json['hourly_rate'] ?? '0').toString()) ?? 0.0,
      salaryAmount:
          double.tryParse((json['salary_amount'] ?? '0').toString()) ?? 0.0,
      currency: (json['currency'] as String?) ?? 'USD',
      effectiveFrom: json['effective_from'] != null
          ? DateTime.tryParse(json['effective_from'].toString())
          : null,
      active: (json['active']?.toString() ?? '1') == '1',
    );
  }

  @override
  List<Object?> get props => [id, employeeId, payType, effectiveFrom, active];
}

class HrBenefitEnrollment extends Equatable {
  const HrBenefitEnrollment({
    required this.id,
    required this.benefitId,
    required this.employeeId,
    this.startDate,
    this.endDate,
    required this.employeeDeduction,
    required this.employerContribution,
    required this.status,
  });

  final int id;
  final int benefitId;
  final int employeeId;
  final DateTime? startDate;
  final DateTime? endDate;
  final double employeeDeduction;
  final double employerContribution;
  final String status;

  factory HrBenefitEnrollment.fromJson(Map<String, dynamic> json) {
    return HrBenefitEnrollment(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      benefitId: int.tryParse((json['benefit_id'] ?? '0').toString()) ?? 0,
      employeeId: int.tryParse((json['employee_id'] ?? '0').toString()) ?? 0,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString())
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())
          : null,
      employeeDeduction:
          double.tryParse((json['employee_deduction'] ?? '0').toString()) ?? 0.0,
      employerContribution: double.tryParse(
              (json['employer_contribution'] ?? '0').toString()) ??
          0.0,
      status: (json['status'] as String?) ?? 'active',
    );
  }

  @override
  List<Object?> get props => [id, benefitId, employeeId, status];
}

class HrContractorLog extends Equatable {
  const HrContractorLog({
    required this.id,
    required this.contractorId,
    this.workDate,
    required this.hours,
    required this.hourlyRate,
    this.description,
    required this.status,
  });

  final int id;
  final int contractorId;
  final DateTime? workDate;
  final double hours;
  final double hourlyRate;
  final String? description;
  final String status;

  double get totalCost => hours * hourlyRate;

  factory HrContractorLog.fromJson(Map<String, dynamic> json) {
    return HrContractorLog(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      contractorId: int.tryParse((json['contractor_id'] ?? '0').toString()) ?? 0,
      workDate: json['work_date'] != null
          ? DateTime.tryParse(json['work_date'].toString())
          : null,
      hours: double.tryParse((json['hours'] ?? '0').toString()) ?? 0.0,
      hourlyRate:
          double.tryParse((json['hourly_rate'] ?? '0').toString()) ?? 0.0,
      description: json['description'] as String?,
      status: (json['status'] as String?) ?? 'unbilled',
    );
  }

  @override
  List<Object?> get props => [id, contractorId, workDate, hours, hourlyRate];
}

class HrTrainingCourse extends Equatable {
  const HrTrainingCourse({
    required this.id,
    required this.title,
    this.description,
    this.competencyArea,
    required this.recurrenceDays,
    required this.active,
  });

  final int id;
  final String title;
  final String? description;
  final String? competencyArea;
  final int recurrenceDays;
  final bool active;

  factory HrTrainingCourse.fromJson(Map<String, dynamic> json) {
    return HrTrainingCourse(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      title: (json['title'] as String?) ?? '',
      description: json['description'] as String?,
      competencyArea: json['competency_area'] as String?,
      recurrenceDays:
          int.tryParse((json['recurrence_days'] ?? '0').toString()) ?? 0,
      active: (json['active']?.toString() ?? '1') == '1',
    );
  }

  @override
  List<Object?> get props => [id, title, active];
}

class HrTrainingRecord extends Equatable {
  const HrTrainingRecord({
    required this.id,
    required this.courseId,
    required this.employeeId,
    this.completedOn,
    this.expiryDate,
    required this.status,
    this.notes,
  });

  final int id;
  final int courseId;
  final int employeeId;
  final DateTime? completedOn;
  final DateTime? expiryDate;
  final String status;
  final String? notes;

  factory HrTrainingRecord.fromJson(Map<String, dynamic> json) {
    return HrTrainingRecord(
      id: int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      courseId: int.tryParse((json['course_id'] ?? '0').toString()) ?? 0,
      employeeId: int.tryParse((json['employee_id'] ?? '0').toString()) ?? 0,
      completedOn: json['completed_on'] != null
          ? DateTime.tryParse(json['completed_on'].toString())
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'].toString())
          : null,
      status: (json['status'] as String?) ?? 'valid',
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, courseId, employeeId, status, expiryDate];
}
