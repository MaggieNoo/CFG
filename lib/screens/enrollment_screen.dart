import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/enrollment_models.dart';
import '../services/enrollment_api_service.dart';
import '../utils/constants.dart';

class EnrollmentScreen extends StatefulWidget {
  final UserModel user;

  const EnrollmentScreen({super.key, required this.user});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  bool _isLoading = true;
  EnrollmentResponse? _enrollmentData;
  String? _errorMessage;
  String? _expandedBranchId;

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result =
          await EnrollmentApiService.getProgramsAndTrainors(widget.user.token);

      if (result['success']) {
        setState(() {
          _enrollmentData = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load programs: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPrograms,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPrograms,
      child: _enrollmentData == null
          ? const Center(child: Text('No programs available'))
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_enrollmentData!.hasActiveEnrollment)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.green[50],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green[700], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Active Enrollments (${_enrollmentData!.enrollmentCount})',
                                  style: TextStyle(
                                    color: Colors.green[900],
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You can enroll in one regular program and one Personal Training program simultaneously.',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select a Program',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose from available programs by branch',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._enrollmentData!.branchPrograms.map((branch) {
                    final isExpanded = _expandedBranchId == branch.branchId;
                    return _buildBranchCard(branch, isExpanded);
                  }).toList(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }

  Widget _buildBranchCard(BranchProgramsModel branch, bool isExpanded) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_on,
                color: AppConstants.primaryColor,
                size: 24,
              ),
            ),
            title: Text(
              branch.branchName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              '${branch.programs.length} programs available',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppConstants.primaryColor,
            ),
            onTap: () {
              setState(() {
                _expandedBranchId = isExpanded ? null : branch.branchId;
              });
            },
          ),
          if (isExpanded)
            Column(
              children: branch.programs
                  .map((program) => _buildProgramTile(program, branch))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildProgramTile(ProgramModel program, BranchProgramsModel branch) {
    final isEnrolled = _enrollmentData!.isProgramEnrolled(program.id);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isEnrolled ? AppConstants.primaryColor : Colors.grey[300]!,
          width: isEnrolled ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isEnrolled ? AppConstants.primaryColor.withOpacity(0.05) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Expanded(
              child: Text(
                program.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            if (isEnrolled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Enrolled',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.payments, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    program.displayRate,
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    program.displayDuration,
                    style: TextStyle(color: Colors.grey[700]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getServiceColor(program).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getServiceLabel(program),
                    style: TextStyle(
                      color: _getServiceColor(program),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (program.isPersonalTraining) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.purple.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person, size: 12, color: Colors.purple[700]),
                        const SizedBox(width: 4),
                        Text(
                          'PT',
                          style: TextStyle(
                            color: Colors.purple[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: isEnrolled
            ? Icon(Icons.check_circle, color: Colors.green, size: 32)
            : ElevatedButton(
                onPressed: _canEnrollInProgram(program)
                    ? () => _showEnrollmentDialog(program, branch)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Enroll'),
              ),
      ),
    );
  }

  Color _getServiceColor(ProgramModel program) {
    // service '1' = Monthly (regular), '2' = Consumable (session-based)
    if (program.isConsumable) return Colors.orange;
    return Colors.green;
  }

  String _getServiceLabel(ProgramModel program) {
    return program.isConsumable ? 'Consumable' : 'Monthly';
  }

  bool _canEnrollInProgram(ProgramModel program) {
    // If no enrollments, can enroll in anything
    if (!_enrollmentData!.hasActiveEnrollment) return true;

    // Check if trying to enroll in same program type
    final enrolledPrograms = _enrollmentData!.branchPrograms
        .expand((branch) => branch.programs)
        .where((p) => _enrollmentData!.isProgramEnrolled(p.id))
        .toList();

    final hasRegularProgram =
        enrolledPrograms.any((p) => !p.isPersonalTraining);
    final hasPTProgram = enrolledPrograms.any((p) => p.isPersonalTraining);

    if (program.isPersonalTraining) {
      // Can enroll in PT if don't have PT yet
      return !hasPTProgram;
    } else {
      // Can enroll in regular if don't have regular yet
      return !hasRegularProgram;
    }
  }

  void _showEnrollmentDialog(ProgramModel program, BranchProgramsModel branch) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _EnrollmentFormScreen(
          program: program,
          branch: branch,
          user: widget.user,
          trainors: _enrollmentData!.getTrainorsByBranch(branch.branchId),
          onSuccess: () {
            _loadPrograms();
          },
        ),
      ),
    );
  }
}

class _EnrollmentFormScreen extends StatefulWidget {
  final ProgramModel program;
  final BranchProgramsModel branch;
  final UserModel user;
  final List<TrainorModel> trainors;
  final VoidCallback onSuccess;

  const _EnrollmentFormScreen({
    required this.program,
    required this.branch,
    required this.user,
    required this.trainors,
    required this.onSuccess,
  });

  @override
  State<_EnrollmentFormScreen> createState() => _EnrollmentFormScreenState();
}

class _EnrollmentFormScreenState extends State<_EnrollmentFormScreen> {
  String? selectedType; // '1' for Daily, '2' for Consumable
  TrainorModel? selectedTrainor;
  final amountController = TextEditingController();
  final amountPaidController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  bool datesEnabled = false;

  @override
  void dispose() {
    amountController.dispose();
    amountPaidController.dispose();
    super.dispose();
  }

  void _onTypeChanged(String? value) {
    setState(() {
      selectedType = value;
      startDate = null;
      endDate = null;

      if (value == '1') {
        // Daily
        amountController.text = widget.program.dailyRate;
        datesEnabled = false;
      } else if (value == '2') {
        // Consumable
        amountController.text = widget.program.sessionRate;
        datesEnabled = true;
      }
    });
  }

  void _onStartDateChanged(DateTime picked) {
    setState(() {
      startDate = picked;
      // Auto-calculate end date for Monthly/Consumable (type='2')
      if (selectedType == '2') {
        if (widget.program.isConsumable) {
          // For Consumable programs, use duration field (in days)
          final duration = int.tryParse(widget.program.duration) ?? 30;
          endDate = picked.add(Duration(days: duration));
        } else {
          // For Monthly programs, add 1 month
          endDate = DateTime(picked.year, picked.month + 1, picked.day);
        }
      }
    });
  }

  Future<void> _submitEnrollment() async {
    // Validation
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select enrollment type')),
      );
      return;
    }

    if (amountPaidController.text.isEmpty ||
        double.tryParse(amountPaidController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    // For Consumable (type='2'), dates are required
    if (selectedType == '2') {
      if (startDate == null || endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Start and end dates are required for Consumable')),
        );
        return;
      }
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final result = await EnrollmentApiService.submitEnrollment(
        itoken: widget.user.token,
        programToken: widget.program.itoken,
        type: selectedType!,
        amountPaid: amountPaidController.text,
        trainorId: selectedTrainor?.id ?? '',
        startDate: startDate ?? DateTime.now(),
        endDate: endDate,
      );

      // Close loading dialog
      Navigator.pop(context);

      if (result['success']) {
        // Close enrollment form first
        Navigator.pop(context);

        // Show success dialog
        _showSuccessDialog(context);

        // Reload data
        widget.onSuccess();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Enrollment failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade50,
                  Colors.white,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success icon with animation
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green.shade600,
                      size: 70,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Enrollment Successful! ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Program name highlight
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          color: Colors.green.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.program.name,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Success message
                  Text(
                    'You\'re all set! Your enrollment has been confirmed.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Next steps
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.blue.shade100,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Visit the Dashboard to view your enrollment details and start tracking your progress!',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade900,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // OK Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Got it!',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enroll: ${widget.program.name}'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Program Info Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 20, color: AppConstants.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          widget.branch.branchName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Rates Display
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Daily',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.program.dailyRate}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Consumable',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.program.sessionRate}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Type Selection
            const Text(
              'Type',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[50],
              ),
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedType,
                    hint: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Text('Select Type'),
                    ),
                    isExpanded: true,
                    icon: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.arrow_drop_down),
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    elevation: 3,
                    itemHeight: 60,
                    items: [
                      DropdownMenuItem(
                        value: '1',
                        child: Container(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 15, bottom: 20),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey.shade200, width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 20, color: Colors.blue.shade700),
                              const SizedBox(width: 12),
                              const Text('Daily',
                                  style: TextStyle(fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: '2',
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Icon(Icons.shopping_bag,
                                  size: 20, color: Colors.orange.shade700),
                              const SizedBox(width: 12),
                              Text(
                                  widget.program.isConsumable
                                      ? 'Consumable'
                                      : 'Monthly',
                                  style: const TextStyle(fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                    ],
                    onChanged: _onTypeChanged,
                    selectedItemBuilder: (BuildContext context) {
                      return ['1', '2'].map<Widget>((String value) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(
                                  value == '1'
                                      ? Icons.calendar_today
                                      : Icons.shopping_bag,
                                  size: 18,
                                  color: value == '1'
                                      ? Colors.blue.shade700
                                      : Colors.orange.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  value == '1'
                                      ? 'Daily'
                                      : (widget.program.isConsumable
                                          ? 'Consumable'
                                          : 'Monthly'),
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Amount (Read-only)
            const Text(
              'Amount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              readOnly: true,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                prefixText: ' ',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 20),

            // Amount Paid
            const Text(
              'Amount Paid',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountPaidController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixText: ' ',
                hintText: '0.00',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // Show Sessions and Duration when Consumable type is selected
            if (selectedType == '2' && widget.program.isConsumable) ...[
              Card(
                elevation: 0,
                color: Colors.orange[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.orange[200]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.orange[700], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Consumable Package Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.orange[200]!),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.fitness_center,
                                      color: Colors.orange[700], size: 24),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${widget.program.sessions} Sessions',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.orange[900],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Will be deducted\non each use',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.orange[200]!),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.schedule,
                                      color: Colors.orange[700], size: 24),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${widget.program.duration} Days',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.orange[900],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Validity period\nfrom start date',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            const Divider(thickness: 1),
            const SizedBox(height: 24),

            // Trainor Selection (Optional)
            Row(
              children: [
                const Text(
                  'Trainor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    'Optional',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[50],
              ),
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<TrainorModel>(
                    value: selectedTrainor,
                    hint: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Text('Select Trainor (Optional)'),
                    ),
                    isExpanded: true,
                    icon: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.arrow_drop_down),
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    elevation: 3,
                    itemHeight: 60,
                    items: widget.trainors.asMap().entries.map((entry) {
                      final index = entry.key;
                      final trainor = entry.value;
                      final isLast = index == widget.trainors.length - 1;

                      return DropdownMenuItem(
                        value: trainor,
                        child: Container(
                          padding: isLast
                              ? const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12)
                              : const EdgeInsets.only(
                                  left: 16, right: 16, top: 15, bottom: 20),
                          decoration: BoxDecoration(
                            border: isLast
                                ? null
                                : Border(
                                    bottom: BorderSide(
                                        color: Colors.grey.shade200, width: 1),
                                  ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.person,
                                  size: 20, color: Colors.blue.shade600),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  trainor.name,
                                  style: const TextStyle(fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTrainor = value;
                      });
                    },
                    selectedItemBuilder: (BuildContext context) {
                      return widget.trainors
                          .map<Widget>((TrainorModel trainor) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(Icons.person,
                                    size: 18, color: Colors.blue.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    selectedTrainor?.name ??
                                        'Select Trainor (Optional)',
                                    style: const TextStyle(
                                        fontSize: 15, color: Colors.black87),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[700],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can enroll independently or select a trainer if you prefer personalized guidance.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[900],
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Starting Date
            const Text(
              'Starting Date',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: !datesEnabled
                  ? null
                  : () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        _onStartDateChanged(picked);
                      }
                    },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: datesEnabled ? Colors.grey : Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                  color: datesEnabled ? Colors.white : Colors.grey[100],
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 20,
                        color: datesEnabled
                            ? AppConstants.primaryColor
                            : Colors.grey[400]),
                    const SizedBox(width: 12),
                    Text(
                      startDate != null
                          ? DateFormat('MM/dd/yyyy').format(startDate!)
                          : 'Select date',
                      style: TextStyle(
                        color: datesEnabled ? Colors.black : Colors.grey[400],
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Ending Date (Auto-calculated)
            const Text(
              'Ending Date',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[100],
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 20, color: Colors.grey[400]),
                  const SizedBox(width: 12),
                  Text(
                    endDate != null
                        ? DateFormat('MM/dd/yyyy').format(endDate!)
                        : 'mm/dd/yyyy',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitEnrollment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'SAVE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
