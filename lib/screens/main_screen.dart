import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:meddit/models/post.dart';
import 'package:meddit/screens/login.dart';
import 'package:meddit/widgets/post_list_cell.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Post>? postList;

  void fetch() async {
    final serverUrl = dotenv.env['SERVER_URL']!;
    final response = await http.get(Uri.parse('$serverUrl/post'));
    switch (response.statusCode) {
      case 200:
        setState(() {
          postList = [];
          final posts = jsonDecode(response.body);
          for (var post in posts) {
            postList!.add(Post.fromJson(post));
          }
        });
        break;
      case 401:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          fetch();
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ));
        });
        break;
      default:
        setState(() {
          postList = [];
        });
    }
  }

  @override
  void initState() {
    fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return getPosts(postList);
  }

  dynamic getPosts(List<Post>? postList) {
    if (postList == null) {
      return const Center(
        child: CircularProgressIndicator(strokeAlign: 5),
      );
    }
    if (postList.isEmpty) {
      return const Center(
        child: Text('No posts found'),
      );
    }
    return SizedBox(
      child: ListView.builder(
          itemCount: postList.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                PostListCell(
                  id: postList[index].id,
                  title: postList[index].title,
                  authorName: postList[index].author.name,
                  timestamp: postList[index].timestamp,
                ),
              ],
            );
          }),
    );
  }
}
