import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/wp_models.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

/// Post reader — notes, test papers, MCQs, syllabus sab isi mein
/// khulte hain. HTML content app ke andar render hota hai.
///
/// * PDF / Google Drive links — bahar browser mein khulte hain.
/// * Website ke andar ke post links — app ke andar hi khulte hain.
/// * Favourite aur offline save yahan se hota hai.
///
/// `embedded: true` ho to sirf content dikhta hai (Subject screen
/// ke Syllabus tab ke liye — wahan apna Scaffold nahi chahiye).
class PostDetailScreen extends StatefulWidget {
  final WpPost post;
  final bool embedded;

  const PostDetailScreen({
    super.key,
    required this.post,
    this.embedded = false,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final ApiService _api = ApiService();
  bool _isFavourite = false;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final fav = await StorageService.isFavourite(widget.post.id);
    final off = await StorageService.isSavedOffline(widget.post.id);
    if (mounted) {
      setState(() {
        _isFavourite = fav;
        _isOffline = off;
      });
    }
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  /// Content mein se PDF / Drive links nikaalo — View/Download
  /// card ke liye.
  List<String> _pdfLinks() {
    final matches = RegExp(
      r'href="([^"]+)"',
    ).allMatches(widget.post.content).map((m) => m.group(1)!).where((url) {
      final u = url.toLowerCase();
      return u.contains('drive.google.com') || u.endsWith('.pdf');
    }).toList();
    return matches.toSet().toList();
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _handleLink(String? url) {
    if (url == null || url.isEmpty) return;
    if (url.contains('drive.google.com') ||
        url.toLowerCase().endsWith('.pdf')) {
      _openExternal(url);
      return;
    }
    if (url.startsWith('https://zahidnotes.com')) {
      final segments = Uri.parse(url).pathSegments;
      if (segments.isNotEmpty) {
        final slug = segments.last;
        _api.fetchPostBySlug(slug).then((post) {
          if (post != null && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostDetailScreen(post: post),
              ),
            );
          } else {
            _openExternal(url);
          }
        });
        return;
      }
    }
    _openExternal(url);
  }

  Future<void> _toggleFavourite() async {
    final nowFav = await StorageService.toggleFavourite(widget.post);
    if (mounted) {
      setState(() => _isFavourite = nowFav);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nowFav ? 'Favourites mein save ho gaya.' : 'Favourites se hata diya.',
          ),
        ),
      );
    }
  }

  Future<void> _toggleOffline() async {
    final nowSaved = await StorageService.toggleOffline(widget.post);
    if (mounted) {
      setState(() => _isOffline = nowSaved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nowSaved
                ? 'Offline save ho gaya — Downloads mein milega.'
                : 'Offline save hata diya.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _content(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavourite ? Icons.favorite : Icons.favorite_border,
            ),
            tooltip: 'Favourite',
            onPressed: _toggleFavourite,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Browser mein kholein',
            onPressed: () => _openExternal(widget.post.link),
          ),
        ],
      ),
      body: _content(context),
    );
  }

  Widget _content(BuildContext context) {
    final pdfLinks = _pdfLinks();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.post.title,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 13,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                widget.post.date.isNotEmpty
                    ? widget.post.date.substring(0, 10)
                    : '',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.language,
                size: 13,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              const Text(
                'zahidnotes.com',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (pdfLinks.isNotEmpty) _pdfCard(pdfLinks),
          Html(
            data: widget.post.content,
            onLinkTap: (url, _, _) => _handleLink(url),
            style: {
              'body': Style(fontSize: FontSize(16), lineHeight: LineHeight(1.55)),
              'p': Style(margin: Margins.only(bottom: 12)),
              'h1': Style(fontSize: FontSize(22)),
              'h2': Style(fontSize: FontSize(20)),
              'h3': Style(fontSize: FontSize(18)),
              'a': Style(
                color: AppColors.primaryRed,
                textDecoration: TextDecoration.underline,
              ),
              'img': Style(
                margin: Margins.symmetric(vertical: 8),
              ),
              'table': Style(
                border: Border.all(color: AppColors.divider),
              ),
              'th': Style(
                backgroundColor: AppColors.primaryRed,
                color: Colors.white,
                padding: HtmlPaddings.all(8),
              ),
              'td': Style(padding: HtmlPaddings.all(8)),
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleOffline,
                  icon: Icon(
                    _isOffline
                        ? Icons.download_done
                        : Icons.download_outlined,
                  ),
                  label: Text(
                    _isOffline ? 'Offline Saved' : 'Offline Save karein',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openExternal(widget.post.link),
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Website par dekhein'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _pdfCard(List<String> links) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.picture_as_pdf_outlined,
                color: AppColors.primaryRed,
              ),
              SizedBox(width: 8),
              Text(
                'PDF Links',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final link in links.take(5))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openExternal(link),
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('View'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openExternal(link),
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
