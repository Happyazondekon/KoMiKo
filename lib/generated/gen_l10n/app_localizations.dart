import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
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
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Komiko'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @iAgreeTo.
  ///
  /// In en, this message translates to:
  /// **'I agree to the'**
  String get iAgreeTo;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @orConnectWith.
  ///
  /// In en, this message translates to:
  /// **'OR CONNECT WITH'**
  String get orConnectWith;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @dailyJoke.
  ///
  /// In en, this message translates to:
  /// **'Joke of the Day'**
  String get dailyJoke;

  /// No description provided for @bestJokes.
  ///
  /// In en, this message translates to:
  /// **'Best Jokes of the Day'**
  String get bestJokes;

  /// No description provided for @randomJoke.
  ///
  /// In en, this message translates to:
  /// **'Random Joke'**
  String get randomJoke;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @exploreStyles.
  ///
  /// In en, this message translates to:
  /// **'Explore Categories'**
  String get exploreStyles;

  /// No description provided for @savedGems.
  ///
  /// In en, this message translates to:
  /// **'Saved Gems'**
  String get savedGems;

  /// No description provided for @myJokes.
  ///
  /// In en, this message translates to:
  /// **'My Jokes'**
  String get myJokes;

  /// No description provided for @themeSettings.
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get themeSettings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose Photo'**
  String get choosePhoto;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdateSuccess;

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image is too large (> 1MB). Please choose another one.'**
  String get imageTooLarge;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addComment;

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Be the first to comment!'**
  String get noComments;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareViaKomiko.
  ///
  /// In en, this message translates to:
  /// **'Shared via Komiko 😄'**
  String get shareViaKomiko;

  /// No description provided for @proposeJoke.
  ///
  /// In en, this message translates to:
  /// **'Propose a Joke'**
  String get proposeJoke;

  /// No description provided for @jokeContent.
  ///
  /// In en, this message translates to:
  /// **'Joke Content'**
  String get jokeContent;

  /// No description provided for @punchline.
  ///
  /// In en, this message translates to:
  /// **'Punchline (Optional)'**
  String get punchline;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @jokePublished.
  ///
  /// In en, this message translates to:
  /// **'Joke published successfully!'**
  String get jokePublished;

  /// No description provided for @enterJokeContent.
  ///
  /// In en, this message translates to:
  /// **'Please enter joke content.'**
  String get enterJokeContent;

  /// No description provided for @loadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading more gems...'**
  String get loadingMore;

  /// No description provided for @catGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get catGeneral;

  /// No description provided for @catAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get catAnimals;

  /// No description provided for @catBelgians.
  ///
  /// In en, this message translates to:
  /// **'Belgians'**
  String get catBelgians;

  /// No description provided for @catBlondes.
  ///
  /// In en, this message translates to:
  /// **'Blondes'**
  String get catBlondes;

  /// No description provided for @catComputer.
  ///
  /// In en, this message translates to:
  /// **'Computer Science'**
  String get catComputer;

  /// No description provided for @catMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get catMedicine;

  /// No description provided for @catSport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get catSport;

  /// No description provided for @catToto.
  ///
  /// In en, this message translates to:
  /// **'Toto'**
  String get catToto;

  /// No description provided for @catManagement.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get catManagement;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @propose.
  ///
  /// In en, this message translates to:
  /// **'Propose'**
  String get propose;

  /// No description provided for @noJokes.
  ///
  /// In en, this message translates to:
  /// **'No jokes yet.'**
  String get noJokes;

  /// No description provided for @noJokesInCategory.
  ///
  /// In en, this message translates to:
  /// **'No jokes in this category yet.'**
  String get noJokesInCategory;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t liked any jokes yet. Explore and like your favourites!'**
  String get noFavorites;

  /// No description provided for @noMyJokes.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t posted any jokes yet.'**
  String get noMyJokes;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @importInitialJokes.
  ///
  /// In en, this message translates to:
  /// **'Import initial jokes'**
  String get importInitialJokes;

  /// No description provided for @jokesImported.
  ///
  /// In en, this message translates to:
  /// **'Jokes imported!'**
  String get jokesImported;

  /// No description provided for @jokesShared.
  ///
  /// In en, this message translates to:
  /// **'Jokes posted'**
  String get jokesShared;

  /// No description provided for @totalLikes.
  ///
  /// In en, this message translates to:
  /// **'Likes received'**
  String get totalLikes;

  /// No description provided for @commentsReceived.
  ///
  /// In en, this message translates to:
  /// **'Comments received'**
  String get commentsReceived;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSince;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get anonymous;

  /// No description provided for @verifiedAccount.
  ///
  /// In en, this message translates to:
  /// **'Verified account'**
  String get verifiedAccount;

  /// No description provided for @deleteJoke.
  ///
  /// In en, this message translates to:
  /// **'Delete joke'**
  String get deleteJoke;

  /// No description provided for @jokeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Joke deleted.'**
  String get jokeDeleted;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this joke?'**
  String get confirmDelete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @myFavorites.
  ///
  /// In en, this message translates to:
  /// **'My Favourites'**
  String get myFavorites;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordInfo.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get resetPasswordInfo;

  /// No description provided for @sendLink.
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get sendLink;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Email Sent!'**
  String get emailSent;

  /// No description provided for @emailSentInfo.
  ///
  /// In en, this message translates to:
  /// **'Check your email at {email} for instructions on how to reset your password.'**
  String emailSentInfo(String email);

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmail;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkYourEmail;

  /// No description provided for @verificationSentTo.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification link to {email}. Please click the link to verify your account.'**
  String verificationSentTo(String email);

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get resendEmail;

  /// No description provided for @resendInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Resend in {count}s'**
  String resendInSeconds(int count);

  /// No description provided for @useAnotherAccount.
  ///
  /// In en, this message translates to:
  /// **'Use another account'**
  String get useAnotherAccount;

  /// No description provided for @invalidEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidEmailOrPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @agreeToTermsError.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the terms and conditions'**
  String get agreeToTermsError;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registrationFailed;

  /// No description provided for @importCleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning up old jokes...'**
  String get importCleaning;

  /// No description provided for @importingProgress.
  ///
  /// In en, this message translates to:
  /// **'Importing {current} / {total}...'**
  String importingProgress(int current, int total);

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'Import completed successfully!'**
  String get importDone;

  /// No description provided for @connectWith.
  ///
  /// In en, this message translates to:
  /// **'OR CONNECT WITH'**
  String get connectWith;

  /// No description provided for @onboardTitle1.
  ///
  /// In en, this message translates to:
  /// **'Laugh Without Limits'**
  String get onboardTitle1;

  /// No description provided for @onboardSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Jokes for every taste, one click away.'**
  String get onboardSubtitle1;

  /// No description provided for @onboardTitle2.
  ///
  /// In en, this message translates to:
  /// **'Discover & Explore'**
  String get onboardTitle2;

  /// No description provided for @onboardSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Hundreds of jokes sorted by category. Find your style.'**
  String get onboardSubtitle2;

  /// No description provided for @onboardTitle3.
  ///
  /// In en, this message translates to:
  /// **'Share the Laughter'**
  String get onboardTitle3;

  /// No description provided for @onboardSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Like, comment and share your favourite jokes with the people you love.'**
  String get onboardSubtitle3;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Go!'**
  String get getStarted;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @errorOops.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong.'**
  String get errorOops;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotifications;

  /// No description provided for @notifLiked.
  ///
  /// In en, this message translates to:
  /// **'{actor} liked your joke'**
  String notifLiked(String actor);

  /// No description provided for @notifCommented.
  ///
  /// In en, this message translates to:
  /// **'{actor} commented on your joke'**
  String notifCommented(String actor);

  /// No description provided for @notifFollowed.
  ///
  /// In en, this message translates to:
  /// **'{actor} started following you'**
  String notifFollowed(String actor);

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @likesReceived.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get likesReceived;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @unfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// No description provided for @jokes.
  ///
  /// In en, this message translates to:
  /// **'Jokes'**
  String get jokes;

  /// No description provided for @notifDailyJoke.
  ///
  /// In en, this message translates to:
  /// **'The joke of the day is waiting for you!'**
  String get notifDailyJoke;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @selectAvatar.
  ///
  /// In en, this message translates to:
  /// **'Select an avatar'**
  String get selectAvatar;

  /// No description provided for @predefinedAvatars.
  ///
  /// In en, this message translates to:
  /// **'Predefined avatars'**
  String get predefinedAvatars;

  /// No description provided for @customAvatar.
  ///
  /// In en, this message translates to:
  /// **'Custom photo'**
  String get customAvatar;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get seeMore;

  /// No description provided for @seeLess.
  ///
  /// In en, this message translates to:
  /// **'See less'**
  String get seeLess;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search for a joke...'**
  String get searchPlaceholder;

  /// No description provided for @typeAWordOrPhrase.
  ///
  /// In en, this message translates to:
  /// **'Type a word or phrase...'**
  String get typeAWordOrPhrase;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResultsFor(String query);

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @categoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find your daily dose of laughter'**
  String get categoriesSubtitle;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Field required'**
  String get fieldRequired;

  /// No description provided for @dataDeletion.
  ///
  /// In en, this message translates to:
  /// **'Deleting data ({current} / {total})...'**
  String dataDeletion(int current, int total);

  /// No description provided for @debugNotifications.
  ///
  /// In en, this message translates to:
  /// **'Debug Notifications'**
  String get debugNotifications;

  /// No description provided for @testInstantNotif.
  ///
  /// In en, this message translates to:
  /// **'Test Instant Notification'**
  String get testInstantNotif;

  /// No description provided for @testDelayedNotif.
  ///
  /// In en, this message translates to:
  /// **'Test 10s Delayed Notification'**
  String get testDelayedNotif;

  /// No description provided for @requestNotifPerm.
  ///
  /// In en, this message translates to:
  /// **'Request Permission Dialog'**
  String get requestNotifPerm;

  /// No description provided for @permissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Permission Granted'**
  String get permissionGranted;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDenied;

  /// No description provided for @notifMorningTitle.
  ///
  /// In en, this message translates to:
  /// **'Good morning! ☕'**
  String get notifMorningTitle;

  /// No description provided for @notifMorningBody.
  ///
  /// In en, this message translates to:
  /// **'Start your day with the Joke of the Day. Smiles guaranteed!'**
  String get notifMorningBody;

  /// No description provided for @notifAfternoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coffee break? 🍩'**
  String get notifAfternoonTitle;

  /// No description provided for @notifAfternoonBody.
  ///
  /// In en, this message translates to:
  /// **'Take 2 minutes to discover the latest trending jokes.'**
  String get notifAfternoonBody;

  /// No description provided for @notifEveningTitle.
  ///
  /// In en, this message translates to:
  /// **'Relaxing time 🌙'**
  String get notifEveningTitle;

  /// No description provided for @notifEveningBody.
  ///
  /// In en, this message translates to:
  /// **'End your day on a high note with our selection of the evening.'**
  String get notifEveningBody;

  /// No description provided for @enableNotifPrompt.
  ///
  /// In en, this message translates to:
  /// **'Even our jokes are sad when you don\'t receive them... 😢'**
  String get enableNotifPrompt;

  /// No description provided for @enableNotifButton.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications!'**
  String get enableNotifButton;

  /// No description provided for @notifStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t miss the fun'**
  String get notifStatusTitle;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequiredTitle;

  /// No description provided for @updateAppImproving.
  ///
  /// In en, this message translates to:
  /// **'Komiko is getting better!'**
  String get updateAppImproving;

  /// No description provided for @updateDescription.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available. Please update to continue laughing without limits and enjoy the latest features.'**
  String get updateDescription;

  /// No description provided for @updateButton.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateButton;

  /// No description provided for @updateDontMissFeatures.
  ///
  /// In en, this message translates to:
  /// **'Don\'t miss out on new jokes and features!'**
  String get updateDontMissFeatures;

  /// No description provided for @rateAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoying Komiko?'**
  String get rateAppTitle;

  /// No description provided for @rateAppDescription.
  ///
  /// In en, this message translates to:
  /// **'If you like the app, please leave us a rating on the store. It helps us a lot!'**
  String get rateAppDescription;

  /// No description provided for @rateNow.
  ///
  /// In en, this message translates to:
  /// **'Rate Now'**
  String get rateNow;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'{content}\n\n{punchline}\n\nView this joke on Komiko: https://play.google.com/store/apps/details?id=com.heyhappy.komiko'**
  String shareText(String content, String punchline);

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Laugh without limits'**
  String get tagline;

  /// No description provided for @aboutKomiko.
  ///
  /// In en, this message translates to:
  /// **'About Komiko'**
  String get aboutKomiko;

  /// No description provided for @aboutKomikoDesc.
  ///
  /// In en, this message translates to:
  /// **'Komiko is the first social network dedicated to bilingual humor. Our mission is to spread joy, one joke at a time.'**
  String get aboutKomikoDesc;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @contactUsDesc.
  ///
  /// In en, this message translates to:
  /// **'Any questions, bugs or suggestions? Our team is here to help.'**
  String get contactUsDesc;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy'**
  String get termsAndPrivacy;

  /// No description provided for @termsAndPrivacyDesc.
  ///
  /// In en, this message translates to:
  /// **'By using Komiko, you agree to our terms of service. We protect your data with the utmost care.'**
  String get termsAndPrivacyDesc;

  /// No description provided for @readFullOnKomiko.
  ///
  /// In en, this message translates to:
  /// **'Read the full joke on the app!'**
  String get readFullOnKomiko;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
