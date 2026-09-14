import 'package:flutter/material.dart';
import 'package:narrate_blog/services/category_service.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List categories = [];

  Future<void> getCategories() async {
    final result = await CategoryService.getCategories();

    setState(() {
      categories = result;
    });
  }

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  final List<Color> categoryColors = const [
    Color(0xFFE4F4F6),
    Color(0xFFFFF1D9),
    Color(0xFFF4E6FF),
    Color(0xFFE6F5E9),
    Color(0xFFFFE8E8),
    Color(0xFFE5EEFF),
    Color(0xFFFFF0E5),
    Color(0xFFE8E8F8),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Eksplor',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Temukan artikel berdasarkan topik yang kamu suka.',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: categories.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        itemCount: categories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              childAspectRatio: 1.35,
                            ),
                        itemBuilder: (context, index) {
                          final category = categories[index];

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  categoryColors[index % categoryColors.length],
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                category['name'],
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
