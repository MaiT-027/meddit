class Comment {
  final int id, timestamp;
  final String name, content;

  Comment({
    required this.id,
    required this.name,
    required this.content,
    required this.timestamp,
  });

  Comment.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        content = json['content'],
        timestamp = json['timestamp'];
}
