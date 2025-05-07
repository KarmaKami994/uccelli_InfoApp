// lib/pages/splash_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:open_file/open_file.dart';

import 'home_page.dart';
import 'package:uccelli_info_app/services/update_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _checkingUpdate = true;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _startUpSequence();
  }

  Future<void> _startUpSequence() async {
    // Keep splash for at least 1s
    await Future.delayed(const Duration(seconds: 1));

    // Check GitHub for latest release
    final latest = await GitHubRelease.fetchLatest();
    final pkg = await PackageInfo.fromPlatform();
    final currentVersion = pkg.version; // e.g. "1.0.0"

    if (latest != null && _isNewer(latest.tagName, currentVersion)) {
      _promptUpdate(latest);
    } else {
      _goHome();
    }
  }

  bool _isNewer(String remoteTag, String localVersion) {
    final remote = remoteTag.startsWith('v') ? remoteTag.substring(1) : remoteTag;
    final rParts = remote.split('.').map(int.parse).toList();
    final lParts = localVersion.split('.').map(int.parse).toList();
    for (var i = 0; i < rParts.length; i++) {
      final r = rParts[i];
      final l = i < lParts.length ? lParts[i] : 0;
      if (r > l) return true;
      if (r < l) return false;
    }
    return false;
  }

  void _promptUpdate(GitHubRelease latest) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Update Available'),
            content: _checkingUpdate
                ? const Text('A new version is available. Download now?')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Downloading update...'),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: _downloadProgress),
                    ],
                  ),
            actions: [
              if (_checkingUpdate) ...[
                TextButton(
                  onPressed: _goHome,
                  child: const Text('Later'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() => _checkingUpdate = false);
                    final apkPath = await latest.downloadApk(
                      onProgress: (p) => setState(() => _downloadProgress = p),
                    );
                    if (apkPath != null) {
                      await OpenFile.open(apkPath);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Download failed')),
                      );
                      _goHome();
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final logoPath = brightness == Brightness.dark
        ? 'lib/assets/images/Logo_Uccelli_Quer_Negativ.png'
        : 'lib/assets/images/Logo_Uccelli_Quer_Positiv.png';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(child: Image.asset(logoPath, width: 180)),
    );
  }
}
