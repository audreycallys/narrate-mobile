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
  int categoryRefreshKey = 0;
  int profileRefreshKey = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        key: ValueKey(homeRefreshKey),
        onProfileTap: () {
          setState(() {
            profileRefreshKey++;
            selectedIndex = 4;
          });
        },
      ),
      CategoryPage(key: ValueKey(categoryRefreshKey)),
      const SizedBox(),
      SavedPage(key: ValueKey(savedRefreshKey)),
      ProfilePage(key: ValueKey(profileRefreshKey)),
    ];

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: BottomNav(
        selectedIndex: selectedIndex,
        onTap: (index) async {
          if (index == 0) {
            setState(() {
              homeRefreshKey++;
              selectedIndex = index;
            });

            return;
          }

          if (index == 1) {
            setState(() {
              categoryRefreshKey++;
              selectedIndex = index;
            });

            return;
          }

          if (index == 2) {
            final created = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostPage()),
            );

            if (!mounted) return;

            if (created == true) {
              setState(() {
                homeRefreshKey++;
                categoryRefreshKey++;
                profileRefreshKey++;
              });
            }

            return;
          }

          if (index == 3) {
            setState(() {
              savedRefreshKey++;
              selectedIndex = index;
            });

            return;
          }

          if (index == 4) {
            setState(() {
              profileRefreshKey++;
              selectedIndex = index;
            });

            return;
          }

          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
