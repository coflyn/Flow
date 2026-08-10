import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';

class ArtworkCacheManager {
  static final Map<String, Uint8List?> _memoryCache = {};
  static final OnAudioQuery _audioQuery = OnAudioQuery();
  static bool _isPreloading = false;
  static Directory? _cacheDir;

  /// Initializes the disk cache directory during main() before runApp.
  static Future<void> init() async {
    await _getCacheDir();
  }

  static Future<Directory> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final baseDir = await getApplicationSupportDirectory();
    final dir = Directory('${baseDir.path}/artwork_cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _cacheDir = dir;
    return dir;
  }

  /// Returns synchronous File if cached on disk, or null.
  static File? getDiskArtworkFile(String trackId) {
    if (_cacheDir == null) return null;
    final file = File('${_cacheDir!.path}/$trackId.jpg');
    if (file.existsSync()) {
      return file;
    }
    return null;
  }

  /// Retrieves native media store artwork from memory instantly if available.
  static Uint8List? getCachedArtwork(String trackId) {
    return _memoryCache[trackId];
  }

  /// Checks if native artwork is already cached in memory or confirmed null.
  static bool isCached(String trackId) {
    return _memoryCache.containsKey(trackId);
  }

  static final Map<String, Future<Uint8List?>> _inFlight = {};

  /// Fetches native artwork asynchronously with disk persistence and AUDIO->ALBUM fallback for M4A.
  static Future<Uint8List?> fetchAndCacheNativeArtwork(
    String trackId, {
    int? highResSize,
  }) async {
    if (_memoryCache.containsKey(trackId) && _memoryCache[trackId] != null) {
      return _memoryCache[trackId];
    }

    // Check disk cache
    final dir = await _getCacheDir();
    final diskFile = File('${dir.path}/$trackId.jpg');
    if (diskFile.existsSync()) {
      try {
        final bytes = await diskFile.readAsBytes();
        if (bytes.isNotEmpty) {
          _memoryCache[trackId] = bytes;
          return bytes;
        }
      } catch (_) {}
    }

    if (_inFlight.containsKey(trackId)) {
      return _inFlight[trackId]!;
    }

    final future = () async {
      final parsedId = int.tryParse(trackId);
      if (parsedId == null) return null;

      Uint8List? bytes;

      // 1. Try ArtworkType.AUDIO
      for (int i = 0; i < 2; i++) {
        try {
          bytes = await _audioQuery.queryArtwork(
            parsedId,
            ArtworkType.AUDIO,
            size: highResSize ?? 300,
            quality: 80,
          );
          if (bytes != null && bytes.isNotEmpty) break;
        } catch (_) {}
        if (i < 1) await Future.delayed(const Duration(milliseconds: 50));
      }

      // 2. Fallback to ArtworkType.ALBUM for M4A / AAC / non-standard MediaStore tracks
      if (bytes == null || bytes.isEmpty) {
        try {
          bytes = await _audioQuery.queryArtwork(
            parsedId,
            ArtworkType.ALBUM,
            size: highResSize ?? 300,
            quality: 80,
          );
        } catch (_) {}
      }

      if (bytes != null && bytes.isNotEmpty) {
        _memoryCache[trackId] = bytes;
        try {
          await diskFile.writeAsBytes(bytes, flush: true);
        } catch (_) {}
      } else {
        // Cache negative result so we don't spam native calls repeatedly
        _memoryCache[trackId] = Uint8List(0);
      }

      _inFlight.remove(trackId);
      return (bytes != null && bytes.isNotEmpty) ? bytes : null;
    }();

    _inFlight[trackId] = future;
    return future;
  }

  /// Silently preloads thumbnails in background
  static Future<void> preloadAllArtworks(
    List<dynamic> tracks,
    Map<String, dynamic> overrides,
  ) async {
    if (_isPreloading) return;
    _isPreloading = true;
    final dir = await _getCacheDir();

    for (final track in tracks) {
      final trackId = track.id.toString();
      final customPath = overrides[trackId]?['coverPath'];

      if (customPath != null && customPath.isNotEmpty) {
        final file = File(customPath);
        if (await file.exists()) {
          final provider = FileImage(file);
          provider.resolve(const ImageConfiguration());
        }
      } else {
        final diskFile = File('${dir.path}/$trackId.jpg');
        if (!diskFile.existsSync() && !_memoryCache.containsKey(trackId)) {
          await fetchAndCacheNativeArtwork(trackId);
        }
      }

      await Future.delayed(const Duration(milliseconds: 2));
    }

    _isPreloading = false;
  }
}
