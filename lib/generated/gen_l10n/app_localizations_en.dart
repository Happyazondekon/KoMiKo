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
  String get choosePhoto => 'Choose Photo';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get profileUpdateSuccess => 'Profile updated successfully!';

  @override
  String get imageTooLarge => 'Image is too large (> 1MB). Please choose another one.';

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
  String get noFavorites => 'You haven\'t liked any jokes yet. Explore and like your favourites!';

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
  String get resetPasswordInfo => 'Enter your email address and we\'ll send you a link to reset your password.';

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
  String get onboardSubtitle2 => 'Hundreds of jokes sorted by category. Find your style.';

  @override
  String get onboardTitle3 => 'Share the Laughter';

  @override
  String get onboardSubtitle3 => 'Like, comment and share your favourite jokes with the people you love.';

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
}
