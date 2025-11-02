import 'package:flutter/material.dart';
import 'package:project/utils/app_colors.dart';
import 'package:project/services/database_service.dart';
import 'package:project/models/student_model.dart';
import 'package:project/models/teacher_model.dart';
import 'package:project/models/course_model.dart';
import 'package:project/models/club_model.dart';
import 'package:project/models/volunteering_opportunity_model.dart';
import 'package:project/models/volunteering_enrollment_model.dart';
import 'package:project/screens/home/pages/club_edit_page.dart';
import 'package:project/screens/home/pages/volunteering_opportunity_edit_page.dart';
import 'package:project/screens/home/pages/volunteering_enrollment_edit_page.dart';
import 'package:project/screens/home/pages/student_edit_page.dart';
import 'package:project/screens/home/pages/teacher_edit_page.dart';

class DetailListPage extends StatefulWidget {
  final String title;
  final List<dynamic> items;
  final String type; // 'students', 'teachers', 'courses', 'clubs', 'volunteering_opportunities', 'volunteering_enrollment'

  const DetailListPage({
    super.key,
    required this.title,
    required this.items,
    required this.type,
  });

  @override
  State<DetailListPage> createState() => _DetailListPageState();
}

class _DetailListPageState extends State<DetailListPage> {
  final DatabaseService _dbService = DatabaseService();
  List<dynamic> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _items = widget.items;
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<dynamic> loadedItems = [];
      switch (widget.type) {
        case 'clubs':
          loadedItems = await _dbService.getClubes();
          break;
        case 'students':
          loadedItems = await _dbService.getStudents();
          break;
        case 'teachers':
          loadedItems = await _dbService.getTeachers();
          break;
        case 'courses':
          loadedItems = await _dbService.getCourses();
          break;
        case 'volunteering_opportunities':
          loadedItems = await _dbService.getVolunteeringOpportunities();
          break;
        case 'volunteering_enrollment':
          loadedItems = await _dbService.getVolunteeringEnrollments();
          break;
      }

      setState(() {
        _items = loadedItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToEdit(dynamic item) async {
    Widget editPage;
    
    switch (widget.type) {
      case 'clubs':
        editPage = ClubEditPage(club: item as ClubModel);
        break;
      case 'students':
        editPage = StudentEditPage(student: item as StudentModel);
        break;
      case 'teachers':
        editPage = TeacherEditPage(teacher: item as TeacherModel);
        break;
      case 'volunteering_opportunities':
        editPage = VolunteeringOpportunityEditPage(opportunity: item as VolunteeringOpportunityModel);
        break;
      case 'volunteering_enrollment':
        editPage = VolunteeringEnrollmentEditPage(enrollment: item as VolunteeringEnrollmentModel);
        break;
      default:
        return; // Not implemented yet
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => editPage),
    );

    if (result == true) {
      // Refresh the list after editing
      _loadItems();
    }
  }

  Future<void> _navigateToAdd() async {
    Widget editPage;
    
    switch (widget.type) {
      case 'clubs':
        editPage = const ClubEditPage();
        break;
      case 'students':
        editPage = const StudentEditPage();
        break;
      case 'teachers':
        editPage = const TeacherEditPage();
        break;
      case 'volunteering_opportunities':
        editPage = const VolunteeringOpportunityEditPage();
        break;
      case 'volunteering_enrollment':
        editPage = const VolunteeringEnrollmentEditPage();
        break;
      default:
        return; // Not implemented yet
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => editPage),
    );

    if (result == true) {
      // Refresh the list after adding
      _loadItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAdd,
            tooltip: 'Add ${widget.title.substring(0, widget.title.length - 1)}',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
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
        child: _items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getEmptyIcon(),
                      size: 64,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No ${widget.title} found',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      return _buildItemCard(_items[index]);
                    },
                  ),
      ),
    );
  }

  IconData _getEmptyIcon() {
    switch (widget.type) {
      case 'students':
        return Icons.school_outlined;
      case 'teachers':
        return Icons.person_outline;
      case 'courses':
        return Icons.book_outlined;
      case 'clubs':
        return Icons.group_outlined;
      case 'volunteering_opportunities':
        return Icons.volunteer_activism_outlined;
      case 'volunteering_enrollment':
        return Icons.person_add_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildItemCard(dynamic item) {
    switch (widget.type) {
      case 'students':
        return _buildStudentCard(item as StudentModel);
      case 'teachers':
        return _buildTeacherCard(item as TeacherModel);
      case 'courses':
        return _buildCourseCard(item as CourseModel);
      case 'clubs':
        return _buildClubCard(item as ClubModel);
      case 'volunteering_opportunities':
        return _buildVolunteeringOpportunityCard(item as VolunteeringOpportunityModel);
      case 'volunteering_enrollment':
        return _buildVolunteeringEnrollmentCard(item as VolunteeringEnrollmentModel);
      default:
        return const SizedBox();
    }
  }

  Widget _buildStudentCard(StudentModel student) {
    return InkWell(
      onTap: () => _navigateToEdit(student),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (student.phone != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      student.phone!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (student.courseId != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Course: ${student.courseId}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherCard(TeacherModel teacher) {
    return InkWell(
      onTap: () => _navigateToEdit(teacher),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person, color: AppColors.success, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teacher.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    teacher.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (teacher.phone != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      teacher.phone!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (teacher.specialization != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Specialization: ${teacher.specialization!}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.book, color: AppColors.warning, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (course.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    course.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (course.studentCount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${course.studentCount} students',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubCard(ClubModel club) {
    Color clubColor = _parseColor(club.color);
    
    return InkWell(
      onTap: () => _navigateToEdit(club),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDefault),
        ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: clubColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getIconFromName(club.iconName), color: clubColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  club.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${club.memberCount} members',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildVolunteeringOpportunityCard(VolunteeringOpportunityModel volunteering) {
    Color volColor = _parseColor(volunteering.color);
    
    return InkWell(
      onTap: () => _navigateToEdit(volunteering),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDefault),
        ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: volColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getIconFromName(volunteering.iconName), color: volColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  volunteering.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  volunteering.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      volunteering.location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${volunteering.enrolledCount} enrolled',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildVolunteeringEnrollmentCard(VolunteeringEnrollmentModel enrollment) {
    return InkWell(
      onTap: () => _navigateToEdit(enrollment),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_add, color: AppColors.secondary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enrollment.userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    enrollment.userEmail,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.volunteer_activism, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          enrollment.opportunityTitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  IconData _getIconFromName(String iconName) {
    // Map common icon names to Flutter icons
    switch (iconName.toLowerCase()) {
      case 'group':
      case 'groups':
        return Icons.group;
      case 'volunteer_activism':
      case 'volunteer':
        return Icons.volunteer_activism;
      case 'sports':
        return Icons.sports;
      case 'music':
        return Icons.music_note;
      case 'art':
        return Icons.palette;
      case 'science':
        return Icons.science;
      case 'tech':
      case 'technology':
        return Icons.computer;
      default:
        return Icons.info;
    }
  }
}

