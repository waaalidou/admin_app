import 'package:flutter/material.dart';
import 'package:project/utils/app_colors.dart';
import 'package:project/screens/auth/services/auth_service.dart';
import 'package:project/services/database_service.dart';
import 'package:project/models/student_model.dart';
import 'package:project/models/teacher_model.dart';
import 'package:project/models/course_model.dart';
import 'package:project/models/club_model.dart';
import 'package:project/models/volunteering_opportunity_model.dart';
import 'package:project/models/volunteering_enrollment_model.dart';
import 'package:project/screens/home/pages/detail_list_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseService _dbService = DatabaseService();
  final AuthService authService = AuthService();
  List<StudentModel> _students = [];
  List<TeacherModel> _teachers = [];
  List<CourseModel> _courses = [];
  List<ClubModel> _clubs = [];
  List<VolunteeringOpportunityModel> _volunteeringOpportunities = [];
  List<VolunteeringEnrollmentModel> _volunteeringEnrollments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final students = await _dbService.getStudents();
      final teachers = await _dbService.getTeachers();
      final courses = await _dbService.getCourses();
      final clubs = await _dbService.getClubes();
      final volunteeringOpportunities = await _dbService.getVolunteeringOpportunities();
      final volunteeringEnrollments = await _dbService.getVolunteeringEnrollments();

      setState(() {
        _students = students;
        _teachers = teachers;
        _courses = courses;
        _clubs = clubs;
        _volunteeringOpportunities = volunteeringOpportunities;
        _volunteeringEnrollments = volunteeringEnrollments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToDetail(String title, List<dynamic> items, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailListPage(
          title: title,
          items: items,
          type: type,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? userEmail = authService.getCurrentUserEmail();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadData();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, authService, userEmail),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.background,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Admin!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            userEmail ?? 'No email',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textOnPrimary.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Statistics Cards - Grid Layout
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                      children: [
                        _buildSummaryCard(
                          'Students',
                          '${_students.length}',
                          Icons.school,
                          AppColors.primary,
                          () => _navigateToDetail('Students', _students, 'students'),
                        ),
                        _buildSummaryCard(
                          'Teachers',
                          '${_teachers.length}',
                          Icons.person,
                          AppColors.success,
                          () => _navigateToDetail('Teachers', _teachers, 'teachers'),
                        ),
                        _buildSummaryCard(
                          'Courses',
                          '${_courses.length}',
                          Icons.book,
                          AppColors.warning,
                          () => _navigateToDetail('Courses', _courses, 'courses'),
                        ),
                        _buildSummaryCard(
                          'Clubs',
                          '${_clubs.length}',
                          Icons.group,
                          AppColors.secondary,
                          () => _navigateToDetail('Clubs', _clubs, 'clubs'),
                        ),
                        _buildSummaryCard(
                          'Opportunities',
                          '${_volunteeringOpportunities.length}',
                          Icons.volunteer_activism,
                          const Color(0xFF4CAF50),
                          () => _navigateToDetail('Volunteering Opportunities', _volunteeringOpportunities, 'volunteering_opportunities'),
                        ),
                        _buildSummaryCard(
                          'Enrollments',
                          '${_volunteeringEnrollments.length}',
                          Icons.person_add,
                          const Color(0xFF9C27B0),
                          () => _navigateToDetail('Volunteering Enrollments', _volunteeringEnrollments, 'volunteering_enrollment'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthService authService, String? userEmail) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail ?? 'No email',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: AppColors.primary),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: AppColors.textSecondary),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: AppColors.textSecondary),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to notifications
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: AppColors.textSecondary),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to help
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Logout', style: TextStyle(color: AppColors.error)),
            onTap: () async {
              Navigator.pop(context);
              await authService.signOut();
              // AuthGate will handle navigation
            },
          ),
        ],
      ),
    );
  }
}

