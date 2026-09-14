import 'package:flutter/material.dart';

import 'package:narrate_blog/pages/category_page.dart';
import 'package:narrate_blog/pages/create_post_page.dart';
import 'package:narrate_blog/pages/home_page.dart';
import 'package:narrate_blog/widgets/bottom_nav.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),

      const CategoryPage(),

      // index 2 tidak dipakai sebagai halaman tab,
      // karena tombol + membuka halaman Create menggunakan Navigator
      const SizedBox(),

      const Center(child: Text('Saved Page')),

      const Center(child: Text('Profile Page')),
    ];

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),

      bottomNavigationBar: BottomNav(
        selectedIndex: selectedIndex,
        onTap: (index) {
          // TOMBOL CREATE
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostPage()),
            );

            return;
          }

          // HOME, CATEGORY, SAVED, PROFILE
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
