import 'package:flutter/material.dart';
import '../models/wp_models.dart';
import 'post_tile.dart';

/// Kisi bhi post list ke liye — loading / error / khaali states
/// aik jaisi rehti hain. Retry par data dobara load hota hai.
class PostListView extends StatefulWidget {
  final Future<List<WpPost>> Function() load;
  final void Function(WpPost post) onTap;
  final String emptyMessage;

  const PostListView({
    super.key,
    required this.load,
    required this.onTap,
    this.emptyMessage = 'Is mein abhi kuch nahi hai.',
  });

  @override
  State<PostListView> createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView> {
  late Future<List<WpPost>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.load();
  }

  void _retry() {
    setState(() {
      _future = widget.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WpPost>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }
        if (snapshot.hasError) {
          return ErrorView(
            message: 'Load nahi hua. Internet check karein.',
            onRetry: _retry,
          );
        }
        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return EmptyView(message: widget.emptyMessage);
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: posts.length,
          itemBuilder: (context, i) {
            return PostTile(post: posts[i], onTap: () => widget.onTap(posts[i]));
          },
        );
      },
    );
  }
}
