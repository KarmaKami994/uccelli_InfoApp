// lib/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';


// >>> Importiere generierten Lokalisierungs-Code <<<
import 'package:uccelli_info_app/gen_l10n/app_localizations.dart';
// <<< Ende Import >>>


// Importiere main.dart, um auf MyAppState zuzugreifen
import '../main.dart'; // <-- Import hinzufügen


import '../providers/theme_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/custom_app_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String version = '1.0.0';
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadNotifications();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => version = info.version);
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => notificationsEnabled = prefs.getBool('notifications') ?? true);
  }

  Future<void> _setNotifications(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', val);
    setState(() => notificationsEnabled = val);
    // TODO: hook up real push toggle
  }

  Future<void> _clearFavorites() async {
    await Provider.of<FavoritesProvider>(context, listen: false).clearAll();
    // >>> Lokalisierter Text für SnackBar <<<
    // Stelle sicher, dass 'clearFavoritesSubtitle' in deinen ARB Dateien existiert
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.clearFavoritesSubtitle)), // <-- Verwende lokalisierten String
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // >>> Lokalisierter Text für SnackBar <<<
       // Stelle sicher, dass translateKeyForCouldNotOpenLink in deinen ARB Dateien existiert
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.translateKeyForCouldNotOpenLink))); // <-- Füge einen Schlüssel hinzu und verwende ihn
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primaryColor = Theme.of(context).primaryColor;
    // >>> Zugriff auf lokalisierte Texte <<<
    final l10n = AppLocalizations.of(context)!; // <-- Hol dir die Instanz der lokalisierten Texte

    // >>> Aktuelle Locale holen <<<
    final currentLocale = Localizations.localeOf(context); // <-- Hol dir die aktuell aktive Locale

    return Scaffold(
      appBar: customAppBar(
        context,
        title: l10n.settingsPageTitle, // <-- Verwende lokalisierten Titel
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [

          // ─── Dark Mode Toggle ─────────────────────────────────────
          SwitchListTile(
            title: Text(l10n.darkModeSetting), // <-- Verwende lokalisierten Text
            value: themeProvider.isDarkMode,
            activeColor: primaryColor,
            activeTrackColor: primaryColor.withOpacity(0.5),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.4),
            onChanged: (_) => themeProvider.toggleTheme(),
          ),

          // ─── Notifications Toggle ───────────────────────────────
          SwitchListTile(
            title: Text(l10n.enableNotificationsSetting), // <-- Verwende lokalisierten Text
            value: notificationsEnabled,
            activeColor: primaryColor,
            activeTrackColor: primaryColor.withOpacity(0.5),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.4),
            onChanged: _setNotifications,
          ),

          const Divider(),

          // >>> Sprachauswahl Dropdown <<<
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.translateKeyForLanguageSetting), // <-- Füge einen Schlüssel für "Sprache" hinzu (z.B. "languageSettingTitle")
            trailing: DropdownButton<Locale>(
              // Zeige die aktuelle Sprache im Dropdown an
              value: currentLocale, // Zeigt die aktuell aktive Locale an
              icon: const Icon(Icons.arrow_drop_down),
              elevation: 16,
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              underline: Container(height: 2),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  // Rufe die setLocale Methode in MyAppState auf
                  MyApp.of(context)?.setLocale(newLocale);
                }
              },
              // Liste aller unterstützten Sprachen im Dropdown
              items: AppLocalizations.supportedLocales
                  .map<DropdownMenuItem<Locale>>((Locale locale) {
                // Definiere hier, wie der Name der Sprache im Dropdown angezeigt werden soll
                // Dies ist ein Beispiel, wie man den Sprachcode (z.B. 'de') in einen lesbaren Namen umwandelt.
                // Du könntest auch lokalisierte Namen verwenden, wenn du sie in deinen ARB-Dateien definierst (z.B. "languageName_de": "Deutsch")
                String languageName;
                switch (locale.languageCode) {
                  case 'de':
                    languageName = 'Deutsch';
                    break;
                  case 'en':
                    languageName = 'English';
                    break;
                  // Füge weitere Sprachen hier hinzu
                  default:
                    languageName = locale.languageCode; // Zeige einfach den Code, wenn kein Name definiert ist
                }
                return DropdownMenuItem<Locale>(
                  value: locale,
                  child: Text(languageName),
                );
              }).toList(),
            ),
          ),
          // <<< Ende Sprachauswahl Dropdown <<<

          const Divider(),

          ListTile(
            leading: const Icon(Icons.delete_sweep),
            title: Text(l10n.clearFavoritesSetting), // <-- Verwende lokalisierten Text
            subtitle: Text(l10n.clearFavoritesSubtitle), // <-- Verwende lokalisierten Text
            onTap: _clearFavorites,
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.star_rate),
            title: Text(l10n.rateAppSetting), // <-- Verwende lokalisierten Text
            onTap: () => _openUrl('https://example.com/appstore'), // TODO: Echten Link einfügen
          ),

          ListTile(
            leading: const Icon(Icons.share),
            title: Text(l10n.shareAppSetting), // <-- Verwende lokalisierten Text
            onTap: () => Share.share(
              // >>> Lokalisierter Text für Share <<<
              // Du könntest hier einen neuen Schlüssel in deinen ARB Dateien hinzufügen für den Share Text
              // z.B. "shareAppText": "Schau dir die Uccelli Society Info App an!\n{link}"
              // und dann hier verwenden: AppLocalizations.of(context)!.shareAppText(link: 'https://example.com/download')
              'Check out Uccelli Society Info App!\nhttps://example.com/download', // <-- Beispiel Share Text (nicht lokalisiert)
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: Text(l10n.sendFeedbackSetting), // <-- Verwende lokalisierten Text
            onTap: () => launchUrl(
              Uri.parse('mailto:uccelli.society@gmail.com?subject=App Feedback'), // TODO: Betreff eventuell lokalisieren
            ),
          ),

          ListTile(
            leading: const Icon(Icons.bug_report),
            title: Text(l10n.reportBugSetting), // <-- Verwende lokalisierten Text
            onTap: () => launchUrl(
              Uri.parse('mailto:uccelli.society@gmail.com?subject=Bug Report'), // TODO: Betreff eventuell lokalisieren
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.aboutSetting), // <-- Verwende lokalisierten Text
            // >>> Lokalisierter Text mit Platzhalter <<<
            subtitle: Text('${l10n.versionPrefix} $version'), // <-- Verwende lokalisierten Präfix
            // Wenn du den Version Prefix in ARB so definierst: "versionPrefix": "Version {version}"
            // Dann kannst du hier verwenden: l10n.versionPrefix(version: version)
            onTap: () => showAboutDialog(
              context: context,
              // >>> Lokalisierte Texte für About Dialog <<<
              applicationName: l10n.appTitle, // <-- Verwende den App Titel aus Lokalisierung
              applicationVersion: version,
              applicationLegalese: '© 2025 Uccelli Society', // TODO: Legalese evtl. lokalisieren
              // ... andere About Dialog Eigenschaften ...
            ),
          ),
        ],
      ),
    );
  }
}
