import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:meddit/main.dart';
import 'package:meddit/models/post.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:meddit/screens/edit_post_screen.dart';
import 'package:meddit/screens/login.dart';
import 'package:meddit/utils/user_info_storage.dart';
import 'package:meddit/utils/error_dialog.dart';
import 'package:meddit/widgets/comment_list_cell.dart';
import 'package:meddit/widgets/custom_indicator.dart';

class PostDetailScreen extends StatefulWidget {
  final int id;
  const PostDetailScreen({
    super.key,
    required this.id,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Post? post;
  static bool isEditable = false;
  static String comment = '';

  void getPost() async {
    final serverUrl = dotenv.env['SERVER_URL']!;
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse(
        '$serverUrl/post/${widget.id}',
      ),
      headers: {
        'Authorization': token ?? '',
      },
    );
    final json = jsonDecode(response.body);
    switch (response.statusCode) {
      case 200:
        setState(() {
          post = Post.fromJson(json.first);
        });
        break;
      case 401:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog(context, '로그인이 필요합니다.');
        });
        gotoLoginPage();
      default:
        break;
    }
  }

  void gotoLoginPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    });
  }

  @override
  void initState() {
    getPost();
    checkEditable();
    super.initState();
  }

  void checkEditable() async {
    if (post?.author.id.toString() == await UserInfoStorage.getUserId()) {
      setState(() {
        isEditable = true;
      });
    }
  }

  void deletePost() async {
    final serverUrl = dotenv.env['SERVER_URL']!;
    final token = await TokenStorage.getToken();

    final response = await http.delete(
      Uri.parse(
        '$serverUrl/post/${widget.id}',
      ),
      headers: {
        'Authorization': token ?? '',
      },
    );
    switch (response.statusCode) {
      case 200:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context);
          Navigator.pop(context);
        });
        break;
      case 401:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog(context, '로그인이 필요합니다.');
        });
        gotoLoginPage();
      default:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog(context, 'Unknown error');
        });
        break;
    }
  }

  void submitComment() async {
    final serverUrl = dotenv.env['SERVER_URL']!;
    final token = await TokenStorage.getToken();

    final response = await http.post(
      Uri.parse(
        '$serverUrl/post/${widget.id}/comment',
      ),
      headers: {
        'Authorization': token ?? '',
      },
      body: {
        'content': comment,
      },
    );

    switch (response.statusCode) {
      case 200:
        setState(
          () async {
            final response = await http.get(
              Uri.parse(
                '$serverUrl/post/${widget.id}',
              ),
              headers: {
                'Authorization': token ?? '',
              },
            );
            post = Post.fromJson(jsonDecode(response.body).first);
          },
        );

        break;
      case 401:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog(context, '로그인이 필요합니다.');
        });
        gotoLoginPage();
      default:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog(context, 'Unknown error');
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MedditAppBar(),
      body: post != null
          ? Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    '${post?.title}',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${post?.author.name}',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${post?.content}',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                  isEditable
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditPostScreen(
                                        id: post!.id,
                                        initialTitle: post!.title,
                                        initialContent: post!.content!),
                                  )),
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: deletePost,
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        )
                      : const SizedBox(),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.orange.shade300,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 1,
                            blurStyle: BlurStyle.outer,
                          )
                        ],
                        border: Border.all(
                          color: Colors.orange.shade200,
                        )),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Column(
                    children: post?.comments != null
                        ? post!.comments!
                            .map(
                              (comment) => CommentListCell(
                                id: comment.id,
                                name: comment.name,
                                content: comment.content,
                                timestamp: comment.timestamp,
                                authorId: comment.authorId,
                              ),
                            )
                            .toList()
                        : const [
                            Text(
                              "No comments yet",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Comment',
                      contentPadding: EdgeInsets.only(
                        left: 10,
                      ),
                    ),
                    onChanged: (value) => comment = value,
                    maxLength: 100,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(
                            const Size(100, 50),
                          ),
                          backgroundColor: MaterialStatePropertyAll(
                            Colors.orange.shade400,
                          ),
                        ),
                        onPressed: submitComment,
                        child: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const Center(
              child: CustomCircularIndicator(),
            ),
    );
  }
}
