import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/track.dart';

class InnerTubeService {
  static final InnerTubeService _instance = InnerTubeService._internal();
  factory InnerTubeService() => _instance;
  InnerTubeService._internal();

  YoutubeExplode? _yt;
  final Map<String, String> _cachePaths = {};

  YoutubeExplode get yt {
    _yt ??= YoutubeExplode();
    return _yt!;
  }

  Future<String?> getAudioStreamFilePath(String videoId) async {
    try {
      if (_cachePaths.containsKey(videoId)) {
        final existing = File(_cachePaths[videoId]!);
        if (await existing.exists() && (await existing.length()) > 50 * 1024) {
          return existing.path;
        }
      }

      final tempDir = await getTemporaryDirectory();
      final cacheFile = File('${tempDir.path}/yt_$videoId.m4a');

      if (await cacheFile.exists() && (await cacheFile.length()) > 50 * 1024) {
        _cachePaths[videoId] = cacheFile.path;
        return cacheFile.path;
      }

      StreamManifest manifest;
      try {
        manifest = await yt.videos.streamsClient.getManifest(
          videoId,
          ytClients: [YoutubeApiClient.androidVr],
        );
      } catch (_) {
        manifest = await yt.videos.streamsClient.getManifest(videoId);
      }

      final audioStreams = manifest.audioOnly;
      if (audioStreams.isEmpty) return null;

      final mp4Streams = audioStreams
          .where((s) => s.container.name.toLowerCase() == 'mp4')
          .toList();
      final streamInfo = mp4Streams.isNotEmpty
          ? mp4Streams.withHighestBitrate()
          : audioStreams.withHighestBitrate();

      final stream = yt.videos.streamsClient.get(streamInfo);
      final fileSink = cacheFile.openWrite();

      final completer = Completer<void>();
      int bytesWritten = 0;
      bool isReadyToPlay = false;

      stream.listen(
        (chunk) {
          fileSink.add(chunk);
          bytesWritten += chunk.length;
          if (!isReadyToPlay && bytesWritten >= 100 * 1024) {
            isReadyToPlay = true;
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        },
        onDone: () async {
          await fileSink.flush();
          await fileSink.close();
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onError: (e) async {
          await fileSink.close();
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        },
        cancelOnError: false,
      );

      await completer.future;
      _cachePaths[videoId] = cacheFile.path;
      return cacheFile.path;
    } catch (e) {
      return null;
    }
  }

  /// Search YouTube / YouTube Music for tracks matching [query].
  Future<List<Track>> searchTracks(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final searchList = await yt.search.search(query);
      final tracks = <Track>[];

      for (final video in searchList) {
        final videoId = video.id.value;
        final thumbUrl = video.thumbnails.highResUrl.isNotEmpty
            ? video.thumbnails.highResUrl
            : video.thumbnails.mediumResUrl;

        tracks.add(
          Track(
            id: 'yt_$videoId',
            title: video.title,
            artist: video.author,
            album: 'YouTube Music',
            url: video.url,
            path: 'youtube:$videoId',
            lyrics: const [],
            duration: video.duration?.inMilliseconds ?? 0,
            isOnline: true,
            thumbnailUrl: thumbUrl,
            videoId: videoId,
          ),
        );
      }
      return tracks;
    } catch (e) {
      return [];
    }
  }

  /// Resolves the local disk path for [videoId].
  Future<String?> getAudioStreamUrl(String videoId) async {
    return getAudioStreamFilePath(videoId);
  }

  /// Fetches synced or plain lyrics for an online track via LRCLIB public API.
  Future<List<String>> fetchOnlineLyrics(String title, String artist) async {
    try {
      final cleanTitle = Uri.encodeComponent(title);
      final cleanArtist = Uri.encodeComponent(artist);
      final url = Uri.parse(
        'https://lrclib.net/api/get?track_name=$cleanTitle&artist_name=$cleanArtist',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final synced = data['syncedLyrics'] as String?;
        if (synced != null && synced.trim().isNotEmpty) {
          return synced.split('\n');
        }
        final plain = data['plainLyrics'] as String?;
        if (plain != null && plain.trim().isNotEmpty) {
          return plain.split('\n');
        }
      }

      // Search fallback if direct match didn't return
      final searchUrl = Uri.parse(
        'https://lrclib.net/api/search?q=${Uri.encodeComponent("$title $artist")} ',
      );
      final searchResp = await http
          .get(searchUrl)
          .timeout(const Duration(seconds: 5));
      if (searchResp.statusCode == 200) {
        final results = jsonDecode(searchResp.body) as List<dynamic>;
        if (results.isNotEmpty) {
          final first = results.first;
          final synced = first['syncedLyrics'] as String?;
          if (synced != null && synced.trim().isNotEmpty) {
            return synced.split('\n');
          }
          final plain = first['plainLyrics'] as String?;
          if (plain != null && plain.trim().isNotEmpty) {
            return plain.split('\n');
          }
        }
      }
    } catch (_) {}
    return const [];
  }

  void dispose() {
    _yt?.close();
    _yt = null;
  }
}
