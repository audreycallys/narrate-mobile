import 'package:flutter/material.dart';
import 'package:narrate_blog/services/category_service.dart';
import 'package:narrate_blog/services/post_service.dart';
import 'package:narrate_blog/pages/category_detail_page.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List categories = [];
  List posts = [];

  Future<void> getData() async {
    final categoryResult = await CategoryService.getCategories();
    final postResult = await PostService.getPosts();

    setState(() {
      categories = categoryResult;
      posts = postResult;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  int getArticleCount(int categoryId) {
    return posts.where((post) {
      return post['categoryId'] == categoryId;
    }).length;
  }

  IconData getCategoryIcon(String name) {
    switch (name) {
      case 'Teknologi':
        return Icons.laptop_mac_outlined;

      case 'Pendidikan':
        return Icons.school_outlined;

      case 'Gaya Hidup':
        return Icons.wb_sunny_outlined;

      case 'Kesehatan':
        return Icons.favorite_border;

      case 'Makanan':
        return Icons.restaurant_outlined;

      case 'Perjalanan':
        return Icons.flight_outlined;

      case 'Bisnis':
        return Icons.business_center_outlined;

      case 'Desain':
        return Icons.palette_outlined;

      default:
        return Icons.article_outlined;
    }
  }

  Color getCategoryColor(String name) {
    switch (name) {
      case 'Teknologi':
        return const Color(0xFFEDE3FA);

      case 'Pendidikan':
        return const Color(0xFFFFE5EA);

      case 'Gaya Hidup':
        return const Color(0xFFF8E2F1);

      case 'Kesehatan':
        return const Color(0xFFE4F4E6);

      case 'Makanan':
        return const Color(0xFFF6F3D9);

      case 'Perjalanan':
        return const Color(0xFFE2EBFA);

      case 'Bisnis':
        return const Color(0xFFFFE8DF);

      case 'Desain':
        return const Color(0xFFECE3F6);

      default:
        return const Color(0xFFF2F2F2);
    }
  }

  Color getCategoryIconColor(String name) {
    switch (name) {
      case 'Teknologi':
        return const Color(0xFF9A6BC3);

      case 'Pendidikan':
        return const Color(0xFFE88698);

      case 'Gaya Hidup':
        return const Color(0xFFD781B5);

      case 'Kesehatan':
        return const Color(0xFF72B77B);

      case 'Makanan':
        return const Color(0xFFC5B852);

      case 'Perjalanan':
        return const Color(0xFF759ACD);

      case 'Bisnis':
        return const Color(0xFFD58A70);

      case 'Desain':
        return const Color(0xFF9C78BE);

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 30, 25, 10),
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

              const SizedBox(height: 15),

              Expanded(
                child: categories.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        itemCount: categories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 18,
                              mainAxisSpacing: 18,
                              childAspectRatio: 1.15,
                            ),
                        itemBuilder: (context, index) {
                          final category = categories[index];

                          final articleCount = getArticleCount(category['id']);

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryDetailPage(
                                    categoryId: category['id'],
                                    categoryName: category['name'],
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: getCategoryColor(category['name']),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      color: const Color(0x66FFFFFF),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      getCategoryIcon(category['name']),
                                      size: 34,
                                      color: getCategoryIconColor(
                                        category['name'],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  Text(
                                    category['name'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    '$articleCount Artikel',
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF7B7B7B),
                                    ),
                                  ),
                                ],
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
