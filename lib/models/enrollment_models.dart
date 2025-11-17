class ProgramModel {
  final String id;
  final String serviceId;
  final String name;
  final String code;
  final String dailyRate;
  final String sessionRate;
  final String sessions;
  final String duration;
  final String service;
  final String itoken;

  ProgramModel({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.code,
    required this.dailyRate,
    required this.sessionRate,
    required this.sessions,
    required this.duration,
    required this.service,
    required this.itoken,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    final program = ProgramModel(
      id: json['id']?.toString() ?? '',
      serviceId: json['sid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      dailyRate: json['drate']?.toString() ?? '0.00',
      sessionRate: json['srate']?.toString() ?? '0.00',
      sessions: json['ses']?.toString() ?? '0',
      duration: json['dur']?.toString() ?? '0',
      service: json['service']?.toString() ?? '',
      itoken: json['itoken']?.toString() ?? '',
    );

    // Debug logging to see actual values
    print('📦 Program: ${program.name}');
    print('   code: "${program.code}"');
    print('   service field: "${program.service}"');
    print('   serviceId field: "${program.serviceId}"');
    print('   isConsumable: ${program.isConsumable}');
    print('   isPersonalTraining: ${program.isPersonalTraining}');
    print('   sessions: ${program.sessions}, duration: ${program.duration}');

    return program;
  }

  // service field is the id_service from database:
  // '1' = Monthly (regular gym membership)
  // '2' = Consumable (session-based with sessions and duration)
  bool get isConsumable => service == '2';

  // Check if this is a Personal Training program
  bool get isPersonalTraining =>
      name.toLowerCase().contains('personal training') ||
      name.toLowerCase().contains('pt') ||
      code.toUpperCase() == 'PT' ||
      code.toLowerCase().contains('personal');

  String get displayRate {
    if (isConsumable) return '₱$sessionRate/session';
    return '₱$sessionRate/month';
  }

  String get displayDuration {
    if (isConsumable) return '$sessions sessions';
    return '1 month';
  }
}

class BranchProgramsModel {
  final String branchId;
  final String branchName;
  final List<ProgramModel> programs;

  BranchProgramsModel({
    required this.branchId,
    required this.branchName,
    required this.programs,
  });

  factory BranchProgramsModel.fromJson(Map<String, dynamic> json) {
    final List<ProgramModel> programs = [];
    if (json['data'] != null && json['data'] is List) {
      for (var programData in json['data']) {
        programs.add(ProgramModel.fromJson(programData));
      }
    }

    return BranchProgramsModel(
      branchId: json['id']?.toString() ?? '',
      branchName: json['branch']?.toString() ?? '',
      programs: programs,
    );
  }
}

class TrainorModel {
  final String id;
  final String branchId;
  final String name;

  TrainorModel({
    required this.id,
    required this.branchId,
    required this.name,
  });

  factory TrainorModel.fromJson(Map<String, dynamic> json) {
    return TrainorModel(
      id: json['id']?.toString() ?? '',
      branchId: json['id_branch']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class EnrollmentResponse {
  final List<String> enrolledProgramIds;
  final List<TrainorModel> trainors;
  final List<BranchProgramsModel> branchPrograms;

  EnrollmentResponse({
    required this.enrolledProgramIds,
    required this.trainors,
    required this.branchPrograms,
  });

  factory EnrollmentResponse.fromJson(Map<String, dynamic> json) {
    final List<TrainorModel> trainors = [];
    if (json['trainors'] != null && json['trainors'] is List) {
      for (var trainorData in json['trainors']) {
        trainors.add(TrainorModel.fromJson(trainorData));
      }
    }

    final List<BranchProgramsModel> branchPrograms = [];
    if (json['programs'] != null && json['programs'] is List) {
      for (var branchData in json['programs']) {
        branchPrograms.add(BranchProgramsModel.fromJson(branchData));
      }
    }

    // Handle both old 'pid' (single) and new 'pids' (multiple) format
    List<String> enrolledIds = [];
    if (json['pids'] != null && json['pids'] is List) {
      // New format - multiple enrolled programs
      enrolledIds = (json['pids'] as List)
          .map((id) => id.toString())
          .where((id) => id.isNotEmpty && id != '0')
          .toList();
    } else if (json['pid'] != null) {
      // Old format - single enrolled program (backward compatibility)
      final pid = json['pid'].toString();
      if (pid.isNotEmpty && pid != '0') {
        enrolledIds = [pid];
      }
    }

    return EnrollmentResponse(
      enrolledProgramIds: enrolledIds,
      trainors: trainors,
      branchPrograms: branchPrograms,
    );
  }

  bool get hasActiveEnrollment => enrolledProgramIds.isNotEmpty;

  // Check if a specific program is enrolled
  bool isProgramEnrolled(String programId) {
    return enrolledProgramIds.contains(programId);
  }

  // Get count of active enrollments
  int get enrollmentCount => enrolledProgramIds.length;

  List<TrainorModel> getTrainorsByBranch(String branchId) {
    return trainors.where((t) => t.branchId == branchId).toList();
  }
}
