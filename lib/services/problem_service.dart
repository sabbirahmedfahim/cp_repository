// CRUD operations is the field
import '../models/problem.dart';
import 'supabase_service.dart';

class ProblemService {
  
  String _standardizeStatus(String status) {
    if (status.isEmpty) return 'Pending';
    
    String trimmed = status.trim().toLowerCase();
    if (trimmed == 'pending') return 'Pending';
    if (trimmed == 'attempt') return 'Attempt';
    if (trimmed == 'solved') return 'Solved';
    
    return 'Pending';
  }

  Future<List<Problem>> getUserProblems() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return [];

    try {
      final response = await SupabaseService.client
          .from('problems')
          .select()
          .eq('user_id', userId)
          .order('date_solved', ascending: false);

      return (response as List).map((json) => Problem.fromJson(json)).toList();
    } catch (error) {
      print('Error fetching problems: $error');
      return [];
    }
  }

  Future<void> addProblem(Problem problem) async { // add problem
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw 'User not logged in';

    try {
      final standardizedStatus = _standardizeStatus(problem.status);
      
      final data = {
        'user_id': userId,
        'title': problem.title.trim(),
        'problem_url': problem.problemUrl.trim(),
        'platform': problem.platform,
        'difficulty': problem.difficulty,
        'status': standardizedStatus,
        'date_solved': problem.dateSolved.toIso8601String().split('T')[0],
        'notes': problem.notes ?? '',
      };
      
      await SupabaseService.client.from('problems').insert(data);
          
    } catch (error) {
      print('Error adding problem: $error');
      rethrow;
    }
  }

  Future<void> updateProblemStatus(String problemId, String newStatus) async {
    try {
      String standardizedStatus = _standardizeStatus(newStatus);
      
      await SupabaseService.client
          .from('problems')
          .update({'status': standardizedStatus})
          .eq('id', problemId);
          
    } catch (error) {
      print('Error updating problem status: $error');
      rethrow;
    }
  }

  Future<void> updateProblem(Problem problem) async { // upd
    try {
      final data = {
        'title': problem.title,
        'problem_url': problem.problemUrl,
        'platform': problem.platform,
        'difficulty': problem.difficulty,
        'status': problem.status,
        'date_solved': problem.dateSolved.toIso8601String().split('T')[0],
        'notes': problem.notes ?? '',
      };
      
      await SupabaseService.client
          .from('problems')
          .update(data)
          .eq('id', problem.id);
    } catch (error) {
      print('Error updating problem: $error');
      rethrow;
    }
  }

  Future<void> deleteProblem(String problemId) async { // delete 
    try {
      await SupabaseService.client
          .from('problems')
          .delete()
          .eq('id', problemId);
    } catch (error) {
      print('Error deleting problem: $error');
      rethrow;
    }
  }

  Future<Map<String, int>> getStats() async {
    final problems = await getUserProblems();
    
    int pending = 0;
    int attempt = 0;
    int solved = 0;
    
    for (var problem in problems) {
      String status = problem.status;
      
      if (status == 'Pending') {
        pending++;
      } else if (status == 'Attempt') {
        attempt++;
      } else if (status == 'Solved') {
        solved++;
      } else {
        pending++;
      }
    }
    
    final total = problems.length;
    
    return {
      'total': total,
      'pending': pending,
      'attempt': attempt,
      'solved': solved,
    };
  }
}