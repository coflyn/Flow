import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/track.dart';

class InnerTubeService {
  static final InnerTubeService _instance = InnerTubeService._internal();
  factory InnerTubeService() => _instance;
  InnerTubeService._internal();

  YoutubeExplode? _yt;
  final Map<String, String> _cachePaths = {};

  /// Saves a played online track to local history (max 50 tracks).
  Future<void> saveOnlineTrackToHistory(Track track) async {
    if (!track.isOnline) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList('yt_online_history') ?? [];
      final List<Map<String, dynamic>> historyMaps = [];

      for (final jsonStr in raw) {
        try {
          historyMaps.add(jsonDecode(jsonStr) as Map<String, dynamic>);
        } catch (_) {}
      }

      historyMaps.removeWhere(
        (m) =>
            m['id'] == track.id ||
            (track.videoId != null && m['videoId'] == track.videoId),
      );

      historyMaps.insert(0, track.toMap());

      if (historyMaps.length > 50) {
        historyMaps.removeRange(50, historyMaps.length);
      }

      final encoded = historyMaps.map((m) => jsonEncode(m)).toList();
      await prefs.setStringList('yt_online_history', encoded);
    } catch (_) {}
  }

  /// Retrieves the saved online tracks history.
  Future<List<Track>> getOnlineTrackHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList('yt_online_history') ?? [];
      final tracks = <Track>[];

      for (final jsonStr in raw) {
        try {
          final map = jsonDecode(jsonStr) as Map<String, dynamic>;
          tracks.add(Track.fromMap(map));
        } catch (_) {}
      }

      return tracks;
    } catch (_) {
      return [];
    }
  }

  /// Removes an online track from history AND deletes its cached temporary audio file.
  Future<void> removeOnlineTrackFromHistory(Track track) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList('yt_online_history') ?? [];
      final List<Map<String, dynamic>> historyMaps = [];

      for (final jsonStr in raw) {
        try {
          historyMaps.add(jsonDecode(jsonStr) as Map<String, dynamic>);
        } catch (_) {}
      }

      final targetVId = track.videoId ?? track.id;
      historyMaps.removeWhere(
        (m) =>
            m['id'] == track.id ||
            m['id'] == targetVId ||
            m['videoId'] == targetVId,
      );

      final encoded = historyMaps.map((m) => jsonEncode(m)).toList();
      await prefs.setStringList('yt_online_history', encoded);

      final tempDir = await getTemporaryDirectory();
      final cacheFile = File('${tempDir.path}/yt_$targetVId.m4a');
      if (await cacheFile.exists()) {
        await cacheFile.delete();
      }
      _cachePaths.remove(targetVId);
    } catch (_) {}
  }

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

      // Automatically prune oldest cache files if cache exceeds 50 items
      _pruneAudioCacheIfNeeded();

      return cacheFile.path;
    } catch (e) {
      return null;
    }
  }

  /// Prunes old temporary audio cache files to keep cache clean (max 50 files).
  static Future<void> _pruneAudioCacheIfNeeded() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.contains('yt_') && f.path.endsWith('.m4a'))
          .toList();

      if (files.length <= 50) return;

      // Sort by last modified date (oldest first)
      files.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));

      // Keep 30 most recent files, delete oldest
      for (int i = 0; i < files.length - 30; i++) {
        try {
          if (await files[i].exists()) {
            await files[i].delete();
          }
        } catch (_) {}
      }
    } catch (_) {}
  }

  /// Clean YouTube video titles and author names using Regex.
  static Map<String, String> cleanYouTubeTitleAndArtist(
    String rawTitle,
    String rawAuthor,
  ) {
    String title = rawTitle;
    String artist = rawAuthor;

    // 1. Clean channel/author name
    artist = artist
        .replaceAll(RegExp(r'\s*-\s*Topic$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*VEVO$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*Official$', caseSensitive: false), '')
        .trim();

    // 2. Parse "Artist - Title" or "Title - Artist" from raw title if present
    final separatorMatch = RegExp(
      r'^(.+?)\s*[\-\–\—\|]\s*(.+)$',
    ).firstMatch(title);
    if (separatorMatch != null) {
      final part1 = separatorMatch.group(1)!.trim();
      final part2 = separatorMatch.group(2)!.trim();

      final cleanAuthorLower = artist.toLowerCase();
      final part2CleanLower = part2
          .replaceAll(RegExp(r'[\(\[\{].*[\)\]\}]'), '')
          .trim()
          .toLowerCase();

      // If part2 matches the author/channel name, pattern is "Title - Artist"
      if (part2CleanLower == cleanAuthorLower ||
          cleanAuthorLower.contains(part2CleanLower)) {
        title = part1;
        artist = part2;
      } else {
        // Pattern: "Artist - Title"
        artist = part1;
        title = part2;
      }
    }

    // 3. Remove common YouTube clutter tags from title
    final clutterRegex = RegExp(
      r'[\(\[\{]\s*(?:official\s*(?:music\s*)?(?:video|audio|lyric\s*video|visualizer|mv)?|lyric(?:s)?|audio|video|hd|4k|mv|remastered(?:\s*\d{4})?|full\s*song)\s*[\)\]\}]|(?:\s*[\-\|]\s*)?(?:official\s*(?:music\s*)?(?:video|audio|lyric\s*video)|lyric\s*video|visualizer)\b',
      caseSensitive: false,
    );

    title = title.replaceAll(clutterRegex, '').trim();
    title = title.replaceAll(RegExp(r'^[\-\–\—\|\s]+|[\-\–\—\|\s]+$'), '').trim();

    if (title.isEmpty) title = rawTitle;
    if (artist.isEmpty) artist = rawAuthor;

    return {'title': title, 'artist': artist};
  }

  /// Fetches a list of trending / random popular tracks for empty search state.
  Future<List<Track>> fetchTrendingOrRandomTracks() async {
    final queries = [
      'Trending Music',
      'Top Hits 2026',
      'Global Top 50',
      'Popular Pop Songs',
      'Indonesian Top Hits',
      'Best Acoustic Hits',
      'Chill Lofi Beats',
    ];
    final startIndex =
        DateTime.now().millisecondsSinceEpoch % queries.length;

    for (int i = 0; i < queries.length; i++) {
      final query = queries[(startIndex + i) % queries.length];
      final results = await searchTracks(query);
      if (results.isNotEmpty) {
        return results;
      }
    }
    return const [];
  }

  static final Map<String, Map<String, String>> _officialMetadataCache = {};

  /// Asynchronously fetches 600x600 HD square album art & official album name via iTunes API.
  Future<Map<String, String>?> fetchOfficialSongArtworkAndAlbum(
    String title,
    String artist,
  ) async {
    final cacheKey = '$artist - $title'.toLowerCase();
    if (_officialMetadataCache.containsKey(cacheKey)) {
      return _officialMetadataCache[cacheKey];
    }
    try {
      final term = Uri.encodeComponent('$artist $title');
      final url = Uri.parse(
        'https://itunes.apple.com/search?term=$term&entity=song&limit=1',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final first = results.first as Map<String, dynamic>;
          final rawArtwork = first['artworkUrl100'] as String?;
          final albumName = first['collectionName'] as String?;
          if (rawArtwork != null && rawArtwork.isNotEmpty) {
            final hdArtwork = rawArtwork.replaceAll('100x100bb', '600x600bb');
            final metadata = {
              'artworkUrl': hdArtwork,
              'album': albumName ?? 'YouTube Music',
            };
            _officialMetadataCache[cacheKey] = metadata;
            return metadata;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  static int _getChannelPriorityScore(
    String author,
    String title,
    String query,
  ) {
    final authorLower = author.toLowerCase();
    final titleLower = title.toLowerCase();
    final queryLower = query.toLowerCase();

    int score = 0;

    // 1. Highest priority: Topic channels (Official record label uploads)
    if (authorLower.endsWith('- topic') || authorLower.contains('topic')) {
      score += 100;
    }

    // 2. High priority: VEVO or Official Artist Channels
    if (authorLower.contains('vevo') || authorLower.contains('official')) {
      score += 80;
    }

    // 3. High priority: Author name matches query keywords
    final queryWords = queryLower.split(' ').where((w) => w.length > 2);
    for (final word in queryWords) {
      if (authorLower.contains(word)) {
        score += 40;
      }
    }

    // 4. Video title has "Official Audio" or "Official Video"
    if (titleLower.contains('official audio') ||
        titleLower.contains('official music video') ||
        titleLower.contains('official video')) {
      score += 50;
    }

    // 5. Penalty for generic fan/lyric re-upload channels
    if (authorLower.contains('chaos') ||
        authorLower.contains('lyrics') ||
        authorLower.contains('sounds') ||
        authorLower.contains('wav')) {
      score -= 30;
    }

    return score;
  }

  /// Search YouTube / YouTube Music for tracks matching [query].
  Future<List<Track>> searchTracks(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    try {
      String searchQuery = trimmed;
      final lower = trimmed.toLowerCase();
      if (!lower.contains('official') &&
          !lower.contains('audio') &&
          !lower.contains('song') &&
          !lower.contains('music')) {
        searchQuery = '$trimmed music';
      }

      dynamic searchList;
      try {
        searchList = await yt.search
            .search(searchQuery)
            .timeout(const Duration(seconds: 6));
      } catch (_) {}

      // Fallback search without 'music' suffix if primary search returned empty/failed
      if (searchList == null || searchList.isEmpty) {
        try {
          searchList = await yt.search
              .search(trimmed)
              .timeout(const Duration(seconds: 6));
        } catch (_) {}
      }

      if (searchList == null || searchList.isEmpty) return [];

      // Sort candidate videos by Channel Priority Score (Topic / Official > Fan re-uploads)
      final candidateList = List.from(searchList);
      candidateList.sort((a, b) {
        final scoreA = _getChannelPriorityScore(a.author, a.title, query);
        final scoreB = _getChannelPriorityScore(b.author, b.title, query);
        return scoreB.compareTo(scoreA);
      });

      final tracks = <Track>[];
      final seenKeys = <String>{};

      final noiseRegex = RegExp(
        r'\b(karaoke|slowed|reverb|subtitulado|tiktok|instrumental|pmv|nightcore|1\s*hour|10\s*hour|loop|demo|fan\s*animation|edit|reaction|review|tutorial|how\s*to|cover|drumless|bass\s*boosted)\b',
        caseSensitive: false,
      );

      for (final video in candidateList) {
        // Skip non-music video clutter (e.g. videos > 15 mins like compilations or 10hr loops)
        if (video.duration != null && video.duration!.inMinutes > 15) {
          continue;
        }

        final rawTitleLower = video.title.toLowerCase();

        // Skip noise/clutter videos if query itself didn't ask for them
        if (!lower.contains('slowed') &&
            !lower.contains('reverb') &&
            !lower.contains('karaoke') &&
            !lower.contains('cover') &&
            noiseRegex.hasMatch(rawTitleLower)) {
          continue;
        }

        final videoId = video.id.value;
        final cleaned = cleanYouTubeTitleAndArtist(video.title, video.author);

        final key =
            '${cleaned['artist']!.toLowerCase()} - ${cleaned['title']!.toLowerCase()}';

        // Deduplicate duplicate song entries from fan re-upload channels!
        if (seenKeys.contains(key)) {
          continue;
        }
        seenKeys.add(key);

        // High-res YouTube thumbnail URL fallback (1280x720)
        String thumbUrl = 'https://i.ytimg.com/vi/$videoId/maxresdefault.jpg';

        tracks.add(
          Track(
            id: 'yt_$videoId',
            title: cleaned['title']!,
            artist: cleaned['artist']!,
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

        if (tracks.length >= 25) break;
      }

      // Fast non-blocking parallel enrichment with short 1.5s timeout per track
      final enhancedTracks = await Future.wait(
        tracks.map((track) async {
          try {
            final official = await fetchOfficialSongArtworkAndAlbum(
              track.title,
              track.artist,
            ).timeout(const Duration(milliseconds: 1500));
            if (official != null) {
              return track.copyWith(
                thumbnailUrl: official['artworkUrl'],
                album: official['album'],
              );
            }
          } catch (_) {}
          return track;
        }),
      );

      return enhancedTracks;
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
