enum SkincareCategory {
  serum,
  moisturizer,
  cleanser,
  sunscreen;

  String get displayName {
    switch (this) {
      case SkincareCategory.serum:
        return 'Serum';
      case SkincareCategory.moisturizer:
        return 'Moisturizer';
      case SkincareCategory.cleanser:
        return 'Cleanser';
      case SkincareCategory.sunscreen:
        return 'Sunscreen';
    }
  }

  static SkincareCategory fromString(String category) {
    switch (category.toLowerCase()) {
      case 'serum':
        return SkincareCategory.serum;
      case 'moisturizer':
        return SkincareCategory.moisturizer;
      case 'cleanser':
        return SkincareCategory.cleanser;
      case 'sunscreen':
        return SkincareCategory.sunscreen;
      default:
        return SkincareCategory.serum; // default fallback
    }
  }
}

class AppConstants {
  // Table names
  static const String tableSkincareShelf = 'skincare_shelf';
  static const String tableRoutines = 'routines';
  static const String tableJournalEntries = 'journal_entries';

  // Storage bucket names
  static const String bucketJournalPhotos = 'journal-photos';

  // Category colors
  static const Map<String, String> categoryColors = {
    'Serum': '0xFFE040FB',      // Purple
    'Sunscreen': '0xFF64DD17',  // Green
    'Moisturizer': '0xFFD50000', // Red
    'Cleanser': '0xFF29B6F6',    // Blue
  };

  // Weather Fallback Defaults
  static const String defaultMockLocation = 'Los Angeles, CA';
  static const double defaultMockTemperature = 33.0;
  static const int defaultInitialScore = 80;
}
