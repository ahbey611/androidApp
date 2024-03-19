import 'package:flutter/material.dart';
import '../../component/footer.dart';
import '../../component/header.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(false, "用户"),
      body: const Center(
        child: Text('用户'),
      ),
    );
  }
}
