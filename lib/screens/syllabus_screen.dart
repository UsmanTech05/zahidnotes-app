import 'package:flutter/material.dart';
import '../models/wp_models.dart';
import '../services/api_service.dart';
import '../services/app_config.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_widget.dart';
import 'post_detail_screen.dart';

/// Smart Syllabus (ALP) 2027 — chaaron classes.
///
/// Syllabus post website se live aata hai (slug se). Us ke andar
/// ki View/Download table bhi website wali hi dikhti hai — PDF
/// links bahar browser/Drive mein khulte hain.
class SyllabusScreen extends StatefulWidget {
  const SyllabusScreen({super.key});

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
  final ApiService _api = ApiService();
  ClassInfo _selected = classes[2]; // 1st Year default

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Syllabus (ALP) 2027')),
      body: Column(
        children: [
          // Class selector (dropdown jaisa — chips)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            color: Colors.white,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in classes)
                  ChoiceChip(
                    label: Text(c.name),
                    selected: _selected == c,
                    selectedColor: AppColors.primaryRed,
                    labelStyle: TextStyle(
                      color: _selected == c
                          ? Colors.white
                          : AppColors.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) {
                      setState(() => _selected = c);
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<WpPost?>(
              future: _api.fetchSyllabusPost(_selected),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || snapshot.data == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        '${_selected.name} ka Smart Syllabus abhi nahi mila. Internet check karein.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  );
                }
                return PostDetailScreen(
                  post: snapshot.data!,
                  embedded: true,
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
