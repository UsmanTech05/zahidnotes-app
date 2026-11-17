import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Google AdMob — ads ki setup.
///
/// ⚠️ IDs abhi Google ke OFFICIAL TEST IDs hain (placeholder).
/// Asli app mein ye IDs user ko apne AdMob account se replace karni
/// hain — README.md mein poora tareeqa likha hai.
///
/// * Banner: list screens ke neeche.
/// * Interstitial: section badalne par kabhi kabhi (har dafa nahi).
/// * Ads kabhi bhi quiz ke buttons ya content ko cover NAHI karte.
class AdsService {
  // ---- PLACEHOLDER (TEST) IDs — apne AdMob account ke IDs se badlein ----
  static const String appId =
      'ca-app-pub-3940256099942544~3347511713'; // TEST App ID
  static const String bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111'; // TEST Banner
  static const String interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712'; // TEST Interstitial

  static bool _initialized = false;
  static InterstitialAd? _interstitialAd;
  static int _navigationCount = 0;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      _loadInterstitial();
    } catch (_) {
      // Ads na chalein to app phir bhi chalni chahiye.
      _initialized = false;
    }
  }

  static void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  /// Section badalne par kabhi kabhi interstitial dikhao (har 3rd dafa).
  /// Quiz ya parhai ke beech mein kabhi nahi.
  static void maybeShowInterstitial() {
    _navigationCount++;
    if (_navigationCount % 3 != 0) return;
    final ad = _interstitialAd;
    if (ad == null) {
      _loadInterstitial();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
      },
    );
    ad.show();
  }
}
