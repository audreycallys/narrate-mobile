import 'package:flutter/material.dart';

import 'package:narrate_blog/constants/app_colors.dart';
import 'package:narrate_blog/pages/edit_profile.dart';
import 'package:narrate_blog/services/post_service.dart';
import 'package:narrate_blog/services/profile_service.dart';
import 'package:narrate_blog/pages/edit_post.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map profile = {};

  List publishedPosts = [];
  List draftPosts = [];
  List archivedPosts = [];

  int selectedTab = 0;

  bool isLoading = true;

  Future<void> getProfileData() async {
    try {
      final profileResult = await ProfileService.getProfile();

      final published = await PostService.getPostsByStatus('published');

      final draft = await PostService.getPostsByStatus('draft');

      final archived = await PostService.getPostsByStatus('archived');

      if (!mounted) return;

      setState(() {
        profile = profileResult;

        publishedPosts = published;
        draftPosts = draft;
        archivedPosts = archived;

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data profil gagal diambil')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getProfileData();
  }

  List get currentPosts {
    if (selectedTab == 0) {
      return publishedPosts;
    }

    if (selectedTab == 1) {
      return draftPosts;
    }

    return archivedPosts;
  }

  String _formatDate(String? createdAt) {
    if (createdAt == null) return '';

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

  int _calculateReadingTime(String content) {
    if (content.trim().isEmpty) {
      return 1;
    }

    final wordCount = content.trim().split(RegExp(r'\s+')).length;

    final minutes = (wordCount / 200).ceil();

    return minutes < 1 ? 1 : minutes;
  }

  Future<void> changePostStatus(Map post, String newStatus) async {
    final postTags = post['tags'] ?? [];

    final List<int> tagIds = postTags
        .map<int>((tag) => tag['id'] as int)
        .toList();

    final success = await PostService.updatePost(
      postId: post['id'],
      title: post['title'],
      content: post['content'],
      categoryId: post['categoryId'],
      status: newStatus,
      tagIds: tagIds,
    );

    if (!mounted) return;

    if (success) {
      await getProfileData();

      String message = '';

      if (newStatus == 'archived') {
        message = 'Postingan berhasil diarsipkan';
      } else {
        message = 'Postingan berhasil dipublikasikan';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status postingan gagal diubah')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 30, 25, 10),
                child: Column(
                  children: [
                    const Text(
                      'Profil Saya',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 30),

                    _buildAvatar(),

                    const SizedBox(height: 30),

                    Text(
                      profile['name'] ?? 'Nama Pengguna',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      profile['email'] ?? '',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        profile['bio'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          height: 1.4,
                          color: Color.fromARGB(255, 82, 82, 82),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProfilePage(profile: profile),
                            ),
                          );

                          await getProfileData();
                        },
                        icon: const Icon(Icons.edit_outlined, size: 17),
                        label: const Text(
                          'Edit Profil',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDDF3F5),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      children: [
                        _buildTab('Postingan Saya', 0),
                        _buildTab('Draf', 1),
                        _buildTab('Arsip', 2),
                      ],
                    ),

                    const SizedBox(height: 8),

                    if (currentPosts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text(
                          'Belum ada artikel.',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        itemCount: currentPosts.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final post = currentPosts[index];

                          return _buildPostCard(post);
                        },
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAvatar() {
    final imageUrl = profile['imageUrl'];

    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
      return CircleAvatar(
        radius: 68,
        backgroundColor: const Color(0xFFDDF3F5),
        backgroundImage: NetworkImage(imageUrl.toString()),
      );
    }

    return const CircleAvatar(
      radius: 68,
      backgroundColor: Color(0xFFDDF3F5),
      child: Icon(Icons.person, size: 68, color: AppColors.primary),
    );
  }

  Widget _buildTab(String title, int index) {
    final isActive = selectedTab == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primary : Colors.black54,
              ),
            ),

            const SizedBox(height: 7),

            Container(
              width: double.infinity,
              height: 2,
              color: isActive ? AppColors.primary : const Color(0xFFE5E5E5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Map post) {
    final String status = post['status'] ?? '';

    final bool isPublished = status == 'published';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post['imageUrl'] ?? '',
                  width: 110,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 110,
                      height: 90,
                      color: const Color(0xFFF1F1F1),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: SizedBox(
                  height: 90,
                  child: Align(
                    alignment: isPublished
                        ? Alignment.topLeft
                        : Alignment.centerLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (status == 'draft') ...[
                          const Text(
                            'Draf',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(255, 82, 82, 82),
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            post['title'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ] else if (status == 'archived') ...[
                          const Text(
                            'Diarsipkan',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(255, 82, 82, 82),
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            post['title'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ] else ...[
                          Text(
                            post['title'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            '${_formatDate(post['createdAt'])} • '
                            '${_calculateReadingTime(post['content'] ?? '')} Menit Baca',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(255, 82, 82, 82),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            post['content'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              SizedBox(
                height: 90,
                child: Align(
                  alignment: isPublished
                      ? Alignment.topCenter
                      : Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(top: isPublished ? 18 : 0),
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.more_vert,
                        size: 22,
                        color: Color(0xFF1E919E),
                      ),
                      onSelected: (value) async {
                        if (value == 'Edit') {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditPostPage(post: post),
                            ),
                          );

                          if (updated == true) {
                            await getProfileData();
                          }

                          return;
                        }

                        if (value == 'Arsipkan') {
                          await changePostStatus(post, 'archived');
                          return;
                        }

                        if (value == 'Publikasikan') {
                          await changePostStatus(post, 'published');
                          return;
                        }

                        if (value == 'Pulihkan') {
                          await changePostStatus(post, 'published');
                          return;
                        }
                      },
                      itemBuilder: (context) {
                        if (status == 'published') {
                          return const [
                            PopupMenuItem(value: 'Edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'Arsipkan',
                              child: Text('Arsipkan'),
                            ),
                            PopupMenuItem(value: 'Hapus', child: Text('Hapus')),
                          ];
                        }

                        if (status == 'draft') {
                          return const [
                            PopupMenuItem(value: 'Edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'Publikasikan',
                              child: Text('Publikasikan'),
                            ),
                            PopupMenuItem(value: 'Hapus', child: Text('Hapus')),
                          ];
                        }

                        return const [
                          PopupMenuItem(
                            value: 'Pulihkan',
                            child: Text('Pulihkan'),
                          ),
                          PopupMenuItem(value: 'Hapus', child: Text('Hapus')),
                        ];
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1, thickness: 1, color: Color(0xFFE5E5E5)),
      ],
    );
  }
}
