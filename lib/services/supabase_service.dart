import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  static String? get currentUserId {
    return client.auth.currentUser?.id;
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}