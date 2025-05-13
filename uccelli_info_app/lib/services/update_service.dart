// lib/services/update_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart'; // Für robusten Versionsvergleich

/// Hält Informationen über ein verfügbares Update.
class AppUpdateInfo {
  final bool updateAvailable;
  final String? latestVersion;
  final String? downloadUrl;

  AppUpdateInfo({required this.updateAvailable, this.latestVersion, this.downloadUrl});

  @override
  String toString() {
    return 'AppUpdateInfo(updateAvailable: $updateAvailable, latestVersion: $latestVersion, downloadUrl: $downloadUrl)';
  }
}

/// Service zur Überprüfung auf App-Updates über die GitHub Releases API.
class UpdateService {
  // TODO: Ersetze dies durch die Details deines GitHub Repositorys
  // Du hast mir KarmaKami994/uccelli_InfoApp genannt, passe es ggf. an falls nötig
  static const String _repoOwner = 'KarmaKami994';
  static const String _repoName = 'uccelli_InfoApp';
  static const String _githubApiBaseUrl = 'https://api.github.com';

  /// Prüft auf das neueste Release auf GitHub.
  /// Gibt ein Future mit AppUpdateInfo zurück.
  Future<AppUpdateInfo> checkForUpdate() async {
    try {
      // Abfrage der neuesten Releases, beschränkt auf 1 Ergebnis
      final response = await http.get(
        Uri.parse('$_githubApiBaseUrl/repos/$_repoOwner/$_repoName/releases?per_page=1'),
        headers: {
          // Empfohlen von GitHub für API-Anfragen
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> releases = json.decode(response.body);

        if (releases.isNotEmpty) {
          final latestRelease = releases.first;
          // tag_name ist das, was du als Version pushst, z.B. "v1.0.37"
          final latestVersionTag = latestRelease['tag_name'] as String;

          // Entferne "v"-Präfix, falls vorhanden, für den Versionsvergleich
          final cleanLatestVersion = latestVersionTag.startsWith('v')
              ? latestVersionTag.substring(1)
              : latestVersionTag;

          // Aktuelle App-Version abrufen
          final PackageInfo packageInfo = await PackageInfo.fromPlatform();
          final currentVersion = packageInfo.version; // z.B. "1.0.36"

          // Versionsvergleich mit dem 'version'-Paket
          try {
            final current = Version.parse(currentVersion);
            final latest = Version.parse(cleanLatestVersion);

            if (latest > current) {
              // Update verfügbar! Finde die APK-Asset-URL
              final assets = latestRelease['assets'] as List<dynamic>;
              String? apkDownloadUrl;
              if (assets.isNotEmpty) {
                // Finde das Asset, das eine APK ist und den Versionsnamen enthält
                final apkAsset = assets.firstWhere(
                  (asset) =>
                      asset['name'].toString().endsWith('.apk') &&
                      asset['name'].toString().contains(cleanLatestVersion),
                  orElse: () => null, // Null zurückgeben, wenn kein passendes Asset gefunden wird
                );
                apkDownloadUrl = apkAsset?['browser_download_url'] as String?;
              }

              // Gebe Informationen über das verfügbare Update zurück
              return AppUpdateInfo(
                updateAvailable: true,
                latestVersion: latestVersionTag, // Gebe den vollständigen Tag zurück
                downloadUrl: apkDownloadUrl, // URL für den Download
              );
            }
          } on FormatException {
             // Fehler beim Parsen der Versionsnummern (sollte nicht passieren, wenn Tags im Format vX.Y.Z sind)
             print('Error parsing version numbers (current: $currentVersion, latest: $latestVersionTag)');
          }
        }
      } else {
        // Fehler bei der HTTP-Anfrage (z.B. Rate Limit, Repo nicht gefunden)
        print('GitHub API error: ${response.statusCode}');
        // Optional: Zeige eine Benutzer-Fehlermeldung an (z.B. "Update-Prüfung fehlgeschlagen")
      }
    } catch (e) {
      // Andere Fehler (Netzwerk, JSON-Parsing etc.)
      print('Error checking for update: $e');
      // Optional: Zeige eine Benutzer-Fehlermeldung an
    }

    // Kein Update verfügbar oder ein Fehler ist aufgetreten
    return AppUpdateInfo(updateAvailable: false);
  }
}