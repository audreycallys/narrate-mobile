import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:narrate_blog/constants/app_colors.dart';
import 'package:narrate_blog/services/category_service.dart';
import 'package:narrate_blog/services/post_service.dart';
import 'package:narrate_blog/services/tag_service.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final tagController = TextEditingController();

  List categories = [];
  List tags = [];

  int? selectedCategoryId;

  List<int> selectedTagIds = [];

  String selectedStatus = 'published';

  File? selectedImage;

  bool isLoading = false;

  // =========================
  // GET CATEGORY
  // =========================
  Future<void> getCategories() async {
    try {
      final result = await CategoryService.getCategories();

      if (!mounted) return;

      setState(() {
        categories = result;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kategori gagal diambil')));
    }
  }

  // =========================
  // GET TAG BERDASARKAN CATEGORY
  // =========================
  Future<void> getTags(int categoryId) async {
    try {
      final result = await TagService.getTags(categoryId);

      if (!mounted) return;

      setState(() {
        tags = result;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tag gagal diambil')));
    }
  }

  // =========================
  // PILIH GAMBAR
  // =========================
  Future<void> pickImage() async {
    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage == null) {
      return;
    }

    final imageSize = await pickedImage.length();

    // maksimal 5MB
    if (imageSize > 5 * 1024 * 1024) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ukuran gambar maksimal 5MB')),
      );

      return;
    }

    setState(() {
      selectedImage = File(pickedImage.path);
    });
  }

  // =========================
  // DIALOG TAMBAH / PILIH TAG
  // =========================
  Future<void> showAddTagDialog() async {
    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );

      return;
    }

    tagController.clear();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool savingTag = false;

        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Tambah Tag',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tags.isNotEmpty) ...[
                      const Text(
                        'Pilih tag yang sudah tersedia',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: tags.map<Widget>((tag) {
                          final int tagId = tag['id'];

                          final bool isSelected = selectedTagIds.contains(
                            tagId,
                          );

                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedTagIds.remove(tagId);
                                } else {
                                  selectedTagIds.add(tagId);
                                }
                              });

                              dialogSetState(() {});
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFDDF3F5)
                                    : const Color(0xFFF1F1F1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tag['name'],
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.black,
                                    ),
                                  ),

                                  if (isSelected) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      const Divider(),

                      const SizedBox(height: 10),
                    ],

                    const Text(
                      'Atau buat tag baru',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: tagController,
                      autofocus: false,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Contoh: Mobile Development',
                        hintStyle: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: savingTag
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text(
                    'Selesai',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                ElevatedButton(
                  onPressed: savingTag
                      ? null
                      : () async {
                          final name = tagController.text.trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ketik nama tag terlebih dahulu'),
                              ),
                            );

                            return;
                          }

                          // CEK TAG SUDAH ADA
                          Map? existingTag;

                          for (final tag in tags) {
                            if (tag['name'].toString().toLowerCase() ==
                                name.toLowerCase()) {
                              existingTag = tag;
                              break;
                            }
                          }

                          // Kalau tag sudah ada,
                          // cukup pilih tag tersebut
                          if (existingTag != null) {
                            final int existingId = existingTag['id'];

                            if (!selectedTagIds.contains(existingId)) {
                              setState(() {
                                selectedTagIds.add(existingId);
                              });
                            }

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }

                            return;
                          }

                          dialogSetState(() {
                            savingTag = true;
                          });

                          try {
                            // CREATE TAG BARU KE BACKEND
                            await TagService.createTag(
                              categoryId: selectedCategoryId!,
                              name: name,
                            );

                            // AMBIL ULANG TAG DARI BACKEND
                            await getTags(selectedCategoryId!);

                            // CARI TAG BARU
                            Map? newTag;

                            for (final tag in tags) {
                              if (tag['name'].toString().toLowerCase() ==
                                  name.toLowerCase()) {
                                newTag = tag;
                                break;
                              }
                            }

                            // OTOMATIS PILIH TAG BARU
                            if (newTag != null) {
                              final int newTagId = newTag['id'];

                              if (!selectedTagIds.contains(newTagId)) {
                                setState(() {
                                  selectedTagIds.add(newTagId);
                                });
                              }
                            }

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          } catch (e) {
                            dialogSetState(() {
                              savingTag = false;
                            });

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tag gagal dibuat')),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: savingTag
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================
  // CREATE POST
  // =========================
  Future<void> submitPost() async {
    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty ||
        selectedCategoryId == null ||
        selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi postingan terlebih dahulu')),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final success = await PostService.createPost(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        categoryId: selectedCategoryId!,
        status: selectedStatus,

        // TAG YANG DIPILIH DIKIRIM KE BACKEND
        tagIds: selectedTagIds,

        imagePath: selectedImage!.path,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              selectedStatus == 'published'
                  ? 'Postingan berhasil dipublikasikan'
                  : 'Postingan berhasil disimpan sebagai draf',
            ),
          ),
        );

        titleController.clear();
        contentController.clear();
        tagController.clear();

        setState(() {
          selectedImage = null;
          selectedCategoryId = null;
          selectedStatus = 'published';

          tags = [];
          selectedTagIds = [];
        });

        // KEMBALI KE HOME
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Postingan gagal dibuat')));
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat membuat postingan'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    getCategories();
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    tagController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 30, 25, 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================
                // HEADER
                // =========================
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
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F1F1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 17,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    const Text(
                      'Buat Postingan',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // =========================
                // UPLOAD IMAGE
                // =========================
                InkWell(
                  onTap: pickImage,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    height: 165,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBDBDBD)),
                    ),
                    child: selectedImage == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 38,
                                color: Color(0xFF777777),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Unggah gambar sampul',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'JPG, PNG atau WEBP (maksimal 5MB)',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              selectedImage!,
                              width: double.infinity,
                              height: 165,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 18),

                // =========================
                // JUDUL
                // =========================
                const Text(
                  'Judul',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                TextField(
                  controller: titleController,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ketik judul...',
                    hintStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // =========================
                // CATEGORY
                // =========================
                const Text(
                  'Kategori',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  hint: const Text(
                    'Pilih satu kategori',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  items: categories.map<DropdownMenuItem<int>>((category) {
                    return DropdownMenuItem<int>(
                      value: category['id'],
                      child: Text(
                        category['name'],
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;

                      // KALAU CATEGORY BERUBAH
                      // TAG LAMA DIHAPUS
                      tags = [];
                      selectedTagIds = [];
                    });

                    if (value != null) {
                      getTags(value);
                    }
                  },
                ),

                const SizedBox(height: 14),

                // =========================
                // TAGS
                // =========================
                const Text(
                  'Tags',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 7),

                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    // TAG YANG SUDAH DIPILIH
                    ...tags
                        .where((tag) => selectedTagIds.contains(tag['id']))
                        .map<Widget>((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDDF3F5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tag['name'],
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),

                                const SizedBox(width: 4),

                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedTagIds.remove(tag['id']);
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 13,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                    // TOMBOL TAMBAH TAG
                    InkWell(
                      onTap: showAddTagDialog,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F1F1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tambah tag',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(Icons.add, size: 13),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // =========================
                // CONTENT
                // =========================
                const Text(
                  'Konten',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                TextField(
                  controller: contentController,
                  maxLines: 5,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tulis isi artikel...',
                    hintStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    contentPadding: const EdgeInsets.all(14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =========================
                // STATUS
                // =========================
                const Text(
                  'Status',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Radio<String>(
                      value: 'published',
                      groupValue: selectedStatus,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),

                    const Text(
                      'Publik',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(width: 25),

                    Radio<String>(
                      value: 'draft',
                      groupValue: selectedStatus,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),

                    const Text(
                      'Draf',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // =========================
                // SUBMIT BUTTON
                // =========================
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : submitPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send_outlined, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                selectedStatus == 'published'
                                    ? 'Publik Postingan'
                                    : 'Simpan Draf',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
