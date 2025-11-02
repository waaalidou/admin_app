import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project/models/message_model.dart';
import 'package:project/models/student_model.dart';
import 'package:project/models/teacher_model.dart';
import 'package:project/models/course_model.dart';
import 'package:project/models/club_model.dart';
import 'package:project/models/volunteering_opportunity_model.dart';
import 'package:project/models/volunteering_enrollment_model.dart';

class DatabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Get messages for a specific wilaya
  Future<List<MessageModel>> getWilayaMessages(String wilayaName) async {
    try {
      final response = await supabase
          .from('wilaya_messages')
          .select()
          .eq('wilaya_name', wilayaName)
          .order('created_at', ascending: true);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error loading messages: $e');
    }
  }

  /// Send a message to a wilaya chat
  Future<void> sendWilayaMessage({
    required String wilayaName,
    required String message,
    required String userId,
  }) async {
    try {
      final user = supabase.auth.currentUser;
      final userName = user?.email?.split('@')[0] ?? 'User';

      // Prepare the message data
      final messageData = {
        'wilaya_name': wilayaName,
        'user_id': userId,
        'user_name': userName,
        'message': message,
      };
      
      // Only add created_at if the table doesn't auto-generate it
      // Some tables use default values or triggers for timestamps
      messageData['created_at'] = DateTime.now().toIso8601String();

      final response = await supabase.from('wilaya_messages').insert(messageData).select();

      // Verify the insert was successful
      if (response.isEmpty) {
        throw Exception('Message was not inserted into database');
      }
    } catch (e) {
      // Provide more detailed error information
      final errorString = e.toString();
      if (errorString.contains('permission') || errorString.contains('policy') || errorString.contains('RLS')) {
        throw Exception('Database permission denied. Please check Row Level Security policies.');
      } else if (errorString.contains('violates') || errorString.contains('constraint')) {
        throw Exception('Database constraint violation: $errorString');
      } else {
        throw Exception('Error sending message: $errorString');
      }
    }
  }

  // ==================== STUDENTS ====================

  /// Get all students
  Future<List<StudentModel>> getStudents() async {
    try {
      final response = await supabase
          .from('students')
          .select()
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => StudentModel.fromJson(json))
          .toList();
    } catch (e) {
      // Return empty list if table doesn't exist
      return [];
    }
  }

  /// Create or update student from current logged-in user
  /// This is called automatically on login
  Future<StudentModel?> createStudentFromCurrentUser() async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        return null; // Not logged in, nothing to do
      }

      final userEmail = currentUser.email ?? '';

      // Check if student already exists with this email
      final existingStudents = await supabase
          .from('students')
          .select()
          .eq('email', userEmail)
          .limit(1);

      // If student already exists, return null (don't create duplicate)
      if (existingStudents.isNotEmpty && existingStudents.length > 0) {
        return null;
      }

      // Extract name from email (before @) or use email as name
      final userName = userEmail.split('@').first;

      // Create new student from logged-in user
      final studentData = <String, dynamic>{
        'name': userName,
        'email': userEmail,
        'phone': null,
        'course_id': null,
      };

      final response = await supabase
          .from('students')
          .insert(studentData)
          .select()
          .single();

      if (response.isEmpty) {
        return null;
      }

      return StudentModel.fromJson(response);
    } catch (e) {
      // Silently fail - table might not exist yet or other issues
      // This is expected behavior when tables don't exist
      print('Note: Could not create student from login: $e');
      return null;
    }
  }

  // ==================== TEACHERS ====================

  /// Get all teachers
  Future<List<TeacherModel>> getTeachers() async {
    try {
      final response = await supabase
          .from('teachers')
          .select()
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => TeacherModel.fromJson(json))
          .toList();
    } catch (e) {
      // Return empty list if table doesn't exist
      return [];
    }
  }

  // ==================== COURSES ====================

  /// Get all courses
  Future<List<CourseModel>> getCourses() async {
    try {
      final response = await supabase
          .from('courses')
          .select()
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => CourseModel.fromJson(json))
          .toList();
    } catch (e) {
      // Return empty list if table doesn't exist
      return [];
    }
  }

  // ==================== CLUBS ====================

  /// Get all clubs
  Future<List<ClubModel>> getClubes() async {
    try {
      final response = await supabase
          .from('clubs')
          .select()
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => ClubModel.fromJson(json))
          .toList();
    } catch (e) {
      // Return empty list if table doesn't exist
      return [];
    }
  }

  // ==================== VOLUNTEERING OPPORTUNITIES ====================

  /// Get all volunteering opportunities
  Future<List<VolunteeringOpportunityModel>> getVolunteeringOpportunities() async {
    try {
      final response = await supabase
          .from('volunteering_opportunities')
          .select()
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => VolunteeringOpportunityModel.fromJson(json))
          .toList();
    } catch (e) {
      // Return empty list if table doesn't exist
      return [];
    }
  }

  // ==================== VOLUNTEERING ENROLLMENT ====================

  /// Get all volunteering enrollments
  Future<List<VolunteeringEnrollmentModel>> getVolunteeringEnrollments() async {
    try {
      final response = await supabase
          .from('volunteering_enrollment')
          .select()
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => VolunteeringEnrollmentModel.fromJson(json))
          .toList();
    } catch (e) {
      // Return empty list if table doesn't exist
      return [];
    }
  }

  // ==================== INSERT METHODS ====================

  /// Add a new club
  Future<ClubModel> addClub(ClubModel club) async {
    try {
      // Verify user is authenticated
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      // Only send the fields that are required/editable, let DB handle id and timestamps
      final clubData = <String, dynamic>{
        'name': club.name,
        'description': club.description,
        'icon_name': club.iconName,
        'color': club.color,
        'member_count': club.memberCount,
      };
      
      // If your RLS policy requires user_id, add it:
      // clubData['user_id'] = currentUser.id;
      
      final response = await supabase
          .from('clubs')
          .insert(clubData)
          .select()
          .single();

      if (response.isEmpty) {
        throw Exception('Failed to insert club: No response from database');
      }

      return ClubModel.fromJson(response);
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('permission') || errorString.contains('policy') || errorString.contains('RLS') || errorString.contains('row-level security')) {
        throw Exception('PERMISSION DENIED: Row Level Security (RLS) is blocking this operation.\n\n'
            'Please check your Supabase dashboard:\n'
            '1. Go to Authentication > Policies\n'
            '2. Find the "clubs" table\n'
            '3. Enable INSERT policy for authenticated users\n'
            '4. Make sure the policy allows: INSERT operations\n\n'
            'Error details: $errorString');
      } else if (errorString.contains('violates') || errorString.contains('constraint')) {
        throw Exception('Database constraint violation: $errorString');
      } else {
        throw Exception('Error adding club: $errorString');
      }
    }
  }

  /// Add a new student
  Future<StudentModel> addStudent(StudentModel student) async {
    try {
      // Verify user is authenticated
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      // Only send the fields that are required/editable, let DB handle id and timestamps
      final studentData = <String, dynamic>{
        'name': student.name,
        'email': student.email,
        'phone': student.phone,
        'course_id': student.courseId,
      };
      
      final response = await supabase
          .from('students')
          .insert(studentData)
          .select()
          .single();

      if (response.isEmpty) {
        throw Exception('Failed to insert student: No response from database');
      }

      return StudentModel.fromJson(response);
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('relation') && errorString.contains('does not exist')) {
        throw Exception('Table "students" does not exist in the database. Please create it first in Supabase.');
      } else if (errorString.contains('permission') || errorString.contains('policy') || errorString.contains('RLS') || errorString.contains('row-level security')) {
        throw Exception('PERMISSION DENIED: Row Level Security (RLS) is blocking this operation.\n\n'
            'Please check your Supabase dashboard:\n'
            '1. Go to Authentication > Policies\n'
            '2. Find the "students" table\n'
            '3. Enable INSERT policy for authenticated users\n'
            '4. Make sure the policy allows: INSERT operations\n\n'
            'Error details: $errorString');
      } else if (errorString.contains('violates') || errorString.contains('constraint')) {
        throw Exception('Database constraint violation: $errorString');
      } else {
        throw Exception('Error adding student: $errorString');
      }
    }
  }

  /// Add a new teacher
  Future<TeacherModel> addTeacher(TeacherModel teacher) async {
    try {
      // Verify user is authenticated
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      // Only send the fields that are required/editable, let DB handle id and timestamps
      final teacherData = <String, dynamic>{
        'name': teacher.name,
        'email': teacher.email,
        'phone': teacher.phone,
        'specialization': teacher.specialization,
      };
      
      final response = await supabase
          .from('teachers')
          .insert(teacherData)
          .select()
          .single();

      if (response.isEmpty) {
        throw Exception('Failed to insert teacher: No response from database');
      }

      return TeacherModel.fromJson(response);
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('relation') && errorString.contains('does not exist')) {
        throw Exception('Table "teachers" does not exist in the database. Please create it first in Supabase.');
      } else if (errorString.contains('permission') || errorString.contains('policy') || errorString.contains('RLS') || errorString.contains('row-level security')) {
        throw Exception('PERMISSION DENIED: Row Level Security (RLS) is blocking this operation.\n\n'
            'Please check your Supabase dashboard:\n'
            '1. Go to Authentication > Policies\n'
            '2. Find the "teachers" table\n'
            '3. Enable INSERT policy for authenticated users\n'
            '4. Make sure the policy allows: INSERT operations\n\n'
            'Error details: $errorString');
      } else if (errorString.contains('violates') || errorString.contains('constraint')) {
        throw Exception('Database constraint violation: $errorString');
      } else {
        throw Exception('Error adding teacher: $errorString');
      }
    }
  }

  /// Add a new course
  Future<CourseModel> addCourse(CourseModel course) async {
    try {
      final response = await supabase
          .from('courses')
          .insert(course.toJson())
          .select()
          .single();

      return CourseModel.fromJson(response);
    } catch (e) {
      throw Exception('Error adding course: $e');
    }
  }

  /// Add a new volunteering opportunity
  Future<VolunteeringOpportunityModel> addVolunteeringOpportunity(VolunteeringOpportunityModel volunteering) async {
    try {
      // Verify user is authenticated
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      // Only send the fields that are required/editable, let DB handle id and timestamps
      final opportunityData = <String, dynamic>{
        'title': volunteering.title,
        'description': volunteering.description,
        'location': volunteering.location,
        'icon_name': volunteering.iconName,
        'color': volunteering.color,
        'enrolled_count': volunteering.enrolledCount,
      };
      
      final response = await supabase
          .from('volunteering_opportunities')
          .insert(opportunityData)
          .select()
          .single();

      if (response.isEmpty) {
        throw Exception('Failed to insert volunteering opportunity: No response from database');
      }

      return VolunteeringOpportunityModel.fromJson(response);
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('permission') || errorString.contains('policy') || errorString.contains('RLS') || errorString.contains('row-level security')) {
        throw Exception('PERMISSION DENIED: Row Level Security (RLS) is blocking this operation.\n\n'
            'Please check your Supabase dashboard:\n'
            '1. Go to Authentication > Policies\n'
            '2. Find the "volunteering_opportunities" table\n'
            '3. Enable INSERT policy for authenticated users\n'
            '4. Make sure the policy allows: INSERT operations\n\n'
            'Error details: $errorString');
      } else if (errorString.contains('violates') || errorString.contains('constraint')) {
        throw Exception('Database constraint violation: $errorString');
      } else {
        throw Exception('Error adding volunteering opportunity: $errorString');
      }
    }
  }

  /// Add a new volunteering enrollment
  Future<VolunteeringEnrollmentModel> addVolunteeringEnrollment(VolunteeringEnrollmentModel enrollment) async {
    try {
      // Verify user is authenticated
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      // Only send the fields that are required/editable, let DB handle id and timestamps
      final enrollmentData = <String, dynamic>{
        'user_id': enrollment.userId,
        'user_name': enrollment.userName,
        'user_email': enrollment.userEmail,
        'opportunity_id': enrollment.opportunityId,
        'opportunity_title': enrollment.opportunityTitle,
      };
      
      final response = await supabase
          .from('volunteering_enrollment')
          .insert(enrollmentData)
          .select()
          .single();

      if (response.isEmpty) {
        throw Exception('Failed to insert volunteering enrollment: No response from database');
      }

      return VolunteeringEnrollmentModel.fromJson(response);
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('permission') || errorString.contains('policy') || errorString.contains('RLS') || errorString.contains('row-level security')) {
        throw Exception('PERMISSION DENIED: Row Level Security (RLS) is blocking this operation.\n\n'
            'Please check your Supabase dashboard:\n'
            '1. Go to Authentication > Policies\n'
            '2. Find the "volunteering_enrollment" table\n'
            '3. Enable INSERT policy for authenticated users\n'
            '4. Make sure the policy allows: INSERT operations\n\n'
            'Error details: $errorString');
      } else if (errorString.contains('violates') || errorString.contains('constraint')) {
        throw Exception('Database constraint violation: $errorString');
      } else {
        throw Exception('Error adding volunteering enrollment: $errorString');
      }
    }
  }

  // ==================== UPDATE METHODS ====================

  /// Update a club
  Future<ClubModel> updateClub(ClubModel club) async {
    try {
      // Verify user is authenticated
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      // First, verify the club exists and get its actual ID from database
      final existingClub = await supabase
          .from('clubs')
          .select('id')
          .eq('id', club.id)
          .maybeSingle();

      if (existingClub == null) {
        throw Exception('Club not found with id: ${club.id}. Cannot update.');
      }

      final actualClubId = existingClub['id'].toString();
      
      final clubData = <String, dynamic>{
        'name': club.name,
        'description': club.description,
        'icon_name': club.iconName,
        'color': club.color,
        'member_count': club.memberCount,
      };
      
      // Don't include updated_at if the DB handles it automatically
      // If your DB requires it, uncomment the line below:
      // clubData['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await supabase
          .from('clubs')
          .update(clubData)
          .eq('id', actualClubId)
          .select()
          .single();

      if (response.isEmpty) {
        throw Exception('Failed to update club: Update returned no data');
      }

      return ClubModel.fromJson(response);
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('permission') || errorString.contains('policy') || errorString.contains('RLS') || errorString.contains('row-level security')) {
        throw Exception('PERMISSION DENIED: Row Level Security (RLS) is blocking this operation.\n\n'
            'Please check your Supabase dashboard:\n'
            '1. Go to Authentication > Policies\n'
            '2. Find the "clubs" table\n'
            '3. Enable UPDATE policy for authenticated users\n'
            '4. Make sure the policy allows: UPDATE operations\n\n'
            'Error details: $errorString');
      } else if (errorString.contains('violates') || errorString.contains('constraint')) {
        throw Exception('Database constraint violation: $errorString');
      } else {
        throw Exception('Error updating club: $errorString');
      }
    }
  }

  /// Delete a club
  Future<void> deleteClub(String clubId) async {
    try {
      // Verify user is authenticated
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      // First verify the club exists and get its actual ID from database
      final checkResponse = await supabase
          .from('clubs')
          .select('id, name')
          .eq('id', clubId)
          .maybeSingle();

      if (checkResponse == null) {
        throw Exception('Club not found with id: $clubId. Cannot delete.');
      }

      final actualClubId = checkResponse['id'].toString();
      final clubName = checkResponse['name'] ?? 'Unknown';

      // Delete the club and verify it was deleted
      final deleteResponse = await supabase
          .from('clubs')
          .delete()
          .eq('id', actualClubId)
          .select();

      // Verify deletion was successful - should return the deleted row
      if (deleteResponse.isEmpty) {
        throw Exception('Failed to delete club "$clubName": Deletion returned no confirmation. The club may have already been deleted or deletion was blocked.');
      }

      // Double check: verify it's actually gone
      final verifyDelete = await supabase
          .from('clubs')
          .select('id')
          .eq('id', actualClubId)
          .maybeSingle();

      if (verifyDelete != null) {
        throw Exception('Warning: Club "$clubName" still exists after deletion attempt. Deletion may have been blocked.');
      }
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('permission') || errorString.contains('policy') || errorString.contains('RLS') || errorString.contains('row-level security')) {
        throw Exception('PERMISSION DENIED: Row Level Security (RLS) is blocking this operation.\n\n'
            'Please check your Supabase dashboard:\n'
            '1. Go to Authentication > Policies\n'
            '2. Find the "clubs" table\n'
            '3. Enable DELETE policy for authenticated users\n'
            '4. Make sure the policy allows: DELETE operations\n\n'
            'Error details: $errorString');
      } else if (errorString.contains('violates') || errorString.contains('constraint')) {
        throw Exception('Database constraint violation: $errorString');
      } else {
        throw Exception('Error deleting club: $errorString');
      }
    }
  }

  /// Update a student
  Future<StudentModel> updateStudent(StudentModel student) async {
    try {
      // Verify user is authenticated
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      // Validate ID is provided
      if (student.id.isEmpty || student.id == 'temp') {
        throw Exception('Invalid student ID. Cannot update.');
      }

      // Prepare update data - exclude id, created_at (let DB handle timestamps)
      final studentData = <String, dynamic>{
        'name': student.name,
        'email': student.email,
        'phone': student.phone,
        'course_id': student.courseId,
      };
      
      // Update directly using the ID from the model
      final response = await supabase
          .from('students')
          .update(studentData)
          .eq('id', student.id)
          .select()
          .single();

      if (response.isEmpty) {
        throw Exception('Failed to update student: Update returned no data');
      }

      return StudentModel.fromJson(response);
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('relation') && errorString.contains('does not exist')) {
        throw Exception('Table "students" does not exist in the database. Please create it first in Supabase.');
      } else if (errorString.contains('permission') || errorString.contains('policy') || errorString.contains('RLS') || errorString.contains('row-level security')) {
        throw Exception('PERMISSION DENIED: Row Level Security (RLS) is blocking this operation.\n\n'
            'Please check your Supabase dashboard:\n'
            '1. Go to Authentication > Policies\n'
            '2. Find the "students" table\n'
            '3. Enable UPDATE policy for authenticated users\n'
            '4. Make sure the policy allows: UPDATE operations\n\n'
            'Error details: $errorString');
      } else if (errorString.contains('violates') || errorString.contains('constraint')) {
        throw Exception('Database constraint violation: $errorString');
      } else if (errorString.contains('No rows found') || errorString.contains('not found')) {
        throw Exception('Student not found with id: ${student.id}. Cannot update.');
      } else {
        throw Exception('Error updating student: $errorString');
      }
    }
  }

  /// Update a teacher
  Future<TeacherModel> updateTeacher(TeacherModel teacher) async {
    try {
      // Verify user is authenticated
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      // Validate ID is provided
      if (teacher.id.isEmpty || teacher.id == 'temp') {
        throw Exception('Invalid teacher ID. Cannot update.');
      }

      // Prepare update data - exclude id, created_at (let DB handle timestamps)
      final teacherData = <String, dynamic>{
        'name': teacher.name,
        'email': teacher.email,
        'phone': teacher.phone,
        'specialization': teacher.specialization,
      };
      
      // Update directly using the ID from the model
      final response = await supabase
          .from('teachers')
          .update(teacherData)
          .eq('id', teacher.id)
          .select()
          .single();

      if (response.isEmpty) {
        throw Exception('Failed to update teacher: Update returned no data');
      }

      return TeacherModel.fromJson(response);
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('relation') && errorString.contains('does not exist')) {
        throw Exception('Table "teachers" does not exist in the database. Please create it first in Supabase.');
      } else if (errorString.contains('permission') || errorString.contains('policy') || errorString.contains('RLS') || errorString.contains('row-level security')) {
        throw Exception('PERMISSION DENIED: Row Level Security (RLS) is blocking this operation.\n\n'
            'Please check your Supabase dashboard:\n'
            '1. Go to Authentication > Policies\n'
            '2. Find the "teachers" table\n'
            '3. Enable UPDATE policy for authenticated users\n'
            '4. Make sure the policy allows: UPDATE operations\n\n'
            'Error details: $errorString');
      } else if (errorString.contains('violates') || errorString.contains('constraint')) {
        throw Exception('Database constraint violation: $errorString');
      } else if (errorString.contains('No rows found') || errorString.contains('not found')) {
        throw Exception('Teacher not found with id: ${teacher.id}. Cannot update.');
      } else {
        throw Exception('Error updating teacher: $errorString');
      }
    }
  }

  /// Delete a student
  Future<void> deleteStudent(String studentId) async {
    try {
      // Verify user is authenticated
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      // Validate ID is provided
      if (studentId.isEmpty || studentId == 'temp') {
        throw Exception('Invalid student ID. Cannot delete.');
      }

      // Delete directly using the ID - Supabase will handle the deletion
      final deleteResponse = await supabase
          .from('students')
          .delete()
          .eq('id', studentId)
          .select();

      // Verify deletion was successful - should return the deleted row(s)
      if (deleteResponse.isEmpty) {
        throw Exception('Failed to delete student: No record found with id "$studentId" or deletion was blocked.');
      }
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('relation') && errorString.contains('does not exist')) {
        throw Exception('Table "students" does not exist in the database. Please create it first in Supabase.');
      } else if (errorString.contains('permission') || errorString.contains('policy') || errorString.contains('RLS') || errorString.contains('row-level security')) {
        throw Exception('PERMISSION DENIED: Row Level Security (RLS) is blocking this operation.\n\n'
            'Please check your Supabase dashboard:\n'
            '1. Go to Authentication > Policies\n'
            '2. Find the "students" table\n'
            '3. Enable DELETE policy for authenticated users\n'
            '4. Make sure the policy allows: DELETE operations\n\n'
            'Error details: $errorString');
      } else if (errorString.contains('violates') || errorString.contains('constraint')) {
        throw Exception('Database constraint violation: Cannot delete student. It may have dependent records. Please delete related records first. Error: $errorString');
      } else if (errorString.contains('No rows found') || errorString.contains('not found')) {
        throw Exception('Student not found with id: $studentId. Cannot delete.');
      } else {
        throw Exception('Error deleting student: $errorString');
      }
    }
  }

  /// Delete a teacher
  Future<void> deleteTeacher(String teacherId) async {
    try {
      // Verify user is authenticated
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      // Validate ID is provided
      if (teacherId.isEmpty || teacherId == 'temp') {
        throw Exception('Invalid teacher ID. Cannot delete.');
      }

      // Delete directly using the ID - Supabase will handle the deletion
      final deleteResponse = await supabase
          .from('teachers')
          .delete()
          .eq('id', teacherId)
          .select();

      // Verify deletion was successful - should return the deleted row(s)
      if (deleteResponse.isEmpty) {
        throw Exception('Failed to delete teacher: No record found with id "$teacherId" or deletion was blocked.');
      }
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('relation') && errorString.contains('does not exist')) {
        throw Exception('Table "teachers" does not exist in the database. Please create it first in Supabase.');
      } else if (errorString.contains('permission') || errorString.contains('policy') || errorString.contains('RLS') || errorString.contains('row-level security')) {
        throw Exception('PERMISSION DENIED: Row Level Security (RLS) is blocking this operation.\n\n'
            'Please check your Supabase dashboard:\n'
            '1. Go to Authentication > Policies\n'
            '2. Find the "teachers" table\n'
            '3. Enable DELETE policy for authenticated users\n'
            '4. Make sure the policy allows: DELETE operations\n\n'
            'Error details: $errorString');
      } else if (errorString.contains('violates') || errorString.contains('constraint')) {
        throw Exception('Database constraint violation: Cannot delete teacher. It may have dependent records. Please delete related records first. Error: $errorString');
      } else if (errorString.contains('No rows found') || errorString.contains('not found')) {
        throw Exception('Teacher not found with id: $teacherId. Cannot delete.');
      } else {
        throw Exception('Error deleting teacher: $errorString');
      }
    }
  }

  /// Update a course
  Future<CourseModel> updateCourse(CourseModel course) async {
    try {
      final response = await supabase
          .from('courses')
          .update(course.toJson())
          .eq('id', course.id)
          .select()
          .single();

      return CourseModel.fromJson(response);
    } catch (e) {
      throw Exception('Error updating course: $e');
    }
  }

  /// Update a volunteering opportunity
  Future<VolunteeringOpportunityModel> updateVolunteeringOpportunity(VolunteeringOpportunityModel volunteering) async {
    try {
      // Verify user is authenticated
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      // Validate ID is provided
      if (volunteering.id.isEmpty || volunteering.id == 'temp') {
        throw Exception('Invalid volunteering opportunity ID. Cannot update.');
      }

      // Prepare update data - exclude enrolled_count as it's typically computed/auto-managed
      // Also exclude id, created_at, updated_at (let DB handle timestamps)
      final opportunityData = <String, dynamic>{
        'title': volunteering.title,
        'description': volunteering.description,
        'location': volunteering.location,
        'icon_name': volunteering.iconName,
        'color': volunteering.color,
        // Note: enrolled_count is typically computed from enrollments, so we don't update it manually
        // If your schema requires it, uncomment the line below:
        // 'enrolled_count': volunteering.enrolledCount,
      };
      
      // Update directly using the ID from the model
      final response = await supabase
          .from('volunteering_opportunities')
          .update(opportunityData)
          .eq('id', volunteering.id)
          .select()
          .single();

      if (response.isEmpty) {
        throw Exception('Failed to update volunteering opportunity: Update returned no data');
      }

      return VolunteeringOpportunityModel.fromJson(response);
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('permission') || errorString.contains('policy') || errorString.contains('RLS') || errorString.contains('row-level security')) {
        throw Exception('PERMISSION DENIED: Row Level Security (RLS) is blocking this operation.\n\n'
            'Please check your Supabase dashboard:\n'
            '1. Go to Authentication > Policies\n'
            '2. Find the "volunteering_opportunities" table\n'
            '3. Enable UPDATE policy for authenticated users\n'
            '4. Make sure the policy allows: UPDATE operations\n\n'
            'Error details: $errorString');
      } else if (errorString.contains('violates') || errorString.contains('constraint')) {
        throw Exception('Database constraint violation: $errorString');
      } else if (errorString.contains('No rows found') || errorString.contains('not found')) {
        throw Exception('Volunteering opportunity not found with id: ${volunteering.id}. Cannot update.');
      } else {
        throw Exception('Error updating volunteering opportunity: $errorString');
      }
    }
  }

  /// Delete a volunteering opportunity
  Future<void> deleteVolunteeringOpportunity(String opportunityId) async {
    try {
      // Verify user is authenticated
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      // Validate ID is provided
      if (opportunityId.isEmpty || opportunityId == 'temp') {
        throw Exception('Invalid volunteering opportunity ID. Cannot delete.');
      }

      // Delete directly using the ID - Supabase will handle the deletion
      final deleteResponse = await supabase
          .from('volunteering_opportunities')
          .delete()
          .eq('id', opportunityId)
          .select();

      // Verify deletion was successful - should return the deleted row(s)
      if (deleteResponse.isEmpty) {
        throw Exception('Failed to delete volunteering opportunity: No record found with id "$opportunityId" or deletion was blocked.');
      }
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('permission') || errorString.contains('policy') || errorString.contains('RLS') || errorString.contains('row-level security')) {
        throw Exception('PERMISSION DENIED: Row Level Security (RLS) is blocking this operation.\n\n'
            'Please check your Supabase dashboard:\n'
            '1. Go to Authentication > Policies\n'
            '2. Find the "volunteering_opportunities" table\n'
            '3. Enable DELETE policy for authenticated users\n'
            '4. Make sure the policy allows: DELETE operations\n\n'
            'Error details: $errorString');
      } else if (errorString.contains('violates') || errorString.contains('constraint')) {
        throw Exception('Database constraint violation: Cannot delete volunteering opportunity. It may have dependent records (e.g., enrollments). Please delete related records first. Error: $errorString');
      } else if (errorString.contains('No rows found') || errorString.contains('not found')) {
        throw Exception('Volunteering opportunity not found with id: $opportunityId. Cannot delete.');
      } else {
        throw Exception('Error deleting volunteering opportunity: $errorString');
      }
    }
  }

  /// Update a volunteering enrollment
  Future<VolunteeringEnrollmentModel> updateVolunteeringEnrollment(VolunteeringEnrollmentModel enrollment) async {
    try {
      // Verify user is authenticated
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      // Validate ID is provided
      if (enrollment.id.isEmpty || enrollment.id == 'temp') {
        throw Exception('Invalid volunteering enrollment ID. Cannot update.');
      }

      // Prepare update data - exclude id, created_at, updated_at, enrolled_at (let DB handle timestamps)
      final enrollmentData = <String, dynamic>{
        'user_id': enrollment.userId,
        'user_name': enrollment.userName,
        'user_email': enrollment.userEmail,
        'opportunity_id': enrollment.opportunityId,
        'opportunity_title': enrollment.opportunityTitle,
      };
      
      // Update directly using the ID from the model
      final response = await supabase
          .from('volunteering_enrollment')
          .update(enrollmentData)
          .eq('id', enrollment.id)
          .select()
          .single();

      if (response.isEmpty) {
        throw Exception('Failed to update volunteering enrollment: Update returned no data');
      }

      return VolunteeringEnrollmentModel.fromJson(response);
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('permission') || errorString.contains('policy') || errorString.contains('RLS') || errorString.contains('row-level security')) {
        throw Exception('PERMISSION DENIED: Row Level Security (RLS) is blocking this operation.\n\n'
            'Please check your Supabase dashboard:\n'
            '1. Go to Authentication > Policies\n'
            '2. Find the "volunteering_enrollment" table\n'
            '3. Enable UPDATE policy for authenticated users\n'
            '4. Make sure the policy allows: UPDATE operations\n\n'
            'Error details: $errorString');
      } else if (errorString.contains('violates') || errorString.contains('constraint')) {
        throw Exception('Database constraint violation: $errorString');
      } else if (errorString.contains('No rows found') || errorString.contains('not found')) {
        throw Exception('Volunteering enrollment not found with id: ${enrollment.id}. Cannot update.');
      } else {
        throw Exception('Error updating volunteering enrollment: $errorString');
      }
    }
  }

  /// Delete a volunteering enrollment
  Future<void> deleteVolunteeringEnrollment(String enrollmentId) async {
    try {
      // Verify user is authenticated
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      // Validate ID is provided
      if (enrollmentId.isEmpty || enrollmentId == 'temp') {
        throw Exception('Invalid volunteering enrollment ID. Cannot delete.');
      }

      // Delete directly using the ID - Supabase will handle the deletion
      final deleteResponse = await supabase
          .from('volunteering_enrollment')
          .delete()
          .eq('id', enrollmentId)
          .select();

      // Verify deletion was successful - should return the deleted row(s)
      if (deleteResponse.isEmpty) {
        throw Exception('Failed to delete volunteering enrollment: No record found with id "$enrollmentId" or deletion was blocked.');
      }
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('permission') || errorString.contains('policy') || errorString.contains('RLS') || errorString.contains('row-level security')) {
        throw Exception('PERMISSION DENIED: Row Level Security (RLS) is blocking this operation.\n\n'
            'Please check your Supabase dashboard:\n'
            '1. Go to Authentication > Policies\n'
            '2. Find the "volunteering_enrollment" table\n'
            '3. Enable DELETE policy for authenticated users\n'
            '4. Make sure the policy allows: DELETE operations\n\n'
            'Error details: $errorString');
      } else if (errorString.contains('violates') || errorString.contains('constraint')) {
        throw Exception('Database constraint violation: Cannot delete volunteering enrollment. Error: $errorString');
      } else if (errorString.contains('No rows found') || errorString.contains('not found')) {
        throw Exception('Volunteering enrollment not found with id: $enrollmentId. Cannot delete.');
      } else {
        throw Exception('Error deleting volunteering enrollment: $errorString');
      }
    }
  }
}

