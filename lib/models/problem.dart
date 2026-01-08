class Problem {
  final String id;
  final String userId;
  final String title;
  final String problemUrl;
  final String platform;
  final String difficulty;
  final String status;
  final DateTime dateSolved;
  final String? notes;
  final DateTime createdAt;

  Problem({
    required this.id,
    required this.userId,
    required this.title,
    required this.problemUrl,
    required this.platform,
    required this.difficulty,
    required this.status,
    required this.dateSolved,
    this.notes,
    required this.createdAt,
  });

  static String _standardizeStatus(String? status) {
    if (status == null || status.isEmpty) return 'Pending';
    
    String trimmed = status.trim().toLowerCase();
    if (trimmed == 'pending') return 'Pending';
    if (trimmed == 'attempt') return 'Attempt';
    if (trimmed == 'solved') return 'Solved';
    
    return 'Pending';
  }

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      problemUrl: json['problem_url'] ?? '',
      platform: json['platform'] ?? '',
      difficulty: json['difficulty'] ?? 'Medium',
      status: _standardizeStatus(json['status']),
      dateSolved: json['date_solved'] != null 
          ? DateTime.parse(json['date_solved'].toString())
          : DateTime.now(),
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'problem_url': problemUrl,
      'platform': platform,
      'difficulty': difficulty,
      'status': status,
      'date_solved': dateSolved.toIso8601String().split('T')[0],
      'notes': notes,
    };
  }

  bool get hasValidUrl {
    try {
      final uri = Uri.parse(problemUrl);
      return uri.isAbsolute;
    } catch (_) {
      return false;
    }
  }

  Problem copyWith({
    String? id,
    String? userId,
    String? title,
    String? problemUrl,
    String? platform,
    String? difficulty,
    String? status,
    DateTime? dateSolved,
    String? notes,
    DateTime? createdAt,
  }) {
    return Problem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      problemUrl: problemUrl ?? this.problemUrl,
      platform: platform ?? this.platform,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      dateSolved: dateSolved ?? this.dateSolved,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}