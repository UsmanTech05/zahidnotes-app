import 'package:flutter/material.dart';
import '../models/wp_models.dart';
import '../services/api_service.dart';
import '../services/app_config.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/common_widgets.dart';
import '../widgets/post_list_view.dart';
import 'post_detail_screen.dart';
import 'quiz_webview_screen.dart';

/// Online Tests flow: Class → Subject → Chapter → Topic → Quiz.
///
/// * Subject list class ki Online Test category se aati hai.
/// * 1st Year Computer (9 chapters, 50 topics) aur 1st Year Biology
///   (12 chapters, 71 topics) ke chapter/topic posts website par
///   banaye gaye hain — un ke liye chapter list khulti hai.
/// * Baaki subjects ke liye subject wali test post dikhayi jati hai.
/// * Quiz (topic post) WebView mein khulta hai — Quiz Maker ka web
///   quiz hai, is liye native rebuild nahi kiya.
class OnlineTestsScreen extends StatelessWidget {
  final ClassInfo classInfo;

  const OnlineTestsScreen({super.key, required this.classInfo});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    return Scaffold(
      appBar: AppBar(title: Text('${classInfo.name} Online Tests')),
      body: Column(
        children: [
          Expanded(
            child: PostListView(
              load: () => api.fetchPosts(
                categoryId: classInfo.onlineTestCategoryId,
              ),
              onTap: (post) => _openSubject(context, post),
              emptyMessage: 'Online tests nahi mile.',
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  void _openSubject(BuildContext context, WpPost post) {
    final slug = post.slug.toLowerCase();
    final isFirstYear = classInfo.level == ClassLevel.firstYear;
    if (isFirstYear && slug.contains('computer')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChapterListScreen(
            classInfo: classInfo,
            subjectPost: post,
            parentCategoryId: firstYearComputerOnlineTestParent,
          ),
        ),
      );
    } else if (isFirstYear && slug.contains('biology')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChapterListScreen(
            classInfo: classInfo,
            subjectPost: post,
            parentCategoryId: firstYearBiologyOnlineTestParent,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
      );
    }
  }
}

/// Chapter list — kisi subject ke saare chapters.
class ChapterListScreen extends StatefulWidget {
  final ClassInfo classInfo;
  final WpPost subjectPost;
  final int parentCategoryId;

  const ChapterListScreen({
    super.key,
    required this.classInfo,
    required this.subjectPost,
    required this.parentCategoryId,
  });

  @override
  State<ChapterListScreen> createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends State<ChapterListScreen> {
  final ApiService _api = ApiService();
  late Future<List<WpCategory>> _chaptersFuture;
  late Future<List<WpPost>> _chapterPostsFuture;

  @override
  void initState() {
    super.initState();
    _chaptersFuture = _api.fetchChapters(widget.parentCategoryId);
    _chapterPostsFuture = _api.fetchChapterPosts(widget.parentCategoryId);
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  int _chapterNumber(String name) {
    final m = RegExp(r'chapter\s*(\d+)', caseSensitive: false).firstMatch(name);
    return m == null ? 0 : int.tryParse(m.group(1)!) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.subjectPost.title)),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<WpCategory>>(
              future: _chaptersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Chapters load nahi hui: ${snapshot.error}'),
                  );
                }
                final chapters = snapshot.data ?? [];
                if (chapters.isEmpty) {
                  return const Center(
                    child: Text('Chapters nahi mile.'),
                  );
                }
                chapters.sort(
                  (a, b) => _chapterNumber(a.name).compareTo(
                        _chapterNumber(b.name),
                      ),
                );
                return FutureBuilder<List<WpPost>>(
                  future: _chapterPostsFuture,
                  builder: (context, postSnap) {
                    final chapterPosts = postSnap.data ?? [];
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: chapters.length,
                      itemBuilder: (context, i) {
                        final ch = chapters[i];
                        final num = _chapterNumber(ch.name);
                        final chapterPost = chapterPosts
                            .where(
                              (p) => _chapterNumber(p.title) == num,
                            )
                            .firstOrNull;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GradientButton(
                            label:
                                '${ch.name}  •  ${ch.count} Topics',
                            icon: Icons.quiz_outlined,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TopicListScreen(
                                    chapter: ch,
                                    chapterPost: chapterPost,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }
}

/// Topic list — kisi chapter ke saare topics (har topic aik quiz).
class TopicListScreen extends StatelessWidget {
  final WpCategory chapter;
  final WpPost? chapterPost;

  const TopicListScreen({
    super.key,
    required this.chapter,
    this.chapterPost,
  });

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    return Scaffold(
      appBar: AppBar(title: Text(chapter.name)),
      body: Column(
        children: [
          if (chapterPost != null && chapterPost!.excerpt.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                chapterPost!.excerpt,
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ),
          Expanded(
            child: FutureBuilder<List<WpPost>>(
              future: api.fetchChapterTopics(chapter.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Topics load nahi hui: ${snapshot.error}'),
                  );
                }
                final topics = snapshot.data ?? [];
                if (topics.isEmpty) {
                  return const Center(child: Text('Topics nahi mile.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: topics.length,
                  itemBuilder: (context, i) {
                    final topic = topics[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GradientButton(
                        label: topic.title,
                        icon: Icons.play_circle_outline,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizWebViewScreen(
                                url: topic.link,
                                title: topic.title,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }
}
