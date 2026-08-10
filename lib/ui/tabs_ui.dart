// ignore_for_file: invalid_use_of_protected_member
part of '../main.dart';

extension _TabsUI on _MainScreenState {
  Widget _buildBodyContent() {
    if (_allTracks.isEmpty) {
      return _buildEmptyState();
    }

    final isDetailView =
        (_currentPageIndex == 1 && _selectedPlaylistDetail != null) ||
        (_currentPageIndex == 2 && _selectedArtistDetail != null) ||
        (_currentPageIndex == 3 && _selectedAlbumDetail != null);

    return PageView(
      controller: _pageController,
      physics: isDetailView
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      onPageChanged: (index) {
        setState(() {
          _currentPageIndex = index;
        });
      },
      children: [
        _KeepAliveWrapper(child: _buildSongsTab()),
        _KeepAliveWrapper(child: _buildPlaylistsTab()),
        _KeepAliveWrapper(child: _buildArtistsTab()),
        _KeepAliveWrapper(child: _buildAlbumsTab()),
      ],
    );
  }

  Widget _buildSongsTab() {
    final key = "songs_${_searchSourceIndex}_$_songsAnimToken";
    final bool shouldAnimate = !_visitedTabKeys.contains(key);
    if (shouldAnimate) {
      _visitedTabKeys.add(key);
    }

    if (_searchSourceIndex == 1) {
      if (_isOnlineSearching) {
        return _buildOnlineHomeSkeleton();
      }
      if (!_isOnlineContentLoaded &&
          _onlineSearchResults.isEmpty &&
          _onlineQuickPicks.isEmpty) {
        if (_searchQuery.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_isOnlineSearching && !_isOnlineContentLoaded) {
              _loadOnlineTabInitialContent();
            }
          });
        }
        return _buildOnlineHomeSkeleton();
      }

      if (_searchQuery.isEmpty) {
        return _FadeInSlideUp(
          key: ValueKey(key),
          animate: shouldAnimate,
          delay: Duration.zero,
          child: _buildOnlineHomeView(),
        );
      }

      return _buildSongList(
        _onlineSearchResults,
        fullQueueList: _onlineSearchResults,
      );
    }

    if (_memoSongsSorted == null ||
        _memoSongsSortBy != _sortBy ||
        _memoSongsSearchQuery != _searchQuery ||
        _memoSongsAllTracksLen != _allTracks.length) {
      List<Track> allSorted = List<Track>.from(_allTracks);

      if (_sortBy == 'title') {
        allSorted.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      } else if (_sortBy == 'artist') {
        allSorted.sort(
          (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
        );
      } else if (_sortBy == 'album') {
        allSorted.sort(
          (a, b) => a.album.toLowerCase().compareTo(b.album.toLowerCase()),
        );
      } else if (_sortBy == 'date_oldest') {
        allSorted = allSorted.reversed.toList();
      } else if (_sortBy == 'duration_longest') {
        allSorted.sort((a, b) => b.duration.compareTo(a.duration));
      } else if (_sortBy == 'duration_shortest') {
        allSorted.sort((a, b) => a.duration.compareTo(b.duration));
      }

      List<Track> displayed = allSorted;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        displayed = allSorted
            .where(
              (t) =>
                  t.title.toLowerCase().contains(q) ||
                  t.artist.toLowerCase().contains(q) ||
                  t.album.toLowerCase().contains(q),
            )
            .toList();
      }

      _memoSongsSorted = allSorted;
      _memoSongsDisplayed = displayed;
      _memoSongsSortBy = _sortBy;
      _memoSongsSearchQuery = _searchQuery;
      _memoSongsAllTracksLen = _allTracks.length;
    }

    return _FadeInSlideUp(
      key: ValueKey(key),
      animate: shouldAnimate,
      delay: Duration.zero,
      child: _buildSongList(
        _memoSongsDisplayed!,
        fullQueueList: _searchQuery.isNotEmpty ? _memoSongsSorted : null,
      ),
    );
  }

  Widget _buildPlaylistsTab() {
    final key = "playlists_${_searchSourceIndex}_$_playlistsAnimToken";
    final bool shouldAnimateTab = !_visitedTabKeys.contains(key);
    if (shouldAnimateTab) {
      _visitedTabKeys.add(key);
    }

    if (_searchSourceIndex == 1) {
      return _FadeInSlideUp(
        key: ValueKey(key),
        animate: shouldAnimateTab,
        delay: Duration.zero,
        child: _buildOnlinePlaylistsView(),
      );
    }

    final favorites = _allTracks
        .where((t) => _favoriteTrackIds.contains(t.id))
        .toList();
    final recentlyAdded = List<Track>.from(_allTracks);
    final trackMap = {for (var t in _allTracks) t.id: t};
    final lastPlayed = _allPlayedTrackIdsOrdered
        .where((id) => trackMap.containsKey(id))
        .map((id) => trackMap[id]!)
        .toList();
    var mostPlayed = List<Track>.from(_allTracks);
    mostPlayed.sort(
      (a, b) => (_playCounts[b.id] ?? 0).compareTo(_playCounts[a.id] ?? 0),
    );
    mostPlayed = mostPlayed.where((t) => (_playCounts[t.id] ?? 0) > 0).toList();
    final forgottenGems = _allTracks.reversed
        .where((t) => (_playCounts[t.id] ?? 0) <= 1)
        .toList();

    final children = [
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _activeAccentColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.add, color: _activeAccentColor),
        ),
        title: Text(
          AppLocalizations.of(context).createNewPlaylist,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _activeAccentColor,
          ),
        ),
        onTap: () => _showCreatePlaylistModal(context),
      ),
      _buildPlaylistCard(
        AppLocalizations.of(context).favourites,
        favorites,
        const Color(0xFFE91E63),
        Icons.favorite,
      ),
      _buildPlaylistCard(
        AppLocalizations.of(context).recentlyAdded,
        recentlyAdded,
        const Color(0xFF2196F3),
        Icons.new_releases,
      ),
      _buildPlaylistCard(
        AppLocalizations.of(context).lastPlayed,
        lastPlayed,
        const Color(0xFFFF9800),
        Icons.history,
      ),
      _buildPlaylistCard(
        AppLocalizations.of(context).mostPlayed,
        mostPlayed,
        const Color(0xFFF44336),
        Icons.local_fire_department,
      ),
      _buildPlaylistCard(
        AppLocalizations.of(context).forgottenGems,
        forgottenGems,
        const Color(0xFF9C27B0),
        Icons.diamond_outlined,
      ),
      if (_userPlaylists.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8, left: 8),
          child: Text(
            AppLocalizations.of(context).myPlaylists,
            style: TextStyle(
              color: isAppLight ? const Color(0xFF1A1A1A) : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ..._userPlaylists.entries.map((entry) {
        final songs = _allTracks
            .where((t) => entry.value.contains(t.id))
            .toList();
        return _buildPlaylistCard(
          entry.key,
          songs,
          const Color(0xFF9C27B0),
          Icons.queue_music,
        );
      }),
    ];

    return _FadeInSlideUp(
      key: ValueKey(key),
      animate: shouldAnimateTab,
      delay: Duration.zero,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: _playingTrack != null ? 84 : 12,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) {
          final keyStr = "playlist_$index";
          final shouldAnimate = !_animatedPlaylistIds.contains(keyStr);
          final count = _animatedPlaylistIds.length;
          final staggerIndex = count < 8 ? count : 0;
          if (shouldAnimate) {
            _animatedPlaylistIds.add(keyStr);
          }
          return _FadeInSlideUp(
            animate: shouldAnimate,
            delay: Duration(milliseconds: staggerIndex * 35),
            child: children[index],
          );
        },
      ),
    );
  }

  Future<void> _loadOnlinePlaylistsTabContent() async {
    if (_isOnlinePlaylistsLoaded) return;
    _isOnlinePlaylistsSearching = true;

    final cachedTrending = await InnerTubeService()
        .getOnlineTrendingPlaylistsCache();
    if (cachedTrending.isNotEmpty && mounted) {
      _onlineTrendingPlaylists = cachedTrending;
    }

    try {
      final trending = await InnerTubeService().fetchTrendingPlaylists();
      if (trending.isNotEmpty) {
        InnerTubeService().saveOnlineTrendingPlaylistsCache(trending);
        _onlineTrendingPlaylists = trending;
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _isOnlinePlaylistsLoaded = true;
          _isOnlinePlaylistsSearching = false;
        });
      }
    }
  }

  Future<void> _fetchAndShowOnlinePlaylistDetails(
    String playlistId,
    String playlistTitle, {
    bool isImport = false,
  }) async {
    final cachedTracks =
        _onlinePlaylistTracks[playlistId] ??
        _onlinePlaylistTracks[playlistTitle] ??
        _userOnlinePlaylists[playlistTitle] ??
        _userOnlinePlaylists[playlistId];

    if (cachedTracks != null && cachedTracks.isNotEmpty) {
      setState(() {
        _cachedDetailKey = null;
        _selectedPlaylistDetail = playlistTitle;
        _selectedPlaylistIsOnline = true;
        _searchQuery = '';
        _searchController.clear();
        _detailColorFuture = _getDetailColor(
          cachedTracks.first,
          playlistName: playlistTitle,
        );
      });
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isAppLight ? Colors.white : const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: _activeAccentColor),
                const SizedBox(height: 16),
                Text(
                  'Loading Playlist...',
                  style: TextStyle(
                    color: isAppLight ? Colors.black87 : Colors.white70,
                    fontSize: 14,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final details = await InnerTubeService().fetchOnlinePlaylistDetails(
        playlistId,
        defaultTitle: playlistTitle,
      );
      final finalTitle = details['title'] as String;
      final tracks = details['tracks'] as List<Track>;

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        if (tracks.isNotEmpty) {
          setState(() {
            _cachedDetailKey = null;
            _onlinePlaylistTracks[playlistId] = tracks;
            _onlinePlaylistTracks[playlistTitle] = tracks;
            _onlinePlaylistTracks[finalTitle] = tracks;
            if (isImport) {
              _userOnlinePlaylists[finalTitle] = tracks;
              _userOnlinePlaylists[playlistTitle] = tracks;
              _userOnlinePlaylists[playlistId] = tracks;
              InnerTubeService().saveUserOnlinePlaylists(_userOnlinePlaylists);
              showFlowToast('Playlist "$finalTitle" imported to My Playlists');
            }
            InnerTubeService().saveOnlinePlaylistTracksCache(
              _onlinePlaylistTracks,
            );
            _selectedPlaylistDetail = finalTitle;
            _selectedPlaylistIsOnline = true;
            _searchQuery = '';
            _searchController.clear();
            _detailColorFuture = _getDetailColor(
              tracks.first,
              playlistName: finalTitle,
            );
          });
        } else {
          showFlowToast('Failed to load playlist tracks');
        }
      }
    } catch (_) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        showFlowToast('Failed to load playlist');
      }
    }
  }

  Widget _buildOnlinePlaylistsView() {
    final isLight = isAppLight;
    final textColor = isLight ? const Color(0xFF1A1A1A) : Colors.white;
    final subtextColor = isLight ? Colors.black54 : Colors.white54;

    if (!_isOnlinePlaylistsLoaded) {
      if (!_isOnlinePlaylistsSearching) {
        _loadOnlinePlaylistsTabContent();
      }
      return _buildOnlinePlaylistsSkeleton();
    }

    final onlineFavorites = _onlineFavoriteTracks;
    final onlineLastPlayed = _onlineHistoryTracks;
    final List<Track> rawOnlineMostPlayed = List.from(_onlineHistoryTracks);
    rawOnlineMostPlayed.sort(
      (a, b) => (_playCounts[b.id] ?? _playCounts[b.videoId] ?? 0).compareTo(
        _playCounts[a.id] ?? _playCounts[a.videoId] ?? 0,
      ),
    );
    final onlineMostPlayed = rawOnlineMostPlayed
        .where((t) => (_playCounts[t.id] ?? _playCounts[t.videoId] ?? 0) > 0)
        .toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: 16,
        bottom: _playingTrack != null ? 84 : 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Trending Community Playlists Carousel
          if (_onlineTrendingPlaylists.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Trending Playlists',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: _onlineTrendingPlaylists.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final item = _onlineTrendingPlaylists[index];
                  final title = item['title'] as String? ?? 'Playlist';
                  final author = item['author'] as String? ?? 'YouTube Music';
                  final thumb = item['thumbnailUrl'] as String? ?? '';
                  final count = item['videoCount'] as int? ?? 0;

                  return GestureDetector(
                    onTap: () => _fetchAndShowOnlinePlaylistDetails(
                      item['id'] as String,
                      title,
                    ),
                    child: SizedBox(
                      width: 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isLight ? Colors.black12 : Colors.white12,
                              image: thumb.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(thumb),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: thumb.isEmpty
                                ? const Icon(
                                    Icons.playlist_play_rounded,
                                    size: 48,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$count tracks • $author',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: subtextColor),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 2. Create / Import Online Playlist Action Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showCreateOnlinePlaylistModal(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _activeAccentColor.withValues(alpha: 0.22),
                            _activeAccentColor.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _activeAccentColor.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _activeAccentColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'New Playlist',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showImportOnlinePlaylistModal(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _activeAccentColor.withValues(alpha: 0.22),
                            _activeAccentColor.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _activeAccentColor.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _activeAccentColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.link_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'Import URL',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Online Smart Playlists & User Playlists
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isOnlineContentLoaded &&
                    _onlineHistoryTracks.isEmpty &&
                    _onlineFavoriteTracks.isEmpty) ...[
                  for (int i = 0; i < 3; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const _SkeletonBox(
                            width: 48,
                            height: 48,
                            borderRadius: 24,
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              _SkeletonBox(
                                width: 140,
                                height: 14,
                                borderRadius: 4,
                              ),
                              SizedBox(height: 6),
                              _SkeletonBox(
                                width: 80,
                                height: 12,
                                borderRadius: 4,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ] else ...[
                  _buildPlaylistCard(
                    AppLocalizations.of(context).favourites,
                    onlineFavorites,
                    const Color(0xFFE91E63),
                    Icons.favorite,
                    isOnline: true,
                  ),
                  _buildPlaylistCard(
                    'Recently Played',
                    onlineLastPlayed,
                    const Color(0xFFFF9800),
                    Icons.history,
                    isOnline: true,
                  ),
                  _buildPlaylistCard(
                    AppLocalizations.of(context).mostPlayed,
                    onlineMostPlayed,
                    const Color(0xFFF44336),
                    Icons.local_fire_department,
                    isOnline: true,
                  ),
                ],
                if (_userOnlinePlaylists.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Text(
                      'My Playlists',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  ..._userOnlinePlaylists.entries.map(
                    (entry) => _buildPlaylistCard(
                      entry.key,
                      entry.value,
                      _activeAccentColor,
                      Icons.queue_music,
                      isOnline: true,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateOnlinePlaylistModal(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Online Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Playlist Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx);
                setState(() {
                  _userOnlinePlaylists[name] = [];
                });
                InnerTubeService().saveUserOnlinePlaylists(
                  _userOnlinePlaylists,
                );
                showFlowToast('Playlist "$name" created');
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showImportOnlinePlaylistModal(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Paste YouTube Music Playlist Link / ID',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final input = controller.text.trim();
              if (input.isNotEmpty) {
                Navigator.pop(ctx);
                String plId = input;
                if (input.contains('list=')) {
                  final uri = Uri.parse(input);
                  plId = uri.queryParameters['list'] ?? input;
                }
                _fetchAndShowOnlinePlaylistDetails(
                  plId,
                  'Imported Playlist',
                  isImport: true,
                );
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistsTab() {
    final key = "artists_${_searchSourceIndex}_$_artistsAnimToken";
    final bool shouldAnimateTab = !_visitedTabKeys.contains(key);
    if (shouldAnimateTab) {
      _visitedTabKeys.add(key);
    }

    final List<Track> activeTrackPool = _searchSourceIndex == 1
        ? {
            ..._onlineHistoryTracks,
            if (_playingTrack != null && _playingTrack!.isOnline)
              _playingTrack!,
          }.toList()
        : _allTracks;

    if (_searchSourceIndex == 1 && _isOnlineSearching && activeTrackPool.isEmpty) {
      return _buildOnlineArtistsSkeleton();
    }

    if (_memoArtistTracksMap == null ||
        _memoArtistPoolLen != activeTrackPool.length ||
        _memoArtistSortBy != _sortBy ||
        _memoArtistSearchQuery != _searchQuery ||
        _memoArtistSearchSource != _searchSourceIndex) {
      final Map<String, List<Track>> artistTracksMap = {};
      for (final t in activeTrackPool) {
        if (t.artist.isNotEmpty && t.artist != '<unknown>') {
          (artistTracksMap[t.artist] ??= []).add(t);
        }
      }

      final List<String> artists = [];
      final seenArtists = <String>{};

      if (_sortBy == 'date') {
        for (final t in activeTrackPool) {
          if (t.artist.isNotEmpty &&
              t.artist != '<unknown>' &&
              seenArtists.add(t.artist)) {
            artists.add(t.artist);
          }
        }
      } else if (_sortBy == 'date_oldest') {
        for (final t in activeTrackPool.reversed) {
          if (t.artist.isNotEmpty &&
              t.artist != '<unknown>' &&
              seenArtists.add(t.artist)) {
            artists.add(t.artist);
          }
        }
      } else if (_sortBy == 'duration_longest') {
        final Map<String, int> maxDuration = {};
        for (final t in activeTrackPool) {
          final current = maxDuration[t.artist] ?? 0;
          if (t.duration > current) {
            maxDuration[t.artist] = t.duration;
          }
        }
        final allUnique = artistTracksMap.keys.toList();
        allUnique.sort(
          (a, b) => (maxDuration[b] ?? 0).compareTo(maxDuration[a] ?? 0),
        );
        artists.addAll(allUnique);
      } else if (_sortBy == 'duration_shortest') {
        final Map<String, int> minDuration = {};
        for (final t in activeTrackPool) {
          final current = minDuration[t.artist] ?? 99999999;
          if (t.duration < current) {
            minDuration[t.artist] = t.duration;
          }
        }
        final allUnique = artistTracksMap.keys.toList();
        allUnique.sort(
          (a, b) => (minDuration[a] ?? 0).compareTo(minDuration[a] ?? 0),
        );
        artists.addAll(allUnique);
      } else {
        final allUnique = artistTracksMap.keys.toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        artists.addAll(allUnique);
      }

      if (_searchQuery.isNotEmpty) {
        artists.retainWhere(
          (a) => a.toLowerCase().contains(_searchQuery.toLowerCase()),
        );
      }

      final List<MapEntry<String, int>> topArtistCounts = [];
      artistTracksMap.forEach((name, tracks) {
        topArtistCounts.add(MapEntry(name, tracks.length));
      });
      topArtistCounts.sort((a, b) => b.value.compareTo(a.value));
      final topArtistsList = topArtistCounts.take(8).map((e) => e.key).toList();

      _memoArtistTracksMap = artistTracksMap;
      _memoArtistsList = artists;
      _memoTopArtistsList = topArtistsList;
      _memoArtistSortBy = _sortBy;
      _memoArtistSearchQuery = _searchQuery;
      _memoArtistPoolLen = activeTrackPool.length;
      _memoArtistSearchSource = _searchSourceIndex;
    }

    final artistTracksMap = _memoArtistTracksMap!;
    final artists = _memoArtistsList!;
    final topArtistsList = _memoTopArtistsList!;

    final isLight = isAppLight;
    final textColor = isLight ? const Color(0xFF1A1A1A) : Colors.white;
    final subtextColor = isLight ? Colors.black54 : Colors.white54;

    return _FadeInSlideUp(
      key: ValueKey(key),
      animate: shouldAnimateTab,
      delay: Duration.zero,
      child: Column(
        children: [
          // Sub-header with artist count & Grid/List layout switcher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${artists.length} ${AppLocalizations.of(context).artist}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: subtextColor,
                  ),
                ),
                const Spacer(),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        _artistViewMode = _artistViewMode == 'grid'
                            ? 'list'
                            : 'grid';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isLight
                            ? Colors.black.withValues(alpha: 0.05)
                            : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _artistViewMode == 'grid'
                            ? Icons.view_list_rounded
                            : Icons.grid_view_rounded,
                        size: 18,
                        color: _activeAccentColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Expanded Artist List/Grid Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: _playingTrack != null ? 84 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Artists Carousel (when search is empty & >= 3 top artists exist)
                  if (_searchQuery.isEmpty && topArtistsList.length >= 3) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 4,
                      ),
                      child: Text(
                        'Top Artists',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        scrollDirection: Axis.horizontal,
                        itemCount: topArtistsList.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final artistName = topArtistsList[index];
                          final artistSongs = artistTracksMap[artistName] ?? [];
                          final count = artistSongs.length;
                          final firstTrack = artistSongs.isNotEmpty
                              ? artistSongs.first
                              : Track(
                                  id: '',
                                  title: '',
                                  artist: artistName,
                                  album: '',
                                  url: '',
                                  path: '',
                                  lyrics: const [],
                                  duration: 0,
                                );

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedArtistDetail = artistName;
                                _searchQuery = '';
                                _searchController.clear();
                                _detailColorFuture = _getDetailColor(
                                  artistSongs.isNotEmpty
                                      ? artistSongs.first
                                      : null,
                                );
                              });
                            },
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _activeAccentColor.withValues(
                                        alpha: 0.6,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                  child: _buildTrackArtwork(
                                    firstTrack,
                                    size: 76,
                                    radius: 38,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: 84,
                                  child: Text(
                                    artistName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$count ${AppLocalizations.of(context).songsCount}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: subtextColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 4,
                      ),
                      child: Text(
                        'All Artists',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Grid View OR List View rendering
                  if (_artistViewMode == 'grid')
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.88,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                            ),
                        itemCount: artists.length,
                        itemBuilder: (context, index) {
                          final artist = artists[index];
                          final artistSongs = artistTracksMap[artist] ?? [];
                          final songCount = artistSongs.length;
                          final firstTrack = artistSongs.isNotEmpty
                              ? artistSongs.first
                              : Track(
                                  id: '',
                                  title: '',
                                  artist: artist,
                                  album: '',
                                  url: '',
                                  path: '',
                                  lyrics: const [],
                                  duration: 0,
                                );
                          final shouldAnimate = !_animatedArtistIds.contains(
                            artist,
                          );
                          final count = _animatedArtistIds.length;
                          final staggerIndex = count < 8 ? count : 0;
                          if (shouldAnimate) {
                            _animatedArtistIds.add(artist);
                          }

                          return _FadeInSlideUp(
                            animate: shouldAnimate,
                            delay: Duration(milliseconds: staggerIndex * 35),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedArtistDetail = artist;
                                  _searchQuery = '';
                                  _searchController.clear();
                                  _detailColorFuture = _getDetailColor(
                                    artistSongs.isNotEmpty
                                        ? artistSongs.first
                                        : null,
                                  );
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isLight
                                      ? Colors.white
                                      : const Color(0xFF1B1B1E),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isLight
                                        ? Colors.black.withValues(alpha: 0.04)
                                        : Colors.white.withValues(alpha: 0.05),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isLight ? 0.03 : 0.2,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildTrackArtwork(
                                      firstTrack,
                                      size: 92,
                                      radius: 46,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      artist,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$songCount ${AppLocalizations.of(context).songsCount}',
                                      style: TextStyle(
                                        color: subtextColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: artists.length,
                        itemBuilder: (context, index) {
                          final artist = artists[index];
                          final artistSongs = artistTracksMap[artist] ?? [];
                          final songCount = artistSongs.length;
                          final firstTrack = artistSongs.isNotEmpty
                              ? artistSongs.first
                              : Track(
                                  id: '',
                                  title: '',
                                  artist: artist,
                                  album: '',
                                  url: '',
                                  path: '',
                                  lyrics: const [],
                                  duration: 0,
                                );
                          final shouldAnimate = !_animatedArtistIds.contains(
                            artist,
                          );
                          final count = _animatedArtistIds.length;
                          final staggerIndex = count < 8 ? count : 0;
                          if (shouldAnimate) {
                            _animatedArtistIds.add(artist);
                          }

                          return _FadeInSlideUp(
                            animate: shouldAnimate,
                            delay: Duration(milliseconds: staggerIndex * 35),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 4,
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedArtistDetail = artist;
                                  _searchQuery = '';
                                  _searchController.clear();
                                  _detailColorFuture = _getDetailColor(
                                    artistSongs.isNotEmpty
                                        ? artistSongs.first
                                        : null,
                                  );
                                });
                              },
                              leading: _buildTrackArtwork(
                                firstTrack,
                                size: 48,
                                radius: 24,
                              ),
                              title: Text(
                                artist,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: textColor,
                                ),
                              ),
                              subtitle: Text(
                                '$songCount ${AppLocalizations.of(context).songsCount}',
                                style: TextStyle(
                                  color: subtextColor,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: isLight ? Colors.black26 : Colors.white24,
                                size: 14,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidAlbumName(String albumName) {
    final l = albumName.toLowerCase().trim();
    return l.isNotEmpty &&
        l != '<unknown>' &&
        l != 'unknown' &&
        l != 'unknown album' &&
        l != 'single' &&
        l != 'singles';
  }

  Widget _buildAlbumsTab() {
    final key = "albums_${_searchSourceIndex}_$_albumsAnimToken";
    final bool shouldAnimateTab = !_visitedTabKeys.contains(key);
    if (shouldAnimateTab) {
      _visitedTabKeys.add(key);
    }

    final List<Track> activeTrackPool = _searchSourceIndex == 1
        ? {
            ..._onlineHistoryTracks,
            if (_playingTrack != null && _playingTrack!.isOnline)
              _playingTrack!,
          }.toList()
        : _allTracks;

    if (_searchSourceIndex == 1 && _isOnlineSearching && activeTrackPool.isEmpty) {
      return _buildOnlineAlbumsSkeleton();
    }

    if (_memoAlbumTracksMap == null ||
        _memoAlbumPoolLen != activeTrackPool.length ||
        _memoAlbumSortBy != _sortBy ||
        _memoAlbumSearchQuery != _searchQuery ||
        _memoAlbumSearchSource != _searchSourceIndex) {
      final Map<String, List<Track>> albumTracksMap = {};
      for (final t in activeTrackPool) {
        if (_isValidAlbumName(t.album)) {
          (albumTracksMap[t.album] ??= []).add(t);
        }
      }

      final List<String> albums = [];
      final seenAlbums = <String>{};

      if (_sortBy == 'date') {
        for (final t in activeTrackPool) {
          if (_isValidAlbumName(t.album) && seenAlbums.add(t.album)) {
            albums.add(t.album);
          }
        }
      } else if (_sortBy == 'date_oldest') {
        for (final t in activeTrackPool.reversed) {
          if (_isValidAlbumName(t.album) && seenAlbums.add(t.album)) {
            albums.add(t.album);
          }
        }
      } else if (_sortBy == 'duration_longest') {
        final Map<String, int> maxDuration = {};
        for (final t in activeTrackPool) {
          final current = maxDuration[t.album] ?? 0;
          if (t.duration > current) {
            maxDuration[t.album] = t.duration;
          }
        }
        final allUnique = albumTracksMap.keys.toList();
        allUnique.sort(
          (a, b) => (maxDuration[b] ?? 0).compareTo(maxDuration[a] ?? 0),
        );
        albums.addAll(allUnique);
      } else if (_sortBy == 'duration_shortest') {
        final Map<String, int> minDuration = {};
        for (final t in activeTrackPool) {
          final current = minDuration[t.album] ?? 99999999;
          if (t.duration < current) {
            minDuration[t.album] = t.duration;
          }
        }
        final allUnique = albumTracksMap.keys.toList();
        allUnique.sort(
          (a, b) => (minDuration[a] ?? 0).compareTo(minDuration[a] ?? 0),
        );
        albums.addAll(allUnique);
      } else {
        final allUnique = albumTracksMap.keys.toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        albums.addAll(allUnique);
      }

      if (_searchQuery.isNotEmpty) {
        albums.retainWhere(
          (a) => a.toLowerCase().contains(_searchQuery.toLowerCase()),
        );
      }

      final List<MapEntry<String, int>> topAlbumCounts = [];
      albumTracksMap.forEach((name, tracks) {
        topAlbumCounts.add(MapEntry(name, tracks.length));
      });
      topAlbumCounts.sort((a, b) => b.value.compareTo(a.value));
      final topAlbumsList = topAlbumCounts.take(8).map((e) => e.key).toList();

      _memoAlbumTracksMap = albumTracksMap;
      _memoAlbumsList = albums;
      _memoTopAlbumsList = topAlbumsList;
      _memoAlbumSortBy = _sortBy;
      _memoAlbumSearchQuery = _searchQuery;
      _memoAlbumPoolLen = activeTrackPool.length;
      _memoAlbumSearchSource = _searchSourceIndex;
    }

    final albumTracksMap = _memoAlbumTracksMap!;
    final albums = _memoAlbumsList!;
    final topAlbumsList = _memoTopAlbumsList!;

    final isLight = isAppLight;
    final textColor = isLight ? const Color(0xFF1A1A1A) : Colors.white;
    final subtextColor = isLight ? Colors.black54 : Colors.white54;

    return _FadeInSlideUp(
      key: ValueKey(key),
      animate: shouldAnimateTab,
      delay: Duration.zero,
      child: Column(
      children: [
        // Sub-header with album count & Grid/List layout switcher
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Text(
                '${albums.length} ${AppLocalizations.of(context).album}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: subtextColor,
                ),
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    setState(() {
                      _albumViewMode = _albumViewMode == 'grid'
                          ? 'list'
                          : 'grid';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isLight
                          ? Colors.black.withValues(alpha: 0.05)
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _albumViewMode == 'grid'
                          ? Icons.view_list_rounded
                          : Icons.grid_view_rounded,
                      size: 18,
                      color: _activeAccentColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Expanded Album List/Grid Content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: _playingTrack != null ? 84 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Albums Carousel (when search is empty & >= 3 top albums exist)
                if (_searchQuery.isEmpty && topAlbumsList.length >= 3) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 4,
                    ),
                    child: Text(
                      'Top Albums',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 168,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      itemCount: topAlbumsList.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final albumName = topAlbumsList[index];
                        final albumSongs = albumTracksMap[albumName] ?? [];
                        final count = albumSongs.length;
                        final firstTrack = albumSongs.isNotEmpty
                            ? albumSongs.first
                            : Track(
                                id: '',
                                title: '',
                                artist: '',
                                album: albumName,
                                url: '',
                                path: '',
                                lyrics: const [],
                                duration: 0,
                              );

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedAlbumDetail = albumName;
                              _searchQuery = '';
                              _searchController.clear();
                              _detailColorFuture = _getDetailColor(
                                albumSongs.isNotEmpty ? albumSongs.first : null,
                              );
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: _buildTrackArtwork(
                                    firstTrack,
                                    size: 110,
                                    radius: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 110,
                                child: Text(
                                  albumName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              SizedBox(
                                width: 110,
                                child: Text(
                                  firstTrack.artist.isNotEmpty
                                      ? firstTrack.artist
                                      : '$count ${AppLocalizations.of(context).songsCount}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: subtextColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 4,
                    ),
                    child: Text(
                      'All Albums',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Grid View vs List View
                if (_albumViewMode == 'grid')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.82,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                      itemCount: albums.length,
                      itemBuilder: (context, index) {
                        final album = albums[index];
                        final albumSongs = albumTracksMap[album] ?? [];
                        final songCount = albumSongs.length;
                        final firstTrack = albumSongs.isNotEmpty
                            ? albumSongs.first
                            : Track(
                                id: '',
                                title: '',
                                artist: '',
                                album: album,
                                url: '',
                                path: '',
                                lyrics: const [],
                                duration: 0,
                              );
                        final shouldAnimate = !_animatedAlbumIds.contains(
                          album,
                        );
                        final count = _animatedAlbumIds.length;
                        final staggerIndex = count < 8 ? count : 0;
                        if (shouldAnimate) {
                          _animatedAlbumIds.add(album);
                        }

                        return _FadeInSlideUp(
                          animate: shouldAnimate,
                          delay: Duration(milliseconds: staggerIndex * 35),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAlbumDetail = album;
                                _searchQuery = '';
                                _searchController.clear();
                                _detailColorFuture = _getDetailColor(
                                  albumSongs.isNotEmpty
                                      ? albumSongs.first
                                      : null,
                                );
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isLight
                                    ? Colors.black.withValues(alpha: 0.03)
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isLight
                                      ? Colors.black.withValues(alpha: 0.06)
                                      : Colors.white.withValues(alpha: 0.08),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.15,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: _buildTrackArtwork(
                                            firstTrack,
                                            size: 140,
                                            radius: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    album,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          firstTrack.artist.isNotEmpty
                                              ? firstTrack.artist
                                              : '<unknown>',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: subtextColor,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _activeAccentColor.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          '$songCount',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: _activeAccentColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: albums.length,
                      itemBuilder: (context, index) {
                        final album = albums[index];
                        final albumSongs = albumTracksMap[album] ?? [];
                        final songCount = albumSongs.length;
                        final firstTrack = albumSongs.isNotEmpty
                            ? albumSongs.first
                            : Track(
                                id: '',
                                title: '',
                                artist: '',
                                album: album,
                                url: '',
                                path: '',
                                lyrics: const [],
                                duration: 0,
                              );
                        final shouldAnimate = !_animatedAlbumIds.contains(
                          album,
                        );
                        final count = _animatedAlbumIds.length;
                        final staggerIndex = count < 8 ? count : 0;
                        if (shouldAnimate) {
                          _animatedAlbumIds.add(album);
                        }

                        return _FadeInSlideUp(
                          animate: shouldAnimate,
                          delay: Duration(milliseconds: staggerIndex * 35),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            onTap: () {
                              setState(() {
                                _selectedAlbumDetail = album;
                                _searchQuery = '';
                                _searchController.clear();
                                _detailColorFuture = _getDetailColor(
                                  albumSongs.isNotEmpty
                                      ? albumSongs.first
                                      : null,
                                );
                              });
                            },
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildTrackArtwork(
                                firstTrack,
                                size: 48,
                                radius: 8,
                              ),
                            ),
                            title: Text(
                              album,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: textColor,
                              ),
                            ),
                            subtitle: Text(
                              '${firstTrack.artist} • $songCount ${AppLocalizations.of(context).songsCount}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: subtextColor,
                                fontSize: 12,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: isLight ? Colors.black26 : Colors.white24,
                              size: 14,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
    );
  }

  Widget _buildSongList(
    List<Track> list, {
    Widget? header,
    bool isMostPlayed = false,
    ScrollController? controller,
    List<Track>? fullQueueList,
    String? playlistContext,
  }) {
    if (list.isEmpty && header == null) {
      return Center(
        child: Text(
          AppLocalizations.of(context).noMatchingSongs,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 14,
          ),
        ),
      );
    }
    return ListView.builder(
      controller: controller,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: _playingTrack != null ? 84 : 12,
      ),
      itemCount: list.length + (header != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (header != null && index == 0) return header;
        final trackIndex = header != null ? index - 1 : index;
        final track = list[trackIndex];
        final isSelected =
            _playingTrack != null && track.id == _playingTrack!.id;

        final isDetail = header != null;
        final shouldAnimate =
            !isDetail && !_animatedTrackIds.contains(track.id);
        final count = _animatedTrackIds.length;
        final staggerIndex = count < 8 ? count : 0;
        if (shouldAnimate) {
          _animatedTrackIds.add(track.id);
        }

        final isMultiSelected = _multiSelectedTrackIds.contains(track.id);

        return _FadeInSlideUp(
          animate: shouldAnimate,
          delay: Duration(milliseconds: staggerIndex * 35),
          child: Container(
            key: ValueKey("list_item_${track.id}"),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: isMultiSelected
                  ? _activeAccentColor.withValues(alpha: 0.15)
                  : (isSelected
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
              border: isMultiSelected
                  ? Border.all(
                      color: _activeAccentColor.withValues(alpha: 0.5),
                      width: 1,
                    )
                  : Border.all(color: Colors.transparent, width: 1),
            ),
            child: ListTile(
              visualDensity: _libraryDensity == 'compact'
                  ? const VisualDensity(vertical: -2)
                  : VisualDensity.standard,
              contentPadding: EdgeInsets.only(
                left: 8,
                right: 0,
                top: _libraryDensity == 'compact' ? 0 : 4,
                bottom: _libraryDensity == 'compact' ? 0 : 4,
              ),
              onLongPress: () {
                _searchFocusNode.unfocus();
                _toggleMultiSelect(track.id);
              },
              onTap: () {
                _searchFocusNode.unfocus();
                if (_multiSelectedTrackIds.isNotEmpty) {
                  _toggleMultiSelect(track.id);
                  return;
                }

                _updatePlayingFrom();
                if (fullQueueList != null) {
                  final realIndex = fullQueueList.indexOf(track);
                  if (realIndex != -1) {
                    _playTrack(realIndex, sourceList: fullQueueList);
                  } else {
                    _playTrack(trackIndex, sourceList: list);
                  }
                } else {
                  _playTrack(trackIndex, sourceList: list);
                }
              },
              leading: _buildTrackArtwork(
                track,
                size: _libraryDensity == 'compact' ? 36 : 44,
                radius: _libraryDensity == 'compact' ? 4 : 6,
              ),
              title: Text(
                track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: isSelected
                      ? _activeAccentColor
                      : (isAppLight ? const Color(0xFF1A1A1A) : Colors.white),
                ),
              ),
              subtitle: Text(
                isMostPlayed
                    ? '${_playCounts[track.id] ?? 0} ${AppLocalizations.of(context).playsCount} • ${track.artist}'
                    : track.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isAppLight ? Colors.black45 : Colors.white38,
                  fontSize: 12,
                ),
              ),
              trailing: Transform.translate(
                offset: const Offset(12, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      MiniMusicVisualizer(
                        color: _activeAccentColor,
                        width: 4,
                        height: 14,
                        radius: 2,
                        animate: _isPlaying,
                      )
                    else
                      Text(
                        _formatDuration(
                          Duration(
                            milliseconds: track.duration > 0
                                ? track.duration
                                : 210000,
                          ),
                        ),
                        style: TextStyle(
                          color: isAppLight ? Colors.black45 : Colors.white38,
                          fontSize: 12,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: isAppLight ? Colors.black45 : Colors.white54,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showTrackOptions(
                        context,
                        track,
                        playlistContext: playlistContext,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _loadOnlineTabInitialContent({bool forceReload = false}) {
    if (!forceReload &&
        _isOnlineContentLoaded &&
        _onlineQuickPicks.isNotEmpty) {
      setState(() {
        _isOnlineSearching = false;
      });
      return;
    }

    final requestId = ++_onlineSearchRequestId;
    setState(() {
      _isOnlineSearching = true;
    });

    final historyFuture = InnerTubeService().getOnlineTrackHistory();
    final quickPicksFuture = InnerTubeService().fetchTrendingOrRandomTracks();

    Future.wait([historyFuture, quickPicksFuture]).then((results) async {
      if (!mounted || _onlineSearchRequestId != requestId) return;
      final history = results[0];
      final quickPicks = results[1];

      String favArtist = '';
      if (history.isNotEmpty) {
        final Map<String, int> artistCounts = {};
        for (final t in history) {
          if (t.artist.isNotEmpty && t.artist != '<unknown>') {
            artistCounts[t.artist] = (artistCounts[t.artist] ?? 0) + 1;
          }
        }
        if (artistCounts.isNotEmpty) {
          final sorted = artistCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          favArtist = sorted.first.key;
        }
      }

      final List<Map<String, String>> artistsList = [];
      final Set<String> seenArtists = {};
      for (final t in [...history, ...quickPicks]) {
        if (t.artist.isNotEmpty &&
            t.artist != '<unknown>' &&
            !seenArtists.contains(t.artist.toLowerCase()) &&
            t.thumbnailUrl != null) {
          seenArtists.add(t.artist.toLowerCase());
          artistsList.add({'name': t.artist, 'imageUrl': t.thumbnailUrl!});
          if (artistsList.length >= 8) break;
        }
      }

      // IMMEDIATELY render home content with history & quick picks!
      if (mounted && _onlineSearchRequestId == requestId) {
        setState(() {
          _onlineHistoryTracks = history;
          _onlineQuickPicks = quickPicks;
          _favoriteArtistName = favArtist;
          _recommendedArtists = artistsList;
          _onlineSearchResults = quickPicks;
          _isOnlineSearching = false;
          _isOnlineContentLoaded = true;
          _isShowingOnlineHistory = history.isNotEmpty;
        });
      }

      // Fetch secondary data in background without blocking Home UI loading state
      Future.microtask(() async {
        List<Track> similarTracks = [];
        if (favArtist.isNotEmpty) {
          try {
            similarTracks = await InnerTubeService().fetchSimilarArtistTracks(
              favArtist,
            );
          } catch (_) {}
        }

        final onlineFavs = await InnerTubeService().getOnlineFavorites();
        final userOnlinePls = await InnerTubeService().getUserOnlinePlaylists();
        final cachedPlTracks = await InnerTubeService()
            .getOnlinePlaylistTracksCache();

        if (cachedPlTracks.isNotEmpty) {
          _onlinePlaylistTracks.addAll(cachedPlTracks);
        }
        for (final f in onlineFavs) {
          _favoriteTrackIds.add(f.id);
          if (f.videoId != null) _favoriteTrackIds.add(f.videoId!);
        }

        if (mounted && _onlineSearchRequestId == requestId) {
          setState(() {
            _onlineFavoriteTracks.clear();
            _onlineFavoriteTracks.addAll(onlineFavs);
            _userOnlinePlaylists.clear();
            _userOnlinePlaylists.addAll(userOnlinePls);
            _similarArtistTracks = similarTracks;
          });
        }
      });
    }).catchError((err) {
      if (mounted && _onlineSearchRequestId == requestId) {
        setState(() {
          _isOnlineSearching = false;
          _isOnlineContentLoaded = true;
        });
      }
    });
  }

  Widget _buildOnlineHomeView() {
    final isLight = isAppLight;
    final textColor = isLight ? const Color(0xFF1A1A1A) : Colors.white;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Quick picks Section
          if (_onlineQuickPicks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quick picks',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_onlineQuickPicks.isNotEmpty) {
                        _playTrack(0, sourceList: _onlineQuickPicks);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isLight
                            ? Colors.black.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Play all',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ..._onlineQuickPicks
                .take(_showMoreQuickPicks ? 12 : 4)
                .map((t) => _buildOnlineQuickPickItem(t)),
            if (_onlineQuickPicks.length > 4) ...[
              const SizedBox(height: 8),
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showMoreQuickPicks = !_showMoreQuickPicks;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isLight
                          ? Colors.black.withValues(alpha: 0.05)
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isLight ? Colors.black12 : Colors.white12,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _showMoreQuickPicks ? 'Show less' : 'Load more',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _showMoreQuickPicks
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: textColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],

          // 2. Recently Played Section
          if (_onlineHistoryTracks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Recently Played',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 190,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: _onlineHistoryTracks.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final track = _onlineHistoryTracks[index];
                  return _buildOnlineHorizontalTrackCard(
                    track,
                    sourceList: _onlineHistoryTracks,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 3. Similar to [Favorite Artist] Section
          if (_similarArtistTracks.isNotEmpty &&
              _favoriteArtistName.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Similar to $_favoriteArtistName',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 190,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: _similarArtistTracks.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final track = _similarArtistTracks[index];
                  return _buildOnlineHorizontalTrackCard(
                    track,
                    sourceList: _similarArtistTracks,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 4. Recommended Artists (Circular Avatar Cards)
          if (_recommendedArtists.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Recommended Artists',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 125,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: _recommendedArtists.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final item = _recommendedArtists[index];
                  final artistName = item['name']!;
                  final imageUrl = item['imageUrl']!;

                  return GestureDetector(
                    onTap: () {
                      _searchController.text = artistName;
                      _searchQuery = artistName;
                      _triggerOnlineSearch(artistName);
                    },
                    child: SizedBox(
                      width: 85,
                      child: Column(
                        children: [
                          Container(
                            width: 75,
                            height: 75,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            artistName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildOnlineQuickPickItem(Track track) {
    final isLight = isAppLight;
    final isPlayingThis = _playingTrack?.id == track.id;
    final textColor = isPlayingThis
        ? _activeAccentColor
        : (isLight ? const Color(0xFF1A1A1A) : Colors.white);
    final subtextColor = isLight ? Colors.black54 : Colors.white54;

    return InkWell(
      onTap: () {
        final idx = _onlineQuickPicks.indexWhere((t) => t.id == track.id);
        if (idx != -1) {
          _playTrack(idx, sourceList: _onlineQuickPicks);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 0, top: 8, bottom: 8),
        child: Row(
          children: [
            _buildTrackArtwork(track, size: 52, radius: 8),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isPlayingThis
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${track.artist} • ${_formatDuration(Duration(milliseconds: track.duration))}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: subtextColor),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: subtextColor, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _showTrackOptions(context, track),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineHorizontalTrackCard(
    Track track, {
    List<Track>? sourceList,
  }) {
    final isLight = isAppLight;
    final isPlayingThis =
        _playingTrack?.id == track.id ||
        (_playingTrack?.videoId != null &&
            track.videoId != null &&
            _playingTrack?.videoId == track.videoId);
    final textColor = isPlayingThis
        ? _activeAccentColor
        : (isLight ? const Color(0xFF1A1A1A) : Colors.white);
    final subtextColor = isLight ? Colors.black54 : Colors.white54;

    return GestureDetector(
      onTap: () {
        if (isPlayingThis) {
          if (_isPlaying) {
            _pauseWithFade();
          } else {
            _playWithFade();
          }
        } else {
          _playTrack(0, sourceList: [track]);
        }
      },
      onLongPress: () => _showTrackOptions(context, track),
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _buildTrackArtwork(track, size: 130, radius: 12),
                if (isPlayingThis)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _showTrackOptions(context, track),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isPlayingThis ? FontWeight.bold : FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              track.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: subtextColor),
            ),
          ],
        ),
      ),
    );
  }

  void _triggerOnlineSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _loadOnlineTabInitialContent();
      return;
    }
    final requestId = ++_onlineSearchRequestId;
    setState(() {
      _isOnlineSearching = true;
      _isShowingOnlineHistory = false;
    });
    InnerTubeService().searchTracks(trimmed).then((results) {
      if (mounted && _onlineSearchRequestId == requestId) {
        setState(() {
          _onlineSearchResults = results;
          _isOnlineSearching = false;
          _isShowingOnlineHistory = false;
        });
      }
    });
  }

  Widget _buildSearchSourceSegmentedToggle() {
    final isLight = isAppLight;
    final isYt = _searchSourceIndex == 1;

    final activeBg = isLight
        ? Colors.black.withValues(alpha: 0.12)
        : const Color(0xFF2C2C2E);
    final activeBorder = isLight ? Colors.black26 : Colors.white30;
    final activeTextColor = isLight ? const Color(0xFF1A1A1A) : Colors.white;

    final inactiveBg = Colors.transparent;
    final inactiveTextColor = isLight ? Colors.black45 : Colors.white54;

    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isLight
            ? Colors.black.withValues(alpha: 0.05)
            : const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLight
              ? Colors.black.withValues(alpha: 0.08)
              : Colors.white10,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (_searchSourceIndex != 0) {
                setState(() {
                  _searchSourceIndex = 0;
                });
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: !isYt ? activeBg : inactiveBg,
                borderRadius: BorderRadius.circular(11),
                border: !isYt
                    ? Border.all(color: activeBorder, width: 1.2)
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.phone_android_rounded,
                    size: 14,
                    color: !isYt ? activeTextColor : inactiveTextColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Local',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: !isYt ? FontWeight.w600 : FontWeight.w500,
                      color: !isYt ? activeTextColor : inactiveTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: () {
              if (_searchSourceIndex != 1) {
                setState(() {
                  _searchSourceIndex = 1;
                });
                if (_searchQuery.isNotEmpty) {
                  _triggerOnlineSearch(_searchQuery);
                } else {
                  _loadOnlineTabInitialContent();
                }
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isYt ? activeBg : inactiveBg,
                borderRadius: BorderRadius.circular(11),
                border: isYt
                    ? Border.all(color: activeBorder, width: 1.2)
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_done_rounded,
                    size: 15,
                    color: isYt ? activeTextColor : inactiveTextColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isYt ? FontWeight.w600 : FontWeight.w500,
                      color: isYt ? activeTextColor : inactiveTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final isLight = isAppLight;
    final searchBgColor = isLight
        ? Colors.black.withValues(alpha: 0.05)
        : const Color(0xFF161616);
    final textColor = isLight ? const Color(0xFF1A1A1A) : Colors.white;
    final hintColor = isLight
        ? Colors.black38
        : Colors.white.withValues(alpha: 0.3);
    final iconColor = isLight ? Colors.black45 : Colors.white54;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: searchBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    focusNode: _searchFocusNode,
                    controller: _searchController,
                    textAlignVertical: TextAlignVertical.center,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (val) {
                      _searchFocusNode.unfocus();
                      if (_searchSourceIndex == 1) {
                        _triggerOnlineSearch(val.trim());
                      }
                    },
                    onChanged: (val) {
                      if (_searchDebouncer?.isActive ?? false) {
                        _searchDebouncer!.cancel();
                      }
                      _searchDebouncer = Timer(
                        const Duration(milliseconds: 350),
                        () {
                          _searchQuery = val.trim();
                          if (_searchSourceIndex == 1) {
                            _triggerOnlineSearch(_searchQuery);
                          } else {
                            _filterSongs();
                          }
                        },
                      );
                    },
                    style: TextStyle(fontSize: 14, color: textColor),
                    decoration: InputDecoration(
                      hintText: _searchSourceIndex == 1
                          ? 'Search Online Music...'
                          : AppLocalizations.of(context).searchSongs,
                      hintStyle: TextStyle(color: hintColor, fontSize: 13),
                      prefixIcon: Icon(
                        _searchSourceIndex == 1
                            ? Icons.youtube_searched_for
                            : Icons.search,
                        color: iconColor,
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close,
                                color: iconColor,
                                size: 16,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _searchQuery = '';
                                if (_searchSourceIndex == 1) {
                                  _loadOnlineTabInitialContent();
                                } else {
                                  _filterSongs();
                                }
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _showSortModal(context),
                child: Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: searchBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.sort_rounded,
                    color: isLight ? Colors.black87 : Colors.white70,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterCapsules() {
    final isLight = isAppLight;
    final filters = [
      _searchSourceIndex == 1
          ? 'Home'
          : AppLocalizations.of(context).songsTitle,
      AppLocalizations.of(context).playlists,
      AppLocalizations.of(context).artists,
      AppLocalizations.of(context).albums,
    ];
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 8),
      child: SizedBox(
        height: 32,
        child: Row(
          children: filters.asMap().entries.map((entry) {
            final index = entry.key;
            final filter = entry.value;
            final isSelected = _currentPageIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (index == 0) {
                      _songsAnimToken++;
                      _homeAnimToken++;
                    } else if (index == 1) {
                      _playlistsAnimToken++;
                    } else if (index == 2) {
                      _artistsAnimToken++;
                    } else if (index == 3) {
                      _albumsAnimToken++;
                    }
                  });
                  if (_currentPageIndex != index) {
                    _pageController.jumpToPage(index);
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(
                    right: index == filters.length - 1 ? 0 : 8,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isLight ? const Color(0xFF1A1A1A) : Colors.white)
                        : (isLight
                              ? Colors.black.withValues(alpha: 0.05)
                              : const Color(0xFF161616)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected
                            ? (isLight ? Colors.white : Colors.black)
                            : (isLight ? Colors.black54 : Colors.white70),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOnlineHomeSkeleton() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _SkeletonBox(width: 140, height: 24, borderRadius: 6),
              _SkeletonBox(width: 70, height: 26, borderRadius: 13),
            ],
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < 6; i++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const _SkeletonBox(width: 52, height: 52, borderRadius: 8),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _SkeletonBox(width: 180, height: 14, borderRadius: 4),
                        SizedBox(height: 8),
                        _SkeletonBox(width: 110, height: 12, borderRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          const _SkeletonBox(width: 160, height: 24, borderRadius: 6),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: Row(
              children: const [
                _SkeletonBox(width: 140, height: 150, borderRadius: 14),
                SizedBox(width: 14),
                _SkeletonBox(width: 140, height: 150, borderRadius: 14),
                SizedBox(width: 14),
                _SkeletonBox(width: 40, height: 150, borderRadius: 14),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SkeletonBox(width: 180, height: 24, borderRadius: 6),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Column(
                children: [
                  _SkeletonBox(width: 75, height: 75, borderRadius: 38),
                  SizedBox(height: 8),
                  _SkeletonBox(width: 65, height: 12, borderRadius: 4),
                ],
              ),
              Column(
                children: [
                  _SkeletonBox(width: 75, height: 75, borderRadius: 38),
                  SizedBox(height: 8),
                  _SkeletonBox(width: 65, height: 12, borderRadius: 4),
                ],
              ),
              Column(
                children: [
                  _SkeletonBox(width: 75, height: 75, borderRadius: 38),
                  SizedBox(height: 8),
                  _SkeletonBox(width: 65, height: 12, borderRadius: 4),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOnlinePlaylistsSkeleton() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: _SkeletonBox(width: 180, height: 24, borderRadius: 6),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 190,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (_, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _SkeletonBox(width: 140, height: 140, borderRadius: 12),
                  SizedBox(height: 8),
                  _SkeletonBox(width: 110, height: 14, borderRadius: 4),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: _SkeletonBox(width: 140, height: 22, borderRadius: 6),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < 6; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: Row(
                children: [
                  const _SkeletonBox(width: 56, height: 56, borderRadius: 10),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _SkeletonBox(width: 160, height: 14, borderRadius: 4),
                      SizedBox(height: 6),
                      _SkeletonBox(width: 90, height: 12, borderRadius: 4),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOnlineArtistsSkeleton() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SkeletonBox(width: 140, height: 22, borderRadius: 6),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Column(
                children: [
                  _SkeletonBox(width: 80, height: 80, borderRadius: 40),
                  SizedBox(height: 8),
                  _SkeletonBox(width: 70, height: 12, borderRadius: 4),
                ],
              ),
              Column(
                children: [
                  _SkeletonBox(width: 80, height: 80, borderRadius: 40),
                  SizedBox(height: 8),
                  _SkeletonBox(width: 70, height: 12, borderRadius: 4),
                ],
              ),
              Column(
                children: [
                  _SkeletonBox(width: 80, height: 80, borderRadius: 40),
                  SizedBox(height: 8),
                  _SkeletonBox(width: 70, height: 12, borderRadius: 4),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          for (int i = 0; i < 7; i++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  const _SkeletonBox(width: 52, height: 52, borderRadius: 26),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _SkeletonBox(width: 150, height: 14, borderRadius: 4),
                      SizedBox(height: 6),
                      _SkeletonBox(width: 80, height: 12, borderRadius: 4),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOnlineAlbumsSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SkeletonBox(width: 120, height: 22, borderRadius: 6),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
              itemCount: 6,
              itemBuilder: (_, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(
                    child: _SkeletonBox(
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  _SkeletonBox(width: 120, height: 14, borderRadius: 4),
                  SizedBox(height: 4),
                  _SkeletonBox(width: 70, height: 12, borderRadius: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const _KeepAliveWrapper({required this.child});

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}

class _FadeInSlideUp extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final bool animate;

  const _FadeInSlideUp({
    super.key,
    required this.child,
    required this.delay,
    this.animate = true,
  });

  @override
  State<_FadeInSlideUp> createState() => _FadeInSlideUpState();
}

class _FadeInSlideUpState extends State<_FadeInSlideUp> {
  bool _isMounted = false;
  Timer? _timer;
  late bool _animate;
  int _restartCount = 0;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  @override
  void didUpdateWidget(_FadeInSlideUp oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.animate == true && oldWidget.animate == false) {
      _initAnimation();
    }
  }

  void _initAnimation() {
    _timer?.cancel();
    _restartCount++;
    _animate = widget.animate;
    if (!_animate) {
      _isMounted = true;
    } else {
      _isMounted = false;
      _timer = Timer(widget.delay, () {
        if (mounted) {
          setState(() {
            _isMounted = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double targetValue = (_isMounted || !_animate) ? 1.0 : 0.0;

    return TweenAnimationBuilder<double>(
      key: ValueKey(_restartCount),
      tween: Tween<double>(begin: _animate ? 0.0 : 1.0, end: targetValue),
      duration: _animate ? const Duration(milliseconds: 350) : Duration.zero,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1.0 - value) * 16),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.08, end: 0.22).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = isAppLight;
    final baseColor = isLight ? Colors.black : Colors.white;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}
