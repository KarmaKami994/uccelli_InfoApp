import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

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
    Locale('de'),
    Locale('en'),
  ];

  /// Der Titel der Anwendung
  ///
  /// In de, this message translates to:
  /// **'Uccelli Society Info App'**
  String get appTitle;

  /// No description provided for @helloWorld.
  ///
  /// In de, this message translates to:
  /// **'Hallo Welt!'**
  String get helloWorld;

  /// No description provided for @settingsPageTitle.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsPageTitle;

  /// No description provided for @darkModeSetting.
  ///
  /// In de, this message translates to:
  /// **'Dunkelmodus'**
  String get darkModeSetting;

  /// No description provided for @enableNotificationsSetting.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen aktivieren'**
  String get enableNotificationsSetting;

  /// No description provided for @clearFavoritesSetting.
  ///
  /// In de, this message translates to:
  /// **'Favoriten löschen'**
  String get clearFavoritesSetting;

  /// No description provided for @clearFavoritesSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Alle gespeicherten Posts entfernen'**
  String get clearFavoritesSubtitle;

  /// No description provided for @rateAppSetting.
  ///
  /// In de, this message translates to:
  /// **'App bewerten'**
  String get rateAppSetting;

  /// No description provided for @shareAppSetting.
  ///
  /// In de, this message translates to:
  /// **'App teilen'**
  String get shareAppSetting;

  /// No description provided for @sendFeedbackSetting.
  ///
  /// In de, this message translates to:
  /// **'Feedback senden'**
  String get sendFeedbackSetting;

  /// No description provided for @reportBugSetting.
  ///
  /// In de, this message translates to:
  /// **'Bug melden'**
  String get reportBugSetting;

  /// No description provided for @aboutSetting.
  ///
  /// In de, this message translates to:
  /// **'Über'**
  String get aboutSetting;

  /// No description provided for @versionPrefix.
  ///
  /// In de, this message translates to:
  /// **'Version'**
  String get versionPrefix;

  /// No description provided for @translateKeyForCouldNotOpenLink.
  ///
  /// In de, this message translates to:
  /// **'Link konnte nicht geöffnet werden'**
  String get translateKeyForCouldNotOpenLink;

  /// No description provided for @translateKeyForLanguageSetting.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get translateKeyForLanguageSetting;

  /// No description provided for @latestPostsTabTitle.
  ///
  /// In de, this message translates to:
  /// **'Neueste Posts'**
  String get latestPostsTabTitle;

  /// No description provided for @upcomingEventsTabTitle.
  ///
  /// In de, this message translates to:
  /// **'Kommende Events'**
  String get upcomingEventsTabTitle;

  /// No description provided for @searchPostsLabel.
  ///
  /// In de, this message translates to:
  /// **'Posts suchen'**
  String get searchPostsLabel;

  /// No description provided for @searchEventsLabel.
  ///
  /// In de, this message translates to:
  /// **'Events suchen'**
  String get searchEventsLabel;

  /// No description provided for @noPostsFound.
  ///
  /// In de, this message translates to:
  /// **'Keine Posts gefunden.'**
  String get noPostsFound;

  /// No description provided for @errorLoadingPosts.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden der Posts:'**
  String get errorLoadingPosts;

  /// No description provided for @noEventsFound.
  ///
  /// In de, this message translates to:
  /// **'Keine Events gefunden.'**
  String get noEventsFound;

  /// No description provided for @errorLoadingEvents.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden der Events:'**
  String get errorLoadingEvents;

  /// No description provided for @eventStartsPrefix.
  ///
  /// In de, this message translates to:
  /// **'Startet:'**
  String get eventStartsPrefix;

  /// No description provided for @homePageTitle.
  ///
  /// In de, this message translates to:
  /// **'Uccelli Society'**
  String get homePageTitle;

  /// No description provided for @favoritesPageTitle.
  ///
  /// In de, this message translates to:
  /// **'Favoriten'**
  String get favoritesPageTitle;

  /// No description provided for @errorLoadingFavorites.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden der Favoriten:'**
  String get errorLoadingFavorites;

  /// No description provided for @noFavoritesYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Favoriten.'**
  String get noFavoritesYet;

  /// No description provided for @publishedOnPrefix.
  ///
  /// In de, this message translates to:
  /// **'Veröffentlicht am:'**
  String get publishedOnPrefix;

  /// No description provided for @sharePostButtonLabel.
  ///
  /// In de, this message translates to:
  /// **'Diesen Post teilen'**
  String get sharePostButtonLabel;

  /// No description provided for @addToCalendarFunctionEntered.
  ///
  /// In de, this message translates to:
  /// **'Funktion aufgerufen!'**
  String get addToCalendarFunctionEntered;

  /// No description provided for @errorParsingEventDate.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Parsen des Event-Datums. Ungültiges Datumsformat.'**
  String get errorParsingEventDate;

  /// No description provided for @unexpectedErrorParsingEventData.
  ///
  /// In de, this message translates to:
  /// **'Ein unerwarteter Fehler ist beim Parsen der Daten aufgetreten.'**
  String get unexpectedErrorParsingEventData;

  /// No description provided for @generalErrorAddingToCalendar.
  ///
  /// In de, this message translates to:
  /// **'Ein allgemeiner Fehler ist beim Hinzufügen zum Kalender aufgetreten.'**
  String get generalErrorAddingToCalendar;

  /// No description provided for @noLinkAvailableForEvent.
  ///
  /// In de, this message translates to:
  /// **'Kein Link für dieses Event verfügbar.'**
  String get noLinkAvailableForEvent;

  /// No description provided for @infoSectionTitle.
  ///
  /// In de, this message translates to:
  /// **'Info'**
  String get infoSectionTitle;

  /// No description provided for @timePrefix.
  ///
  /// In de, this message translates to:
  /// **'Zeit:'**
  String get timePrefix;

  /// No description provided for @entryFeePrefix.
  ///
  /// In de, this message translates to:
  /// **'Eintritt:'**
  String get entryFeePrefix;

  /// No description provided for @descriptionSectionTitle.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung'**
  String get descriptionSectionTitle;

  /// No description provided for @venueSectionTitle.
  ///
  /// In de, this message translates to:
  /// **'Veranstaltungsort'**
  String get venueSectionTitle;

  /// No description provided for @addToCalendarButtonLabel.
  ///
  /// In de, this message translates to:
  /// **'Zum Kalender hinzufügen'**
  String get addToCalendarButtonLabel;

  /// No description provided for @joinEventButtonLabel.
  ///
  /// In de, this message translates to:
  /// **'Am Event teilnehmen'**
  String get joinEventButtonLabel;
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
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
