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
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 95,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x18000000),
                        blurRadius: 12,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _navItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home,
                        index: 0,
                      ),

                      _navItem(
                        icon: Icons.grid_view_outlined,
                        activeIcon: Icons.grid_view,
                        index: 1,
                      ),

                      // Ruang kosong untuk tombol +
                      const Expanded(child: SizedBox()),

                      _navItem(
                        icon: Icons.bookmark_border,
                        activeIcon: Icons.bookmark,
                        index: 3,
                      ),

                      _navItem(
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                        index: 4,
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 0,
                child: InkWell(
                  onTap: () {
                    onTap(2);
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x30000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, size: 38, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required IconData activeIcon,
    required int index,
  }) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          onTap(index);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 27,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),

            const SizedBox(height: 6),

            Container(
              width: 20,
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
