import 'package:flutter/material.dart';
import '../models/problem.dart';
import '../utils/url_helper.dart';
import 'difficulty_chip.dart';

class ProblemCard extends StatefulWidget {
  final Problem problem;
  final VoidCallback? onStatusChanged;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ProblemCard({
    Key? key,
    required this.problem,
    this.onStatusChanged,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  _ProblemCardState createState() => _ProblemCardState();
}

class _ProblemCardState extends State<ProblemCard> {
  late Problem problem;
  bool showDeleteConfirm = false;

  @override
  void initState() {
    super.initState();
    problem = widget.problem;
  }

  Color getPlatformColor(String platform) {
    final lower = platform.toLowerCase();
    if (lower.contains('leetcode')) return Colors.orange;
    if (lower.contains('codeforces')) return Colors.red;
    if (lower.contains('codechef')) return Colors.brown;
    if (lower.contains('hackerrank')) return Colors.green;
    if (lower.contains('atcoder')) return Colors.blue;
    if (lower.contains('cses')) return Colors.purple;
    if (lower.contains('spoj')) return Colors.teal;
    return Colors.grey.shade700;
  }

  Widget buildStatusButton() {
    Color buttonColor;
    IconData icon;
    String tooltip;

    switch (problem.status) {
      case 'Solved':
        buttonColor = Colors.green;
        icon = Icons.check;
        tooltip = 'Solved - Tap to change';
        break;
      case 'Attempt':
        buttonColor = Colors.blue;
        icon = Icons.refresh;
        tooltip = 'Attempted - Tap to change';
        break;
      default:
        buttonColor = Colors.grey.shade400;
        icon = Icons.access_time;
        tooltip = 'Pending - Tap to change';
    }

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: cycleStatus,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: buttonColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: buttonColor.withOpacity(0.3)),
          ),
          child: Icon(icon, color: buttonColor, size: 20),
        ),
      ),
    );
  }

  void cycleStatus() {
    String newStatus;
    switch (problem.status) {
      case 'Pending': newStatus = 'Attempt'; break;
      case 'Attempt': newStatus = 'Solved'; break;
      default: newStatus = 'Pending';
    }

    setState(() => problem = problem.copyWith(status: newStatus));
    widget.onStatusChanged?.call();
  }

  void confirmDelete() => setState(() => showDeleteConfirm = true);
  void cancelDelete() => setState(() => showDeleteConfirm = false);
  void performDelete() => widget.onDelete?.call();

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
                    onTap: () async {
                      if (problem.hasValidUrl) {
                        await UrlHelper.launchProblemUrl(problem.problemUrl);
                      }
                      widget.onTap?.call();
                    },
                    child: Text(
                      problem.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: problem.hasValidUrl ? Colors.blue : Colors.black,
                        decoration: problem.hasValidUrl ? TextDecoration.underline : TextDecoration.none,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                buildStatusButton(),
                SizedBox(width: 8),
                
                if (!showDeleteConfirm)
                  Tooltip(
                    message: 'Delete problem',
                    child: IconButton(
                      icon: Icon(Icons.delete_outline, size: 20, color: Colors.grey.shade500),
                      onPressed: confirmDelete,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ),
              ],
            ),
            
            if (showDeleteConfirm) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(child: Text('Delete this problem?', style: TextStyle(color: Colors.red.shade800, fontSize: 12, fontWeight: FontWeight.w500))),
                    SizedBox(width: 8),
                    TextButton(onPressed: cancelDelete, child: Text('Cancel', style: TextStyle(fontSize: 12)), style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero)),
                    SizedBox(width: 4),
                    ElevatedButton(onPressed: performDelete, child: Text('Delete', style: TextStyle(fontSize: 12)), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4), minimumSize: Size.zero)),
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
                    color: getPlatformColor(problem.platform),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    problem.platform,
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(width: 8),
                DifficultyChip(difficulty: problem.difficulty),
                Spacer(),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('${problem.dateSolved.day}/${problem.dateSolved.month}/${problem.dateSolved.year}', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            
            if (problem.notes != null && problem.notes!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12),
                  Text('Notes:', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 4),
                  Text(problem.notes!, style: TextStyle(color: Colors.grey.shade700, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
          ],
        ),
      ),
    );
  }
}