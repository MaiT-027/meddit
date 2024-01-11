import 'package:flutter/material.dart';
import 'package:meddit/widgets/post_list_cell.dart';

class CommentListCell extends StatelessWidget {
  final int id, timestamp;
  final String name, content;
  const CommentListCell({
    super.key,
    required this.id,
    required this.name,
    required this.content,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$name: $content',
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        Text(
          getTime(timestamp),
        ),
      ],
    );
  }
}
