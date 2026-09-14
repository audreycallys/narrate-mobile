import 'package:flutter/material.dart';
import 'package:narrate_blog/widgets/bottom_nav.dart';
import 'package:narrate_blog/pages/home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomePage(),

    Center(
      child: Text('Category Page'),
    ),

    Center(
      child: Text('Create Page'),
    ),

    Center(
      child: Text('Saved Page'),
    ),

    Center(
      child: Text('Profile Page'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNav(
        selectedIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}