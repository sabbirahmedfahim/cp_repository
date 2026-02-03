import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/problem.dart';

final supabase = Supabase.instance.client;

String? getUserId() {
  return supabase.auth.currentUser?.id;
}

bool isLoggedIn() {
  return supabase.auth.currentUser != null;
}

Future<String?> register(String email, String password) async {
  try {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    return response.user?.id;
  } catch (e) {
    throw e.toString();
  }
}

Future<String?> login(String email, String password) async {
  try {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user?.id;
  } catch (e) {
    throw e.toString();
  }
}

Future<void> logout() async {
  await supabase.auth.signOut();
}

Future<List<Problem>> getProblems() async {
  final userId = getUserId();
  if (userId == null) return [];

  try {
    final response = await supabase
        .from('problems')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    List<Problem> problems = [];
    for (var item in response) {
      problems.add(Problem.fromMap(item));
    }
    return problems;
  } catch (e) {
    return [];
  }
}

Future<void> addProblem(Problem problem) async {
  final userId = getUserId();
  if (userId == null) throw 'Not logged in';

  final data = problem.toMap();
  data['user_id'] = userId;

  await supabase.from('problems').insert(data);
}

Future<void> updateProblemStatus(String problemId, String newStatus) async {
  final updateData = {'status': newStatus};
  
  await supabase
      .from('problems')
      .update(updateData)
      .eq('id', problemId);
}

Future<void> updateProblemTags(String problemId, List<String> tags) async {
  await supabase
      .from('problems')
      .update({'tags': tags})
      .eq('id', problemId);
}

Future<void> deleteProblem(String problemId) async {
  await supabase
      .from('problems')
      .delete()
      .eq('id', problemId);
}

Future<Map<String, int>> getStats() async {
  final problems = await getProblems();
  
  int pending = 0;
  int attempt = 0;
  int solved = 0;
  
  for (var problem in problems) {
    if (problem.status == 'Pending') pending++;
    else if (problem.status == 'Attempt') attempt++;
    else if (problem.status == 'Solved') solved++;
    else pending++;
  }
  
  return {
    'total': problems.length,
    'pending': pending,
    'attempt': attempt,
    'solved': solved,
  };
}

Future<void> openUrl(String url) async {
  try {
    final uri = Uri.parse(url);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  } catch (e) {
    print('Error launching URL: $e');
    rethrow;
  }
}

Future<Map<String, dynamic>?> getUserProfile() async {
  final userId = getUserId();
  if (userId == null) return null;

  try {
    final response = await supabase
        .from('user_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    
    return response;
  } catch (e) {
    return null;
  }
}

Future<void> updateUserProfile({
  String? fullName,
  String? university,
}) async {
  final userId = getUserId();
  if (userId == null) throw 'Not logged in';

  final data = <String, dynamic>{};
  if (fullName != null) data['full_name'] = fullName.trim();
  if (university != null) data['university'] = university.trim();
  data['updated_at'] = DateTime.now().toIso8601String();

  try {
    final existing = await supabase
        .from('user_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (existing == null) {
      data['user_id'] = userId;
      await supabase.from('user_profiles').insert(data);
    } else {
      await supabase
          .from('user_profiles')
          .update(data)
          .eq('user_id', userId);
    }
  } catch (e) {
    throw 'Failed to update profile: $e';
  }
}