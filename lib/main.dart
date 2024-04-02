import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'router/router.dart';
import './homePages/chat/chat.dart';

void main() {
  runApp(
    MyApp(),
    /* ChangeNotifierProvider(
      create: (context) => ChatUsersProvider(),
      child: MyApp(),
    ), */
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "login",
      onGenerateRoute: onGenerateRoute,
    );
  }
}
