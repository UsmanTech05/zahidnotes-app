import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// App ki configuration — sirf IDs aur slugs (content nahi).
///
/// Ye category IDs zahidnotes.com par verify ki gayi hain (Nov 2026).
/// Agar website par category badle to sirf yahan ID update karein —
/// saara content phir bhi live API se aayega.

enum ClassLevel { ninth, tenth, firstYear, secondYear }

class ClassInfo {
  final ClassLevel level;
  final String name; // "9th Class"
  final String shortName; // "9th"
  final LinearGradient gradient;

  // Section-wise category IDs (WordPress categories)
  final int notesCategoryId;
  final int onlineTestCategoryId;
  final int testPapersCategoryId;
  final int mcqsCategoryId;
  final int pairingSchemeCategoryId;
  final int guessPapersCategoryId;
  final int textBooksCategoryId;

  /// Smart Syllabus post ka slug (API se search karke laate hain).
  final String syllabusSlug;

  const ClassInfo({
    required this.level,
    required this.name,
    required this.shortName,
    required this.gradient,
    required this.notesCategoryId,
    required this.onlineTestCategoryId,
    required this.testPapersCategoryId,
    required this.mcqsCategoryId,
    required this.pairingSchemeCategoryId,
    required this.guessPapersCategoryId,
    required this.textBooksCategoryId,
    required this.syllabusSlug,
  });
}

const List<ClassInfo> classes = [
  ClassInfo(
    level: ClassLevel.ninth,
    name: '9th Class',
    shortName: '9th',
    gradient: AppColors.ninthGradient,
    notesCategoryId: 1158,
    onlineTestCategoryId: 1180,
    testPapersCategoryId: 1160,
    mcqsCategoryId: 1175,
    pairingSchemeCategoryId: 1170,
    guessPapersCategoryId: 1165,
    textBooksCategoryId: 4201,
    syllabusSlug: '9th-class-smart-syllabus-2027',
  ),
  ClassInfo(
    level: ClassLevel.tenth,
    name: '10th Class',
    shortName: '10th',
    gradient: AppColors.tenthGradient,
    notesCategoryId: 1157,
    onlineTestCategoryId: 1181,
    testPapersCategoryId: 1161,
    mcqsCategoryId: 1176,
    pairingSchemeCategoryId: 1171,
    guessPapersCategoryId: 1166,
    textBooksCategoryId: 4202,
    syllabusSlug: '10th-class-smart-syllabus-2027-new-alp',
  ),
  ClassInfo(
    level: ClassLevel.firstYear,
    name: '1st Year',
    shortName: '1st Year',
    gradient: AppColors.firstYearGradient,
    notesCategoryId: 1156,
    onlineTestCategoryId: 1182,
    testPapersCategoryId: 1162,
    mcqsCategoryId: 1177,
    pairingSchemeCategoryId: 1172,
    guessPapersCategoryId: 1167,
    textBooksCategoryId: 4203,
    syllabusSlug: '1st-year-smart-syllabus-2027',
  ),
  ClassInfo(
    level: ClassLevel.secondYear,
    name: '2nd Year',
    shortName: '2nd Year',
    gradient: AppColors.secondYearGradient,
    notesCategoryId: 1155,
    onlineTestCategoryId: 1183,
    testPapersCategoryId: 1163,
    mcqsCategoryId: 1178,
    pairingSchemeCategoryId: 1173,
    guessPapersCategoryId: 1168,
    textBooksCategoryId: 4204,
    syllabusSlug: '2nd-year-smart-syllabus-2027',
  ),
];

/// Sections — har section ek class ki category se data laata hai.
enum SectionType {
  notes,
  onlineTests,
  testPapers,
  mcqs,
  pairingScheme,
  guessPapers,
  textBooks,
  syllabus,
}

extension SectionTypeInfo on SectionType {
  String get title {
    switch (this) {
      case SectionType.notes:
        return 'Notes';
      case SectionType.onlineTests:
        return 'Online Tests';
      case SectionType.testPapers:
        return 'Test Papers';
      case SectionType.mcqs:
        return 'MCQs';
      case SectionType.pairingScheme:
        return 'Pairing Scheme';
      case SectionType.guessPapers:
        return 'Guess Papers';
      case SectionType.textBooks:
        return 'Text Books';
      case SectionType.syllabus:
        return 'Smart Syllabus';
    }
  }

  IconData get icon {
    switch (this) {
      case SectionType.notes:
        return Icons.menu_book;
      case SectionType.onlineTests:
        return Icons.quiz_outlined;
      case SectionType.testPapers:
        return Icons.description_outlined;
      case SectionType.mcqs:
        return Icons.list_alt_outlined;
      case SectionType.pairingScheme:
        return Icons.table_chart_outlined;
      case SectionType.guessPapers:
        return Icons.lightbulb_outline;
      case SectionType.textBooks:
        return Icons.library_books_outlined;
      case SectionType.syllabus:
        return Icons.school_outlined;
    }
  }

  int categoryIdFor(ClassInfo c) {
    switch (this) {
      case SectionType.notes:
        return c.notesCategoryId;
      case SectionType.onlineTests:
        return c.onlineTestCategoryId;
      case SectionType.testPapers:
        return c.testPapersCategoryId;
      case SectionType.mcqs:
        return c.mcqsCategoryId;
      case SectionType.pairingScheme:
        return c.pairingSchemeCategoryId;
      case SectionType.guessPapers:
        return c.guessPapersCategoryId;
      case SectionType.textBooks:
        return c.textBooksCategoryId;
      case SectionType.syllabus:
        return 0; // Syllabus slug se laate hain, category se nahi.
    }
  }
}

/// 1st Year ke chapter-wise online tests — in ke chapter/topic posts
/// website par banaye gaye hain (Computer: 9 chapters / 50 topics,
/// Biology: 12 chapters / 71 topics).
///
/// Ye parent category IDs sirf in do subjects ke liye hain. Baaki
/// subjects ke liye subject wali test post dikhayi jati hai.
const int firstYearComputerOnlineTestParent = 4552;
const int firstYearBiologyOnlineTestParent = 4562;

/// App ke links — Privacy Policy ka URL user ko apni website ke mutabiq
/// update karna hai (README dekhein).
class AppLinks {
  static const String website = 'https://zahidnotes.com';
  static const String privacyPolicy = 'https://zahidnotes.com/privacy-policy/';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.zahidnotes.app';
}
