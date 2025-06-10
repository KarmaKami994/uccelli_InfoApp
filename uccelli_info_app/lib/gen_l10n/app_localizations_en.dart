// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Uccelli Society Info App';

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get settingsPageTitle => 'Settings';

  @override
  String get darkModeSetting => 'Dark Mode';

  @override
  String get enableNotificationsSetting => 'Enable Notifications';

  @override
  String get clearFavoritesSetting => 'Clear Favorites';

  @override
  String get clearFavoritesSubtitle => 'Remove all bookmarked posts';

  @override
  String get rateAppSetting => 'Rate this App';

  @override
  String get shareAppSetting => 'Share this App';

  @override
  String get sendFeedbackSetting => 'Send Feedback';

  @override
  String get reportBugSetting => 'Report a Bug';

  @override
  String get aboutSetting => 'About';

  @override
  String get versionPrefix => 'Version';

  @override
  String get translateKeyForCouldNotOpenLink => 'Could not open link';

  @override
  String get translateKeyForLanguageSetting => 'Language';

  @override
  String get latestPostsTabTitle => 'Latest Posts';

  @override
  String get upcomingEventsTabTitle => 'Upcoming Events';

  @override
  String get searchPostsLabel => 'Search Posts';

  @override
  String get searchEventsLabel => 'Search Events';

  @override
  String get noPostsFound => 'No posts found.';

  @override
  String get errorLoadingPosts => 'Error loading posts:';

  @override
  String get noEventsFound => 'No events found.';

  @override
  String get errorLoadingEvents => 'Error loading events:';

  @override
  String get eventStartsPrefix => 'Starts:';

  @override
  String get homePageTitle => 'Uccelli Society';

  @override
  String get favoritesPageTitle => 'Favorites';

  @override
  String get errorLoadingFavorites => 'Error loading favorites:';

  @override
  String get noFavoritesYet => 'No favorites yet.';

  @override
  String get publishedOnPrefix => 'Published on:';

  @override
  String get sharePostButtonLabel => 'Share this Post';

  @override
  String get addToCalendarFunctionEntered => 'Function entered!';

  @override
  String get errorParsingEventDate =>
      'Error parsing event date. Invalid date format.';

  @override
  String get unexpectedErrorParsingEventData =>
      'An unexpected error occurred while parsing data.';

  @override
  String get generalErrorAddingToCalendar =>
      'A general error occurred while adding to calendar.';

  @override
  String get noLinkAvailableForEvent => 'No link available for this event.';

  @override
  String get infoSectionTitle => 'Info';

  @override
  String get timePrefix => 'Time:';

  @override
  String get entryFeePrefix => 'Entry Fee:';

  @override
  String get descriptionSectionTitle => 'Description';

  @override
  String get venueSectionTitle => 'Venue';

  @override
  String get addToCalendarButtonLabel => 'Add to Calendar';

  @override
  String get joinEventButtonLabel => 'Join the Event';
}
