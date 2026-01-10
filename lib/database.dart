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
        .order('date_solved', ascending: false);

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

Future<void> updateStatus(String problemId, String newStatus) async {
  await supabase
      .from('problems')
      .update({'status': newStatus})
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
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  } catch (_) {}
}