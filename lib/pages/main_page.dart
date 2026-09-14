import 'package:flutter/material.dart';

import 'package:narrate_blog/pages/category.dart';
import 'package:narrate_blog/pages/create_post.dart';
import 'package:narrate_blog/pages/home.dart';
import 'package:narrate_blog/pages/profile.dart';
import 'package:narrate_blog/pages/saved.dart';
import 'package:narrate_blog/widgets/bottom_nav.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  int savedRefreshKey = 0;
  int homeRefreshKey = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        key: ValueKey(homeRefreshKey),
        onProfileTap: () {
          setState(() {
            selectedIndex = 4;
          });
        },
      ),

      const CategoryPage(),

      // index 2 tidak dipakai sebagai halaman tab,
      // karena tombol + membuka halaman Create menggunakan Navigator
      const SizedBox(),

      SavedPage(key: ValueKey(savedRefreshKey)),

      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),

      bottomNavigationBar: BottomNav(
        selectedIndex: selectedIndex,
        onTap: (index) {
          // HOME
          if (index == 0) {
            setState(() {
              homeRefreshKey++;
              selectedIndex = index;
            });

            return;
          }
          // TOMBOL CREATE
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostPage()),
            );

            return;
          }

          // SAVED
          if (index == 3) {
            setState(() {
              savedRefreshKey++;
              selectedIndex = index;
            });

            return;
          }

          // CATEGORY, PROFILE
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
