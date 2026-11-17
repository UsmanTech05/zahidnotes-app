import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Quiz Maker quiz — WebView mein khulta hai.
///
/// Quiz website ka web quiz hai (shortcode se banta hai), is liye
/// is ko native rebuild nahi kiya — poora quiz website se hi
/// load hota hai, result bhi wahin milta hai.
///
/// NOTE: Ads yahan kabhi nahi dikhaye jate — quiz ke buttons
/// hamesha saaf rehte hain.
class QuizWebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const QuizWebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<QuizWebViewScreen> createState() => _QuizWebViewScreenState();
}

class _QuizWebViewScreenState extends State<QuizWebViewScreen> {
  late final WebViewController _controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Dobara load karein',
            onPressed: () => _controller.reload(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _progress < 100
              ? LinearProgressIndicator(
                  value: _progress / 100,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
