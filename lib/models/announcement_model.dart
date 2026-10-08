/// Announcement / Notice Board Model
class AnnouncementModel {
  final int? id;
  final String title;
  final String content;
  final String date;
  final String author;
  final String priority; // normal, high, urgent

  const AnnouncementModel({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.author,
    this.priority = 'normal',
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      date: map['date'] as String,
      author: (map['author'] as String?) ?? 'Admin',
      priority: (map['priority'] as String?) ?? 'normal',
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'content': content,
      'date': date,
      'author': author,
      'priority': priority,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
