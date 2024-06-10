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
import "../homePages/user/otherUser.dart";
import "../homePages/home/search.dart";
import '../homePages/home/searchPage.dart';
import '../homePages/home/detailed_search_post.dart';

import "../homePages/chat/chatDraft.dart";
import "../homePages/chatV2/chatV2.dart";
import "../homePages/chatV2/chatRoomV2.dart";

String routePath = '/home';

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
  //'otherUser': (context) => const OtherUserPage(),
  'chatDraft': (context) => const ChatPage2(),
  '/chatV2': (context) => const ChatPageV2(),
  '/chatRoomV2': (context, {arguments}) => ChatRoomV2(arguments: arguments),
  '/search': (context) => const Search(),
  '/searchPost': (context) => const SearchPage(),
};

var onGenerateRoute = (RouteSettings settings) {
  final String? name = settings.name;
  final Function pageContentBuilder = routes[name] as Function;

  // ignore: unnecessary_null_comparison
  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      final Route route = MaterialPageRoute(
          settings: settings,
          builder: (context) =>
              pageContentBuilder(context, arguments: settings.arguments));
      return route;
    } else {
      final Route route = MaterialPageRoute(
          settings: settings,
          builder: (context) => pageContentBuilder(context));
      return route;
    }
  }
};
