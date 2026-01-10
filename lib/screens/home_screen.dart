import 'package:flutter/material.dart';
import '../database.dart';
import '../models/problem.dart';
import '../widgets/difficulty_chip.dart';
import 'add_problem_screen.dart';
import 'login_screen.dart';
import 'dart:math';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Problem> problems = [];
  bool loading = true;
  int total = 0;
  int pending = 0;
  int attempt = 0;
  int solved = 0;
  String? filter;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final data = await getProblems();
      final stats = await getStats();
      
      setState(() {
        problems = data;
        total = stats['total'] ?? 0;
        pending = stats['pending'] ?? 0;
        attempt = stats['attempt'] ?? 0;
        solved = stats['solved'] ?? 0;
      });
    } catch (e) {
      print('Load error: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  void setFilter(String? status) {
    setState(() {
      if (filter == status) {
        filter = null;
      } else {
        filter = status;
      }
    });
  }

  List<Problem> get shownProblems {
    if (filter == null) return problems;
    return problems.where((p) => p.status == filter).toList();
  }

  Future<void> changeStatus(Problem problem, String newStatus) async {
    try {
      await updateStatus(problem.id, newStatus);
      await load();
    } catch (e) {
      print('Status error: $e');
    }
  }

  Future<void> _deleteProblem(String problemId) async {
    try {
      await deleteProblem(problemId);
      await load();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed'), backgroundColor: Colors.red));
    }
  }

  Future<void> _logoutUser() async {
    try {
      await logout();
      
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  Color getPlatformColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('leetcode')) return Colors.orange;
    if (lower.contains('codeforces')) return Colors.red;
    if (lower.contains('codechef')) return Colors.brown;
    if (lower.contains('hackerrank')) return Colors.green;
    if (lower.contains('atcoder')) return Colors.blue;
    if (lower.contains('cses')) return Colors.purple;
    if (lower.contains('spoj')) return Colors.teal;
    return Colors.grey.shade700;
  }

  Color getStatusColor(String s) {
    if (s == 'Solved') return Colors.green;
    if (s == 'Attempt') return Colors.blue;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CP Repository'),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: _logoutUser)],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Your Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      Center(
                        child: Container(
                          width: 180,
                          height: 180,
                          child: CustomPaint(painter: ChartPainter(pending: pending, attempt: attempt, solved: solved)),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('$total Problems Total', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(label: Text('All ($total)'), selected: filter == null, onSelected: (_) => setFilter(null)),
                        SizedBox(width: 8),
                        FilterChip(label: Text('Pending ($pending)'), selected: filter == 'Pending', onSelected: (_) => setFilter('Pending')),
                        SizedBox(width: 8),
                        FilterChip(label: Text('Attempt ($attempt)'), selected: filter == 'Attempt', onSelected: (_) => setFilter('Attempt')),
                        SizedBox(width: 8),
                        FilterChip(label: Text('Solved ($solved)'), selected: filter == 'Solved', onSelected: (_) => setFilter('Solved')),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('All Problems', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${shownProblems.length} problems', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                Expanded(
                  child: shownProblems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.code_off, size: 64, color: Colors.grey.shade300),
                              SizedBox(height: 16),
                              Text(filter == null ? 'No problems yet' : 'No ${filter!.toLowerCase()} problems', style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
                              SizedBox(height: 8),
                              Text(filter == null ? 'Add your first problem' : 'Try changing filter', style: TextStyle(color: Colors.grey.shade400)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: load,
                          child: ListView.builder(
                            itemCount: shownProblems.length,
                            itemBuilder: (context, index) {
                              final problem = shownProblems[index];
                              return ProblemCard(
                                problem: problem,
                                onStatusChange: () {
                                  String next;
                                  if (problem.status == 'Pending') next = 'Attempt';
                                  else if (problem.status == 'Attempt') next = 'Solved';
                                  else next = 'Pending';
                                  changeStatus(problem, next);
                                },
                                onDelete: () => _deleteProblem(problem.id),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddProblemScreen()));
          load();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final int pending;
  final int attempt;
  final int solved;

  ChartPainter({required this.pending, required this.attempt, required this.solved});

  @override
  void paint(Canvas canvas, Size size) {
    final total = pending + attempt + solved;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (total == 0) {
      canvas.drawCircle(center, radius, Paint()..color = Colors.grey.shade300);
      return;
    }

    double start = -pi / 2;

    void draw(int value, Color color) {
      if (value == 0) return;
      final sweep = value / total * 2 * pi;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, true, Paint()..color = color);
      start += sweep;
    }

    draw(pending, Colors.grey.shade400);
    draw(attempt, Colors.blue);
    draw(solved, Colors.green);
  }

  @override
  bool shouldRepaint(ChartPainter old) {
    return pending != old.pending || attempt != old.attempt || solved != old.solved;
  }
}

class ProblemCard extends StatefulWidget {
  final Problem problem;
  final VoidCallback onStatusChange;
  final VoidCallback onDelete;

  const ProblemCard({
    required this.problem,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  _ProblemCardState createState() => _ProblemCardState();
}

class _ProblemCardState extends State<ProblemCard> {
  bool showDelete = false;

  Color getStatusButtonColor(String status) {
    if (status == 'Solved') return Colors.green;
    if (status == 'Attempt') return Colors.blue;
    return Colors.grey;
  }

  IconData getStatusIcon(String status) {
    if (status == 'Solved') return Icons.check;
    if (status == 'Attempt') return Icons.refresh;
    return Icons.access_time;
  }

  Color getPlatformColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('leetcode')) return Colors.orange;
    if (lower.contains('codeforces')) return Colors.red;
    if (lower.contains('codechef')) return Colors.brown;
    if (lower.contains('hackerrank')) return Colors.green;
    if (lower.contains('atcoder')) return Colors.blue;
    if (lower.contains('cses')) return Colors.purple;
    if (lower.contains('spoj')) return Colors.teal;
    return Colors.grey.shade700;
  }

  Color getStatusChipColor(String s) {
    if (s == 'Solved') return Colors.green;
    if (s == 'Attempt') return Colors.blue;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (widget.problem.isValidUrl && widget.problem.url.isNotEmpty) {
                        openUrl(widget.problem.url);
                      }
                    },
                    child: Text(
                      widget.problem.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: widget.problem.isValidUrl ? Colors.blue : Colors.black,
                        decoration: widget.problem.isValidUrl ? TextDecoration.underline : TextDecoration.none,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                InkWell(
                  onTap: widget.onStatusChange,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: getStatusButtonColor(widget.problem.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: getStatusButtonColor(widget.problem.status).withOpacity(0.3)),
                    ),
                    child: Icon(getStatusIcon(widget.problem.status), color: getStatusButtonColor(widget.problem.status), size: 20),
                  ),
                ),
                SizedBox(width: 8),
                
                if (!showDelete)
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 20, color: Colors.grey.shade500),
                    onPressed: () => setState(() => showDelete = true),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            
            if (showDelete) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade100)),
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(child: Text('Delete?', style: TextStyle(color: Colors.red.shade800, fontSize: 12, fontWeight: FontWeight.w500))),
                    SizedBox(width: 8),
                    TextButton(onPressed: () => setState(() => showDelete = false), child: Text('Cancel', style: TextStyle(fontSize: 12)), style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4))),
                    SizedBox(width: 4),
                    ElevatedButton(onPressed: () { widget.onDelete(); setState(() => showDelete = false); }, child: Text('Delete', style: TextStyle(fontSize: 12)), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4))),
                  ],
                ),
              ),
            ],
            
            SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: getPlatformColor(widget.problem.platform), borderRadius: BorderRadius.circular(12)),
                  child: Text(widget.problem.platform, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                ),
                SizedBox(width: 8),
                DifficultyChip(difficulty: widget.problem.difficulty),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: getStatusChipColor(widget.problem.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: getStatusChipColor(widget.problem.status).withOpacity(0.3)),
                  ),
                  child: Text(widget.problem.status, style: TextStyle(color: getStatusChipColor(widget.problem.status), fontSize: 12, fontWeight: FontWeight.w500)),
                ),
                Spacer(),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('${widget.problem.date.day}/${widget.problem.date.month}/${widget.problem.date.year}', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            
            if (widget.problem.notes != null && widget.problem.notes!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12),
                  Text('Notes:', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 4),
                  Text(widget.problem.notes!, style: TextStyle(color: Colors.grey.shade700), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
          ],
        ),
      ),
    );
  }
}