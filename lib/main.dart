import 'package:flutter/material.dart';
import 'services/ads_service.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // AdMob initialize — agar fail ho to bhi app chalni chahiye.
  await AdsService.init();
  runApp(const ZahidNotesApp());
}

class ZahidNotesApp extends StatelessWidget {
  const ZahidNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZahidNotes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomeScreen(),
    );
  }
}
