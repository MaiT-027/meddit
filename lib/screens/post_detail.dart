import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:meddit/main.dart';
import 'package:meddit/models/post.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:meddit/widgets/comment_list_cell.dart';

class PostDetail extends StatefulWidget {
  final int id;
  const PostDetail({
    super.key,
    required this.id,
  });

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  Post? post;

  void getPost() async {
    final serverUrl = dotenv.env['SERVER_URL']!;
    final response = await http.get(Uri.parse('$serverUrl/post/${widget.id}'));
    final json = jsonDecode(response.body);
    switch (response.statusCode) {
      case 200:
        setState(() {
          post = Post.fromJson(json.first);
        });
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    getPost();
    super.initState();
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
                              .map((comment) => CommentListCell(
                                    id: comment.id,
                                    name: comment.name,
                                    content: comment.content,
                                    timestamp: comment.timestamp,
                                  ))
                              .toList()
                          : [
                              const Text(
                                "No comments yet",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              )
                            ],
                    )
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator(
                  strokeAlign: 5,
                ),
              ));
  }
}
