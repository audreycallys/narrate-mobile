import 'package:flutter/material.dart';
import 'package:narrate_blog/constants/app_colors.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: selectedIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: _navIcon(Icons.home_outlined, 0),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: _navIcon(Icons.grid_view_outlined, 1),
            label: 'Category',
          ),

          BottomNavigationBarItem(
            icon: _navIcon(Icons.add_circle_outline, 2, size: 32),
            label: 'Create',
          ),

          BottomNavigationBarItem(
            icon: _navIcon(Icons.bookmark_border, 3),
            label: 'Saved',
          ),

          BottomNavigationBarItem(
            icon: _navIcon(Icons.person_outline, 4),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, int index, {double size = 28}) {
    final isSelected = selectedIndex == index;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: size,
          color: isSelected ? AppColors.primary : Colors.grey,
        ),

        const SizedBox(height: 5),

        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}
