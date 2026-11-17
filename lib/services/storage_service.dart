import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wp_models.dart';

/// Favourites aur offline saved posts — phone mein save hote hain.
///
/// Favourite: sirf id/title/link save hota hai (content hamesha
/// website se fresh aata hai).
/// Offline save: post ka HTML bhi save hota hai taake bina internet
/// parha ja sake.
class StorageService {
  static const String _favKey = 'favourite_posts';
  static const String _offlineKey = 'offline_posts';

  static Map<String, dynamic> _postToMap(WpPost post) => {
        'id': post.id,
        'title': post.title,
        'link': post.link,
        'slug': post.slug,
        'content': post.content,
        'excerpt': post.excerpt,
      };

  static WpPost _postFromMap(Map<String, dynamic> m) => WpPost(
        id: m['id'] as int? ?? 0,
        date: '',
        slug: m['slug'] as String? ?? '',
        link: m['link'] as String? ?? '',
        title: m['title'] as String? ?? '',
        excerpt: m['excerpt'] as String? ?? '',
        content: m['content'] as String? ?? '',
        categories: const [],
      );

  static Future<List<Map<String, dynamic>>> _readList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> _writeList(
    String key,
    List<Map<String, dynamic>> items,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(items));
  }

  // ---------- Favourites ----------
  static Future<List<WpPost>> getFavourites() async {
    final items = await _readList(_favKey);
    return items.map(_postFromMap).toList();
  }

  static Future<bool> isFavourite(int postId) async {
    final items = await _readList(_favKey);
    return items.any((m) => m['id'] == postId);
  }

  static Future<bool> toggleFavourite(WpPost post) async {
    final items = await _readList(_favKey);
    final exists = items.any((m) => m['id'] == post.id);
    if (exists) {
      items.removeWhere((m) => m['id'] == post.id);
    } else {
      items.add(_postToMap(post));
    }
    await _writeList(_favKey, items);
    return !exists;
  }

  // ---------- Offline saved posts ----------
  static Future<List<WpPost>> getOfflinePosts() async {
    final items = await _readList(_offlineKey);
    return items.map(_postFromMap).toList();
  }

  static Future<bool> isSavedOffline(int postId) async {
    final items = await _readList(_offlineKey);
    return items.any((m) => m['id'] == postId);
  }

  static Future<bool> toggleOffline(WpPost post) async {
    final items = await _readList(_offlineKey);
    final exists = items.any((m) => m['id'] == post.id);
    if (exists) {
      items.removeWhere((m) => m['id'] == post.id);
    } else {
      items.add(_postToMap(post));
    }
    await _writeList(_offlineKey, items);
    return !exists;
  }
}
