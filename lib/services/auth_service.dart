import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  Future<String?> signUp(String email, String password) async {
    try {
      final response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
      );
      
      return response.user?.id;
    } catch (error) {
      rethrow;
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      return response.user?.id;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await SupabaseService.client.auth.signOut();
  }

  bool isLoggedIn() {
    return SupabaseService.client.auth.currentSession != null;
  }
}