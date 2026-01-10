class Problem {
  String id;
  String userId;
  String title;
  String url;
  String platform;
  String difficulty;
  String status;
  DateTime date;
  String? notes;
  DateTime createdAt;

  Problem({
    this.id = '',
    this.userId = '',
    required this.title,
    required this.url,
    required this.platform,
    this.difficulty = 'Medium',
    this.status = 'Pending',
    required this.date,
    this.notes,
    required this.createdAt,
  });

  bool get isValidUrl {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute;
    } catch (_) {
      return false;
    }
  }

  static Problem fromMap(Map<String, dynamic> data) {
    String statusText = data['status']?.toString() ?? 'Pending';
    if (statusText.toLowerCase() == 'pending') statusText = 'Pending';
    if (statusText.toLowerCase() == 'attempt') statusText = 'Attempt';
    if (statusText.toLowerCase() == 'solved') statusText = 'Solved';

    return Problem(
      id: data['id']?.toString() ?? '',
      userId: data['user_id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      url: data['problem_url']?.toString() ?? '',
      platform: data['platform']?.toString() ?? '',
      difficulty: data['difficulty']?.toString() ?? 'Medium',
      status: statusText,
      date: data['date_solved'] != null 
          ? DateTime.parse(data['date_solved'].toString())
          : DateTime.now(),
      notes: data['notes']?.toString(),
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title.trim(),
      'problem_url': url.trim(),
      'platform': platform.trim(),
      'difficulty': difficulty,
      'status': status,
      'date_solved': date.toIso8601String().split('T')[0],
      'notes': notes ?? '',
    };
  }
}