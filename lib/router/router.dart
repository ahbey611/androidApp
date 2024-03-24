import 'package:flutter/material.dart';
import '../account/login.dart';
import '../account/welcome.dart';
import '../account/register.dart';
import '../account/resetPassword.dart';

import '../component/footer.dart';
import '../homePages/home/home.dart';
import '../homePages/chat/chat.dart';
import '../homePages/chat/chatRoom.dart';
import '../homePages/post/post.dart';
import '../homePages/user/user2.dart';

Map routes = {
  '/': (context) => const WelcomePage(),
  '/mainPages': (context, {arguments}) => MainPages(arguments: arguments),
  'login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/resetPassword': (context) => const ResetPasswordPage(),
  '/home': (context) => const HomePage(),
  '/chat': (context) => const ChatPage(),
  '/chatRoom': (context, {arguments}) => ChatRoom(arguments: arguments),
  '/post': (context) => const PostPage(),
  'user2': (context) => const UserPage2(),
};

var onGenerateRoute = (RouteSettings settings) {
  final String? name = settings.name;
  final Function pageContentBuilder = routes[name] as Function;

  // ignore: unnecessary_null_comparison
  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      final Route route = MaterialPageRoute(
          builder: (context) =>
              pageContentBuilder(context, arguments: settings.arguments));
      return route;
    } else {
      final Route route =
          MaterialPageRoute(builder: (context) => pageContentBuilder(context));
      return route;
    }
  }
};
