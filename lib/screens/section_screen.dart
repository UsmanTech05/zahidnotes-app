import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/app_config.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/post_list_view.dart';
import 'post_detail_screen.dart';

/// Kisi class ke kisi section ki list — Notes, Test Papers, MCQs,
/// Pairing Scheme, Guess Papers, Text Books.
///
/// Data class ki category se live aata hai.
class SectionScreen extends StatelessWidget {
  final ClassInfo classInfo;
  final SectionType section;

  const SectionScreen({
    super.key,
    required this.classInfo,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    return Scaffold(
      appBar: AppBar(
        title: Text('${classInfo.name} ${section.title}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PostListView(
              load: () => api.fetchPosts(
                categoryId: section.categoryIdFor(classInfo),
              ),
              onTap: (post) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(post: post),
                  ),
                );
              },
              emptyMessage:
                  '${classInfo.name} ke ${section.title} abhi nahi hain.',
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }
}
