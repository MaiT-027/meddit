import 'package:meddit/models/comment.dart';
import 'package:meddit/models/user.dart';

class Post {
  final String title;
  String? content;
  final int id, timestamp;
  final User author;
  List<Comment>? comments = [];

  Post({
    required this.title,
    required this.id,
    required this.timestamp,
    required this.author,
    this.content,
    this.comments,
  });

  Post.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        timestamp = json['timestamp'],
        author = User.fromJson(json['author']),
        content = json['content'],
        comments = json['comments'] != null
            ? (json['comments'] as List)
                .map((comment) => Comment.fromJson(comment))
                .toList()
            : null;
}
