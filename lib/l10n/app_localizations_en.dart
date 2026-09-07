// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GlowMatch';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get all => 'All';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get navHome => 'Home';

  @override
  String get navBudget => 'Budget';

  @override
  String get navScan => 'Scan';

  @override
  String get navJournal => 'Journal';

  @override
  String get navShelf => 'Shelf';

  @override
  String get onboardingTitle1 => 'Track Your Glow';

  @override
  String get onboardingDesc1 =>
      'Log your AM & PM skincare routines and maintain a visual skin progress journal.';

  @override
  String get onboardingTitle2 => 'Scan Ingredients';

  @override
  String get onboardingDesc2 =>
      'Use AI to scan product ingredients via OCR and check their safety and compatibility.';

  @override
  String get onboardingTitle3 => 'Smart Budget';

  @override
  String get onboardingDesc3 =>
      'Keep track of your skincare spending and analyze cost-per-apply efficiency.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get signInTitle => 'Sign In';

  @override
  String get signInSubtitle => 'Welcome back! Sign in to sync your routines.';

  @override
  String get signUpTitle => 'Sign Up';

  @override
  String get signUpSubtitle =>
      'Create an account to backup your shelf & progress.';

  @override
  String get emailLabel => 'Email Address';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => '••••••••';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get signInButton => 'Sign In';

  @override
  String get signUpButton => 'Sign Up';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign Up';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign In';

  @override
  String get orDivider => 'OR';

  @override
  String get emailValidationError => 'Please enter a valid email address';

  @override
  String get passwordLengthError => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get morningRoutine => 'Morning Routine';

  @override
  String get eveningRoutine => 'Evening Routine';

  @override
  String get steps => 'Steps';

  @override
  String stepsCompleted(int completed, int total) {
    return '$completed/$total Completed';
  }

  @override
  String get noRoutineSteps =>
      'No routine steps yet. Tap below to add your first step!';

  @override
  String get deleteStepTitle => 'Delete Step?';

  @override
  String deleteStepMessage(String stepName, String routineName) {
    return 'Remove \"$stepName\" from your $routineName routine?';
  }

  @override
  String get deleteStepWarning =>
      'Are you sure you want to delete this step? Remaining steps will be renumbered.';

  @override
  String get completePreviousStepsOrder =>
      'Please complete previous steps in order.';

  @override
  String usedOneApply(String productName) {
    return 'Used 1 apply of $productName!';
  }

  @override
  String stepNumber(int number) {
    return 'Step $number';
  }

  @override
  String get customStep => 'Custom Step';

  @override
  String get clickToAdd => 'Click to add';

  @override
  String get completedForToday => 'Completed for Today';

  @override
  String get completeRoutine => 'Complete Routine';

  @override
  String get routineCompletedToast =>
      'Routine Completed! Consistency score updated.';

  @override
  String get milestone7DaysToast => '🎉 7 Day Milestone! Awesome dedication!';

  @override
  String get milestone14DaysToast =>
      '🎉 14 Day Milestone! You are unstoppable!';

  @override
  String get milestone30DaysToast =>
      '🎉 30 Day Milestone! You are a skincare master!';

  @override
  String dayStreakBadge(int count) {
    return '$count Day Streak';
  }

  @override
  String get startRoutineMotivation =>
      'Start your routine today to begin your glowing skin streak! 🔥';

  @override
  String get milestone30Motivation =>
      '👑 30+ Day Milestone! Skincare Master status unlocked!';

  @override
  String get milestone14Motivation =>
      '🌟 14 Day Milestone! Your skin barrier is thanking you!';

  @override
  String get milestone7Motivation =>
      '🏆 7 Day Milestone! You are building a solid skincare habit!';

  @override
  String get keepItUpMotivation =>
      '✨ Keep it up! Consistency is the key to glowing skin.';

  @override
  String get addRoutineStep => 'Add Routine Step';

  @override
  String get editRoutineStep => 'Edit Routine Step';

  @override
  String get stepNameLabel => 'Step Name (e.g., Toner)';

  @override
  String get stepNameSimpleLabel => 'Step Name';

  @override
  String get instructionsLabel => 'Instructions (e.g., Apply with pad)';

  @override
  String get instructionsSimpleLabel => 'Instructions';

  @override
  String get linkShelfProductOptional => 'Link Shelf Product (Optional)';

  @override
  String get linkShelfProduct => 'Link Shelf Product';

  @override
  String get selectProductHint => 'Select product';

  @override
  String get noneOption => 'None';

  @override
  String get streakHistoryAndStats => 'Streak History & Stats';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get longestStreak => 'Longest Streak';

  @override
  String get totalCompleted => 'Total Completed';

  @override
  String streakDaysCount(int count) {
    return '$count Days';
  }

  @override
  String get streakHistory => 'Streak History';

  @override
  String get noStreakHistoryYet =>
      'No streak history yet. Complete your first routine!';

  @override
  String get completed => 'Completed';

  @override
  String get missed => 'Missed';

  @override
  String get skincareMasterMilestone => '👑 Skincare Master Milestone!';

  @override
  String get unstoppableBarrierMilestone => '🌟 Unstoppable barrier milestone!';

  @override
  String get solidHabitMilestone => '🏆 Solid habit milestone!';

  @override
  String get visualCalendar => 'Visual Calendar';

  @override
  String get totalSpendInPeriod => 'TOTAL SPEND IN PERIOD';

  @override
  String get period30Days => '30 Days';

  @override
  String get period90Days => '90 Days';

  @override
  String get periodAllTime => 'All Time';

  @override
  String get calculatingBudget => 'Calculating budget...';

  @override
  String get allocation => 'ALLOCATION';

  @override
  String get noActiveProductsAllocation =>
      'No active products on your shelf to calculate allocations.';

  @override
  String get categoriesCount => 'Categories';

  @override
  String get costPerApplyCalculator => 'COST-PER-APPLY CALCULATOR';

  @override
  String get selectProductFromShelf => 'Select Product from Shelf';

  @override
  String get customValuesNoProduct => 'Custom values (no product)';

  @override
  String get productPrice => 'Product Price';

  @override
  String get estimatedUses => 'Estimated Uses';

  @override
  String get efficiencyMetric => 'EFFICIENCY METRIC';

  @override
  String get perApplication => '/ application';

  @override
  String get spendingHistory => 'SPENDING HISTORY (LAST 6 MONTHS)';

  @override
  String get setMonthlyBudgetLimit => 'Set Monthly Budget Limit';

  @override
  String budgetLimit(String currency) {
    return 'Budget Limit ($currency)';
  }

  @override
  String get myShelf => 'My Shelf';

  @override
  String get shelfSubtitle => 'Your skincare inventory & usage tracker.';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get filter => 'FILTER';

  @override
  String get filterByCategory => 'Filter by Category';

  @override
  String get categories => 'Categories';

  @override
  String get tapToAddSkincare => 'tap to add new skincare';

  @override
  String get addSkincareProduct => 'Add Skincare Product';

  @override
  String get editSkincareProduct => 'Edit Skincare Product';

  @override
  String get productImage => 'Product Image';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get productName => 'Product Name';

  @override
  String get productNameHint => 'e.g. Moisture Surge Intense';

  @override
  String get brand => 'Brand';

  @override
  String get brandHint => 'e.g. Clinique';

  @override
  String get category => 'Category';

  @override
  String get selectCategoryHint => 'Select a category';

  @override
  String priceWithCurrency(String currency) {
    return 'Price ($currency)';
  }

  @override
  String get priceHint => 'e.g. 150000';

  @override
  String get productSize => 'Product Size';

  @override
  String get productSizeHint => 'e.g. 30ml, 50g';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get ingredientsHint => 'e.g. Niacinamide, Hyaluronic Acid, Ceramide';

  @override
  String get addProduct => 'Add Product';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get deleteProductTitle => 'Delete Product?';

  @override
  String deleteProductConfirm(String name) {
    return 'Are you sure you want to delete $name from your shelf?';
  }

  @override
  String deletedProductSnackbar(String name) {
    return 'Deleted $name';
  }

  @override
  String get productDetailPrice => 'PRICE';

  @override
  String get productDetailUsesRemaining => 'USES REMAINING';

  @override
  String get productDetailCostPerUse => 'COST PER USE';

  @override
  String get productDetailSize => 'PRODUCT SIZE';

  @override
  String get productDetailDateAdded => 'DATE ADDED';

  @override
  String get productDetailIngredients => 'INGREDIENTS';

  @override
  String get noIngredientsListed => 'No ingredients listed.';

  @override
  String get editProductUpper => 'EDIT PRODUCT';

  @override
  String get deleteProductUpper => 'DELETE PRODUCT';

  @override
  String get manageCategoriesTitle => 'Manage Categories';

  @override
  String get createNewCategory => 'Create New Category';

  @override
  String get categoryNameHint => 'Category Name (e.g. Essence)';

  @override
  String get categoryNameLabel => 'Category Name';

  @override
  String get chooseCategoryColor => 'Choose Category Color';

  @override
  String get addCategoryUpper => 'ADD CATEGORY';

  @override
  String get allCategories => 'All Categories';

  @override
  String get defaultBadge => 'DEFAULT';

  @override
  String get renameCategory => 'Rename Category';

  @override
  String get chooseColor => 'Choose Color';

  @override
  String get categoryAlreadyExists => 'Category name already exists!';

  @override
  String get deleteCategoryTitle => 'Delete Category';

  @override
  String deleteCategoryWarningInUse(int count, String categoryName) {
    return 'Warning: There are $count product(s) currently using \"$categoryName\". Deleting this category will reassign them to the default category \"Serum\". Are you sure you want to delete?';
  }

  @override
  String deleteCategoryWarningSimple(String categoryName) {
    return 'Are you sure you want to delete the category \"$categoryName\"?';
  }

  @override
  String categoryDeletedSnackbar(String categoryName) {
    return 'Category \"$categoryName\" deleted.';
  }

  @override
  String get journal => 'Journal';

  @override
  String get journalSubtitle => 'Track your glow progress.';

  @override
  String get uploadingGlow => 'Uploading your glow...';

  @override
  String get compareModeTooltip => 'Compare Mode';

  @override
  String get cancelCompareTooltip => 'Cancel Compare';

  @override
  String selectedComparisonCount(int count) {
    return 'Selected: $count/2 entries';
  }

  @override
  String get compare => 'Compare';

  @override
  String get compareMaxLimitError =>
      'You can only select up to 2 entries for comparison.';

  @override
  String get glowActivity => 'Glow Activity';

  @override
  String get less => 'Less';

  @override
  String get more => 'More';

  @override
  String get thisWeek => 'THIS WEEK';

  @override
  String get lastWeek => 'LAST WEEK';

  @override
  String weeksAgo(int count) {
    return '$count WEEKS AGO';
  }

  @override
  String get addPhoto => 'Add Photo';

  @override
  String scoreLabel(int score) {
    return 'Score: $score';
  }

  @override
  String get addProgressPhoto => 'ADD PROGRESS PHOTO';

  @override
  String get chooseCaptureGlow => 'Choose how to capture your glow.';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get useCameraNow => 'Use camera right now';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get pickExistingPhoto => 'Pick an existing photo';

  @override
  String get addProgressNote => 'Add Progress Note';

  @override
  String get skinFeelHint => 'How does your skin feel today? (optional)';

  @override
  String get logProgress => 'Log Progress';

  @override
  String get skinLogUploaded => '📸 Skin log uploaded! Score updated.';

  @override
  String get uploadFailed => 'Upload failed. Try again.';

  @override
  String get compareGlow => 'COMPARE GLOW';

  @override
  String get beforeUpper => 'BEFORE';

  @override
  String get afterUpper => 'AFTER';

  @override
  String get progressDetails => 'PROGRESS DETAILS';

  @override
  String get closeComparison => 'CLOSE COMPARISON';

  @override
  String get logEntry => 'LOG ENTRY';

  @override
  String get notesUpper => 'NOTES';

  @override
  String get noNotesLogged => 'No notes logged for this entry.';

  @override
  String get deleteLogEntry => 'DELETE LOG ENTRY';

  @override
  String get deleteEntryDialogTitle => 'Delete Entry?';

  @override
  String get deleteEntryConfirmMessage =>
      'Are you sure you want to permanently delete this progress log?';

  @override
  String get entryDeletedSnackbar => '🗑️ Entry deleted.';

  @override
  String get scannerTitle => 'Skin Scanner';

  @override
  String get scanIngredientsUpper => 'SCAN INGREDIENTS';

  @override
  String get scanHistoryUpper => 'SCAN HISTORY';

  @override
  String get alignIngredientsInFrame =>
      'Align ingredient list within the frame';

  @override
  String get cameraInitializing => 'Initializing Camera...';

  @override
  String get cameraPermissionRequired => 'Camera Permission Required';

  @override
  String get cameraPermissionDesc =>
      'Please grant camera permission in your device settings to scan ingredient labels.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get analyzingIngredients => 'Analyzing Ingredients...';

  @override
  String get clearAllScanHistoryTitle => 'Clear all scan history?';

  @override
  String get clearAllScanHistoryDesc =>
      'Are you sure you want to delete all saved scan history? This action cannot be undone.';

  @override
  String get clearHistoryButton => 'Clear History';

  @override
  String get historyClearedSnackbar => 'Scan history cleared.';

  @override
  String get noScanHistoryTitle => 'No scan history yet';

  @override
  String get noScanHistoryDesc => 'Your analyzed ingredients will appear here.';

  @override
  String analyzedOnDate(String date) {
    return 'Analyzed on $date';
  }

  @override
  String detectedIngredientsCount(int count) {
    return 'Detected Ingredients ($count)';
  }

  @override
  String safetyScore(int score) {
    return 'Safety Score: $score/100';
  }

  @override
  String get skinSuitability => 'Skin Suitability:';

  @override
  String get recommendations => 'Recommendations:';

  @override
  String get scanAgain => 'SCAN AGAIN';

  @override
  String statusLevel(String level) {
    return 'Status: $level';
  }

  @override
  String get galleryTooltip => 'Pick from Gallery';

  @override
  String textBlocksDetectedTap(int count) {
    return '$count text blocks detected — TAP to analyze';
  }

  @override
  String get detectingText => 'Detecting text...';

  @override
  String get noCameraAvailable => 'No Camera Available';

  @override
  String get noCameraDesc =>
      'GlowMatch cannot detect a physical camera on this device or simulator.';

  @override
  String get scanAnalysisUpper => 'SCAN ANALYSIS';

  @override
  String get noIngredientsFoundMessage =>
      'No ingredients found.\nTry tapping a text block containing an ingredients list.';

  @override
  String get ingredientInteractionsUpper => 'INGREDIENT INTERACTIONS';

  @override
  String get safetyAndDescription => 'Safety & Ingredient Description:';

  @override
  String get pastProductScans => 'Past product scans';

  @override
  String get noDetailAvailable => 'No detail available.';

  @override
  String get imageScanner => 'IMAGE SCANNER';

  @override
  String get profileAndSettings => 'Profile & Settings';

  @override
  String get guestUser => 'Guest User';

  @override
  String get securedUser => 'Secured User';

  @override
  String get guestAccountWarning => 'Guest Account (Data is temporary)';

  @override
  String get secureYourAccount => 'Secure Your Account';

  @override
  String get secureAccountDesc =>
      'Link an email and password to avoid losing your skincare shelf and routines.';

  @override
  String get linkEmailAccount => 'Link Email Account';

  @override
  String get accountSecuredSuccess => 'Account successfully secured!';

  @override
  String get appSettings => 'App Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeDesc => 'Toggle app-wide dark theme';

  @override
  String get language => 'Language';

  @override
  String get languageDesc => 'Choose your preferred language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get english => 'English';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get preferredCurrency => 'Preferred Currency';

  @override
  String get preferredCurrencyDesc => 'Choose your display and budget currency';

  @override
  String get notifications => 'Notifications';

  @override
  String get routineReminders => 'Routine Reminders';

  @override
  String get routineRemindersDesc => 'Enable AM & PM routine notifications';

  @override
  String get amReminder => '🌅  AM Reminder';

  @override
  String get amReminderDesc => 'Morning routine alert';

  @override
  String get pmReminder => '🌙  PM Reminder';

  @override
  String get pmReminderDesc => 'Evening routine alert';

  @override
  String get signOut => 'Sign Out';

  @override
  String get confirmSignOut => 'Confirm Sign Out';

  @override
  String get confirmSignOutGuest =>
      'Warning: You are currently using a Guest account. Signing out will permanently delete your skincare shelf and routines. Are you sure you want to sign out?';

  @override
  String get confirmSignOutUser =>
      'Are you sure you want to sign out of your account?';
}
