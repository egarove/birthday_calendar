import 'package:flutter/material.dart';
import 'package:birthday_calendar/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //AppBar omitido
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fondo.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),

            child: Column(
              children: [

                Spacer(),

                Container(
                  padding: const EdgeInsets.all(35),
                  child: const Icon(
                    Icons.cake_rounded,
                    size: 80,
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  'BIRTHDAY CALENDAR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Spacer(),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, 'login'),
                      child: const Text('INICIAR SESION'),
                    ),

                    const SizedBox(height: 15),

                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, 'register'),
                      child: const Text('REGISTRO'),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}