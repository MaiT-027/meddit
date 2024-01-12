import 'package:flutter/material.dart';
import 'package:meddit/screens/main_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Meddit',
      home: MaterialApp(
        home: MainScreen(),
      ),
    );
  }
}

class MedditAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MedditAppBar({
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Meddit'),
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      centerTitle: true,
      backgroundColor: Colors.orangeAccent,
    );
  }
}
