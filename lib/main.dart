import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'router/router.dart';
import './homePages/chat/chat.dart';
import './provider/post.dart';
import './provider/comment.dart';
import './provider/chat.dart';
import './provider/get_it.dart';

void main() {
  setupGetIt();
  runApp(
      /* ChangeNotifierProvider(
      create: (context) => PostNotifier(),
      child: MyApp(),
    ), */
      MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    /* return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "login",
      onGenerateRoute: onGenerateRoute,
    ); */
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PostNotifier()),
        ChangeNotifierProvider(create: (context) => CommentNotifier()),
        // ChangeNotifierProvider(create: (context) => ChatUserNotifier()),
        ChangeNotifierProvider.value(value: GetIt.instance<ChatUserNotifier>()),
        ChangeNotifierProvider.value(
            value: GetIt.instance<ChatMessageNotifier>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Login Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: "login",
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }
}
