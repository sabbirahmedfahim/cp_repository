import 'package:flutter/material.dart';
import '../database.dart';
import '../models/problem.dart';
import '../widgets/problem_card.dart';
import 'add_problem_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Problem> problems = [];
  bool isLoading = true;
  int totProblems = 0, pending = 0, attempt = 0, solved = 0;
  String? currChipsFilter;
  String? pinnedProblemId;

  @override
  void initState() {
    super.initState();
    clctDataFromDB();
  }

  Future<void> clctDataFromDB() async {
    setState(() => isLoading = true);
    try {
      problems = await getProblems();
      final stats = await getStats();
      totProblems = stats['total'] ?? 0;
      pending = stats['pending'] ?? 0;
      attempt = stats['attempt'] ?? 0;
      solved = stats['solved'] ?? 0;
    } catch (e) {
      print('Error: $e');
    }
    setState(() => isLoading = false);
  }

  List<Problem> getFilteredProblems() {
    var filteredProblems = problems;

    if (currChipsFilter == 'Unsolved') {
      filteredProblems = filteredProblems
          .where((p) => p.status == 'Pending' || p.status == 'Attempt')
          .toList();
    } else if (currChipsFilter == 'Solved') {
      filteredProblems =
          filteredProblems.where((p) => p.status == 'Solved').toList();
    }

    return filteredProblems;
  }

  Problem? getPinnedProblem() {
    if (pinnedProblemId == null) return null;
    return problems.firstWhere((problem) => problem.id == pinnedProblemId);
  }

  List<Problem> getNonPinnedProblems() {
    return getFilteredProblems()
        .where((problem) => problem.id != pinnedProblemId)
        .toList();
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

  Future<void> _showTagsDialog(Problem problem) async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => TagDialog(existingTags: problem.tags),
    );

    if (result != null) {
      await updateProblemTags(problem.id, result);
      await clctDataFromDB();
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
      clctDataFromDB();
    }
  }

  Future<void> _showDeleteDialog(String problemId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text('Delete Problem', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete this problem? This action cannot be undone.',
          style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      await deleteProblem(problemId);
      if (pinnedProblemId == problemId) {
        pinnedProblemId = null;
      }
      clctDataFromDB();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted'), backgroundColor: Colors.green));
    }
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
        backgroundColor: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(height: 60),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.white),
              title: Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => SettingsScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          
          int getGridColumns() {
            if (screenWidth < 600) return 1;
            if (screenWidth < 900) return 2;
            if (screenWidth < 1200) return 3;
            return 4;
          }
          
          final gridColumns = getGridColumns();
          
          return Stack(
            children: [
              if (isLoading)
                Center(child: CircularProgressIndicator(color: Colors.blue))
              else
                Column(
                  children: [
                    if (getPinnedProblem() != null) ...[
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16, right: 16, top: 16, bottom: 8),
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
                                    fontSize: 12, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      if (screenWidth < 600)
                        ProblemCard(
                            problem: getPinnedProblem()!,
                            isPinned: true,
                            isRowLayout: false,
                            onStatusChange: () => _changeStatus(getPinnedProblem()!),
                            onDelete: () => _showDeleteDialog(getPinnedProblem()!.id),
                            onTagsTap: () => _showTagsDialog(getPinnedProblem()!),
                            onTogglePin: () => togglePin(getPinnedProblem()!.id))
                      else
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ProblemCard(
                            problem: getPinnedProblem()!,
                            isPinned: true,
                            isRowLayout: true,
                            onStatusChange: () => _changeStatus(getPinnedProblem()!),
                            onDelete: () => _showDeleteDialog(getPinnedProblem()!.id),
                            onTagsTap: () => _showTagsDialog(getPinnedProblem()!),
                            onTogglePin: () => togglePin(getPinnedProblem()!.id),
                          ),
                        ),
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
                              label: Text('All ($totProblems)',
                                  style: TextStyle(color: Colors.white)),
                              selected: currChipsFilter == null,
                              selectedColor: Colors.blue,
                              backgroundColor: Colors.grey[900],
                              onSelected: (_) => setState(() => currChipsFilter =
                                  currChipsFilter == null ? '' : null),
                            ),
                            SizedBox(width: 12),
                            FilterChip(
                              label: Text('Unsolved ($unsolved)',
                                  style: TextStyle(color: Colors.white)),
                              selected: currChipsFilter == 'Unsolved',
                              selectedColor: Colors.orange,
                              backgroundColor: Colors.grey[900],
                              onSelected: (_) => setState(() => currChipsFilter =
                                  currChipsFilter == 'Unsolved'
                                      ? null
                                      : 'Unsolved'),
                            ),
                            SizedBox(width: 12),
                            FilterChip(
                              label: Text('Solved ($solved)',
                                  style: TextStyle(color: Colors.white)),
                              selected: currChipsFilter == 'Solved',
                              selectedColor: Colors.green,
                              backgroundColor: Colors.grey[900],
                              onSelected: (_) => setState(() => currChipsFilter =
                                  currChipsFilter == 'Solved' ? null : 'Solved'),
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
                          Text('${getNonPinnedProblems().length} problems',
                              style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (getNonPinnedProblems().isEmpty && getPinnedProblem() == null) {
                            String titleText;
                            String subtitleText;

                            if (currChipsFilter == null) {
                              titleText = 'No problems yet';
                              subtitleText = 'Add your first problem';
                            } else if (currChipsFilter == 'Unsolved') {
                              titleText = 'No unsolved problems';
                              subtitleText = 'All problems are solved!';
                            } else {
                              titleText = 'No solved problems';
                              subtitleText = 'Solve some problems first';
                            }

                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.code_off,
                                      size: 64, color: Colors.grey.shade700),
                                  SizedBox(height: 16),
                                  Text(
                                    titleText,
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey.shade400),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    subtitleText,
                                    style: TextStyle(color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (getNonPinnedProblems().isEmpty && getPinnedProblem() != null) {
                            return Container(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  'No more problems to show',
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ),
                            );
                          }

                          return RefreshIndicator(
                            color: Colors.blue,
                            onRefresh: clctDataFromDB,
                            child: screenWidth < 600
                                ? ListView.builder(
                                    itemCount: getNonPinnedProblems().length,
                                    itemBuilder: (context, index) {
                                      final problem = getNonPinnedProblems()[index];
                                      return ProblemCard(
                                        problem: problem,
                                        isPinned: false,
                                        isRowLayout: false,
                                        onStatusChange: () => _changeStatus(problem),
                                        onDelete: () => _showDeleteDialog(problem.id),
                                        onTagsTap: () => _showTagsDialog(problem),
                                        onTogglePin: () => togglePin(problem.id),
                                      );
                                    },
                                  )
                                : GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: gridColumns,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: screenWidth < 900 ? 1.5 : 1.8,
                                    ),
                                    padding: EdgeInsets.all(16),
                                    itemCount: getNonPinnedProblems().length,
                                    itemBuilder: (context, index) {
                                      final problem = getNonPinnedProblems()[index];
                                      return ProblemCard(
                                        problem: problem,
                                        isPinned: false,
                                        isRowLayout: false,
                                        onStatusChange: () => _changeStatus(problem),
                                        onDelete: () => _showDeleteDialog(problem.id),
                                        onTagsTap: () => _showTagsDialog(problem),
                                        onTogglePin: () => togglePin(problem.id),
                                      );
                                    },
                                  ),
                          );
                        },
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
                      await Navigator.push(context,
                          MaterialPageRoute(builder: (_) => AddProblemScreen()));
                      clctDataFromDB();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth < 600 ? 32 : 48,
                        vertical: screenWidth < 600 ? 16 : 20,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text('Add Problem',
                        style: TextStyle(
                            fontSize: screenWidth < 600 ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ),
            ],
          );
        },
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
      title: Row(
        children: [
          Icon(Icons.label, color: Colors.blue),
          SizedBox(width: 8),
          Text('Tags', style: TextStyle(color: Colors.white)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Tags:', style: TextStyle(color: Colors.grey, fontSize: 14)),
            SizedBox(height: 8),
            if (tags.isEmpty)
              Text('No tags yet', style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) {
                  return Chip(
                    label: Text(tag, style: TextStyle(color: Colors.white)),
                    deleteIcon: Icon(Icons.close, size: 16, color: Colors.white),
                    backgroundColor: Colors.grey[800],
                    onDeleted: () => removeTag(tag),
                  );
                }).toList(),
              ),
            SizedBox(height: 16),
            Text('Add New Tag:', style: TextStyle(color: Colors.grey, fontSize: 14)),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: tagController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter tag name',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.blue),
                  onPressed: addTag,
                  tooltip: 'Add Tag',
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.grey)),
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