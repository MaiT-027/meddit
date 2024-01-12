import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meddit/main.dart';
import 'package:meddit/screens/login.dart';
import 'package:meddit/screens/main_screen.dart';
import 'package:meddit/utils/user_info_storage.dart';
import 'package:meddit/utils/error_dialog.dart';
import 'package:meddit/widgets/custom_indicator.dart';
import 'package:http/http.dart' as http;

class WritePostScreen extends StatefulWidget {
  const WritePostScreen({
    super.key,
  });

  @override
  State<WritePostScreen> createState() => _WritePostScreenState();
}

class _WritePostScreenState extends State<WritePostScreen> {
  static bool isLoading = false;
  static String title = '', content = '';
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
      showErrorDialog(context, 'Please fill out all fields');
      return;
    }

    setState(() {
      isLoading = true;
    });
    final token = await TokenStorage.getToken();
    final response = await http.post(
      Uri.parse('${dotenv.env['SERVER_URL']!}/post'),
      body: {
        'title': title,
        'content': content,
      },
      headers: {
        'Authorization': token ?? '',
      },
    );

    switch (response.statusCode) {
      case 201:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ),
          );
        });
        setState(() {
          isLoading = false;
          title = '';
          content = '';
        });
        break;
      case 401:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog(context, '로그인이 필요합니다.');
        });
        gotoLoginPage();
        setState(() {
          isLoading = false;
        });
        break;
      default:
        break;
    }
  }

  void gotoLoginPage() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      },
    );
  }
}
