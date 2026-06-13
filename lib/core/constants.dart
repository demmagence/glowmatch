enum SkincareCategory {
  serum,
  moisturizer,
  cleanser,
  sunscreen,
  toner,
  exfoliant,
  mask,
  eyeCream;

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
      case SkincareCategory.toner:
        return 'Toner';
      case SkincareCategory.exfoliant:
        return 'Exfoliant';
      case SkincareCategory.mask:
        return 'Mask';
      case SkincareCategory.eyeCream:
        return 'Eye Cream';
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
      case 'toner':
        return SkincareCategory.toner;
      case 'exfoliant':
        return SkincareCategory.exfoliant;
      case 'mask':
        return SkincareCategory.mask;
      case 'eye cream':
      case 'eyecream':
        return SkincareCategory.eyeCream;
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
  static const String tableUserStreaks = 'user_streaks';

  // Storage bucket names
  static const String bucketJournalPhotos = 'journal-photos';
  static const String bucketProductPhotos = 'product-photos';

  // Category colors
  static const Map<String, String> categoryColors = {
    'Serum': '0xFFE040FB',      // Purple
    'Sunscreen': '0xFF64DD17',  // Green
    'Moisturizer': '0xFFD50000', // Red
    'Cleanser': '0xFF29B6F6',    // Blue
    'Toner': '0xFFFFD600',       // Yellow/Amber
    'Exfoliant': '0xFFFF6D00',   // Orange
    'Mask': '0xFF00BFA5',        // Teal
    'Eye Cream': '0xFFFF4081',   // Pink
  };

  // Weather Fallback Defaults
  static const String defaultMockLocation = 'Los Angeles, CA';
  static const double defaultMockTemperature = 33.0;
  static const int defaultInitialScore = 80;
}

