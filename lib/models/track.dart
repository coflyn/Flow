class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String url;
  final String path;
  final List<String> lyrics;
  final int duration;

  final bool isOnline;
  final String? thumbnailUrl;
  final String? videoId;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.url,
    required this.path,
    required this.lyrics,
    required this.duration,
    this.isOnline = false,
    this.thumbnailUrl,
    this.videoId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'url': url,
      'path': path,
      'lyrics': lyrics,
      'duration': duration,
      'isOnline': isOnline,
      'thumbnailUrl': thumbnailUrl,
      'videoId': videoId,
    };
  }

  factory Track.fromMap(Map<String, dynamic> map) {
    return Track(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      album: map['album'] ?? '',
      url: map['url'] ?? '',
      path: map['path'] ?? '',
      lyrics: List<String>.from(map['lyrics'] ?? []),
      duration: map['duration'] ?? 0,
      isOnline: map['isOnline'] ?? false,
      thumbnailUrl: map['thumbnailUrl'],
      videoId: map['videoId'],
    );
  }

  Track copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? url,
    String? path,
    List<String>? lyrics,
    int? duration,
    bool? isOnline,
    String? thumbnailUrl,
    String? videoId,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      url: url ?? this.url,
      path: path ?? this.path,
      lyrics: lyrics ?? this.lyrics,
      duration: duration ?? this.duration,
      isOnline: isOnline ?? this.isOnline,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoId: videoId ?? this.videoId,
    );
  }
}
