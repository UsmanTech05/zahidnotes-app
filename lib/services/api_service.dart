import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wp_models.dart';
import 'app_config.dart';

/// WordPress REST API client — zahidnotes.com.
///
/// Saara data live aata hai. Koi post, subject ya quiz app mein
/// hardcode nahi hai.
class ApiService {
  static const String baseUrl = 'https://zahidnotes.com/wp-json/wp/v2';
  static const Duration timeout = Duration(seconds: 25);

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<WpCategory>> fetchCategories({
    int? parent,
    bool hideEmpty = false,
  }) async {
    final params = <String, String>{
      'per_page': '100',
      'hide_empty': hideEmpty.toString(),
      'orderby': 'id',
      'order': 'asc',
    };
    if (parent != null) params['parent'] = parent.toString();
    final uri = Uri.parse(
      '$baseUrl/categories',
    ).replace(queryParameters: params);
    final res = await _client.get(uri).timeout(timeout);
    if (res.statusCode != 200) {
      throw Exception('Categories load nahi hui (HTTP ${res.statusCode})');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => WpCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Kisi class ke Notes ke groups (Compulsory / Science / Arts)
  /// aur un ke andar ke subjects (leaf categories) — do levels.
  ///
  /// Returns: {groupName: [subjects]} — sirf woh groups jin mein
  /// subjects hain. Subjects wohi dikhte hain jin ki posts hain
  /// (hideEmpty: true), is liye list hamesha website jaisi rehti hai.
  Future<Map<String, List<WpCategory>>> fetchSubjectsByGroup(
    ClassInfo classInfo,
  ) async {
    final groups = await fetchCategories(parent: classInfo.notesCategoryId);
    final result = <String, List<WpCategory>>{};
    for (final group in groups) {
      final subjects = await fetchCategories(
        parent: group.id,
        hideEmpty: true,
      );
      if (subjects.isNotEmpty) {
        result[group.name] = subjects;
      }
    }
    return result;
  }

  Future<List<WpPost>> fetchPosts({
    required int categoryId,
    int page = 1,
    int perPage = 100,
    String order = 'desc',
  }) async {
    final uri = Uri.parse('$baseUrl/posts').replace(
      queryParameters: {
        'categories': categoryId.toString(),
        'per_page': perPage.toString(),
        'page': page.toString(),
        'orderby': 'date',
        'order': order,
        '_embed': '1',
      },
    );
    final res = await _client.get(uri).timeout(timeout);
    if (res.statusCode != 200) {
      throw Exception('Posts load nahi hui (HTTP ${res.statusCode})');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => WpPost.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<WpPost?> fetchPostBySlug(String slug) async {
    final uri = Uri.parse('$baseUrl/posts').replace(
      queryParameters: {'slug': slug, '_embed': '1'},
    );
    final res = await _client.get(uri).timeout(timeout);
    if (res.statusCode != 200) return null;
    final list = jsonDecode(res.body) as List<dynamic>;
    if (list.isEmpty) return null;
    return WpPost.fromJson(list.first as Map<String, dynamic>);
  }

  Future<List<WpPost>> searchPosts(String query) async {
    final uri = Uri.parse('$baseUrl/posts').replace(
      queryParameters: {
        'search': query,
        'per_page': '30',
        'orderby': 'relevance',
        '_embed': '1',
      },
    );
    final res = await _client.get(uri).timeout(timeout);
    if (res.statusCode != 200) {
      throw Exception('Search nahi hui (HTTP ${res.statusCode})');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => WpPost.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Smart Syllabus post — slug se.
  Future<WpPost?> fetchSyllabusPost(ClassInfo classInfo) {
    return fetchPostBySlug(classInfo.syllabusSlug);
  }

  /// Chapter-wise online tests (sirf 1st Year Computer aur Biology):
  /// parent category ke neeche chapter subcategories hoti hain.
  Future<List<WpCategory>> fetchChapters(int parentCategoryId) {
    return fetchCategories(parent: parentCategoryId, hideEmpty: true);
  }

  /// Kisi chapter ke topic posts (us ki subcategory se).
  Future<List<WpPost>> fetchChapterTopics(int chapterCategoryId) {
    return fetchPosts(categoryId: chapterCategoryId, order: 'asc');
  }

  /// Chapter posts (parent category mein) — chapter ki intro ke liye.
  Future<List<WpPost>> fetchChapterPosts(int parentCategoryId) {
    return fetchPosts(categoryId: parentCategoryId, order: 'asc');
  }

  void dispose() => _client.close();
}

/// Title mein subject ka naam dhoondna — Test Papers / MCQs waghera
/// class-level lists hain, is liye subject ke hisaab se filter karte hain.
///
/// Misal: "10th Class Physics Test Papers" mein "Physics" hai.
/// Kuch naam mukhtalif likhe hote hain (Math/Mathematics, Islamiat/
 /// Islamiyat) — un ke liye aliases hain. Agar kuch na mile to poori
/// class ki list dikha dete hain (kuch chhupate nahi).
bool titleMatchesSubject(String title, String subjectName) {
  final t = _normalize(title);
  final s = _normalize(subjectName);
  if (s.isEmpty) return true;
  if (t.contains(s)) return true;
  const aliases = <String, List<String>>{
    'math': ['mathematics'],
    'mathematics': ['math'],
    'computer': ['computer science'],
    'computer science': ['computer'],
    'islamiat': ['islamiyat'],
    'islamiyat': ['islamiat'],
    'pak study': ['pakistan studies', 'pakistan study'],
    'pakistan studies': ['pak study'],
    'tarjma tul quran': ['tarjuma tul quran', 'tarjuma-tul-quran'],
    'tarjuma tul quran': ['tarjma tul quran'],
    'urdu compulsory': ['urdu'],
    'islamiat compulsory': ['islamiat', 'islamiyat'],
    'islamiat elective': ['islamiat ikhtiyari', 'islamiyat ikhtiyari'],
    'business math': ['business maths'],
    'business maths': ['business math'],
  };
  final extra = aliases[s];
  if (extra != null) {
    for (final a in extra) {
      if (t.contains(a)) return true;
    }
  }
  return false;
}

String _normalize(String s) {
  return s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), ' ').replaceAll(
        RegExp(r'\s+'),
        ' ',
      ).trim();
}
