import 'package:flutter/material.dart';
import '../models/wp_models.dart';
import '../services/api_service.dart';
import '../services/app_config.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/post_list_view.dart';
import 'post_detail_screen.dart';
import 'online_tests_screen.dart';

/// Subject screen — tabs:
/// Notes | Test Papers | Online Tests | MCQs | Pairing Scheme |
/// Guess Papers | Syllabus
///
/// Notes tab subject ki apni category se aata hai. Baaki tabs
/// class ki list ko subject ke naam se filter karte hain (website
/// par Test Papers / MCQs class-level lists hain). Agar filter se
/// kuch na mile to poori class ki list dikha dete hain.
class SubjectScreen extends StatefulWidget {
  final ClassInfo classInfo;
  final WpCategory subject;

  const SubjectScreen({
    super.key,
    required this.classInfo,
    required this.subject,
  });

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  final ApiService _api = ApiService();

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  bool get _hasChapterTests =>
      widget.classInfo.level == ClassLevel.firstYear &&
      (widget.subject.slug.contains('computer') ||
          widget.subject.slug.contains('biology'));

  Future<List<WpPost>> _filteredPosts(SectionType section) async {
    final all = await _api.fetchPosts(
      categoryId: section.categoryIdFor(widget.classInfo),
    );
    final filtered = all
        .where((p) => titleMatchesSubject(p.title, widget.subject.name))
        .toList();
    // Filter khaali ho to poori list dikhao — kuch chhupana nahi.
    return filtered.isEmpty ? all : filtered;
  }

  void _openPost(WpPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: widget.classInfo.gradient),
          ),
          title: Text(widget.subject.name),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Notes'),
              Tab(text: 'Test Papers'),
              Tab(text: 'Online Tests'),
              Tab(text: 'MCQs'),
              Tab(text: 'Pairing Scheme'),
              Tab(text: 'Guess Papers'),
              Tab(text: 'Syllabus'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  // Notes — subject ki apni category
                  PostListView(
                    load: () => _api.fetchPosts(
                      categoryId: widget.subject.id,
                    ),
                    onTap: _openPost,
                    emptyMessage: 'Is subject ke notes abhi nahi hain.',
                  ),
                  // Test Papers
                  PostListView(
                    load: () => _filteredPosts(SectionType.testPapers),
                    onTap: _openPost,
                    emptyMessage: 'Test papers nahi mile.',
                  ),
                  // Online Tests
                  _onlineTestsTab(),
                  // MCQs
                  PostListView(
                    load: () => _filteredPosts(SectionType.mcqs),
                    onTap: _openPost,
                    emptyMessage: 'MCQs nahi mile.',
                  ),
                  // Pairing Scheme
                  PostListView(
                    load: () => _filteredPosts(SectionType.pairingScheme),
                    onTap: _openPost,
                    emptyMessage: 'Pairing scheme nahi mili.',
                  ),
                  // Guess Papers
                  PostListView(
                    load: () => _filteredPosts(SectionType.guessPapers),
                    onTap: _openPost,
                    emptyMessage: 'Guess papers nahi mile.',
                  ),
                  // Syllabus
                  _syllabusTab(),
                ],
              ),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Widget _onlineTestsTab() {
    return Column(
      children: [
        if (_hasChapterTests)
          FutureBuilder<List<WpPost>>(
            future: _filteredPosts(SectionType.onlineTests),
            builder: (context, snapshot) {
              final posts = snapshot.data;
              if (posts == null || posts.isEmpty) {
                return const SizedBox.shrink();
              }
              // Pehli post hi subject ki test post hai
              // (maslan "1st Year Computer Online Tests").
              final subjectPost = posts.first;
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChapterListScreen(
                          classInfo: widget.classInfo,
                          subjectPost: subjectPost,
                          parentCategoryId: widget.subject.slug
                                  .contains('computer')
                              ? firstYearComputerOnlineTestParent
                              : firstYearBiologyOnlineTestParent,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.quiz_outlined, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Chapter-wise Tests dekhein',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        Expanded(
          child: PostListView(
            load: () => _filteredPosts(SectionType.onlineTests),
            onTap: _openPost,
            emptyMessage: 'Online tests nahi mile.',
          ),
        ),
      ],
    );
  }

  Widget _syllabusTab() {
    return FutureBuilder<WpPost?>(
      future: _api.fetchSyllabusPost(widget.classInfo),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final post = snapshot.data;
        if (post == null) {
          return const Center(
            child: Text('Syllabus nahi mila.'),
          );
        }
        return PostDetailScreen(post: post, embedded: true);
      },
    );
  }
}
