// lib/services/update_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class GitHubRelease {
  final String tagName;
  final String downloadUrl;

  GitHubRelease({
    required this.tagName,
    required this.downloadUrl,
  });

  /// Fetch the latest release metadata from GitHub
  static Future<GitHubRelease?> fetchLatest() async {
    final uri = Uri.parse(
      'https://api.github.com/repos/KarmaKami994/uccelli_InfoApp/releases/latest',
    );
    final resp = await http.get(uri);
    if (resp.statusCode != 200) return null;

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final tagName = json['tag_name'] as String;
    final assets = (json['assets'] as List<dynamic>);
    final apkAsset = assets.firstWhere(
      (a) => (a['name'] as String).endsWith('.apk'),
      orElse: () => null,
    );
    if (apkAsset == null) return null;

    return GitHubRelease(
      tagName: tagName,
      downloadUrl: apkAsset['browser_download_url'] as String,
    );
  }

  /// Downloads the APK, reporting progress 0.0→1.0, and returns the local path
  Future<String?> downloadApk({
    required void Function(double progress) onProgress,
  }) async {
    final uri = Uri.parse(downloadUrl);
    final client = HttpClient();
    final req = await client.getUrl(uri);
    final res = await req.close();
    if (res.statusCode != 200) return null;

    final contentLength = res.contentLength;
    var received = 0;
    final bytes = <int>[];

    await for (var chunk in res) {
      bytes.addAll(chunk);
      received += chunk.length;
      onProgress(received / contentLength);
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/update.apk');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
