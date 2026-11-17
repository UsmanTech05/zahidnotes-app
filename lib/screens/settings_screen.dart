import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_config.dart';
import '../services/storage_service.dart';

/// Settings — About, links aur data saaf karne ke options.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About ZahidNotes'),
            subtitle: const Text(
              '9th, 10th, 1st Year aur 2nd Year ke notes, tests, MCQs aur syllabus.',
            ),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'ZahidNotes',
                applicationVersion: '1.0.0',
                applicationLegalese:
                    'Data: zahidnotes.com (WordPress REST API se live).',
                children: const [
                  SizedBox(height: 12),
                  Text(
                    'Is app ka saara data website se live aata hai. Website par update karte hi app mein bhi update ho jata hai.',
                  ),
                ],
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Website dekhein'),
            subtitle: const Text('zahidnotes.com'),
            onTap: () => _openUrl(AppLinks.website),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () => _openUrl(AppLinks.privacyPolicy),
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Play Store par rate karein'),
            onTap: () => _openUrl(AppLinks.playStoreUrl),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Favourites saaf karein'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Favourites saaf karein?'),
                  content: const Text(
                    'Saari favourite posts delete ho jayengi.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Saaf karein'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                final favs = await StorageService.getFavourites();
                for (final p in favs) {
                  await StorageService.toggleFavourite(p);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Favourites saaf kar diye.'),
                    ),
                  );
                }
              }
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'ZahidNotes v1.0.0 • com.zahidnotes.app',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
