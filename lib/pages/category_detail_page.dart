import 'package:flutter/material.dart';
import 'package:narrate_blog/services/post_service.dart';
import 'package:narrate_blog/widgets/article_card.dart';

class CategoryDetailPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryDetailPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  List posts = [];

  Future<void> getPosts() async {
    final result = await PostService.getPosts();

    final filteredPosts = result.where((post) {
      return post['categoryId'] == widget.categoryId;
    }).toList();

    setState(() {
      posts = filteredPosts;
    });
  }

  @override
  void initState() {
    super.initState();
    getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 30, 25, 10),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F1F1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  Text(
                    widget.categoryName,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              Text(
                'Artikel seputar ${widget.categoryName.toLowerCase()}',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 28),

              Expanded(
                child: posts.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada artikel di kategori ini.',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];

                          return ArticleCard(
                            imageUrl: post['imageUrl'],
                            title: post['title'],
                            createdAt: post['createdAt'],
                            content: post['content'],
                            isSaved: false,
                            onBookmarkTap: () {
                              print('Bookmark artikel ${post['id']}');
                            },
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
