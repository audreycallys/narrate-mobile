import 'package:flutter/material.dart';
import 'package:narrate_blog/pages/splash.dart';

void main() {
  runApp(const NarrateBlog());
}

class NarrateBlog extends StatelessWidget {
  const NarrateBlog({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}