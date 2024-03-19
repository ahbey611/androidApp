import 'package:flutter/material.dart';
import '../../component/header.dart';
import '../../component/footer.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(false, "发布帖子"),
      body: const Center(
        child: Text('发布帖子'),
      ),
    );
  }
}
