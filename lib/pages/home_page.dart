import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:narrate_blog/constants/app_colors.dart';
import 'package:narrate_blog/pages/detail_article_page.dart';
import 'package:narrate_blog/services/category_service.dart';
import 'package:narrate_blog/services/post_service.dart';
import 'package:narrate_blog/widgets/article_card.dart';
import 'package:narrate_blog/services/saved_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentCarousel = 0;

  List posts = [];
  List categories = [];

  Future<void> getPosts() async {
    final result = await PostService.getPosts();

    setState(() {
      posts = result;
    });
  }

  Future<void> getCategories() async {
    final result = await CategoryService.getCategories();

    setState(() {
      categories = result;
    });
  }

  Set<int> savedPostIds = {};

  Future<void> getSavedPosts() async {
    final savedPosts = await SavedService.getSavedPosts();

    if (!mounted) return;

    setState(() {
      savedPostIds = savedPosts.map<int>((saved) {
        final post = saved['post'] ?? saved;

        return post['id'] ?? saved['postId'];
      }).toSet();
    });
  }

  Future<void> toggleSaved(Map post) async {
    final int postId = post['id'];
    final bool alreadySaved = savedPostIds.contains(postId);

    bool success;

    if (alreadySaved) {
      success = await SavedService.deleteSavedPost(postId);
    } else {
      success = await SavedService.savePost(postId);
    }

    if (!mounted) return;

    if (success) {
      setState(() {
        if (alreadySaved) {
          savedPostIds.remove(postId);
        } else {
          savedPostIds.add(postId);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            alreadySaved
                ? 'Artikel dihapus dari tersimpan'
                : 'Artikel berhasil disimpan',
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    getPosts();
    getCategories();
    getSavedPosts();
  }

  String getCategoryName(int categoryId) {
    final category = categories.firstWhere(
      (category) => category['id'] == categoryId,
      orElse: () => {'name': 'Artikel'},
    );

    return category['name'];
  }

  String formatDate(String createdAt) {
    final date = DateTime.parse(createdAt).toLocal();

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  int calculateReadingTime(String content) {
    final wordCount = content.trim().split(RegExp(r'\s+')).length;
    final minutes = (wordCount / 200).ceil();

    return minutes < 1 ? 1 : minutes;
  }

  @override
  Widget build(BuildContext context) {
    final popularPosts = [...posts];

    popularPosts.sort(
      (a, b) => (b['viewCount'] ?? 0).compareTo(a['viewCount'] ?? 0),
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 30, 25, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, Sakezza Labiru!',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Ada cerita apa hari ini?',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari artikel, kategori, atau topik...',
                    hintStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      color: Color.fromARGB(255, 82, 82, 82),
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFECECEC),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (posts.isEmpty)
                  const SizedBox(
                    height: 185,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 185,
                      viewportFraction: 1,
                      autoPlay: true,
                      enlargeCenterPage: false,
                      onPageChanged: (index, reason) {
                        setState(() {
                          currentCarousel = index;
                        });
                      },
                    ),
                    items: posts.take(3).map((post) {
                      return InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailArticlePage(
                                post: post,
                                categoryName: getCategoryName(
                                  post['categoryId'],
                                ),
                              ),
                            ),
                          );

                          await getSavedPosts();
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  post['imageUrl'],
                                  fit: BoxFit.cover,
                                ),

                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black87,
                                      ],
                                    ),
                                  ),
                                ),

                                Positioned(
                                  left: 18,
                                  right: 18,
                                  bottom: 14,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post['title'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'PlusJakartaSans',
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      Text(
                                        '${formatDate(post['createdAt'])} • '
                                        '${calculateReadingTime(post['content'])} Menit Baca',
                                        style: const TextStyle(
                                          fontFamily: 'PlusJakartaSans',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 15),

                if (posts.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(posts.take(3).length, (index) {
                      return Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentCarousel == index
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                      );
                    }),
                  ),

                const SizedBox(height: 25),

                const Text(
                  'Artikel Terpopuler',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 15),

                if (posts.isNotEmpty)
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: popularPosts.length > 5
                          ? 5
                          : popularPosts.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(width: 12);
                      },
                      itemBuilder: (context, index) {
                        final post = popularPosts[index];

                        return InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailArticlePage(
                                  post: post,
                                  categoryName: getCategoryName(
                                    post['categoryId'],
                                  ),
                                ),
                              ),
                            );

                            await getSavedPosts();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 140,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    post['imageUrl'],
                                    fit: BoxFit.cover,
                                  ),

                                  Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black87,
                                        ],
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    left: 8,
                                    right: 8,
                                    bottom: 8,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post['title'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          '${formatDate(post['createdAt'])} • '
                                          '${calculateReadingTime(post['content'])} Menit Baca',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 8,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 25),

                const Text(
                  'Semua Artikel',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 5),

                if (posts.isNotEmpty)
                  Column(
                    children: List.generate(posts.length, (index) {
                      final post = posts[index];

                      return ArticleCard(
                        imageUrl: post['imageUrl'],
                        title: post['title'],
                        createdAt: post['createdAt'],
                        content: post['content'],
                        isSaved: savedPostIds.contains(post['id']),

                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailArticlePage(
                                post: post,
                                categoryName: getCategoryName(
                                  post['categoryId'],
                                ),
                              ),
                            ),
                          );

                          getSavedPosts();
                        },
                        onBookmarkTap: () {
                          toggleSaved(post);
                        },
                      );
                    }),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
