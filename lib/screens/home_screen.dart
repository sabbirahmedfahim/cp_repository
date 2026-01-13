import 'package:flutter/material.dart';
import '../database.dart';
import '../models/problem.dart';
import 'add_problem_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Problem> problems = [];
  bool loading = true;
  int total = 0, pending = 0, attempt = 0, solved = 0;
  String? filter;
  String? tagFilter;
  String? pinnedProblemId;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      problems = await getProblems();
      final stats = await getStats();
      total = stats['total'] ?? 0;
      pending = stats['pending'] ?? 0;
      attempt = stats['attempt'] ?? 0;
      solved = stats['solved'] ?? 0;
    } catch (e) {
      print('Error: $e');
    }
    setState(() => loading = false);
  }

  List<Problem> get shownProblems {
    var filtered = problems;
    
    if (filter == 'Unsolved') {
      filtered = filtered.where((p) => p.status == 'Pending' || p.status == 'Attempt').toList();
    } else if (filter == 'Solved') {
      filtered = filtered.where((p) => p.status == 'Solved').toList();
    }
    
    if (tagFilter != null && tagFilter!.isNotEmpty) {
      filtered = filtered.where((p) => p.tags.contains(tagFilter!)).toList();
    }
    
    return filtered;
  }

  Problem? get pinnedProblem {
    if (pinnedProblemId == null) return null;
    return problems.firstWhere((problem) => problem.id == pinnedProblemId, orElse: () => Problem(
      id: '',
      userId: '',
      title: '',
      url: '',
      platform: '',
      tags: [],
      status: 'Pending',
      createdAt: DateTime.now(),
    ));
  }

  List<Problem> get nonPinnedProblems {
    return shownProblems.where((problem) => problem.id != pinnedProblemId).toList();
  }

  void togglePin(String problemId) {
    setState(() {
      if (pinnedProblemId == problemId) {
        pinnedProblemId = null;
      } else {
        pinnedProblemId = problemId;
      }
    });
  }

  List<String> getAllTags() {
    final allTags = <String>{};
    for (var problem in problems) {
      allTags.addAll(problem.tags);
    }
    return allTags.toList()..sort();
  }

  Future<void> _promptTags(Problem problem) async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => TagDialog(existingTags: problem.tags),
    );

    if (result != null) {
      await updateProblemTags(problem.id, result);
      await load();
    }
  }

  void _changeStatus(Problem problem) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: Colors.black,
        title: Text('Change Status', style: TextStyle(color: Colors.white)),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'Pending'),
            child: Row(children: [
              Icon(Icons.access_time, color: Colors.grey),
              SizedBox(width: 12),
              Text('Pending', style: TextStyle(color: Colors.white)),
            ]),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'Attempt'),
            child: Row(children: [
              Icon(Icons.refresh, color: Colors.blue),
              SizedBox(width: 12),
              Text('Attempt', style: TextStyle(color: Colors.white)),
            ]),
          ),
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(context, 'Solved');
            },
            child: Row(children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 12),
              Text('Solved', style: TextStyle(color: Colors.white)),
            ]),
          ),
        ],
      ),
    );

    if (result != null && result != problem.status) {
      await updateProblemStatus(problem.id, result);
      if (result == 'Solved') {
        await _promptTags(problem);
      }
      load();
    }
  }

  void _deleteProblem(String id) async {
    await deleteProblem(id);
    if (pinnedProblemId == id) {
      pinnedProblemId = null;
    }
    load();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted'), backgroundColor: Colors.green));
  }

  void _logout() async {
    await logout();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    int unsolved = pending + attempt;

    return Scaffold(
      backgroundColor: Colors.black,
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade800,
                    child: Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'User Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    supabase.auth.currentUser?.email ?? 'Not logged in',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.grey.shade300),
              title: Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red.shade300),
              title: Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('CP Repository', style: TextStyle(color: Colors.white)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Stack(
        children: [
          loading
              ? Center(child: CircularProgressIndicator(color: Colors.blue))
              : Column(
                  children: [
                    if (pinnedProblem != null) ...[
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('FOCUS ZONE',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade400)),
                            Text('Currently focused',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      _ProblemCard(
                          problem: pinnedProblem!,
                          isPinned: true,
                          onStatusChange: () => _changeStatus(pinnedProblem!),
                          onDelete: () => _deleteProblem(pinnedProblem!.id),
                          onEditTags: () => _promptTags(pinnedProblem!),
                          onTogglePin: () => togglePin(pinnedProblem!.id)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Divider(color: Colors.grey.shade800),
                      ),
                      SizedBox(height: 8),
                    ],
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: Text('All ($total)', style: TextStyle(color: Colors.white)),
                              selected: filter == null,
                              selectedColor: Colors.blue,
                              backgroundColor: Colors.grey[900],
                              onSelected: (_) => setState(
                                  () => filter = filter == null ? '' : null),
                            ),
                            SizedBox(width: 12),
                            FilterChip(
                              label: Text('Unsolved ($unsolved)', style: TextStyle(color: Colors.white)),
                              selected: filter == 'Unsolved',
                              selectedColor: Colors.orange,
                              backgroundColor: Colors.grey[900],
                              onSelected: (_) => setState(() => filter =
                                  filter == 'Unsolved' ? null : 'Unsolved'),
                            ),
                            SizedBox(width: 12),
                            FilterChip(
                              label: Text('Solved ($solved)', style: TextStyle(color: Colors.white)),
                              selected: filter == 'Solved',
                              selectedColor: Colors.green,
                              backgroundColor: Colors.grey[900],
                              onSelected: (_) => setState(() =>
                                  filter = filter == 'Solved' ? null : 'Solved'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ALL PROBLEMS',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade400)),
                          Text('${nonPinnedProblems.length} problems',
                              style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: nonPinnedProblems.isEmpty && pinnedProblem == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.code_off,
                                      size: 64, color: Colors.grey.shade700),
                                  SizedBox(height: 16),
                                  Text(
                                    filter == null
                                        ? 'No problems yet'
                                        : filter == 'Unsolved'
                                            ? 'No unsolved problems'
                                            : 'No solved problems',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey.shade400),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    filter == null
                                        ? 'Add your first problem'
                                        : filter == 'Unsolved'
                                            ? 'All problems are solved!'
                                            : 'Solve some problems first',
                                    style: TextStyle(color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            )
                          : nonPinnedProblems.isEmpty && pinnedProblem != null
                              ? Container(
                                  padding: EdgeInsets.all(20),
                                  child: Center(
                                    child: Text(
                                      'No more problems to show',
                                      style: TextStyle(color: Colors.grey.shade500),
                                    ),
                                  ),
                                )
                              : RefreshIndicator(
                                  color: Colors.blue,
                                  onRefresh: load,
                                  child: ListView.builder(
                                    itemCount: nonPinnedProblems.length,
                                    itemBuilder: (context, index) {
                                      final problem = nonPinnedProblems[index];
                                      return _ProblemCard(
                                          problem: problem,
                                          isPinned: false,
                                          onStatusChange: () => _changeStatus(problem),
                                          onDelete: () => _deleteProblem(problem.id),
                                          onEditTags: () => _promptTags(problem),
                                          onTogglePin: () => togglePin(problem.id));
                                    },
                                  ),
                                ),
                    ),
                  ],
                ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                      context, MaterialPageRoute(builder: (_) => AddProblemScreen()));
                  load();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text('Add Problem', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TagDialog extends StatefulWidget {
  final List<String> existingTags;
  
  const TagDialog({required this.existingTags});
  
  @override
  _TagDialogState createState() => _TagDialogState();
}

class _TagDialogState extends State<TagDialog> {
  final tagController = TextEditingController();
  List<String> tags = [];
  
  @override
  void initState() {
    super.initState();
    tags = List.from(widget.existingTags);
  }
  
  void addTag() {
    final tag = tagController.text.trim();
    if (tag.isNotEmpty && !tags.contains(tag)) {
      setState(() {
        tags.add(tag);
        tagController.clear();
      });
    }
  }

  void removeTag(String tag) {
    setState(() {
      tags.remove(tag);
    });
  }
  
  @override
  void dispose() {
    tagController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      title: Text('Add Tags (Optional)', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add tags for this problem (press Enter to add)', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 16),
            TextField(
              controller: tagController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g., DP, Graph, Math',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add, color: Colors.blue),
                  onPressed: addTag,
                ),
              ),
              onSubmitted: (_) => addTag(),
            ),
            SizedBox(height: 12),
            if (tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) {
                  return Chip(
                    label: Text(tag, style: TextStyle(color: Colors.white)),
                    deleteIcon: Icon(Icons.close, size: 16, color: Colors.white),
                    backgroundColor: Colors.grey[900],
                    onDeleted: () => removeTag(tag),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Skip', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, tags),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
      insetPadding: EdgeInsets.all(20),
      contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: EdgeInsets.fromLTRB(24, 0, 24, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _ProblemCard extends StatefulWidget {
  final Problem problem;
  final bool isPinned;
  final VoidCallback onStatusChange;
  final VoidCallback onDelete;
  final VoidCallback onEditTags;
  final VoidCallback onTogglePin;

  const _ProblemCard({
      required this.problem,
      required this.isPinned,
      required this.onStatusChange,
      required this.onDelete,
      required this.onEditTags,
      required this.onTogglePin});

  @override
  _ProblemCardState createState() => _ProblemCardState();
}

class _ProblemCardState extends State<_ProblemCard> {
  bool showDelete = false;

  Color _statusColor(String s) => s == 'Solved'
      ? Colors.green
      : s == 'Attempt'
          ? Colors.blue
          : Colors.grey;
  IconData _statusIcon(String s) => s == 'Solved'
      ? Icons.check_circle
      : s == 'Attempt'
          ? Icons.refresh
          : Icons.access_time;

  Color _platformColor(String name) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
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
                      if (widget.problem.isValidUrl &&
                          widget.problem.url.isNotEmpty) {
                        openUrl(widget.problem.url);
                      }
                    },
                    child: Text(
                      widget.problem.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: widget.problem.isValidUrl
                            ? Colors.blue
                            : Colors.white,
                        decoration: widget.problem.isValidUrl
                            ? TextDecoration.underline
                            : TextDecoration.none,
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
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color:
                          _statusColor(widget.problem.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _statusColor(widget.problem.status)
                              .withOpacity(0.3)),
                    ),
                    child: Icon(_statusIcon(widget.problem.status),
                        color: _statusColor(widget.problem.status), size: 18),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.edit, size: 18, color: Colors.blue),
                  onPressed: widget.onEditTags,
                  padding: EdgeInsets.zero,
                  tooltip: 'Edit Tags',
                ),
                SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    widget.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 18,
                    color: widget.isPinned ? Colors.orange : Colors.grey.shade500,
                  ),
                  onPressed: widget.onTogglePin,
                  padding: EdgeInsets.zero,
                  tooltip: widget.isPinned ? 'Unpin' : 'Pin',
                ),
                SizedBox(width: 4),
                if (!showDelete)
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        size: 18, color: Colors.grey.shade500),
                    onPressed: () => setState(() => showDelete = true),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            if (showDelete) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.red.shade900,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade700)),
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 18, color: Colors.red.shade300),
                    SizedBox(width: 8),
                    Expanded(
                        child: Text('Delete?',
                            style: TextStyle(
                                color: Colors.red.shade200,
                                fontSize: 13,
                                fontWeight: FontWeight.w500))),
                    SizedBox(width: 8),
                    TextButton(
                        onPressed: () => setState(() => showDelete = false),
                        child: Text('Cancel', style: TextStyle(fontSize: 13, color: Colors.grey))),
                    SizedBox(width: 4),
                    ElevatedButton(
                        onPressed: () {
                          widget.onDelete();
                          setState(() => showDelete = false);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: Text('Delete', style: TextStyle(fontSize: 13, color: Colors.white))),
                  ],
                ),
              ),
            ],
            SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: _platformColor(widget.problem.platform),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(widget.problem.platform,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor(widget.problem.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _statusColor(widget.problem.status)
                            .withOpacity(0.3)),
                  ),
                  child: Text(widget.problem.status,
                      style: TextStyle(
                          color: _statusColor(widget.problem.status),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
                if (widget.isPinned) ...[
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.push_pin, size: 12, color: Colors.orange),
                        SizedBox(width: 4),
                        Text('Pinned',
                            style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            if (widget.problem.tags.isNotEmpty) ...[
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: widget.problem.tags.map((tag) {
                  return Chip(
                    label: Text(tag,
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                    backgroundColor: Colors.grey[800],
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}