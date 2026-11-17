# ZahidNotes — Mobile App (Flutter)

> **Roman Urdu mein:** Ye ZahidNotes (zahidnotes.com) ki official mobile app hai — Flutter se bani hui. App ka saara data website se **live** aata hai (WordPress REST API), is liye website par notes, test ya syllabus update karte hi app mein bhi update ho jata hai. Design website ki apni color scheme mein hai.

> **English:** Official mobile app for ZahidNotes (zahidnotes.com), built with Flutter. All content comes **live** from the website via the WordPress REST API, so any update on the website appears in the app automatically. The design uses the website's own colour scheme.

---

## App mein kya hai / Features

| Feature | Detail |
|---|---|
| **Classes** | 9th, 10th, 1st Year, 2nd Year — har class ke saare subjects (website se live: 9th 20, 10th 21, 1st Year 30, 2nd Year 29) |
| **Sections** | Notes, Test Papers, MCQs, Online Tests, Pairing Scheme, Guess Papers, Text Books, Smart Syllabus |
| **Subject screen** | Tabs: Notes, Test Papers, Online Tests, MCQs, Pairing Scheme, Guess Papers, Syllabus |
| **Notes reader** | Post ka HTML app ke andar; PDF / Drive links bahar khulte hain (View / Download) |
| **Online Tests** | Class → Subject → Chapter → Topic → Quiz (1st Year Computer: 9 chapters / 50 topics; 1st Year Biology: 12 chapters / 71 topics — website par banaye gaye chapter/topic posts se) |
| **Quiz** | Quiz Maker ka web quiz app ke andar WebView mein khulta hai (native rebuild nahi — quiz website ka hi chalta hai) |
| **Smart Syllabus** | ALP 2027 — chaaron classes, View/Download rows |
| **Search** | Website ki saari posts mein search |
| **Dropdown menu** | ☰ Hamburger menu: Classes, Sections, Favourites, Downloads, Settings |
| **Favourites** | ❤️ se post save karein |
| **Downloads (Offline)** | Post offline save karein — bina internet parhein |
| **Ads (AdMob)** | Banner (list screens ke neeche) + Interstitial (kabhi kabhi section badalne par) — quiz par kabhi ad nahi |

## Design / Rang

- Primary buttons: website ka red gradient **#d60000 → #7a0000**
- Class gradients (website ke CSS se):
  - 9th: `#FF416C → #FF4B2B`
  - 10th: `#11998E → #38EF7D`
  - 1st Year: `#2F80ED → #56CCF2`
  - 2nd Year: `#8E2DE2 → #4A00E0`

## Data kaise aata hai / How data works

- Base URL: `https://zahidnotes.com/wp-json/wp/v2/`
- Categories aur posts API se fetch hote hain — **koi subject list ya quiz app mein hardcode nahi hai.**
- Category IDs `lib/services/app_config.dart` mein hain (Notes, Online Test, Test Papers, MCQs, Pairing Scheme, Guess Papers).
- Chapter-wise tests sirf un subjects ke liye hain jin ke chapter/topic posts website par banaye gaye hain (1st Year Computer aur Biology). Baaki subjects ke liye subject wali test post dikhayi jati hai.

## Build status (is machine par) / Build status on this machine

> ⚠️ **APK / AAB is machine par build NAHI hua.** Is environment mein Android SDK / JDK ka setup proxy ki wajah se complete nahi ho saka, is liye `flutter build apk` nahi chal saka. **Code mukammal hai aur `flutter analyze` se clean hai (0 errors)** — kisi bhi computer par Flutter SDK + Android SDK install kar ke `flutter pub get` aur `flutter build appbundle --release` se release AAB ban jayegi. Neeche diye gaye steps follow karein.

## Chalane ka tareeqa / How to run

```bash
# 1. Flutter SDK install karein (https://flutter.dev/docs/get-started/install)
flutter --version

# 2. Dependencies install karein
cd zahidnotes-app
flutter pub get

# 3. Phone/emulator par chalaye
flutter run

# 4. Code check karein
flutter analyze
```

## Play Store ke liye release build (AAB)

```bash
# Debug APK (testing ke liye)
flutter build apk --debug

# Release AAB (Play Store par upload karne ke liye)
flutter build appbundle --release
```

Release build se pehle ye zaroori hain:

1. **App signing** — apni keystore banayein aur `android/key.properties` mein lagayein:
   ```properties
   storePassword=<apni keystore ka password>
   keyPassword=<key ka password>
   keyAlias=upload
   storeFile=<keystore ka path>
   ```
   Keystore banane ke liye: `keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
   ⚠️ Keystore aur passwords ko **kabhi** git mein ya kisi ko share na karein — ye aap ki app ki pehchan hai.
2. **Google Play Developer account** — $25 aik dafa (lifetime): https://play.google.com/console
3. **AdMob IDs** — neeche dekhein.
4. **Privacy Policy** — Play Store par app ke liye privacy policy ka URL lazmi hai. `lib/services/app_config.dart` mein `AppLinks.privacyPolicy` ko apni policy page ka URL dein (misal: website par aik Privacy Policy page banayein).
5. **Launcher icon** — `assets/icon/icon.png` se banayein:
   ```bash
   dart run flutter_launcher_icons
   ```

## AdMob setup (ads ke liye)

⚠️ **Abhi code mein Google ke OFFICIAL TEST IDs hain — asli earning ke liye in ko replace karna lazmi hai.**

1. https://admob.google.com par account banayein (Pakistan, currency USD).
2. App add karein: **ZahidNotes — Android — com.zahidnotes.app**
3. Ad units banayein: **Banner** aur **Interstitial** — har aik ki ID milegi.
4. Ye IDs in jagah replace karein:
   - `lib/services/ads_service.dart` — `appId`, `bannerAdUnitId`, `interstitialAdUnitId`
   - `android/app/src/main/AndroidManifest.xml` — `com.google.android.gms.ads.APPLICATION_ID` wali line
5. Test IDs se kabhi earning nahi hoti — sirf apne real IDs se.

## Jo abhi nahi hai / NOT included

- **iOS build** — iOS ke liye macOS + Xcode chahiye (Flutter code dono ke liye aik hi hai; is project mein iOS folder mojood hai).
- **AdMob real IDs** — user ko apne account se lagani hain (upar dekhein).
- **Play Store upload** — user ko khud karna hai (Developer account + signing + privacy policy chahiye).
- **Push notifications** — abhi nahi hain (Firebase setup ke baad add ho sakti hain).

## Project structure

```
lib/
  main.dart                  App start + AdMob init
  theme/app_theme.dart       Rang, gradients, theme
  models/wp_models.dart      WordPress category/post models
  services/
    app_config.dart          Classes, sections, category IDs, links
    api_service.dart         WordPress REST API client
    ads_service.dart         AdMob (placeholder IDs)
    storage_service.dart     Favourites + offline posts
  screens/
    home_screen.dart         Home — classes, sections, syllabus banner
    class_screen.dart        Class ke subjects (groups ke hisaab se)
    class_picker_screen.dart Section ke liye class select karein
    subject_screen.dart      Subject tabs (Notes, Tests, MCQs...)
    section_screen.dart      Kisi section ki list
    post_detail_screen.dart  Post reader (HTML + PDF links)
    online_tests_screen.dart Class → Subject → Chapter → Topic
    quiz_webview_screen.dart Quiz Maker quiz (WebView)
    syllabus_screen.dart     Smart Syllabus (ALP) 2027
    search_screen.dart       Search
    favourites_screen.dart   Favourites
    downloads_screen.dart    Downloads (offline save ki hui posts)
    settings_screen.dart     Settings / About
  widgets/
    common_widgets.dart      Gradient button, class card, section tile
    banner_ad_widget.dart    AdMob banner
    post_tile.dart           Post list row + loading/error views
    post_list_view.dart      List + retry logic
    app_drawer.dart          Hamburger menu (☰)
android/app/
  build.gradle.kts           applicationId: com.zahidnotes.app
  src/main/AndroidManifest.xml  AdMob App ID (placeholder)
```

## Version

- **Version:** 1.0.0+1
- **Application ID:** `com.zahidnotes.app`
- **App name:** ZahidNotes
