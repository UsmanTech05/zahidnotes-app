/// WordPress REST API ke models — zahidnotes.com se aane wala data.
///
/// NOTE: Koi bhi content (subjects, posts, quizzes) app mein hardcode NAHI
/// hai. Sab kuch live API se aata hai, is liye website par naya content
/// add karte hi app mein bhi aa jata hai.
library;

class WpCategory {
  final int id;
  final int count;
  final String name;
  final String slug;
  final int parent;
  final String link;

  const WpCategory({
    required this.id,
    required this.count,
    required this.name,
    required this.slug,
    required this.parent,
    required this.link,
  });

  factory WpCategory.fromJson(Map<String, dynamic> json) {
    return WpCategory(
      id: json['id'] as int? ?? 0,
      count: json['count'] as int? ?? 0,
      name: _stripHtml(json['name'] as String? ?? ''),
      slug: json['slug'] as String? ?? '',
      parent: json['parent'] as int? ?? 0,
      link: json['link'] as String? ?? '',
    );
  }
}

class WpPost {
  final int id;
  final String date;
  final String slug;
  final String link;
  final String title;
  final String excerpt;
  final String content;
  final List<int> categories;
  final String? imageUrl;

  const WpPost({
    required this.id,
    required this.date,
    required this.slug,
    required this.link,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.categories,
    this.imageUrl,
  });

  factory WpPost.fromJson(Map<String, dynamic> json) {
    String? image;
    try {
      final embedded = json['_embedded'] as Map<String, dynamic>?;
      final media = embedded?['wp:featuredmedia'] as List<dynamic>?;
      if (media != null && media.isNotEmpty) {
        image = media.first['source_url'] as String?;
      }
    } catch (_) {
      image = null;
    }
    return WpPost(
      id: json['id'] as int? ?? 0,
      date: json['date'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      link: json['link'] as String? ?? '',
      title: _stripHtml(
        (json['title'] as Map<String, dynamic>?)?['rendered'] as String? ?? '',
      ),
      excerpt: _stripHtml(
        (json['excerpt'] as Map<String, dynamic>?)?['rendered'] as String? ?? '',
      ),
      content:
          (json['content'] as Map<String, dynamic>?)?['rendered'] as String? ??
              '',
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      imageUrl: image,
    );
  }
}

String _stripHtml(String html) {
  return html
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#8217;', "'")
      .replaceAll('&#8211;', '-')
      .replaceAll('&#038;', '&')
      .replaceAll('&nbsp;', ' ')
      .trim();
}
