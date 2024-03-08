import 'package:flutter/material.dart';
import '../account/login.dart';
import '../account/welcome.dart';
import '../homePages/home.dart';
import '../account/register.dart';
import '../account/resetPassword.dart';

Map routes = {
  '/': (context) => const WelcomePage(),
  '/login': (context) => const LoginPage(),
  '/home': (context) => const Home(),
  '/register': (context) => const RegisterPage(),
  '/resetPassword': (context) => const ResetPasswordPage(),
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
