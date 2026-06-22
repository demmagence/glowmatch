class AppConstants {
  static const String tableSkincareShelf = 'skincare_shelf';
  static const String tableRoutines = 'routines';
  static const String tableJournalEntries = 'journal_entries';
  static const String tableUserStreaks = 'user_streaks';
  static const String tableDailyCompletionLog = 'daily_completion_log';

  static const String bucketJournalPhotos = 'journal-photos';
  static const String bucketProductPhotos = 'product-photos';

  static const Map<String, String> categoryColors = {
    'Serum': '0xFFE040FB',
    'Sunscreen': '0xFF64DD17',
    'Moisturizer': '0xFFD50000',
    'Cleanser': '0xFF29B6F6',
    'Toner': '0xFFFFD600',
    'Exfoliant': '0xFFFF6D00',
    'Mask': '0xFF00BFA5',
    'Eye Cream': '0xFFFF4081',
  };

  static const String defaultMockLocation = 'Los Angeles, CA';
  static const double defaultMockTemperature = 33.0;
  static const int defaultInitialScore = 80;
}
