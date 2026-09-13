import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'GlowMatch'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get navBudget;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get navJournal;

  /// No description provided for @navShelf.
  ///
  /// In en, this message translates to:
  /// **'Shelf'**
  String get navShelf;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Track Your Glow'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Log your AM & PM skincare routines and maintain a visual skin progress journal.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Scan Ingredients'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Use AI to scan product ingredients via OCR and check their safety and compatibility.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Smart Budget'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Keep track of your skincare spending and analyze cost-per-apply efficiency.'**
  String get onboardingDesc3;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Sign in to sync your routines.'**
  String get signInSubtitle;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account to backup your shelf & progress.'**
  String get signUpSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get alreadyHaveAccount;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// No description provided for @emailValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailValidationError;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLengthError;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @morningRoutine.
  ///
  /// In en, this message translates to:
  /// **'Morning Routine'**
  String get morningRoutine;

  /// No description provided for @eveningRoutine.
  ///
  /// In en, this message translates to:
  /// **'Evening Routine'**
  String get eveningRoutine;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @stepsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} Completed'**
  String stepsCompleted(int completed, int total);

  /// No description provided for @noRoutineSteps.
  ///
  /// In en, this message translates to:
  /// **'No routine steps yet. Tap below to add your first step!'**
  String get noRoutineSteps;

  /// No description provided for @deleteStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Step?'**
  String get deleteStepTitle;

  /// No description provided for @deleteStepMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{stepName}\" from your {routineName} routine?'**
  String deleteStepMessage(String stepName, String routineName);

  /// No description provided for @deleteStepWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this step? Remaining steps will be renumbered.'**
  String get deleteStepWarning;

  /// No description provided for @completePreviousStepsOrder.
  ///
  /// In en, this message translates to:
  /// **'Please complete previous steps in order.'**
  String get completePreviousStepsOrder;

  /// No description provided for @usedOneApply.
  ///
  /// In en, this message translates to:
  /// **'Used 1 apply of {productName}!'**
  String usedOneApply(String productName);

  /// No description provided for @stepNumber.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String stepNumber(int number);

  /// No description provided for @customStep.
  ///
  /// In en, this message translates to:
  /// **'Custom Step'**
  String get customStep;

  /// No description provided for @clickToAdd.
  ///
  /// In en, this message translates to:
  /// **'Click to add'**
  String get clickToAdd;

  /// No description provided for @completedForToday.
  ///
  /// In en, this message translates to:
  /// **'Completed for Today'**
  String get completedForToday;

  /// No description provided for @completeRoutine.
  ///
  /// In en, this message translates to:
  /// **'Complete Routine'**
  String get completeRoutine;

  /// No description provided for @routineCompletedToast.
  ///
  /// In en, this message translates to:
  /// **'Routine Completed! Consistency score updated.'**
  String get routineCompletedToast;

  /// No description provided for @milestone7DaysToast.
  ///
  /// In en, this message translates to:
  /// **'🎉 7 Day Milestone! Awesome dedication!'**
  String get milestone7DaysToast;

  /// No description provided for @milestone14DaysToast.
  ///
  /// In en, this message translates to:
  /// **'🎉 14 Day Milestone! You are unstoppable!'**
  String get milestone14DaysToast;

  /// No description provided for @milestone30DaysToast.
  ///
  /// In en, this message translates to:
  /// **'🎉 30 Day Milestone! You are a skincare master!'**
  String get milestone30DaysToast;

  /// No description provided for @dayStreakBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} Day Streak'**
  String dayStreakBadge(int count);

  /// No description provided for @startRoutineMotivation.
  ///
  /// In en, this message translates to:
  /// **'Start your routine today to begin your glowing skin streak! 🔥'**
  String get startRoutineMotivation;

  /// No description provided for @milestone30Motivation.
  ///
  /// In en, this message translates to:
  /// **'👑 30+ Day Milestone! Skincare Master status unlocked!'**
  String get milestone30Motivation;

  /// No description provided for @milestone14Motivation.
  ///
  /// In en, this message translates to:
  /// **'🌟 14 Day Milestone! Your skin barrier is thanking you!'**
  String get milestone14Motivation;

  /// No description provided for @milestone7Motivation.
  ///
  /// In en, this message translates to:
  /// **'🏆 7 Day Milestone! You are building a solid skincare habit!'**
  String get milestone7Motivation;

  /// No description provided for @keepItUpMotivation.
  ///
  /// In en, this message translates to:
  /// **'✨ Keep it up! Consistency is the key to glowing skin.'**
  String get keepItUpMotivation;

  /// No description provided for @addRoutineStep.
  ///
  /// In en, this message translates to:
  /// **'Add Routine Step'**
  String get addRoutineStep;

  /// No description provided for @editRoutineStep.
  ///
  /// In en, this message translates to:
  /// **'Edit Routine Step'**
  String get editRoutineStep;

  /// No description provided for @stepNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Step Name (e.g., Toner)'**
  String get stepNameLabel;

  /// No description provided for @stepNameSimpleLabel.
  ///
  /// In en, this message translates to:
  /// **'Step Name'**
  String get stepNameSimpleLabel;

  /// No description provided for @instructionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructions (e.g., Apply with pad)'**
  String get instructionsLabel;

  /// No description provided for @instructionsSimpleLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructionsSimpleLabel;

  /// No description provided for @linkShelfProductOptional.
  ///
  /// In en, this message translates to:
  /// **'Link Shelf Product (Optional)'**
  String get linkShelfProductOptional;

  /// No description provided for @linkShelfProduct.
  ///
  /// In en, this message translates to:
  /// **'Link Shelf Product'**
  String get linkShelfProduct;

  /// No description provided for @selectProductHint.
  ///
  /// In en, this message translates to:
  /// **'Select product'**
  String get selectProductHint;

  /// No description provided for @noneOption.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneOption;

  /// No description provided for @streakHistoryAndStats.
  ///
  /// In en, this message translates to:
  /// **'Streak History & Stats'**
  String get streakHistoryAndStats;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get longestStreak;

  /// No description provided for @totalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Total Completed'**
  String get totalCompleted;

  /// No description provided for @streakDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Days'**
  String streakDaysCount(int count);

  /// No description provided for @streakHistory.
  ///
  /// In en, this message translates to:
  /// **'Streak History'**
  String get streakHistory;

  /// No description provided for @noStreakHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No streak history yet. Complete your first routine!'**
  String get noStreakHistoryYet;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @skincareMasterMilestone.
  ///
  /// In en, this message translates to:
  /// **'👑 Skincare Master Milestone!'**
  String get skincareMasterMilestone;

  /// No description provided for @unstoppableBarrierMilestone.
  ///
  /// In en, this message translates to:
  /// **'🌟 Unstoppable barrier milestone!'**
  String get unstoppableBarrierMilestone;

  /// No description provided for @solidHabitMilestone.
  ///
  /// In en, this message translates to:
  /// **'🏆 Solid habit milestone!'**
  String get solidHabitMilestone;

  /// No description provided for @visualCalendar.
  ///
  /// In en, this message translates to:
  /// **'Visual Calendar'**
  String get visualCalendar;

  /// No description provided for @totalSpendInPeriod.
  ///
  /// In en, this message translates to:
  /// **'TOTAL SPEND IN PERIOD'**
  String get totalSpendInPeriod;

  /// No description provided for @period30Days.
  ///
  /// In en, this message translates to:
  /// **'30 Days'**
  String get period30Days;

  /// No description provided for @period90Days.
  ///
  /// In en, this message translates to:
  /// **'90 Days'**
  String get period90Days;

  /// No description provided for @periodAllTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get periodAllTime;

  /// No description provided for @calculatingBudget.
  ///
  /// In en, this message translates to:
  /// **'Calculating budget...'**
  String get calculatingBudget;

  /// No description provided for @allocation.
  ///
  /// In en, this message translates to:
  /// **'ALLOCATION'**
  String get allocation;

  /// No description provided for @noActiveProductsAllocation.
  ///
  /// In en, this message translates to:
  /// **'No active products on your shelf to calculate allocations.'**
  String get noActiveProductsAllocation;

  /// No description provided for @categoriesCount.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesCount;

  /// No description provided for @costPerApplyCalculator.
  ///
  /// In en, this message translates to:
  /// **'COST-PER-APPLY CALCULATOR'**
  String get costPerApplyCalculator;

  /// No description provided for @selectProductFromShelf.
  ///
  /// In en, this message translates to:
  /// **'Select Product from Shelf'**
  String get selectProductFromShelf;

  /// No description provided for @customValuesNoProduct.
  ///
  /// In en, this message translates to:
  /// **'Custom values (no product)'**
  String get customValuesNoProduct;

  /// No description provided for @productPrice.
  ///
  /// In en, this message translates to:
  /// **'Product Price'**
  String get productPrice;

  /// No description provided for @estimatedUses.
  ///
  /// In en, this message translates to:
  /// **'Estimated Uses'**
  String get estimatedUses;

  /// No description provided for @efficiencyMetric.
  ///
  /// In en, this message translates to:
  /// **'EFFICIENCY METRIC'**
  String get efficiencyMetric;

  /// No description provided for @perApplication.
  ///
  /// In en, this message translates to:
  /// **'/ application'**
  String get perApplication;

  /// No description provided for @spendingHistory.
  ///
  /// In en, this message translates to:
  /// **'SPENDING HISTORY (LAST 6 MONTHS)'**
  String get spendingHistory;

  /// No description provided for @setMonthlyBudgetLimit.
  ///
  /// In en, this message translates to:
  /// **'Set Monthly Budget Limit'**
  String get setMonthlyBudgetLimit;

  /// No description provided for @budgetLimit.
  ///
  /// In en, this message translates to:
  /// **'Budget Limit ({currency})'**
  String budgetLimit(String currency);

  /// No description provided for @myShelf.
  ///
  /// In en, this message translates to:
  /// **'My Shelf'**
  String get myShelf;

  /// No description provided for @shelfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your skincare inventory & usage tracker.'**
  String get shelfSubtitle;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'FILTER'**
  String get filter;

  /// No description provided for @filterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by Category'**
  String get filterByCategory;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @tapToAddSkincare.
  ///
  /// In en, this message translates to:
  /// **'tap to add new skincare'**
  String get tapToAddSkincare;

  /// No description provided for @addSkincareProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Skincare Product'**
  String get addSkincareProduct;

  /// No description provided for @editSkincareProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Skincare Product'**
  String get editSkincareProduct;

  /// No description provided for @productImage.
  ///
  /// In en, this message translates to:
  /// **'Product Image'**
  String get productImage;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @productNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Moisture Surge Intense'**
  String get productNameHint;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @brandHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Clinique'**
  String get brandHint;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @selectCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategoryHint;

  /// No description provided for @priceWithCurrency.
  ///
  /// In en, this message translates to:
  /// **'Price ({currency})'**
  String priceWithCurrency(String currency);

  /// No description provided for @priceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 150000'**
  String get priceHint;

  /// No description provided for @productSize.
  ///
  /// In en, this message translates to:
  /// **'Product Size'**
  String get productSize;

  /// No description provided for @productSizeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 30ml, 50g'**
  String get productSizeHint;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @ingredientsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Niacinamide, Hyaluronic Acid, Ceramide'**
  String get ingredientsHint;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @deleteProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Product?'**
  String get deleteProductTitle;

  /// No description provided for @deleteProductConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name} from your shelf?'**
  String deleteProductConfirm(String name);

  /// No description provided for @deletedProductSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Deleted {name}'**
  String deletedProductSnackbar(String name);

  /// No description provided for @productDetailPrice.
  ///
  /// In en, this message translates to:
  /// **'PRICE'**
  String get productDetailPrice;

  /// No description provided for @productDetailUsesRemaining.
  ///
  /// In en, this message translates to:
  /// **'USES REMAINING'**
  String get productDetailUsesRemaining;

  /// No description provided for @productDetailCostPerUse.
  ///
  /// In en, this message translates to:
  /// **'COST PER USE'**
  String get productDetailCostPerUse;

  /// No description provided for @productDetailSize.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT SIZE'**
  String get productDetailSize;

  /// No description provided for @productDetailDateAdded.
  ///
  /// In en, this message translates to:
  /// **'DATE ADDED'**
  String get productDetailDateAdded;

  /// No description provided for @productDetailIngredients.
  ///
  /// In en, this message translates to:
  /// **'INGREDIENTS'**
  String get productDetailIngredients;

  /// No description provided for @noIngredientsListed.
  ///
  /// In en, this message translates to:
  /// **'No ingredients listed.'**
  String get noIngredientsListed;

  /// No description provided for @editProductUpper.
  ///
  /// In en, this message translates to:
  /// **'EDIT PRODUCT'**
  String get editProductUpper;

  /// No description provided for @deleteProductUpper.
  ///
  /// In en, this message translates to:
  /// **'DELETE PRODUCT'**
  String get deleteProductUpper;

  /// No description provided for @manageCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategoriesTitle;

  /// No description provided for @createNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Create New Category'**
  String get createNewCategory;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'Category Name (e.g. Essence)'**
  String get categoryNameHint;

  /// No description provided for @categoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryNameLabel;

  /// No description provided for @chooseCategoryColor.
  ///
  /// In en, this message translates to:
  /// **'Choose Category Color'**
  String get chooseCategoryColor;

  /// No description provided for @addCategoryUpper.
  ///
  /// In en, this message translates to:
  /// **'ADD CATEGORY'**
  String get addCategoryUpper;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @defaultBadge.
  ///
  /// In en, this message translates to:
  /// **'DEFAULT'**
  String get defaultBadge;

  /// No description provided for @renameCategory.
  ///
  /// In en, this message translates to:
  /// **'Rename Category'**
  String get renameCategory;

  /// No description provided for @chooseColor.
  ///
  /// In en, this message translates to:
  /// **'Choose Color'**
  String get chooseColor;

  /// No description provided for @categoryAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Category name already exists!'**
  String get categoryAlreadyExists;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryWarningInUse.
  ///
  /// In en, this message translates to:
  /// **'Warning: There are {count} product(s) currently using \"{categoryName}\". Deleting this category will reassign them to the default category \"Serum\". Are you sure you want to delete?'**
  String deleteCategoryWarningInUse(int count, String categoryName);

  /// No description provided for @deleteCategoryWarningSimple.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the category \"{categoryName}\"?'**
  String deleteCategoryWarningSimple(String categoryName);

  /// No description provided for @categoryDeletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Category \"{categoryName}\" deleted.'**
  String categoryDeletedSnackbar(String categoryName);

  /// No description provided for @journal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journal;

  /// No description provided for @journalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your glow progress.'**
  String get journalSubtitle;

  /// No description provided for @uploadingGlow.
  ///
  /// In en, this message translates to:
  /// **'Uploading your glow...'**
  String get uploadingGlow;

  /// No description provided for @compareModeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Compare Mode'**
  String get compareModeTooltip;

  /// No description provided for @cancelCompareTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel Compare'**
  String get cancelCompareTooltip;

  /// No description provided for @selectedComparisonCount.
  ///
  /// In en, this message translates to:
  /// **'Selected: {count}/2 entries'**
  String selectedComparisonCount(int count);

  /// No description provided for @compare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get compare;

  /// No description provided for @compareMaxLimitError.
  ///
  /// In en, this message translates to:
  /// **'You can only select up to 2 entries for comparison.'**
  String get compareMaxLimitError;

  /// No description provided for @glowActivity.
  ///
  /// In en, this message translates to:
  /// **'Glow Activity'**
  String get glowActivity;

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'LAST WEEK'**
  String get lastWeek;

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} WEEKS AGO'**
  String weeksAgo(int count);

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String scoreLabel(int score);

  /// No description provided for @addProgressPhoto.
  ///
  /// In en, this message translates to:
  /// **'ADD PROGRESS PHOTO'**
  String get addProgressPhoto;

  /// No description provided for @chooseCaptureGlow.
  ///
  /// In en, this message translates to:
  /// **'Choose how to capture your glow.'**
  String get chooseCaptureGlow;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @useCameraNow.
  ///
  /// In en, this message translates to:
  /// **'Use camera right now'**
  String get useCameraNow;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @pickExistingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Pick an existing photo'**
  String get pickExistingPhoto;

  /// No description provided for @addProgressNote.
  ///
  /// In en, this message translates to:
  /// **'Add Progress Note'**
  String get addProgressNote;

  /// No description provided for @skinFeelHint.
  ///
  /// In en, this message translates to:
  /// **'How does your skin feel today? (optional)'**
  String get skinFeelHint;

  /// No description provided for @logProgress.
  ///
  /// In en, this message translates to:
  /// **'Log Progress'**
  String get logProgress;

  /// No description provided for @skinLogUploaded.
  ///
  /// In en, this message translates to:
  /// **'📸 Skin log uploaded! Score updated.'**
  String get skinLogUploaded;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Try again.'**
  String get uploadFailed;

  /// No description provided for @compareGlow.
  ///
  /// In en, this message translates to:
  /// **'COMPARE GLOW'**
  String get compareGlow;

  /// No description provided for @beforeUpper.
  ///
  /// In en, this message translates to:
  /// **'BEFORE'**
  String get beforeUpper;

  /// No description provided for @afterUpper.
  ///
  /// In en, this message translates to:
  /// **'AFTER'**
  String get afterUpper;

  /// No description provided for @progressDetails.
  ///
  /// In en, this message translates to:
  /// **'PROGRESS DETAILS'**
  String get progressDetails;

  /// No description provided for @closeComparison.
  ///
  /// In en, this message translates to:
  /// **'CLOSE COMPARISON'**
  String get closeComparison;

  /// No description provided for @logEntry.
  ///
  /// In en, this message translates to:
  /// **'LOG ENTRY'**
  String get logEntry;

  /// No description provided for @notesUpper.
  ///
  /// In en, this message translates to:
  /// **'NOTES'**
  String get notesUpper;

  /// No description provided for @noNotesLogged.
  ///
  /// In en, this message translates to:
  /// **'No notes logged for this entry.'**
  String get noNotesLogged;

  /// No description provided for @deleteLogEntry.
  ///
  /// In en, this message translates to:
  /// **'DELETE LOG ENTRY'**
  String get deleteLogEntry;

  /// No description provided for @deleteEntryDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry?'**
  String get deleteEntryDialogTitle;

  /// No description provided for @deleteEntryConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this progress log?'**
  String get deleteEntryConfirmMessage;

  /// No description provided for @entryDeletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'🗑️ Entry deleted.'**
  String get entryDeletedSnackbar;

  /// No description provided for @scannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Skin Scanner'**
  String get scannerTitle;

  /// No description provided for @scanIngredientsUpper.
  ///
  /// In en, this message translates to:
  /// **'SCAN INGREDIENTS'**
  String get scanIngredientsUpper;

  /// No description provided for @scanHistoryUpper.
  ///
  /// In en, this message translates to:
  /// **'SCAN HISTORY'**
  String get scanHistoryUpper;

  /// No description provided for @alignIngredientsInFrame.
  ///
  /// In en, this message translates to:
  /// **'Align ingredient list within the frame'**
  String get alignIngredientsInFrame;

  /// No description provided for @cameraInitializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing Camera...'**
  String get cameraInitializing;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission Required'**
  String get cameraPermissionRequired;

  /// No description provided for @cameraPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Please grant camera permission in your device settings to scan ingredient labels.'**
  String get cameraPermissionDesc;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @analyzingIngredients.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Ingredients...'**
  String get analyzingIngredients;

  /// No description provided for @clearAllScanHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all scan history?'**
  String get clearAllScanHistoryTitle;

  /// No description provided for @clearAllScanHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all saved scan history? This action cannot be undone.'**
  String get clearAllScanHistoryDesc;

  /// No description provided for @clearHistoryButton.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistoryButton;

  /// No description provided for @historyClearedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Scan history cleared.'**
  String get historyClearedSnackbar;

  /// No description provided for @noScanHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'No scan history yet'**
  String get noScanHistoryTitle;

  /// No description provided for @noScanHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Your analyzed ingredients will appear here.'**
  String get noScanHistoryDesc;

  /// No description provided for @analyzedOnDate.
  ///
  /// In en, this message translates to:
  /// **'Analyzed on {date}'**
  String analyzedOnDate(String date);

  /// No description provided for @detectedIngredientsCount.
  ///
  /// In en, this message translates to:
  /// **'Detected Ingredients ({count})'**
  String detectedIngredientsCount(int count);

  /// No description provided for @safetyScore.
  ///
  /// In en, this message translates to:
  /// **'Safety Score: {score}/100'**
  String safetyScore(int score);

  /// No description provided for @skinSuitability.
  ///
  /// In en, this message translates to:
  /// **'Skin Suitability:'**
  String get skinSuitability;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations:'**
  String get recommendations;

  /// No description provided for @scanAgain.
  ///
  /// In en, this message translates to:
  /// **'SCAN AGAIN'**
  String get scanAgain;

  /// No description provided for @statusLevel.
  ///
  /// In en, this message translates to:
  /// **'Status: {level}'**
  String statusLevel(String level);

  /// No description provided for @galleryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pick from Gallery'**
  String get galleryTooltip;

  /// No description provided for @textBlocksDetectedTap.
  ///
  /// In en, this message translates to:
  /// **'{count} text blocks detected — TAP to analyze'**
  String textBlocksDetectedTap(int count);

  /// No description provided for @detectingText.
  ///
  /// In en, this message translates to:
  /// **'Detecting text...'**
  String get detectingText;

  /// No description provided for @noCameraAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Camera Available'**
  String get noCameraAvailable;

  /// No description provided for @noCameraDesc.
  ///
  /// In en, this message translates to:
  /// **'GlowMatch cannot detect a physical camera on this device or simulator.'**
  String get noCameraDesc;

  /// No description provided for @scanAnalysisUpper.
  ///
  /// In en, this message translates to:
  /// **'SCAN ANALYSIS'**
  String get scanAnalysisUpper;

  /// No description provided for @noIngredientsFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No ingredients found.\nTry tapping a text block containing an ingredients list.'**
  String get noIngredientsFoundMessage;

  /// No description provided for @ingredientInteractionsUpper.
  ///
  /// In en, this message translates to:
  /// **'INGREDIENT INTERACTIONS'**
  String get ingredientInteractionsUpper;

  /// No description provided for @safetyAndDescription.
  ///
  /// In en, this message translates to:
  /// **'Safety & Ingredient Description:'**
  String get safetyAndDescription;

  /// No description provided for @pastProductScans.
  ///
  /// In en, this message translates to:
  /// **'Past product scans'**
  String get pastProductScans;

  /// No description provided for @noDetailAvailable.
  ///
  /// In en, this message translates to:
  /// **'No detail available.'**
  String get noDetailAvailable;

  /// No description provided for @imageScanner.
  ///
  /// In en, this message translates to:
  /// **'IMAGE SCANNER'**
  String get imageScanner;

  /// No description provided for @profileAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileAndSettings;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// No description provided for @securedUser.
  ///
  /// In en, this message translates to:
  /// **'Secured User'**
  String get securedUser;

  /// No description provided for @guestAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'Guest Account (Data is temporary)'**
  String get guestAccountWarning;

  /// No description provided for @secureYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Secure Your Account'**
  String get secureYourAccount;

  /// No description provided for @secureAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Link an email and password to avoid losing your skincare shelf and routines.'**
  String get secureAccountDesc;

  /// No description provided for @linkEmailAccount.
  ///
  /// In en, this message translates to:
  /// **'Link Email Account'**
  String get linkEmailAccount;

  /// No description provided for @accountSecuredSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account successfully secured!'**
  String get accountSecuredSuccess;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Toggle app-wide dark theme'**
  String get darkModeDesc;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get languageDesc;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @indonesian.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get indonesian;

  /// No description provided for @preferredCurrency.
  ///
  /// In en, this message translates to:
  /// **'Preferred Currency'**
  String get preferredCurrency;

  /// No description provided for @preferredCurrencyDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose your display and budget currency'**
  String get preferredCurrencyDesc;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @routineReminders.
  ///
  /// In en, this message translates to:
  /// **'Routine Reminders'**
  String get routineReminders;

  /// No description provided for @routineRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable AM & PM routine notifications'**
  String get routineRemindersDesc;

  /// No description provided for @amReminder.
  ///
  /// In en, this message translates to:
  /// **'🌅  AM Reminder'**
  String get amReminder;

  /// No description provided for @amReminderDesc.
  ///
  /// In en, this message translates to:
  /// **'Morning routine alert'**
  String get amReminderDesc;

  /// No description provided for @pmReminder.
  ///
  /// In en, this message translates to:
  /// **'🌙  PM Reminder'**
  String get pmReminder;

  /// No description provided for @pmReminderDesc.
  ///
  /// In en, this message translates to:
  /// **'Evening routine alert'**
  String get pmReminderDesc;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @confirmSignOut.
  ///
  /// In en, this message translates to:
  /// **'Confirm Sign Out'**
  String get confirmSignOut;

  /// No description provided for @confirmSignOutGuest.
  ///
  /// In en, this message translates to:
  /// **'Warning: You are currently using a Guest account. Signing out will permanently delete your skincare shelf and routines. Are you sure you want to sign out?'**
  String get confirmSignOutGuest;

  /// No description provided for @confirmSignOutUser.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of your account?'**
  String get confirmSignOutUser;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
