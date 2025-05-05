// lib/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorites cleared')),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not open link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: customAppBar(
        context,
        title: 'Settings',
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [

          // ─── Dark Mode Toggle ─────────────────────────────────────
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeProvider.isDarkMode,
            activeColor: primaryColor,                       // thumb when ON
            activeTrackColor: primaryColor.withOpacity(0.5), // track when ON
            inactiveThumbColor: Colors.grey,                 // thumb when OFF
            inactiveTrackColor: Colors.grey.withOpacity(0.4),// track when OFF
            onChanged: (_) => themeProvider.toggleTheme(),
          ),

          // ─── Notifications Toggle ───────────────────────────────
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: notificationsEnabled,
            activeColor: primaryColor,
            activeTrackColor: primaryColor.withOpacity(0.5),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.4),
            onChanged: _setNotifications,
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.delete_sweep),
            title: const Text('Clear Favorites'),
            subtitle: const Text('Remove all bookmarked posts'),
            onTap: _clearFavorites,
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.star_rate),
            title: const Text('Rate this App'),
            onTap: () => _openUrl('https://example.com/appstore'),
          ),

          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share this App'),
            onTap: () => Share.share(
              'Check out Uccelli Society Info App!\nhttps://example.com/download',
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Send Feedback'),
            onTap: () => launchUrl(
              Uri.parse('mailto:uccelli.society@gmail.com?subject=App Feedback'),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Report a Bug'),
            onTap: () => launchUrl(
              Uri.parse('mailto:uccelli.society@gmail.com?subject=Bug Report'),
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: Text('Version $version'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Uccelli Society Info App',
              applicationVersion: version,
              applicationLegalese: '© 2025 Uccelli Society',
            ),
          ),
        ],
      ),
    );
  }
}
