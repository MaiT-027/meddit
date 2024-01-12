class Comment {
  final int id, timestamp, authorId;
  final String name, content;

  Comment({
    required this.id,
    required this.name,
    required this.content,
    required this.timestamp,
    required this.authorId,
  });

  Comment.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        content = json['content'],
        timestamp = json['timestamp'],
        authorId = json['authorId'];
}
