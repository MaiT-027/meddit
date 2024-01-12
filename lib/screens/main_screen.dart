import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:meddit/main.dart';
import 'package:meddit/models/post.dart';
import 'package:meddit/screens/login.dart';
import 'package:meddit/screens/write_post_screen.dart';
import 'package:meddit/utils/user_info_storage.dart';
import 'package:meddit/utils/error_dialog.dart';
import 'package:meddit/widgets/custom_indicator.dart';
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
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse('$serverUrl/post'),
      headers: {
        'Authorization': token ?? '',
      },
    );
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
          showErrorDialog(context, '로그인이 필요합니다.');
        });
        gotoLoginPage();
        break;
      default:
        setState(() {
          postList = [];
        });
    }
  }

  void gotoLoginPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ));
    });
  }

  @override
  void initState() {
    fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MedditAppBar(),
      body: getPosts(postList),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WritePostScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  dynamic getPosts(List<Post>? postList) {
    if (postList == null) {
      return const Center(
        child: CustomCircularIndicator(),
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
