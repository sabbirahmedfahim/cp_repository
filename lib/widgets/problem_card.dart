import 'package:flutter/material.dart';
import '../models/problem.dart';
import '../database.dart';

class ProblemCard extends StatelessWidget {
  final Problem problem;
  final bool isPinned;
  final bool isRowLayout;
  final VoidCallback onStatusChange;
  final VoidCallback onDelete;
  final VoidCallback onTagsTap;
  final VoidCallback onTogglePin;

  const ProblemCard({
    required this.problem,
    this.isPinned = false,
    this.isRowLayout = false,
    required this.onStatusChange,
    required this.onDelete,
    required this.onTagsTap,
    required this.onTogglePin,
  });

  @override
  Widget build(BuildContext context) {
    if (isRowLayout) {
      return _buildRowLayout(context);
    }
    return _buildCardLayout(context);
  }

  Widget _buildRowLayout(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPinned ? Colors.orange.withOpacity(0.3) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (problem.isValidUrl && problem.url.isNotEmpty) {
                      openUrl(problem.url);
                    }
                  },
                  child: Text(
                    problem.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: problem.isValidUrl ? Colors.blue : Colors.white,
                      decoration: problem.isValidUrl
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _PlatformChip(platform: problem.platform),
                    SizedBox(width: 8),
                    _StatusChip(status: problem.status),
                    if (isPinned) ...[
                      SizedBox(width: 8),
                      _PinnedIndicator(),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Column(
            children: [
              _StatusIconButton(
                status: problem.status,
                onTap: onStatusChange,
              ),
              SizedBox(height: 8),
              IconButton(
                icon: Icon(Icons.label, size: 20, color: Colors.blue),
                onPressed: onTagsTap,
                tooltip: 'View/Edit Tags',
              ),
              IconButton(
                icon: Icon(
                  isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  size: 20,
                  color: isPinned ? Colors.orange : Colors.grey.shade500,
                ),
                onPressed: onTogglePin,
                tooltip: isPinned ? 'Unpin' : 'Pin',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardLayout(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (problem.isValidUrl && problem.url.isNotEmpty) {
                        openUrl(problem.url);
                      }
                    },
                    child: Text(
                      problem.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: problem.isValidUrl ? Colors.blue : Colors.white,
                        decoration: problem.isValidUrl
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                _StatusIconButton(
                  status: problem.status,
                  onTap: onStatusChange,
                  size: 30,
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.label,
                      size: 18,
                      color: problem.tags.isEmpty
                          ? Colors.grey.shade500
                          : Colors.blue),
                  onPressed: onTagsTap,
                  padding: EdgeInsets.zero,
                  tooltip: problem.tags.isEmpty ? 'Add Tags' : 'View/Edit Tags',
                ),
                SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 18,
                    color: isPinned ? Colors.orange : Colors.grey.shade500,
                  ),
                  onPressed: onTogglePin,
                  padding: EdgeInsets.zero,
                  tooltip: isPinned ? 'Unpin' : 'Pin',
                ),
                SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      size: 18, color: Colors.grey.shade500),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  tooltip: 'Delete',
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _PlatformChip(platform: problem.platform),
                SizedBox(width: 8),
                _StatusChip(status: problem.status),
                if (isPinned) ...[
                  SizedBox(width: 8),
                  _PinnedIndicator(),
                ],
              ],
            ),
            if (problem.tags.isNotEmpty) ...[
              SizedBox(height: 6),
              GestureDetector(
                onTap: onTagsTap,
                child: Row(
                  children: [
                    Icon(Icons.label, size: 14, color: Colors.blue),
                    SizedBox(width: 4),
                    Text(
                      '${problem.tags.length} tag${problem.tags.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusIconButton extends StatelessWidget {
  final String status;
  final VoidCallback onTap;
  final double size;

  const _StatusIconButton({
    required this.status,
    required this.onTap,
    this.size = 40,
  });

  Color _getStatusColor(String s) {
    if (s == 'Solved') return Colors.green;
    if (s == 'Attempt') return Colors.blue;
    return Colors.grey;
  }

  IconData _getStatusIcon(String s) {
    if (s == 'Solved') return Icons.check_circle;
    if (s == 'Attempt') return Icons.refresh;
    return Icons.access_time;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);

    return InkWell(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }
}

class _PlatformChip extends StatelessWidget {
  final String platform;

  const _PlatformChip({required this.platform});

  Color _getPlatformColor(String name) {
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _getPlatformColor(platform),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        platform,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  Color _getStatusColor(String s) {
    if (s == 'Solved') return Colors.green;
    if (s == 'Attempt') return Colors.blue;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _PinnedIndicator extends StatelessWidget {
  const _PinnedIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.push_pin, size: 12, color: Colors.orange),
          SizedBox(width: 4),
          Text(
            'Pinned',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
