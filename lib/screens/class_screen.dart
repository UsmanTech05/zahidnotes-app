import 'package:flutter/material.dart';
import '../models/wp_models.dart';
import '../services/api_service.dart';
import '../services/app_config.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/post_tile.dart';
import 'subject_screen.dart';

/// Class screen — subjects groups ke hisaab se:
/// Compulsory Subjects / Science / Arts (& Commerce).
///
/// Subjects live API se aate hain (Notes categories ke neeche),
/// is liye website par subject add/remove hote hi list update
/// ho jati hai.
class ClassScreen extends StatefulWidget {
  final ClassInfo classInfo;

  const ClassScreen({super.key, required this.classInfo});

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  final ApiService _api = ApiService();
  late Future<Map<String, List<WpCategory>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchSubjectsByGroup(widget.classInfo);
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: widget.classInfo.gradient),
        ),
        title: Text('${widget.classInfo.name} Notes'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Map<String, List<WpCategory>>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingView();
                }
                if (snapshot.hasError) {
                  return ErrorView(
                    message: 'Subjects load nahi hui. Internet check karein.',
                    onRetry: () {
                      setState(() {
                        _future =
                            _api.fetchSubjectsByGroup(widget.classInfo);
                      });
                    },
                  );
                }
                final groups = snapshot.data ?? {};
                if (groups.isEmpty) {
                  return const EmptyView(
                    message: 'Is class ke subjects nahi mile.',
                  );
                }
                final total =
                    groups.values.fold<int>(0, (sum, l) => sum + l.length);
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      '$total Subjects — apna subject chunein',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final entry in groups.entries) ...[
                      _groupHeader(entry.key),
                      const SizedBox(height: 8),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.6,
                        children: [
                          for (final subject in entry.value)
                            _subjectTile(context, subject),
                        ],
                      ),
                      const SizedBox(height: 18),
                    ],
                  ],
                );
              },
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _groupHeader(String name) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _subjectTile(BuildContext context, WpCategory subject) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubjectScreen(
              classInfo: widget.classInfo,
              subject: subject,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            const Icon(
              Icons.menu_book,
              color: AppColors.primaryRed,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                subject.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
