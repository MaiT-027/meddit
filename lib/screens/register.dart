import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meddit/main.dart';
import 'package:http/http.dart' as http;
import 'package:meddit/screens/login.dart';
import 'package:meddit/utils/error_dialog.dart';
import 'package:meddit/widgets/custom_indicator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static String id = '', password = '', confirmPassword = '', name = '';
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
                  onChanged: (value) => id = value,
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
                  onChanged: (value) => password = value,
                  maxLength: 20,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Confirm Password',
                  ),
                  onChanged: (value) => confirmPassword = value,
                  maxLength: 20,
                ),
                const SizedBox(
                  width: 100,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                  ),
                  onChanged: (value) => name = value,
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
                  onPressed: register,
                  child: const Text("Register"),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void register() async {
    if (id == '' || password == '' || confirmPassword == '' || name == '') {
      showErrorDialog(context, 'Please fill out all fields');
      return;
    }
    if (password != confirmPassword) {
      showErrorDialog(context, 'Passwords do not match');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('${dotenv.env["SERVER_URL"]!}/user'),
      body: {
        'userId': id,
        'password': password,
        'name': name,
      },
    );

    switch (response.statusCode) {
      case 201:
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
        );
        setState(() {
          isLoading = false;
        });
        break;
      default:
        setState(() {
          isLoading = false;
        });
        break;
    }
  }
}
