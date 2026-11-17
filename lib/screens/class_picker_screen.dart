import 'package:flutter/material.dart';
import '../services/app_config.dart';
import '../services/ads_service.dart';
import '../widgets/common_widgets.dart';
import 'section_screen.dart';
import 'online_tests_screen.dart';

/// Section kholne se pehle class select karein (dropdown jaisa flow).
///
/// Home screen ya drawer se section tap karne par yahan aate hain.
class ClassPickerScreen extends StatelessWidget {
  final SectionType section;

  const ClassPickerScreen({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(section.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${section.title} — apni class select karein',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
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
                        AdsService.maybeShowInterstitial();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => section == SectionType.onlineTests
                                ? OnlineTestsScreen(classInfo: c)
                                : SectionScreen(
                                    classInfo: c,
                                    section: section,
                                  ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _classSubtitle(ClassInfo c) {
    switch (c.level) {
      case ClassLevel.ninth:
        return 'Matric Part 1';
      case ClassLevel.tenth:
        return 'Matric Part 2';
      case ClassLevel.firstYear:
        return '11th Class';
      case ClassLevel.secondYear:
        return '12th Class';
    }
  }
}
