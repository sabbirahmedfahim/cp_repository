class Problem {
  String id;
  String userId;
  String title;
  String url;
  String platform;
  List<String> tags;
  String status;
  DateTime createdAt;

  Problem({
    this.id = '',
    this.userId = '',
    required this.title,
    required this.url,
    required this.platform,
    this.tags = const [],
    this.status = 'Pending',
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

  bool get isSolved => status.toLowerCase() == 'solved';

  static Problem fromMap(Map<String, dynamic> data) {
    String statusText = data['status']?.toString() ?? 'Pending';
    if (statusText.toLowerCase() == 'pending') statusText = 'Pending';
    if (statusText.toLowerCase() == 'attempt') statusText = 'Attempt';
    if (statusText.toLowerCase() == 'solved') statusText = 'Solved';

    List<String> tagsList = [];
    if (data['tags'] != null) {
      if (data['tags'] is List) {
        tagsList = List<String>.from(data['tags']);
      }
    }

    return Problem(
      id: data['id']?.toString() ?? '',
      userId: data['user_id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      url: data['problem_url']?.toString() ?? '',
      platform: data['platform']?.toString() ?? '',
      tags: tagsList,
      status: statusText,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title.trim(),
      'problem_url': url.trim(),
      'platform': platform.trim(),
      'status': status,
    };
    
    if (tags.isNotEmpty) {
      map['tags'] = tags;
    }
    
    return map;
  }
}