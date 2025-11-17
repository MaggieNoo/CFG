class TimeInOutModel {
  final String enrollmentId;
  final String branch;
  final String program;
  final String trainor;
  final String amount;
  final String paid;
  final String duration;
  final String sessions;
  final String isDaily;
  final String? timeIn;
  final String? timeOut;
  final String? dtrId;
  final bool hasTimedOut;
  final bool requiresPayment;
  final bool displayPayment;
  final bool requestsPayment;
  final bool closeAfter;
  final String
      action; // "1" = time-out, "2" = pay, "3" = pay+time-out, "6" = select enrollment
  final String buttonOne;
  final String buttonTwo;

  TimeInOutModel({
    required this.enrollmentId,
    required this.branch,
    required this.program,
    required this.trainor,
    required this.amount,
    required this.paid,
    required this.duration,
    required this.sessions,
    required this.isDaily,
    this.timeIn,
    this.timeOut,
    this.dtrId,
    required this.hasTimedOut,
    required this.requiresPayment,
    required this.displayPayment,
    required this.requestsPayment,
    required this.closeAfter,
    required this.action,
    required this.buttonOne,
    required this.buttonTwo,
  });

  factory TimeInOutModel.fromJson(Map<String, dynamic> json) {
    return TimeInOutModel(
      enrollmentId:
          json['id_enroll']?.toString() ?? json['id']?.toString() ?? '',
      branch: json['branch']?.toString() ?? '',
      program: json['program']?.toString() ?? '',
      trainor: json['trainor']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      paid: json['paid']?.toString() ?? '0.00',
      duration: json['dur']?.toString() ?? '0',
      sessions: json['ses']?.toString() ?? '0',
      isDaily: json['is_daily']?.toString() ?? '0',
      timeIn: json['t_in']?.toString(),
      timeOut: json['t_out']?.toString(),
      dtrId: json['idout']?.toString(),
      hasTimedOut: json['out']?.toString() == '1',
      requiresPayment: json['req']?.toString() == 'true' || json['req'] == true,
      displayPayment: json['p']?.toString() == '1',
      requestsPayment: json['d']?.toString() == '3',
      closeAfter: json['cl']?.toString() == 'true' || json['cl'] == true,
      action: json['d']?.toString() ?? '1',
      buttonOne: json['btn1']?.toString() ?? '',
      buttonTwo: json['btn2']?.toString() ?? '',
    );
  }

  bool get needsPayment => requiresPayment || requestsPayment;
  bool get canTimeOut => hasTimedOut && !needsPayment;
  bool get showPayButton => displayPayment;
}

// Model for enrollment option when user has multiple enrollments
class EnrollmentOption {
  final String id;
  final String program;
  final String trainor;
  final String isDaily;
  final String amount;
  final String paid;
  final String? daysLeft;
  final String? sessionsUsed;
  final String? totalSessions;

  EnrollmentOption({
    required this.id,
    required this.program,
    required this.trainor,
    required this.isDaily,
    required this.amount,
    required this.paid,
    this.daysLeft,
    this.sessionsUsed,
    this.totalSessions,
  });

  factory EnrollmentOption.fromJson(Map<String, dynamic> json) {
    return EnrollmentOption(
      id: json['id']?.toString() ?? '',
      program: json['program']?.toString() ?? '',
      trainor: json['trainor']?.toString() ?? '',
      isDaily: json['is_daily']?.toString() ?? '0',
      amount: json['amount']?.toString() ?? '0.00',
      paid: json['paid']?.toString() ?? '0.00',
      daysLeft: json['days_left']?.toString(),
      sessionsUsed: json['sessions_used']?.toString(),
      totalSessions: json['total_sessions']?.toString(),
    );
  }

  String get typeLabel => isDaily == '1' ? 'Daily' : 'Monthly/Consumable';

  String get sessionInfo {
    if (totalSessions == null || totalSessions == '0') {
      return 'N/A sessions';
    }
    final used = sessionsUsed ?? '0';
    return '$used/$totalSessions sessions';
  }

  String get daysLeftInfo {
    if (daysLeft == null || daysLeft == '0') {
      return 'Expired';
    }
    return '$daysLeft days left';
  }
}

class TimeInOutResponse {
  final String result;
  final String message;
  final TimeInOutModel? attendance;
  final List<EnrollmentOption>? enrollmentOptions; // For multiple enrollments

  TimeInOutResponse({
    required this.result,
    required this.message,
    this.attendance,
    this.enrollmentOptions,
  });

  factory TimeInOutResponse.fromJson(Map<String, dynamic> json) {
    // Extract message from data field
    String rawMessage = json['data']?.toString() ?? '';

    // Check if this is a multiple enrollment selection response (d=6)
    if (json['d']?.toString() == '6' && json['enrollments'] != null) {
      List<EnrollmentOption> options = [];
      try {
        List<dynamic> enrollmentsList = json['enrollments'] as List<dynamic>;
        for (var enrollment in enrollmentsList) {
          options.add(
              EnrollmentOption.fromJson(enrollment as Map<String, dynamic>));
        }
      } catch (e) {
        print('❌ Error parsing enrollment options: $e');
      }

      return TimeInOutResponse(
        result: json['result']?.toString() ?? '0',
        message: rawMessage,
        attendance: null,
        enrollmentOptions: options,
      );
    }

    // If we have attendance data, create the model
    // Only create if idout has a valid value (not empty string)
    TimeInOutModel? attendanceModel;
    String idout = json['idout']?.toString() ?? '';
    String btn1 = json['btn1']?.toString() ?? '';

    // Create attendance model if we have a DTR ID OR if we have action buttons
    // (buttons indicate there's an active attendance session)
    if (idout.isNotEmpty || btn1.isNotEmpty) {
      try {
        attendanceModel = TimeInOutModel.fromJson(json);
      } catch (e) {
        print('❌ Error parsing TimeInOutModel: $e');
        // If parsing fails, attendance will remain null
      }
    }

    return TimeInOutResponse(
      result: json['result']?.toString() ?? '0',
      message: rawMessage,
      attendance: attendanceModel,
      enrollmentOptions: null,
    );
  }

  bool get isSuccess => result == '1';
  bool get hasMultipleEnrollments =>
      enrollmentOptions != null && enrollmentOptions!.isNotEmpty;
}

class TimeActionResponse {
  final String result;
  final String message;

  TimeActionResponse({
    required this.result,
    required this.message,
  });

  factory TimeActionResponse.fromJson(Map<String, dynamic> json) {
    return TimeActionResponse(
      result: json['result']?.toString() ?? '0',
      message: json['data']?.toString() ?? '',
    );
  }

  bool get isSuccess => result == '1';
}
