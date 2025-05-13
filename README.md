# 📱 Uccelli Society Info App

> Dein mobiler Begleiter für die neuesten Nachrichten, Blog-Artikel und Events der Uccelli Society.

---

## ✨ Über die App

Die Uccelli Society Info App wurde entwickelt, um Mitgliedern und Interessierten des Verein direkten Zugriff auf aktuelle Informationen zu ermöglichen. Mit dem Ziel, die Kommunikation zu modernisieren, bietet die App einen zentralen Anlaufpunkt für News und bevorstehende Veranstaltungen, optimiert für mobile Endgeräte.

---

## 🚀 Features

### Benutzerfreundliche Funktionen

* **Aktuelle Posts & Blog:** Direkte Anzeige der neuesten Artikel von der WordPress-Webseite.
* **Bevorstehende Events:** Überblick über kommende Veranstaltungen der Uccelli Society mit relevanten Details.
* **Dark / Light Mode:** Anpassbares Design basierend auf den Präferenzen des Benutzers.
* **Favoriten:** Möglichkeit, interessante Posts zu markieren und schnell wiederzufinden.
* **Inhalte durchsuchen & aktualisieren:** Einfache Suche und Pull-to-Refresh-Funktionalität für Posts und Events.
* **Detaillierte Eventansicht:** Anzeige aller relevanten Eventinformationen inkl. Ort, Zeit und Kosten.
* **"Zum Kalender hinzufügen" Funktion:** Integration mit dem nativen Kalender des Geräts, um Events einfach zu speichern.
* **Push-Benachrichtigungen:** Empfang von Benachrichtigungen bei wichtigen Neuigkeiten oder Events.
* **Offline-Zugriff:** Dank lokalem Caching sind Posts und Events auch ohne Internetverbindung verfügbar.

### Technische Highlights & Entwicklungsprozess

* **Framework:** Entwickelt mit **Flutter** (Stable Channel) für plattformübergreifende Kompatibilität (Android & iOS).
* **State Management:** Einsatz von **Provider** für eine effiziente und skalierbare Zustandsverwaltung.
* **API-Integration:** Anbindung an die **WordPress REST API** und die **The Events Calendar REST API** zur dynamischen Inhaltsanzeige.
* **Datenverarbeitung:** **HTML-Parsing und Unescaping** von API-Inhalten zur sauberen Darstellung in der App.
* **Lokale Datenhaltung:** Nutzung von **Hive** für robustes und schnelles Offline-Caching von Posts.
* **Push Notifications:** Integration von **Firebase Cloud Messaging (FCM)** für zuverlässige Benachrichtigungsdienste.
* **OTA Updates:** Implementierung einer **Over-The-Air (OTA) Update-Funktionalität** für die App-Verteilung ausserhalb von App Stores, inkl. Versionsprüfung (über GitHub Releases API), Download-Logik und Berechtigungsmanagement (`permission_handler`, `app_settings`, `dio`, `open_filex`).
* **CI/CD Pipeline:** Automatisierter Release-Build (APK) über **GitHub Actions**, ausgelöst durch Git Tags, inkl. Code-Shrinking (R8/Proguard) und Signierung.
* **Plattformspezifische Anpassungen:** Handling von Android-spezifischen Konfigurationen (z.B. `AndroidManifest.xml` Permissions, `FileProvider`) für Features wie OTA-Updates und Kalenderintegration.
* **Versionsmanagement:** Verwaltung von App- und Paketversionen (`pubspec.yaml`, `package_info_plus`, `version`).
* **Fehlerbehandlung:** Implementierung von `try-catch`-Blöcken und UI-Feedback (Toasts, Dialoge) für robuste Laufzeitstabilität.

---

## 🛠️ Technologien & Pakete

* Flutter
* Dart
* Provider
* HTTP
* version
* html / html_unescape
* flutter_html
* url_launcher
* share_plus
* package_info_plus
* hive / hive_flutter
* firebase_core / firebase_messaging
* flutter_local_notifications
* dio
* path_provider
* open_filex
* permission_handler
* app_settings
* animate_do
* Maps_flutter (falls verwendet)
* geocoding (falls verwendet)
* device_info_plus (falls verwendet)
* flutter_launcher_icons
* cupertino_icons

---

## 📸 Screenshots

<p float="left">
  <img src="screenshots/screenshot_home.png" width="250" alt="Screenshot Startseite" />
  <img src="screenshots/screenshot_events.png" width="250" alt="Screenshot Events" />
  <img src="screenshots/screenshot_event_details.png" width="250" alt="Screenshot Event Details" />
  <img src="screenshots/screenshot_favorites.png" width="250" alt="Screenshot Favoriten" />
  </p>
---

## ⚙️ Setup und Ausführung

Um das Projekt lokal einzurichten und auszuführen:

1.  Klone das Repository: `git clone https://udevsharold.github.io/repo/`
2.  Navigiere in das Projektverzeichnis: `cd uccelli_info_app`
3.  Hole die Abhängigkeiten: `flutter pub get`
4.  Stelle sicher, dass ein Android- oder iOS-Gerät verbunden ist oder ein Emulator läuft.
5.  Starte die App: `flutter run`

*Hinweis:* Für bestimmte Funktionen wie Firebase-Push-Benachrichtigungen und Google Maps musst du möglicherweise eine eigene Firebase-Projektkonfiguration (`google-services.json` für Android, `GoogleService-Info.plist` für iOS) und API-Schlüssel einrichten.

---

## 📄 Lizenz

Dieses Projekt ist unter der **MIT Lizenz** lizenziert – siehe die [LICENSE](LICENSE)-Datei für Details.

---

© 2025 Uccelli Society · Built with ❤️ by KamiCorp