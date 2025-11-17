import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import '../services/dashboard_api_service.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';
import '../models/dashboard_models.dart';
import 'login_screen.dart';
import 'enrollment_screen.dart';
import 'timeinout_screen.dart';
import 'payment_screen.dart';
import 'profile_screen.dart';
import 'attendance_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [];

  final List<String> _titles = [
    'Camalig Fitness Gym',
    'Enroll to Program',
    'Time In/Out',
    'My Profile',
  ];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      _HomeTab(
        user: widget.user,
        onNavigateToTab: (index) {
          setState(() => _currentIndex = index);
        },
      ),
      EnrollmentScreen(user: widget.user),
      TimeInOutScreen(
        user: widget.user,
        showBottomNav: true,
        onNavigateToHome: () {
          setState(() => _currentIndex = 0); // Navigate back to Home tab
        },
        onNavigateToTab: (index) {
          setState(() => _currentIndex = index); // Navigate to specific tab
        },
      ),
      ProfileScreen(
        initialUser: widget.user,
        onNavigateToTab: (index) {
          setState(() => _currentIndex = index); // Navigate to requested tab
        },
      ),
    ]);
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.accentColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        title: Text(_titles[_currentIndex]),
        elevation: 0,
      ),
      drawer: _buildDrawer(),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Programs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            activeIcon: Icon(Icons.qr_code_scanner),
            label: 'Time In/Out',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppConstants.primaryColor, Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: widget.user.profileImage != null &&
                            widget.user.profileImage!.isNotEmpty
                        ? ClipOval(
                            child: Image.memory(
                              base64Decode(widget.user.profileImage!),
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppConstants.primaryColor,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 50,
                            color: AppConstants.primaryColor,
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.user.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.user.email,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.home_outlined,
                  title: 'Dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 0);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.fitness_center_outlined,
                  title: 'My Programs',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 1);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.history,
                  title: 'Attendance History',
                  onTap: () async {
                    Navigator.pop(context); // Close drawer
                    // Navigate to Attendance History screen
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttendanceHistoryScreen(
                          user: widget.user,
                        ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.payment_outlined,
                  title: 'Payment History',
                  onTap: () async {
                    Navigator.pop(context); // Close drawer
                    final result = await Navigator.push<int>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(
                          user: widget.user,
                          onNavigateToTab: (index) {
                            setState(() => _currentIndex = index);
                          },
                        ),
                      ),
                    );
                    // If a tab index was returned, navigate to that tab
                    if (result != null) {
                      setState(() => _currentIndex = result);
                    }
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: 'My Profile',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 3);
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () {
                    Navigator.pop(context);
                    _handleLogout();
                  },
                  color: AppConstants.accentColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppConstants.textSecondary),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? AppConstants.textPrimary,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}

// Home Tab
class _HomeTab extends StatefulWidget {
  final UserModel user;
  final Function(int)? onNavigateToTab;

  const _HomeTab({required this.user, this.onNavigateToTab});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  bool _isLoading = true;
  List<EnrollmentInfoModel> _enrollments = []; // Changed from single to List
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load enrollment info
      final enrollmentResult = await DashboardApiService.getEnrollmentInfo(
        widget.user.token,
      );

      print(' Dashboard - Enrollment Result: $enrollmentResult');

      if (enrollmentResult['success']) {
        final List<EnrollmentInfoModel> enrollments =
            enrollmentResult['enrollments'] ?? [];
        _enrollments = enrollments;
        print(' Dashboard - ${_enrollments.length} enrollment(s) loaded');
        for (var e in _enrollments) {
          print(
              '  - ${e.program} (${e.isPersonalTraining ? "PT" : "Regular"})');
        }
      } else {
        print(
            ' Dashboard - Enrollment failed: ${enrollmentResult['message']}');
        _enrollments = [];
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load dashboard data: $e';
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
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDashboardData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppConstants.primaryColor, Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.user.firstName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
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
                  // Quick Stats - Aggregated from all enrollments
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quick Stats',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                      if (_enrollments.length > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.accentColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_enrollments.length} Active Programs',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.fitness_center,
                          title: _enrollments.isEmpty
                              ? 'No Program'
                              : _enrollments.length == 1
                                  ? 'Program Type'
                                  : 'Programs',
                          value: _enrollments.isEmpty
                              ? 'N/A'
                              : _enrollments.length == 1
                                  ? _enrollments[0].program
                                  : '${_enrollments.length} Active',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.calendar_today,
                          title: 'Days Left',
                          value: _getMinDaysLeft(),
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.access_time,
                          title: 'Sessions Left',
                          value: _getTotalSessionsLeft(),
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.payments,
                          title: 'Total Balance',
                          value: _getTotalBalance(),
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Current Programs - Show all enrollments
                  if (_enrollments.isNotEmpty) ...[
                    const Text(
                      'Current Programs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Display each enrollment
                    ..._enrollments.map((enrollment) => Column(
                          children: [
                            _buildEnrollmentCard(enrollment),
                            const SizedBox(height: 16),
                          ],
                        )),
                  ],

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildActionCard(
                    context,
                    icon: Icons.login,
                    title: 'Time In',
                    subtitle: 'Mark your gym entry',
                    color: Colors.green,
                    onTap: () {
                      widget.onNavigateToTab
                          ?.call(2); // Navigate to Time In/Out tab
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildActionCard(
                    context,
                    icon: Icons.add_circle,
                    title: 'Enroll to Program',
                    subtitle: 'Join a new fitness program',
                    color: AppConstants.primaryColor,
                    onTap: () {
                      widget.onNavigateToTab
                          ?.call(1); // Navigate to Enrollment tab
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildActionCard(
                    context,
                    icon: Icons.payment,
                    title: 'Payment',
                    subtitle: 'View payment history',
                    color: Colors.orange,
                    onTap: () async {
                      final result = await Navigator.push<int>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(
                            user: widget.user,
                            onNavigateToTab: widget.onNavigateToTab,
                          ),
                        ),
                      );
                      // If a tab index was returned, navigate to that tab
                      if (result != null && widget.onNavigateToTab != null) {
                        widget.onNavigateToTab!(result);
                      }
                    },
                  ),
                ],
              ),
            ),

            // Bottom padding for better UX
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppConstants.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppConstants.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollmentStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // Helper methods for aggregating stats from multiple enrollments
  String _getMinDaysLeft() {
    if (_enrollments.isEmpty) return '0';
    final days = _enrollments.map((e) => e.daysLeft).toList();
    days.sort();
    return days.first.toString(); // Return the nearest expiration
  }

  String _getTotalSessionsLeft() {
    if (_enrollments.isEmpty) return 'N/A';
    int total = 0;
    bool hasSessionTracking = false;

    for (var enrollment in _enrollments) {
      if (enrollment.hasSessionTracking) {
        hasSessionTracking = true;
        total += enrollment.remainingSessions;
      }
    }

    return hasSessionTracking ? total.toString() : 'N/A';
  }

  String _getTotalBalance() {
    if (_enrollments.isEmpty) return '0.00';
    double total = 0;

    for (var enrollment in _enrollments) {
      total += enrollment.remainingBalance;
    }

    return '${total.toStringAsFixed(2)}';
  }

  // Build individual enrollment card
  Widget _buildEnrollmentCard(EnrollmentInfoModel enrollment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: enrollment.isPersonalTraining
              ? [
                  const Color(0xFF9333EA),
                  const Color(0xFFC026D3)
                ] // Purple for PT
              : [
                  AppConstants.primaryColor,
                  const Color(0xFF3B82F6)
                ], // Blue for Regular
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  enrollment.program,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (enrollment.isPersonalTraining)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'PT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              if (enrollment.isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  child: const Text(
                    'EXPIRED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                enrollment.branch,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.person, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  enrollment.trainor,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white30, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEnrollmentStat('Sessions Used', enrollment.sessionsDisplay),
              Container(width: 1, height: 30, color: Colors.white30),
              _buildEnrollmentStat('Total Paid',
                  '${enrollment.completeTotalPaid.toStringAsFixed(2)}'),
              Container(width: 1, height: 30, color: Colors.white30),
              _buildEnrollmentStat('Ends',
                  enrollment.endDate.isNotEmpty ? enrollment.endDate : 'N/A'),
            ],
          ),
        ],
      ),
    );
  }
}
