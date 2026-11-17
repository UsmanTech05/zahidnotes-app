import 'package:flutter/material.dart';
import '../models/wp_models.dart';
import '../services/storage_service.dart';
import '../widgets/post_tile.dart';
import 'post_detail_screen.dart';

/// Favourites — user ne jo posts save ki hain.
class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  late Future<List<WpPost>> _future;

  @override
  void initState() {
    super.initState();
    _future = StorageService.getFavourites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
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
                  'Abhi koi favourite nahi hai.\nKisi post par ❤️ dabayein.',
              icon: Icons.favorite_border,
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
                  // Wapas aane par list refresh karein (unfavourite ho
                  // sakta hai).
                  setState(() {
                    _future = StorageService.getFavourites();
                  });
                },
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () async {
                    await StorageService.toggleFavourite(posts[i]);
                    setState(() {
                      _future = StorageService.getFavourites();
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
