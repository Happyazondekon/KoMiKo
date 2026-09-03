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
  /// **'Choose a photo'**
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
  /// **'Your feedback helps us make the app even funnier!'**
  String get rateAppDescription;

  /// No description provided for @rateNow.
  ///
  /// In en, this message translates to:
  /// **'Rate Now'**
  String get rateNow;

  /// No description provided for @submitRating.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitRating;

  /// No description provided for @rateOnPlayStore.
  ///
  /// In en, this message translates to:
  /// **'Rate on Play Store'**
  String get rateOnPlayStore;

  /// No description provided for @rateLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get rateLater;

  /// No description provided for @noThanks.
  ///
  /// In en, this message translates to:
  /// **'No thanks'**
  String get noThanks;

  /// No description provided for @thankYouForRating.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback! ❤️'**
  String get thankYouForRating;

  /// No description provided for @tapToRate.
  ///
  /// In en, this message translates to:
  /// **'Tap a star to rate'**
  String get tapToRate;

  /// No description provided for @rating1Star.
  ///
  /// In en, this message translates to:
  /// **'Terrible 😠'**
  String get rating1Star;

  /// No description provided for @rating2Stars.
  ///
  /// In en, this message translates to:
  /// **'Bad 😕'**
  String get rating2Stars;

  /// No description provided for @rating3Stars.
  ///
  /// In en, this message translates to:
  /// **'Okay 🙂'**
  String get rating3Stars;

  /// No description provided for @rating4Stars.
  ///
  /// In en, this message translates to:
  /// **'Good! 😊'**
  String get rating4Stars;

  /// No description provided for @rating5Stars.
  ///
  /// In en, this message translates to:
  /// **'Amazing! 😍'**
  String get rating5Stars;

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

  /// No description provided for @feedForYou.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get feedForYou;

  /// No description provided for @feedSelectedForYou.
  ///
  /// In en, this message translates to:
  /// **'Selected for you'**
  String get feedSelectedForYou;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @reportJoke.
  ///
  /// In en, this message translates to:
  /// **'Report joke'**
  String get reportJoke;

  /// No description provided for @jokeReported.
  ///
  /// In en, this message translates to:
  /// **'Joke reported. Thank you! 💪'**
  String get jokeReported;

  /// No description provided for @komikoPro.
  ///
  /// In en, this message translates to:
  /// **'Komiko Pro'**
  String get komikoPro;

  /// No description provided for @komikoProBadge.
  ///
  /// In en, this message translates to:
  /// **'Komiko Pro ✨'**
  String get komikoProBadge;

  /// No description provided for @komikoProUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock the full power of Komiko'**
  String get komikoProUnlock;

  /// No description provided for @proFeaturePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos in your jokes'**
  String get proFeaturePhotoTitle;

  /// No description provided for @proFeaturePhotoDesc.
  ///
  /// In en, this message translates to:
  /// **'Exclusive to Pro & Verified members • Tap to unlock'**
  String get proFeaturePhotoDesc;

  /// No description provided for @proFeatureBoostTitle.
  ///
  /// In en, this message translates to:
  /// **'Boosted posts'**
  String get proFeatureBoostTitle;

  /// No description provided for @proFeatureBoostDesc.
  ///
  /// In en, this message translates to:
  /// **'Your joke gets boosted in everyone\'s feed'**
  String get proFeatureBoostDesc;

  /// No description provided for @proFeatureBadgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Verified Pro Badge'**
  String get proFeatureBadgeTitle;

  /// No description provided for @proFeatureBadgeDesc.
  ///
  /// In en, this message translates to:
  /// **'Display your status with the golden ✓ badge on your posts'**
  String get proFeatureBadgeDesc;

  /// No description provided for @proFeaturePriorityTitle.
  ///
  /// In en, this message translates to:
  /// **'Feed priority'**
  String get proFeaturePriorityTitle;

  /// No description provided for @proFeaturePriorityDesc.
  ///
  /// In en, this message translates to:
  /// **'Your recent jokes naturally rank higher'**
  String get proFeaturePriorityDesc;

  /// No description provided for @planMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get planMonthly;

  /// No description provided for @planAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get planAnnual;

  /// No description provided for @planPerMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get planPerMonth;

  /// No description provided for @planPerYear.
  ///
  /// In en, this message translates to:
  /// **'/ year'**
  String get planPerYear;

  /// No description provided for @savePercent.
  ///
  /// In en, this message translates to:
  /// **'Save ~37% ✨'**
  String get savePercent;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @autoRenewDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Auto-renewable subscription. Cancel anytime.'**
  String get autoRenewDisclaimer;

  /// No description provided for @proUpgradeBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Komiko Pro ✨'**
  String get proUpgradeBannerTitle;

  /// No description provided for @proUpgradeBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get your verified badge and boost your jokes'**
  String get proUpgradeBannerSubtitle;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get addPhoto;

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get zoomIn;

  /// No description provided for @maxPhotoSize.
  ///
  /// In en, this message translates to:
  /// **'Max ~750 KB'**
  String get maxPhotoSize;

  /// No description provided for @imageTooHeavy.
  ///
  /// In en, this message translates to:
  /// **'Image is too large. Please select a smaller image (max ~750 KB).'**
  String get imageTooHeavy;

  /// No description provided for @errorLoadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error loading image'**
  String get errorLoadingImage;

  /// No description provided for @boostInFeed.
  ///
  /// In en, this message translates to:
  /// **'Feature post'**
  String get boostInFeed;

  /// No description provided for @boostInFeedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your joke will be boosted in the feed'**
  String get boostInFeedDesc;

  /// No description provided for @accountRestrictedMsg.
  ///
  /// In en, this message translates to:
  /// **'Your account is restricted. You cannot publish at this time.'**
  String get accountRestrictedMsg;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @adminPosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get adminPosts;

  /// No description provided for @adminUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminUsers;

  /// No description provided for @adminReported.
  ///
  /// In en, this message translates to:
  /// **'Reported'**
  String get adminReported;

  /// No description provided for @noReportedContent.
  ///
  /// In en, this message translates to:
  /// **'No reported content 🎉'**
  String get noReportedContent;

  /// No description provided for @aiRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get aiRecommended;

  /// No description provided for @aiCuratedForYou.
  ///
  /// In en, this message translates to:
  /// **'Specially curated for your taste'**
  String get aiCuratedForYou;

  /// No description provided for @reportJokeTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this joke'**
  String get reportJokeTitle;

  /// No description provided for @reportJokeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a reason. This joke will no longer be shown in your feed.'**
  String get reportJokeSubtitle;

  /// No description provided for @reportReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate or offensive content'**
  String get reportReasonInappropriate;

  /// No description provided for @reportReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment or hate speech'**
  String get reportReasonHarassment;

  /// No description provided for @reportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam or misleading content'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonCopyright.
  ///
  /// In en, this message translates to:
  /// **'Plagiarism or copyright violation'**
  String get reportReasonCopyright;

  /// No description provided for @reportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other reason'**
  String get reportReasonOther;

  /// No description provided for @reportCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Add details (optional)...'**
  String get reportCommentHint;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Report & hide'**
  String get submitReport;

  /// No description provided for @jokeHiddenFromFeed.
  ///
  /// In en, this message translates to:
  /// **'Joke reported and hidden from your feed 👍'**
  String get jokeHiddenFromFeed;

  /// No description provided for @welcomeUsernameTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Komiko!'**
  String get welcomeUsernameTitle;

  /// No description provided for @welcomeUsernameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here is your username. You can keep it or change it now:'**
  String get welcomeUsernameSubtitle;

  /// No description provided for @usernameFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Your username'**
  String get usernameFieldLabel;

  /// No description provided for @usernameFieldHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Alex, LaughMaster...'**
  String get usernameFieldHint;

  /// No description provided for @usernameEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid username'**
  String get usernameEmptyError;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go!'**
  String get continueButton;

  /// No description provided for @usernameConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Profile ready! Welcome aboard!'**
  String get usernameConfirmed;

  /// No description provided for @tutorialStepFeedTitle.
  ///
  /// In en, this message translates to:
  /// **'The News Feed'**
  String get tutorialStepFeedTitle;

  /// No description provided for @tutorialStepFeedDesc.
  ///
  /// In en, this message translates to:
  /// **'Discover the best jokes curated for you. Like, comment, and share your favorites as beautiful images!'**
  String get tutorialStepFeedDesc;

  /// No description provided for @tutorialStepProposeTitle.
  ///
  /// In en, this message translates to:
  /// **'Share a Joke'**
  String get tutorialStepProposeTitle;

  /// No description provided for @tutorialStepProposeDesc.
  ///
  /// In en, this message translates to:
  /// **'Make the community laugh! Tap the + button to publish your own bilingual jokes.'**
  String get tutorialStepProposeDesc;

  /// No description provided for @tutorialStepCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Themed Categories'**
  String get tutorialStepCategoriesTitle;

  /// No description provided for @tutorialStepCategoriesDesc.
  ///
  /// In en, this message translates to:
  /// **'Explore jokes by topic: Toto, Geek, Dark humor, Short jokes, Animals, and much more!'**
  String get tutorialStepCategoriesDesc;

  /// No description provided for @tutorialStepFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Offline Favorites'**
  String get tutorialStepFavoritesTitle;

  /// No description provided for @tutorialStepFavoritesDesc.
  ///
  /// In en, this message translates to:
  /// **'Easily find all the jokes you loved to read them again even without an internet connection.'**
  String get tutorialStepFavoritesDesc;

  /// No description provided for @tutorialStepSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings & Profile'**
  String get tutorialStepSettingsTitle;

  /// No description provided for @tutorialStepSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Switch between French and English, toggle dark mode, edit your profile, and discover Komiko Pro!'**
  String get tutorialStepSettingsDesc;

  /// No description provided for @tutorialNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tutorialNext;

  /// No description provided for @tutorialFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish tour'**
  String get tutorialFinish;

  /// No description provided for @tutorialSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get tutorialSkip;

  /// No description provided for @replayTutorial.
  ///
  /// In en, this message translates to:
  /// **'Replay tutorial'**
  String get replayTutorial;

  /// No description provided for @enhanceJokeAi.
  ///
  /// In en, this message translates to:
  /// **'Komiko Assistant ✨'**
  String get enhanceJokeAi;

  /// No description provided for @enhanceJokeAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Komiko Assistant ✨'**
  String get enhanceJokeAiTitle;

  /// No description provided for @enhanceJokeAiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How would you like to transform your joke?'**
  String get enhanceJokeAiSubtitle;

  /// No description provided for @enhanceEmptyWarning.
  ///
  /// In en, this message translates to:
  /// **'Please write a draft of your joke first so Komiko Assistant can enhance it!'**
  String get enhanceEmptyWarning;

  /// No description provided for @enhanceOptionFunnier.
  ///
  /// In en, this message translates to:
  /// **'Make it funnier'**
  String get enhanceOptionFunnier;

  /// No description provided for @enhanceOptionFunnierDesc.
  ///
  /// In en, this message translates to:
  /// **'Adds hilarious comedic twists and details'**
  String get enhanceOptionFunnierDesc;

  /// No description provided for @enhanceOptionPunchy.
  ///
  /// In en, this message translates to:
  /// **'Shorter & punchier'**
  String get enhanceOptionPunchy;

  /// No description provided for @enhanceOptionPunchyDesc.
  ///
  /// In en, this message translates to:
  /// **'Cuts the fluff for instant impact'**
  String get enhanceOptionPunchyDesc;

  /// No description provided for @enhanceOptionPunchline.
  ///
  /// In en, this message translates to:
  /// **'Explosive punchline'**
  String get enhanceOptionPunchline;

  /// No description provided for @enhanceOptionPunchlineDesc.
  ///
  /// In en, this message translates to:
  /// **'Crafts an unexpected, unforgettable finish'**
  String get enhanceOptionPunchlineDesc;

  /// No description provided for @enhanceOptionClean.
  ///
  /// In en, this message translates to:
  /// **'Refine & polish'**
  String get enhanceOptionClean;

  /// No description provided for @enhanceOptionCleanDesc.
  ///
  /// In en, this message translates to:
  /// **'Flawless grammar and smooth comedic timing'**
  String get enhanceOptionCleanDesc;

  /// No description provided for @enhanceOptionCrazy.
  ///
  /// In en, this message translates to:
  /// **'Absurd & wacky'**
  String get enhanceOptionCrazy;

  /// No description provided for @enhanceOptionCrazyDesc.
  ///
  /// In en, this message translates to:
  /// **'Offbeat tone and delightful surprises'**
  String get enhanceOptionCrazyDesc;

  /// No description provided for @enhanceOptionDark.
  ///
  /// In en, this message translates to:
  /// **'Dark & sarcastic humor'**
  String get enhanceOptionDark;

  /// No description provided for @enhanceOptionDarkDesc.
  ///
  /// In en, this message translates to:
  /// **'Edgy, cynical and biting punchline'**
  String get enhanceOptionDarkDesc;

  /// No description provided for @aiGeneratingProposal.
  ///
  /// In en, this message translates to:
  /// **'Komiko Assistant is polishing your joke...'**
  String get aiGeneratingProposal;

  /// No description provided for @applyAiSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Apply to my joke'**
  String get applyAiSuggestion;

  /// No description provided for @tryAnotherStyle.
  ///
  /// In en, this message translates to:
  /// **'Try another style'**
  String get tryAnotherStyle;

  /// No description provided for @originalVersion.
  ///
  /// In en, this message translates to:
  /// **'Original version'**
  String get originalVersion;

  /// No description provided for @enhancedVersion.
  ///
  /// In en, this message translates to:
  /// **'Enhanced version'**
  String get enhancedVersion;

  /// No description provided for @freeUsesLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Last free trial!} other{{count} free trials remaining}}'**
  String freeUsesLeft(int count);

  /// No description provided for @freeQuotaExhaustedPhoto.
  ///
  /// In en, this message translates to:
  /// **'You have used your 5 free photos. Upgrade to Komiko Pro for unlimited access!'**
  String get freeQuotaExhaustedPhoto;

  /// No description provided for @freeQuotaExhaustedAssistant.
  ///
  /// In en, this message translates to:
  /// **'You have used your 5 free trials with Komiko Assistant. Upgrade to Pro for unlimited access!'**
  String get freeQuotaExhaustedAssistant;

  /// No description provided for @freeBadge.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeBadge;

  /// No description provided for @freeTrialsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count}/5'**
  String freeTrialsRemaining(int count);
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
