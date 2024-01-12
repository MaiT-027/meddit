import 'dart:convert';
import 'package:meddit/screens/register.dart';
import 'package:meddit/utils/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meddit/main.dart';
import 'package:http/http.dart' as http;
import 'package:meddit/screens/main_screen.dart';
import 'package:meddit/utils/user_info_storage.dart';
import 'package:meddit/widgets/custom_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static String id = '', password = '';
  static bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        appBar: MedditAppBar(),
        body: Center(
          child: CustomCircularIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: const MedditAppBar(),
        body: Center(
          child: SizedBox(
            width: 450,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'ID',
                  ),
                  onChanged: (value) {
                    id = value;
                  },
                  maxLength: 20,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                  onChanged: (value) {
                    password = value;
                  },
                  maxLength: 20,
                ),
                const SizedBox(
                  height: 50,
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
                  onPressed: () => login(id, password),
                  child: const Text("Login"),
                ),
                const SizedBox(
                  height: 10,
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
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      )),
                  child: const Text("Register"),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void login(String id, String password) async {
    if (id.isEmpty || password.isEmpty) {
      showErrorDialog(context, 'ID or password is empty');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final response = await http
        .post(Uri.parse('${dotenv.env['SERVER_URL']!}/user/login'), body: {
      'userId': id,
      'password': password,
    });

    switch (response.statusCode) {
      case 200:
        final token = jsonDecode(response.body)['token'];
        final id = jsonDecode(response.body)['id'];
        final name = jsonDecode(response.body)['name'];
        await TokenStorage.setToken(token);
        await UserInfoStorage.setUserInfo(id, name);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainScreen(),
              ));
        });
        setState(() {
          isLoading = false;
        });
        break;
      case 400:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog(context, 'Invalid ID or password');
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
