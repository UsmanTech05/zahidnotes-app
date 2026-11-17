import 'package:flutter/material.dart';
import '../services/app_config.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/common_widgets.dart';
import 'class_screen.dart';
import 'class_picker_screen.dart';
import 'search_screen.dart';
import 'syllabus_screen.dart';

/// Home screen — classes, sections aur Smart Syllabus.
///
/// Design: website ki color scheme (red gradient buttons, har class
/// ka apna gradient), header mein hamburger menu (☰).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.school, size: 26),
            SizedBox(width: 8),
            Text('ZahidNotes'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SearchScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: AppColors.textMuted),
                          SizedBox(width: 10),
                          Text(
                            'Search notes, tests, MCQs...',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Your Class',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Class cards — 2x2 grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.55,
                    children: [
                      for (final c in classes)
                        ClassCard(
                          title: c.name,
                          subtitle: _classSubtitle(c),
                          gradient: c.gradient,
                          icon: Icons.school_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ClassScreen(classInfo: c),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'All Sections',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pehle section chunein, phir class — har section mein website ka live data milega.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.7,
                    children: [
                      for (final s in SectionType.values)
                        SectionTile(
                          title: s.title,
                          subtitle: _sectionSubtitle(s),
                          icon: s.icon,
                          color: AppColors.primaryRed,
                          onTap: () {
                            if (s == SectionType.syllabus) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SyllabusScreen(),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ClassPickerScreen(section: s),
                                ),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Smart Syllabus banner
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SyllabusScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.picture_as_pdf_outlined,
                            color: Colors.white,
                            size: 36,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Smart Syllabus (ALP) 2027',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Saare classes ka syllabus — View / Download PDF',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'App ka data zahidnotes.com se live aata hai — website par naya notes ya test add hote hi app mein bhi aa jata hai.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  String _classSubtitle(ClassInfo c) {
    switch (c.level) {
      case ClassLevel.ninth:
        return 'Matric Part 1 • 20 Subjects';
      case ClassLevel.tenth:
        return 'Matric Part 2 • 21 Subjects';
      case ClassLevel.firstYear:
        return '11th Class • 30 Subjects';
      case ClassLevel.secondYear:
        return '12th Class • 29 Subjects';
    }
  }

  String _sectionSubtitle(SectionType s) {
    switch (s) {
      case SectionType.notes:
        return 'PDF notes — all subjects';
      case SectionType.onlineTests:
        return 'Chapter & topic tests';
      case SectionType.testPapers:
        return 'Chapter-wise papers';
      case SectionType.mcqs:
        return 'Subject-wise MCQs';
      case SectionType.pairingScheme:
        return 'Paper pattern 2026-27';
      case SectionType.guessPapers:
        return 'Important questions';
      case SectionType.textBooks:
        return 'Punjab Board books';
      case SectionType.syllabus:
        return 'ALP Smart Syllabus';
    }
  }
}
