import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project/models/message_model.dart';

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
}

