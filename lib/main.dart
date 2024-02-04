import 'package:flutter/material.dart';
import 'package:testvalleyflutter/ui/chat_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(
            0xffFF006B,
          ),
        ),
        useMaterial3: true,
      ),
      home: ChatScreen(),
    );
  }
}
