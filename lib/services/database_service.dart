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
      final response = await supabase
          .from('students')
          .insert(student.toJson())
          .select()
          .single();

      return StudentModel.fromJson(response);
    } catch (e) {
      throw Exception('Error adding student: $e');
    }
  }

  /// Add a new teacher
  Future<TeacherModel> addTeacher(TeacherModel teacher) async {
    try {
      final response = await supabase
          .from('teachers')
          .insert(teacher.toJson())
          .select()
          .single();

      return TeacherModel.fromJson(response);
    } catch (e) {
      throw Exception('Error adding teacher: $e');
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
      final response = await supabase
          .from('students')
          .update(student.toJson())
          .eq('id', student.id)
          .select()
          .single();

      return StudentModel.fromJson(response);
    } catch (e) {
      throw Exception('Error updating student: $e');
    }
  }

  /// Update a teacher
  Future<TeacherModel> updateTeacher(TeacherModel teacher) async {
    try {
      final response = await supabase
          .from('teachers')
          .update(teacher.toJson())
          .eq('id', teacher.id)
          .select()
          .single();

      return TeacherModel.fromJson(response);
    } catch (e) {
      throw Exception('Error updating teacher: $e');
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

      // First, verify the opportunity exists and get its actual ID from database
      final existingOpportunity = await supabase
          .from('volunteering_opportunities')
          .select('id')
          .eq('id', volunteering.id)
          .maybeSingle();

      if (existingOpportunity == null) {
        throw Exception('Volunteering opportunity not found with id: ${volunteering.id}. Cannot update.');
      }

      final actualOpportunityId = existingOpportunity['id'].toString();
      
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
          .update(opportunityData)
          .eq('id', actualOpportunityId)
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

      // First verify the opportunity exists and get its actual ID from database
      final checkResponse = await supabase
          .from('volunteering_opportunities')
          .select('id, title')
          .eq('id', opportunityId)
          .maybeSingle();

      if (checkResponse == null) {
        throw Exception('Volunteering opportunity not found with id: $opportunityId. Cannot delete.');
      }

      final actualOpportunityId = checkResponse['id'].toString();
      final opportunityTitle = checkResponse['title'] ?? 'Unknown';

      // Delete the opportunity and verify it was deleted
      final deleteResponse = await supabase
          .from('volunteering_opportunities')
          .delete()
          .eq('id', actualOpportunityId)
          .select();

      // Verify deletion was successful - should return the deleted row
      if (deleteResponse.isEmpty) {
        throw Exception('Failed to delete volunteering opportunity "$opportunityTitle": Deletion returned no confirmation. The opportunity may have already been deleted or deletion was blocked.');
      }

      // Double check: verify it's actually gone
      final verifyDelete = await supabase
          .from('volunteering_opportunities')
          .select('id')
          .eq('id', actualOpportunityId)
          .maybeSingle();

      if (verifyDelete != null) {
        throw Exception('Warning: Volunteering opportunity "$opportunityTitle" still exists after deletion attempt. Deletion may have been blocked.');
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
        throw Exception('Database constraint violation: $errorString');
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

      // First, verify the enrollment exists and get its actual ID from database
      final existingEnrollment = await supabase
          .from('volunteering_enrollment')
          .select('id')
          .eq('id', enrollment.id)
          .maybeSingle();

      if (existingEnrollment == null) {
        throw Exception('Volunteering enrollment not found with id: ${enrollment.id}. Cannot update.');
      }

      final actualEnrollmentId = existingEnrollment['id'].toString();
      
      final enrollmentData = <String, dynamic>{
        'user_id': enrollment.userId,
        'user_name': enrollment.userName,
        'user_email': enrollment.userEmail,
        'opportunity_id': enrollment.opportunityId,
        'opportunity_title': enrollment.opportunityTitle,
      };
      
      final response = await supabase
          .from('volunteering_enrollment')
          .update(enrollmentData)
          .eq('id', actualEnrollmentId)
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

      // First verify the enrollment exists and get its actual ID from database
      final checkResponse = await supabase
          .from('volunteering_enrollment')
          .select('id, user_name, opportunity_title')
          .eq('id', enrollmentId)
          .maybeSingle();

      if (checkResponse == null) {
        throw Exception('Volunteering enrollment not found with id: $enrollmentId. Cannot delete.');
      }

      final actualEnrollmentId = checkResponse['id'].toString();
      final userName = checkResponse['user_name'] ?? 'Unknown';
      final opportunityTitle = checkResponse['opportunity_title'] ?? 'Unknown';

      // Delete the enrollment and verify it was deleted
      final deleteResponse = await supabase
          .from('volunteering_enrollment')
          .delete()
          .eq('id', actualEnrollmentId)
          .select();

      // Verify deletion was successful - should return the deleted row
      if (deleteResponse.isEmpty) {
        throw Exception('Failed to delete enrollment for "$userName" in "$opportunityTitle": Deletion returned no confirmation. The enrollment may have already been deleted or deletion was blocked.');
      }

      // Double check: verify it's actually gone
      final verifyDelete = await supabase
          .from('volunteering_enrollment')
          .select('id')
          .eq('id', actualEnrollmentId)
          .maybeSingle();

      if (verifyDelete != null) {
        throw Exception('Warning: Enrollment still exists after deletion attempt. Deletion may have been blocked.');
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
        throw Exception('Database constraint violation: $errorString');
      } else {
        throw Exception('Error deleting volunteering enrollment: $errorString');
      }
    }
  }
}

