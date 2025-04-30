// lib/services/post_cache_service.dart

import 'package:hive_flutter/hive_flutter.dart';

class PostCacheService {
  static const String postsBoxName = "postsBox";

  Box get postsBox => Hive.box(postsBoxName);

  Future<void> savePosts(List<dynamic> posts) async {
    await postsBox.put('cachedPosts', posts);
  }

  List<dynamic>? loadPosts() {
    return postsBox.get('cachedPosts') as List<dynamic>?;
  }
}
