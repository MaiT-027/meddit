import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meddit/main.dart';
import 'package:meddit/screens/login.dart';
import 'package:meddit/utils/error_dialog.dart';
import 'package:meddit/utils/user_info_storage.dart';
import 'package:meddit/widgets/custom_indicator.dart';
import 'package:http/http.dart' as http;

class EditPostScreen extends StatefulWidget {
  const EditPostScreen({
    super.key,
    required this.initialTitle,
    required this.initialContent,
    required this.id,
  });
  final int id;
  final String initialTitle, initialContent;
  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  static bool isLoading = false;
  static String title = '', content = '';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    _titleController.text = widget.initialTitle;
    _contentController.text = widget.initialContent;
    title = widget.initialTitle;
    content = widget.initialContent;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MedditAppBar(),
      body: isLoading
          ? const Center(
              child: CustomCircularIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Center(
                child: SizedBox(
                  width: 650,
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Title',
                          contentPadding: EdgeInsets.only(
                            left: 10,
                          ),
                        ),
                        maxLength: 20,
                        onChanged: (value) => title = value,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Content',
                          contentPadding: EdgeInsets.only(
                            bottom: 200,
                            left: 10,
                          ),
                        ),
                        maxLength: 300,
                        onChanged: (value) => content = value,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(
                            const Size(300, 50),
                          ),
                          backgroundColor: MaterialStatePropertyAll(
                            Colors.orange.shade300,
                          ),
                        ),
                        onPressed: submit,
                        child: const Text("Submit"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void submit() async {
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields"),
        ),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    final response = await http.patch(
      Uri.parse(
        '${dotenv.env['SERVER_URL']!}/post/${widget.id}',
      ),
      headers: {
        'Authorization': await TokenStorage.getToken() ?? '',
      },
      body: {
        'title': title,
        'content': content,
      },
    );

    setState(() {
      isLoading = true;
    });

    switch (response.statusCode) {
      case 200:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context);
        });
        setState(() {
          isLoading = false;
        });
        break;
      case 401:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog(context, '로그인이 필요합니다');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        });
        setState(() {
          isLoading = false;
        });
        break;
      default:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog(context, 'Unknown error');
        });
        setState(() {
          isLoading = false;
        });
        break;
    }
  }
}
