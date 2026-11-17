import 'package:flutter/material.dart';
import '../models/wp_models.dart';
import '../services/storage_service.dart';
import '../widgets/post_tile.dart';
import 'post_detail_screen.dart';

/// Downloads — offline save ki hui posts (bina internet parhein).
///
/// PDF files phone ke system Downloads folder mein save hoti hain
/// (browser/PDF viewer se) — yahan sirf wo posts dikhti hain jo
/// user ne app mein "Offline Save" ki hain.
class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  late Future<List<WpPost>> _future;

  @override
  void initState() {
    super.initState();
    _future = StorageService.getOfflinePosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Downloads (Offline)')),
      body: FutureBuilder<List<WpPost>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const EmptyView(
              message:
                  'Abhi kuch offline save nahi hai.\nKisi post par "Offline Save karein" dabayein.',
              icon: Icons.download_outlined,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: posts.length,
            itemBuilder: (context, i) {
              return PostTile(
                post: posts[i],
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(post: posts[i]),
                    ),
                  );
                  setState(() {
                    _future = StorageService.getOfflinePosts();
                  });
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await StorageService.toggleOffline(posts[i]);
                    setState(() {
                      _future = StorageService.getOfflinePosts();
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
