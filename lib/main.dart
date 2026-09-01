import 'package:flutter/material.dart';
import 'package:nova_ui/nova_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('HELLO'),
                const SizedBox(height: 40),
                CtaFactory.selectCTA(
                  type: CtaType.facebookLogin,
                  data: CtaData(text: 'Sign Up with Facebook', onTapped: () {}),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
