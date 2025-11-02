import 'package:flutter/material.dart';
import 'package:project/utils/app_colors.dart';
import 'package:project/services/database_service.dart';
import 'package:project/models/student_model.dart';
import 'package:project/models/teacher_model.dart';
import 'package:project/models/course_model.dart';
import 'package:project/models/club_model.dart';
import 'package:project/models/volunteering_opportunity_model.dart';
import 'package:project/models/volunteering_enrollment_model.dart';
import 'package:project/screens/home/pages/detail_list_page.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final DatabaseService _dbService = DatabaseService();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        title: const Text(
          'Statistics',
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
                    // Summary Cards - Grid Layout
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
}
