import 'package:flutter/material.dart';
import 'package:birthday_calendar/screens/screens.dart';

class AppRoutes {

  static const initialRoute = 'home';

  static Map<String, Widget Function(BuildContext)> routes = {
    'home' : (BuildContext context) => const HomeScreen(),
    'login' : (BuildContext context) => const LoginScreen()
  };
}