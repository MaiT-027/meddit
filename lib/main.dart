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
    return MaterialApp(
      title: 'Meddit',
      home: MaterialApp(
        home: Scaffold(
          appBar: const MedditAppBar(),
          body: const MainScreen(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
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
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const App(),
                    ),
                  );
                },
                icon: const Icon(Icons.home),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
