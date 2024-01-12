import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meddit/screens/post_detail_screen.dart';

class PostListCell extends StatelessWidget {
  final String title, authorName;
  final int id, timestamp;
  const PostListCell({
    super.key,
    required this.id,
    required this.title,
    required this.authorName,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.orange.shade100,
                width: 3,
              ),
              color: Colors.orange.shade50,
            ),
            child: ElevatedButton(
              style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                    const Size(0, 50),
                  ),
                  shape: MaterialStateProperty.all(
                      const BeveledRectangleBorder())),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PostDetailScreen(
                    id: id,
                  ),
                ));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 30,
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Text(
                    authorName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: Text(
                      getTime(timestamp),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String getTime(int timestamp) {
  return DateFormat('yyyy-MM-dd HH:mm:ss')
      .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
}
