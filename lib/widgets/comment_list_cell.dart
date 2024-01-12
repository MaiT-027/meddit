import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meddit/utils/error_dialog.dart';
import 'package:meddit/utils/user_info_storage.dart';
import 'package:meddit/widgets/post_list_cell.dart';
import 'package:http/http.dart' as http;

class CommentListCell extends StatefulWidget {
  final int id, timestamp, authorId;
  final String name, content;
  const CommentListCell({
    super.key,
    required this.id,
    required this.name,
    required this.content,
    required this.timestamp,
    required this.authorId,
  });

  @override
  State<CommentListCell> createState() => _CommentListCellState();
}

class _CommentListCellState extends State<CommentListCell> {
  static bool isDeletable = false;
  @override
  void initState() {
    checkDeletable();
    super.initState();
  }

  void checkDeletable() async {
    if (widget.authorId.toString() == await UserInfoStorage.getUserId()) {
      isDeletable = true;
    }
  }

  Future deleteComment(int id) async {
    final token = await TokenStorage.getToken();
    final response = await http.delete(
      Uri.parse('${dotenv.env['API_URL']!}/comment/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    switch (response.statusCode) {
      case 200:
        dispose();
        break;
      case 401:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog(context, '로그인이 필요합니다.');
          Navigator.pop(context);
          Navigator.pop(context);
        });
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.name}: ${widget.content}',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const Spacer(),
            Text(
              getTime(widget.timestamp),
            ),
            isDeletable
                ? IconButton(
                    onPressed: () async {
                      await deleteComment(widget.id);
                    },
                    icon: const Icon(Icons.delete),
                  )
                : const SizedBox(),
          ],
        ),
        const SizedBox(
          height: 5,
        )
      ],
    );
  }
}
