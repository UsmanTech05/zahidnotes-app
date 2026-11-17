import 'package:flutter/material.dart';
import '../models/wp_models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/post_tile.dart';
import 'post_detail_screen.dart';

/// Search — website ki saari posts mein dhoondein.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _controller = TextEditingController();
  Future<List<WpPost>>? _results;
  bool _searched = false;

  @override
  void dispose() {
    _api.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _searched = true;
      _results = _api.searchPosts(q);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      hintText: 'Misal: Physics notes, Biology test...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.divider,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _search,
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: !_searched
                ? const Center(
                    child: Text(
                      'Kuch likh kar search karein.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : FutureBuilder<List<WpPost>>(
                    future: _results,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const LoadingView();
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Search nahi hui. Internet check karein.',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                            ),
                          ),
                        );
                      }
                      final posts = snapshot.data ?? [];
                      if (posts.isEmpty) {
                        return const EmptyView(
                          message: 'Kuch nahi mila. Doosra lafz try karein.',
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: posts.length,
                        itemBuilder: (context, i) {
                          return PostTile(
                            post: posts[i],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PostDetailScreen(post: posts[i]),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
