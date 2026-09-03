// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Komiko';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get fullName => 'Full Name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get iAgreeTo => 'I agree to the';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get and => 'and';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get orConnectWith => 'OR CONNECT WITH';

  @override
  String get google => 'Google';

  @override
  String get facebook => 'Facebook';

  @override
  String get apple => 'Apple';

  @override
  String get home => 'Home';

  @override
  String get categories => 'Categories';

  @override
  String get favorites => 'Favorites';

  @override
  String get settings => 'Settings';

  @override
  String get dailyJoke => 'Joke of the Day';

  @override
  String get bestJokes => 'Best Jokes of the Day';

  @override
  String get randomJoke => 'Random Joke';

  @override
  String get seeAll => 'See All';

  @override
  String get exploreStyles => 'Explore Categories';

  @override
  String get savedGems => 'Saved Gems';

  @override
  String get myJokes => 'My Jokes';

  @override
  String get themeSettings => 'Theme Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get logOut => 'Log Out';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get username => 'Username';

  @override
  String get bio => 'Bio';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get choosePhoto => 'Choose a photo';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get profileUpdateSuccess => 'Profile updated successfully!';

  @override
  String get imageTooLarge =>
      'Image is too large (> 1MB). Please choose another one.';

  @override
  String get comments => 'Comments';

  @override
  String get addComment => 'Add a comment...';

  @override
  String get noComments => 'No comments yet. Be the first to comment!';

  @override
  String get like => 'Like';

  @override
  String get share => 'Share';

  @override
  String get shareViaKomiko => 'Shared via Komiko 😄';

  @override
  String get proposeJoke => 'Propose a Joke';

  @override
  String get jokeContent => 'Joke Content';

  @override
  String get punchline => 'Punchline (Optional)';

  @override
  String get category => 'Category';

  @override
  String get publish => 'Publish';

  @override
  String get jokePublished => 'Joke published successfully!';

  @override
  String get enterJokeContent => 'Please enter joke content.';

  @override
  String get loadingMore => 'Loading more gems...';

  @override
  String get catGeneral => 'General';

  @override
  String get catAnimals => 'Animals';

  @override
  String get catBelgians => 'Belgians';

  @override
  String get catBlondes => 'Blondes';

  @override
  String get catComputer => 'Computer Science';

  @override
  String get catMedicine => 'Medicine';

  @override
  String get catSport => 'Sport';

  @override
  String get catToto => 'Toto';

  @override
  String get catManagement => 'Management';

  @override
  String get catOther => 'Other';

  @override
  String get propose => 'Propose';

  @override
  String get noJokes => 'No jokes yet.';

  @override
  String get noJokesInCategory => 'No jokes in this category yet.';

  @override
  String get noFavorites =>
      'You haven\'t liked any jokes yet. Explore and like your favourites!';

  @override
  String get noMyJokes => 'You haven\'t posted any jokes yet.';

  @override
  String get error => 'Error';

  @override
  String get language => 'Language';

  @override
  String get french => 'French';

  @override
  String get english => 'English';

  @override
  String get importInitialJokes => 'Import initial jokes';

  @override
  String get jokesImported => 'Jokes imported!';

  @override
  String get jokesShared => 'Jokes posted';

  @override
  String get totalLikes => 'Likes received';

  @override
  String get commentsReceived => 'Comments received';

  @override
  String get memberSince => 'Member since';

  @override
  String get anonymous => 'User';

  @override
  String get verifiedAccount => 'Verified account';

  @override
  String get deleteJoke => 'Delete joke';

  @override
  String get jokeDeleted => 'Joke deleted.';

  @override
  String get confirmDelete => 'Do you really want to delete this joke?';

  @override
  String get confirm => 'Confirm';

  @override
  String get myFavorites => 'My Favourites';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get createAccount => 'Create Account';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordInfo =>
      'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get sendLink => 'Send Link';

  @override
  String get emailSent => 'Email Sent!';

  @override
  String emailSentInfo(String email) {
    return 'Check your email at $email for instructions on how to reset your password.';
  }

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get verifyEmail => 'Verify Email';

  @override
  String get checkYourEmail => 'Check your email';

  @override
  String verificationSentTo(String email) {
    return 'We\'ve sent a verification link to $email. Please click the link to verify your account.';
  }

  @override
  String get resendEmail => 'Resend Email';

  @override
  String resendInSeconds(int count) {
    return 'Resend in ${count}s';
  }

  @override
  String get useAnotherAccount => 'Use another account';

  @override
  String get invalidEmailOrPassword => 'Invalid email or password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get agreeToTermsError => 'Please agree to the terms and conditions';

  @override
  String get registrationFailed => 'Registration failed. Please try again.';

  @override
  String get importCleaning => 'Cleaning up old jokes...';

  @override
  String importingProgress(int current, int total) {
    return 'Importing $current / $total...';
  }

  @override
  String get importDone => 'Import completed successfully!';

  @override
  String get connectWith => 'OR CONNECT WITH';

  @override
  String get onboardTitle1 => 'Laugh Without Limits';

  @override
  String get onboardSubtitle1 => 'Jokes for every taste, one click away.';

  @override
  String get onboardTitle2 => 'Discover & Explore';

  @override
  String get onboardSubtitle2 =>
      'Hundreds of jokes sorted by category. Find your style.';

  @override
  String get onboardTitle3 => 'Share the Laughter';

  @override
  String get onboardSubtitle3 =>
      'Like, comment and share your favourite jokes with the people you love.';

  @override
  String get getStarted => 'Let\'s Go!';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get errorOops => 'Oops! Something went wrong.';

  @override
  String get retry => 'Retry';

  @override
  String get noNotifications => 'No notifications yet.';

  @override
  String notifLiked(String actor) {
    return '$actor liked your joke';
  }

  @override
  String notifCommented(String actor) {
    return '$actor commented on your joke';
  }

  @override
  String notifFollowed(String actor) {
    return '$actor started following you';
  }

  @override
  String get followers => 'Followers';

  @override
  String get following => 'Following';

  @override
  String get likesReceived => 'Likes';

  @override
  String get follow => 'Follow';

  @override
  String get unfollow => 'Unfollow';

  @override
  String get jokes => 'Jokes';

  @override
  String get notifDailyJoke => 'The joke of the day is waiting for you!';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get selectAvatar => 'Select an avatar';

  @override
  String get predefinedAvatars => 'Predefined avatars';

  @override
  String get customAvatar => 'Custom photo';

  @override
  String get seeMore => 'See more';

  @override
  String get seeLess => 'See less';

  @override
  String get search => 'Search';

  @override
  String get searchPlaceholder => 'Search for a joke...';

  @override
  String get typeAWordOrPhrase => 'Type a word or phrase...';

  @override
  String noResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get categoriesSubtitle => 'Find your daily dose of laughter';

  @override
  String get fieldRequired => 'Field required';

  @override
  String dataDeletion(int current, int total) {
    return 'Deleting data ($current / $total)...';
  }

  @override
  String get debugNotifications => 'Debug Notifications';

  @override
  String get testInstantNotif => 'Test Instant Notification';

  @override
  String get testDelayedNotif => 'Test 10s Delayed Notification';

  @override
  String get requestNotifPerm => 'Request Permission Dialog';

  @override
  String get permissionGranted => 'Permission Granted';

  @override
  String get permissionDenied => 'Permission Denied';

  @override
  String get notifMorningTitle => 'Good morning! ☕';

  @override
  String get notifMorningBody =>
      'Start your day with the Joke of the Day. Smiles guaranteed!';

  @override
  String get notifAfternoonTitle => 'Coffee break? 🍩';

  @override
  String get notifAfternoonBody =>
      'Take 2 minutes to discover the latest trending jokes.';

  @override
  String get notifEveningTitle => 'Relaxing time 🌙';

  @override
  String get notifEveningBody =>
      'End your day on a high note with our selection of the evening.';

  @override
  String get enableNotifPrompt =>
      'Even our jokes are sad when you don\'t receive them... 😢';

  @override
  String get enableNotifButton => 'Enable Notifications!';

  @override
  String get notifStatusTitle => 'Don\'t miss the fun';

  @override
  String get updateRequiredTitle => 'Update Required';

  @override
  String get updateAppImproving => 'Komiko is getting better!';

  @override
  String get updateDescription =>
      'A new version of the app is available. Please update to continue laughing without limits and enjoy the latest features.';

  @override
  String get updateButton => 'Update Now';

  @override
  String get updateDontMissFeatures =>
      'Don\'t miss out on new jokes and features!';

  @override
  String get rateAppTitle => 'Enjoying Komiko?';

  @override
  String get rateAppDescription =>
      'Your feedback helps us make the app even funnier!';

  @override
  String get rateNow => 'Rate Now';

  @override
  String get submitRating => 'Submit';

  @override
  String get rateOnPlayStore => 'Rate on Play Store';

  @override
  String get rateLater => 'Maybe later';

  @override
  String get noThanks => 'No thanks';

  @override
  String get thankYouForRating => 'Thank you for your feedback! ❤️';

  @override
  String get tapToRate => 'Tap a star to rate';

  @override
  String get rating1Star => 'Terrible 😠';

  @override
  String get rating2Stars => 'Bad 😕';

  @override
  String get rating3Stars => 'Okay 🙂';

  @override
  String get rating4Stars => 'Good! 😊';

  @override
  String get rating5Stars => 'Amazing! 😍';

  @override
  String get later => 'Later';

  @override
  String shareText(String content, String punchline) {
    return '$content\n\n$punchline\n\nView this joke on Komiko: https://play.google.com/store/apps/details?id=com.heyhappy.komiko';
  }

  @override
  String get tagline => 'Laugh without limits';

  @override
  String get aboutKomiko => 'About Komiko';

  @override
  String get aboutKomikoDesc =>
      'Komiko is the first social network dedicated to bilingual humor. Our mission is to spread joy, one joke at a time.';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get contactUsDesc =>
      'Any questions, bugs or suggestions? Our team is here to help.';

  @override
  String get termsAndPrivacy => 'Terms & Privacy';

  @override
  String get termsAndPrivacyDesc =>
      'By using Komiko, you agree to our terms of service. We protect your data with the utmost care.';

  @override
  String get readFullOnKomiko => 'Read the full joke on the app!';

  @override
  String get feedForYou => 'For you';

  @override
  String get feedSelectedForYou => 'Selected for you';

  @override
  String get featured => 'Featured';

  @override
  String get reportJoke => 'Report joke';

  @override
  String get jokeReported => 'Joke reported. Thank you! 💪';

  @override
  String get komikoPro => 'Komiko Pro';

  @override
  String get komikoProBadge => 'Komiko Pro ✨';

  @override
  String get komikoProUnlock => 'Unlock the full power of Komiko';

  @override
  String get proFeaturePhotoTitle => 'Photos in your jokes';

  @override
  String get proFeaturePhotoDesc =>
      'Exclusive to Pro & Verified members • Tap to unlock';

  @override
  String get proFeatureBoostTitle => 'Boosted posts';

  @override
  String get proFeatureBoostDesc =>
      'Your joke gets boosted in everyone\'s feed';

  @override
  String get proFeatureBadgeTitle => 'Verified Pro Badge';

  @override
  String get proFeatureBadgeDesc =>
      'Display your status with the golden ✓ badge on your posts';

  @override
  String get proFeaturePriorityTitle => 'Feed priority';

  @override
  String get proFeaturePriorityDesc =>
      'Your recent jokes naturally rank higher';

  @override
  String get planMonthly => 'Monthly';

  @override
  String get planAnnual => 'Annual';

  @override
  String get planPerMonth => '/ month';

  @override
  String get planPerYear => '/ year';

  @override
  String get savePercent => 'Save ~37% ✨';

  @override
  String get popular => 'Popular';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get autoRenewDisclaimer =>
      'Auto-renewable subscription. Cancel anytime.';

  @override
  String get proUpgradeBannerTitle => 'Upgrade to Komiko Pro ✨';

  @override
  String get proUpgradeBannerSubtitle =>
      'Get your verified badge and boost your jokes';

  @override
  String get addPhoto => 'Add a photo';

  @override
  String get zoomIn => 'Expand';

  @override
  String get maxPhotoSize => 'Max ~750 KB';

  @override
  String get imageTooHeavy =>
      'Image is too large. Please select a smaller image (max ~750 KB).';

  @override
  String get errorLoadingImage => 'Error loading image';

  @override
  String get boostInFeed => 'Feature post';

  @override
  String get boostInFeedDesc => 'Your joke will be boosted in the feed';

  @override
  String get accountRestrictedMsg =>
      'Your account is restricted. You cannot publish at this time.';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get adminPosts => 'Posts';

  @override
  String get adminUsers => 'Users';

  @override
  String get adminReported => 'Reported';

  @override
  String get noReportedContent => 'No reported content 🎉';

  @override
  String get aiRecommended => 'Recommended for you';

  @override
  String get aiCuratedForYou => 'Specially curated for your taste';

  @override
  String get reportJokeTitle => 'Report this joke';

  @override
  String get reportJokeSubtitle =>
      'Select a reason. This joke will no longer be shown in your feed.';

  @override
  String get reportReasonInappropriate => 'Inappropriate or offensive content';

  @override
  String get reportReasonHarassment => 'Harassment or hate speech';

  @override
  String get reportReasonSpam => 'Spam or misleading content';

  @override
  String get reportReasonCopyright => 'Plagiarism or copyright violation';

  @override
  String get reportReasonOther => 'Other reason';

  @override
  String get reportCommentHint => 'Add details (optional)...';

  @override
  String get submitReport => 'Report & hide';

  @override
  String get jokeHiddenFromFeed => 'Joke reported and hidden from your feed 👍';

  @override
  String get welcomeUsernameTitle => 'Welcome to Komiko!';

  @override
  String get welcomeUsernameSubtitle =>
      'Here is your username. You can keep it or change it now:';

  @override
  String get usernameFieldLabel => 'Your username';

  @override
  String get usernameFieldHint => 'E.g. Alex, LaughMaster...';

  @override
  String get usernameEmptyError => 'Please enter a valid username';

  @override
  String get continueButton => 'Let\'s go!';

  @override
  String get usernameConfirmed => 'Profile ready! Welcome aboard!';

  @override
  String get tutorialStepFeedTitle => 'The News Feed';

  @override
  String get tutorialStepFeedDesc =>
      'Discover the best jokes curated for you. Like, comment, and share your favorites as beautiful images!';

  @override
  String get tutorialStepProposeTitle => 'Share a Joke';

  @override
  String get tutorialStepProposeDesc =>
      'Make the community laugh! Tap the + button to publish your own bilingual jokes.';

  @override
  String get tutorialStepCategoriesTitle => 'Themed Categories';

  @override
  String get tutorialStepCategoriesDesc =>
      'Explore jokes by topic: Toto, Geek, Dark humor, Short jokes, Animals, and much more!';

  @override
  String get tutorialStepFavoritesTitle => 'Your Offline Favorites';

  @override
  String get tutorialStepFavoritesDesc =>
      'Easily find all the jokes you loved to read them again even without an internet connection.';

  @override
  String get tutorialStepSettingsTitle => 'Settings & Profile';

  @override
  String get tutorialStepSettingsDesc =>
      'Switch between French and English, toggle dark mode, edit your profile, and discover Komiko Pro!';

  @override
  String get tutorialNext => 'Next';

  @override
  String get tutorialFinish => 'Finish tour';

  @override
  String get tutorialSkip => 'Skip';

  @override
  String get replayTutorial => 'Replay tutorial';

  @override
  String get enhanceJokeAi => 'Komiko Assistant ✨';

  @override
  String get enhanceJokeAiTitle => 'Komiko Assistant ✨';

  @override
  String get enhanceJokeAiSubtitle =>
      'How would you like to transform your joke?';

  @override
  String get enhanceEmptyWarning =>
      'Please write a draft of your joke first so Komiko Assistant can enhance it!';

  @override
  String get enhanceOptionFunnier => 'Make it funnier';

  @override
  String get enhanceOptionFunnierDesc =>
      'Adds hilarious comedic twists and details';

  @override
  String get enhanceOptionPunchy => 'Shorter & punchier';

  @override
  String get enhanceOptionPunchyDesc => 'Cuts the fluff for instant impact';

  @override
  String get enhanceOptionPunchline => 'Explosive punchline';

  @override
  String get enhanceOptionPunchlineDesc =>
      'Crafts an unexpected, unforgettable finish';

  @override
  String get enhanceOptionClean => 'Refine & polish';

  @override
  String get enhanceOptionCleanDesc =>
      'Flawless grammar and smooth comedic timing';

  @override
  String get enhanceOptionCrazy => 'Absurd & wacky';

  @override
  String get enhanceOptionCrazyDesc => 'Offbeat tone and delightful surprises';

  @override
  String get enhanceOptionDark => 'Dark & sarcastic humor';

  @override
  String get enhanceOptionDarkDesc => 'Edgy, cynical and biting punchline';

  @override
  String get aiGeneratingProposal =>
      'Komiko Assistant is polishing your joke...';

  @override
  String get applyAiSuggestion => 'Apply to my joke';

  @override
  String get tryAnotherStyle => 'Try another style';

  @override
  String get originalVersion => 'Original version';

  @override
  String get enhancedVersion => 'Enhanced version';

  @override
  String freeUsesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count free trials remaining',
      one: 'Last free trial!',
    );
    return '$_temp0';
  }

  @override
  String get freeQuotaExhaustedPhoto =>
      'You have used your 5 free photos. Upgrade to Komiko Pro for unlimited access!';

  @override
  String get freeQuotaExhaustedAssistant =>
      'You have used your 5 free trials with Komiko Assistant. Upgrade to Pro for unlimited access!';

  @override
  String get freeBadge => 'Free';

  @override
  String freeTrialsRemaining(int count) {
    return '$count/5';
  }
}
