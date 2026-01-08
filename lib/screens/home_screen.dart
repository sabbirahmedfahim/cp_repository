import 'package:flutter/material.dart';
import '../models/problem.dart';
import '../services/auth_service.dart';
import '../services/problem_service.dart';
import '../constants/strings.dart';
import '../widgets/problem_card.dart';
import '../widgets/pie_chart_widget.dart';
import 'add_problem_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService auth = AuthService();
  final ProblemService problemService = ProblemService();
  List<Problem> problems = [];
  int totalProblems = 0;
  int pendingCount = 0;
  int attemptCount = 0;
  int solvedCount = 0;
  bool isLoading = true;
  String? filterStatus;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final fetchedProblems = await problemService.getUserProblems(); // load this
      final stats = await problemService.getStats();
      
      setState(() {
        problems = fetchedProblems;
        totalProblems = stats['total'] ?? 0;
        pendingCount = stats['pending'] ?? 0;
        attemptCount = stats['attempt'] ?? 0;
        solvedCount = stats['solved'] ?? 0;
      });
    } catch (error) {
      print('Error loading data: $error');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateProblemStatus(Problem problem, String newStatus) async {
    try {
      await problemService.updateProblemStatus(problem.id, newStatus);
      await loadData();
    } catch (error) {
      print('Error updating status: $error');
    }
  }

  Future<void> deleteProblem(String problemId) async {
    try {
      await problemService.deleteProblem(problemId);
      await loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Problem deleted'), backgroundColor: Colors.green),
      );
    } catch (error) {
      print('Error deleting problem: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $error'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> performLogout() async {
    await auth.signOut(); // kick
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void filterByStatus(String? status) {
    setState(() {
      filterStatus = filterStatus == status ? null : status;
    });
  }

  List<Problem> get filteredProblems {
    if (filterStatus == null) return problems;
    
    return problems.where((problem) {
      return problem.status.toLowerCase() == filterStatus!.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appName),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: performLogout),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.yourProgress, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      Center(
                        child: Container(
                          width: 180,
                          height: 180,
                          child: PieChartWidget(
                            pendingCount: pendingCount,
                            attemptCount: attemptCount,
                            solvedCount: solvedCount,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Center(
                        child: Text(
                          '$totalProblems Problems Total',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: Text('All ($totalProblems)'),
                                selected: filterStatus == null,
                                onSelected: (_) => filterByStatus(null),
                              ),
                              SizedBox(width: 8),
                              FilterChip(
                                label: Text('${AppStrings.pending} ($pendingCount)'),
                                selected: filterStatus == 'Pending',
                                onSelected: (_) => filterByStatus('Pending'),
                              ),
                              SizedBox(width: 8),
                              FilterChip(
                                label: Text('${AppStrings.attempt} ($attemptCount)'),
                                selected: filterStatus == 'Attempt',
                                onSelected: (_) => filterByStatus('Attempt'),
                              ),
                              SizedBox(width: 8),
                              FilterChip(
                                label: Text('${AppStrings.solved} ($solvedCount)'),
                                selected: filterStatus == 'Solved',
                                onSelected: (_) => filterByStatus('Solved'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.allProblems, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${filteredProblems.length} problems', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                Expanded(
                  child: filteredProblems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.code_off, size: 64, color: Colors.grey.shade300),
                              SizedBox(height: 16),
                              Text(
                                filterStatus == null ? 'No problems yet' : 'No ${filterStatus!.toLowerCase()} problems',
                                style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
                              ),
                              SizedBox(height: 8),
                              Text(
                                filterStatus == null ? 'Add your first problem to get started' : 'Try changing the filter or add new problems',
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: loadData,
                          child: ListView.builder(
                            itemCount: filteredProblems.length,
                            itemBuilder: (context, index) {
                              final problem = filteredProblems[index];
                              return ProblemCard(
                                problem: problem,
                                onStatusChanged: () async {
                                  String newStatus;
                                  switch (problem.status) {
                                    case 'Pending': newStatus = 'Attempt'; break;
                                    case 'Attempt': newStatus = 'Solved'; break;
                                    default: newStatus = 'Pending';
                                  }
                                  await updateProblemStatus(problem, newStatus);
                                },
                                onDelete: () => deleteProblem(problem.id),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => AddProblemScreen()));
          loadData();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}