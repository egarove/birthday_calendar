import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/theme/app_theme.dart';
import 'package:birthday_calendar/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; //usuario actual
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bithday-Calendar',
      theme: AppTheme.lightTheme(),
      routes: AppRoutes.routes,
      initialRoute: user != null ? 'dashboard' : AppRoutes.initialRoute,
    );
  }
}