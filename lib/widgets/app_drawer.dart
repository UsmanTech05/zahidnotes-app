import 'package:flutter/material.dart';
import '../services/app_config.dart';
import '../theme/app_theme.dart';
import '../screens/class_screen.dart';
import '../screens/class_picker_screen.dart';
import '../screens/favourites_screen.dart';
import '../screens/downloads_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/syllabus_screen.dart';

/// Hamburger menu (☰) — drawer.
///
/// * Classes (dropdown): 9th, 10th, 1st Year, 2nd Year
/// * Sections (dropdown): Notes, Test Papers, MCQs, Online Tests,
///   Pairing Scheme, Guess Papers, Text Books, Smart Syllabus
///   (section kholne par pehle class select hoti hai)
/// * Favourites, Downloads, Settings
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Row(
                  children: [
                    Icon(Icons.school, color: Colors.white, size: 40),
                    SizedBox(width: 10),
                    Text(
                      'ZahidNotes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '9th • 10th • 1st Year • 2nd Year',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Notes, Tests, MCQs, Syllabus — sab kuch',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ExpansionTile(
            leading: const Icon(Icons.class_outlined),
            title: const Text('Classes'),
            children: [
              for (final c in classes)
                ListTile(
                  leading: Icon(Icons.bookmark, color: _classColor(c)),
                  title: Text('${c.name} Notes'),
                  onTap: () {
                    Navigator.pop(context);
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
          ExpansionTile(
            leading: const Icon(Icons.grid_view_outlined),
            title: const Text('Sections'),
            children: [
              for (final s in SectionType.values)
                ListTile(
                  leading: Icon(s.icon, color: AppColors.primaryRed),
                  title: Text(s.title),
                  onTap: () {
                    Navigator.pop(context);
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
                          builder: (_) => ClassPickerScreen(section: s),
                        ),
                      );
                    }
                  },
                ),
            ],
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.favorite_outline),
            title: const Text('Favourites'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavouritesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Downloads (Offline)'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DownloadsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'ZahidNotes v1.0.0\nData: zahidnotes.com (live)',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _classColor(ClassInfo c) {
    switch (c.level) {
      case ClassLevel.ninth:
        return const Color(0xFFFF416C);
      case ClassLevel.tenth:
        return const Color(0xFF11998E);
      case ClassLevel.firstYear:
        return const Color(0xFF2F80ED);
      case ClassLevel.secondYear:
        return const Color(0xFF8E2DE2);
    }
  }
}
