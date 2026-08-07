// ignore_for_file: invalid_use_of_protected_member, deprecated_member_use
part of '../main.dart';

extension _TrackOptionsUI on _MainScreenState {
  void _showTrackOptions(
    BuildContext context,
    Track track, {
    bool isFromPlayer = false,
    String? playlistContext,
  }) {
    final isLight = isAppLight;
    showModalBottomSheet(
      context: context,
      backgroundColor: isLight
          ? const Color(0xFFF0F0F3)
          : const Color(0xFF161616),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isFavorited = _favoriteTrackIds.contains(track.id);
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        _buildTrackArtwork(track, size: 48, radius: 8),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.title,
                                style: TextStyle(
                                  color: isLight
                                      ? const Color(0xFF1A1A1A)
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: getFontFamily(_activeFont),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${track.artist} • ${track.album}',
                                style: TextStyle(
                                  color: isLight
                                      ? Colors.black54
                                      : Colors.white54,
                                  fontSize: 14,
                                  fontFamily: getFontFamily(_activeFont),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: isLight
                        ? Colors.black.withValues(alpha: 0.08)
                        : Colors.white10,
                    height: 1,
                  ),
                  if (!isFromPlayer) ...[
                    _buildOptionItem(
                      Icons.playlist_play,
                      AppLocalizations.of(context).playNext,
                      () {
                        Navigator.pop(context);
                        if (_playingTrack?.id == track.id) {
                          showFlowToast(
                            AppLocalizations.of(context).cannotPlayNextActive,
                          );
                          return;
                        }
                        if (_playbackQueue.isNotEmpty) {
                          _moveTrackInQueue(track, _currentIndex + 1);
                          showFlowToast(
                            AppLocalizations.of(context).addedPlayNext,
                          );
                        }
                      },
                    ),
                    _buildOptionItem(
                      Icons.queue_music,
                      AppLocalizations.of(context).addToQueue,
                      () {
                        Navigator.pop(context);
                        if (_playingTrack?.id == track.id) {
                          showFlowToast(
                            AppLocalizations.of(context).cannotPlayNextActive,
                          );
                          return;
                        }
                        if (_playbackQueue.isNotEmpty) {
                          _moveTrackInQueue(track, _playbackQueue.length);
                          showFlowToast(
                            AppLocalizations.of(context).addedSongsToQueue,
                          );
                        }
                      },
                    ),
                  ],
                  _buildOptionItem(
                    Icons.playlist_add,
                    AppLocalizations.of(context).addToPlaylist,
                    () {
                      Navigator.pop(context);
                      _showAddToPlaylistModal(context, [track]);
                    },
                  ),
                  _buildOptionItem(
                    Icons.timer,
                    AppLocalizations.of(context).sleepTimer,
                    () {
                      Navigator.pop(context);
                       _showFullSleepTimerDialog(context);
                    },
                  ),
                  _buildOptionItem(
                    Icons.content_cut_rounded,
                    AppLocalizations.of(context).ringtoneCutter,
                    () {
                      Navigator.pop(context);
                      _showRingtoneCutterModal(context, track);
                    },
                  ),
                  _buildOptionItem(
                    Icons.equalizer_rounded,
                    AppLocalizations.of(context).equalizer,
                    () {
                      Navigator.pop(context);
                      MainScreen.showEqualizer(context);
                    },
                  ),
                  _buildOptionItem(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    AppLocalizations.of(context).favourites,
                    () {
                      _toggleFavorite(track.id);
                      if (isFavorited) {
                        final loc = lookupAppLocalizations(
                          Locale(FlowStrings.currentLang),
                        );
                        if (_MainScreenState
                                .mainScreenState!
                                ._playingFromName ==
                            loc.favourites) {
                          _MainScreenState.mainScreenState!
                              ._removeFromQueueAndPlayer(track.id);
                        }
                      }
                      setModalState(() {});
                    },
                    iconColor: isFavorited
                        ? _activeAccentColor
                        : (isLight ? Colors.black54 : Colors.white70),
                  ),
                  if (playlistContext != null &&
                      _userPlaylists.containsKey(playlistContext))
                    _buildOptionItem(
                      Icons.remove_circle_outline,
                      AppLocalizations.of(context).removeFromPlaylist,
                      () async {
                        Navigator.pop(context);
                        setState(() {
                          _userPlaylists[playlistContext]!.remove(track.id);
                        });
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(
                          'user_playlists',
                          jsonEncode(_userPlaylists),
                        );
                        _MainScreenState.mainScreenState!
                            ._removeFromQueueAndPlayer(track.id);
                        if (!context.mounted) return;
                        showFlowToast(
                          AppLocalizations.of(context).trackDeleted,
                        );
                      },
                      iconColor: Colors.redAccent,
                    ),
                  _buildOptionItem(
                    Icons.album_outlined,
                    AppLocalizations.of(context).goToAlbum,
                    () {
                      Navigator.pop(context);
                      setState(() {
                        _isPlayerOpen = false;
                        _selectedAlbumDetail = track.album;
                        _searchQuery = '';
                        _searchController.clear();
                        final albumSongs = _allTracks
                            .where((t) => t.album == track.album)
                            .toList();
                        _detailColorFuture = _getDetailColor(
                          albumSongs.isNotEmpty ? albumSongs.first : null,
                        );
                        _currentPageIndex = 3;
                        _pageController.animateToPage(
                          3,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      });
                    },
                  ),
                  _buildOptionItem(
                    Icons.person_outline,
                    AppLocalizations.of(context).goToArtist,
                    () {
                      Navigator.pop(context);
                      setState(() {
                        _isPlayerOpen = false;
                        _selectedArtistDetail = track.artist;
                        _searchQuery = '';
                        _searchController.clear();
                        final artistSongs = _allTracks
                            .where((t) => t.artist == track.artist)
                            .toList();
                        _detailColorFuture = _getDetailColor(
                          artistSongs.isNotEmpty ? artistSongs.first : null,
                        );
                        _currentPageIndex = 2;
                        _pageController.animateToPage(
                          2,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      });
                    },
                  ),
                  _buildOptionItem(
                    Icons.edit_outlined,
                    AppLocalizations.of(context).editMetadata,
                    () {
                      Navigator.pop(context);
                      _showEditMetadataModal(context, track);
                    },
                  ),
                  _buildOptionItem(
                    Icons.info_outline,
                    AppLocalizations.of(context).songInfo,
                    () {
                      Navigator.pop(context);
                      _showSongInfoModal(context, track);
                    },
                  ),
                  _buildOptionItem(
                    Icons.visibility_off_outlined,
                    AppLocalizations.of(context).hideFromLibrary,
                    () async {
                      Navigator.pop(context);
                      final prefs = await SharedPreferences.getInstance();
                      _hiddenTrackIds.add(track.id);
                      await prefs.setStringList(
                        'hidden_track_ids',
                        _hiddenTrackIds.toList(),
                      );
                      setState(() {
                        _allTracks.removeWhere((t) => t.id == track.id);
                        _cachedDetailKey = null;
                      });
                      _MainScreenState.mainScreenState!
                          ._removeFromQueueAndPlayer(track.id);
                      final serialized = _allTracks
                          .map((t) => t.toMap())
                          .toList();
                      await prefs.setString(
                        'cached_tracks_list',
                        jsonEncode(serialized),
                      );
                      showFlowToast(
                        lookupAppLocalizations(
                          Locale(FlowStrings.currentLang),
                        ).trackHidden,
                      );
                    },
                  ),
                  _buildOptionItem(
                    Icons.delete_outline,
                    AppLocalizations.of(context).deleteFromDevice,
                    () async {
                      final parentContext = this.context;
                      Navigator.pop(context);
                      final bool? confirm = await showConfirmationDialog(
                        parentContext,
                        title: AppLocalizations.of(parentContext).confirmDelete,
                        content: AppLocalizations.of(parentContext).confirmDeleteBody,
                        confirmText: AppLocalizations.of(parentContext).delete,
                      );
                      if (confirm != true) return;

                      try {
                        final file = File(track.path);
                        if (track.path.isNotEmpty && await file.exists()) {
                          await file.delete();
                          setState(() {
                            _allTracks.removeWhere((t) => t.id == track.id);
                            _cachedDetailKey = null;
                          });
                          _MainScreenState.mainScreenState!
                              ._removeFromQueueAndPlayer(track.id);
                          final prefs = await SharedPreferences.getInstance();
                          final serialized = _allTracks
                              .map((t) => t.toMap())
                              .toList();
                          await prefs.setString(
                            'cached_tracks_list',
                            jsonEncode(serialized),
                          );
                          showFlowToast(
                            lookupAppLocalizations(
                              Locale(FlowStrings.currentLang),
                            ).trackDeleted,
                          );
                        } else {
                          if (!parentContext.mounted) return;
                          _showScopedStorageFallbackDialog(parentContext, track);
                        }
                      } catch (e) {
                        if (!parentContext.mounted) return;
                        _showScopedStorageFallbackDialog(parentContext, track);
                      }
                    },
                    iconColor: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showScopedStorageFallbackDialog(BuildContext ctx, Track track) {
    final isLight = isAppLight;
    showDialog(
      context: ctx,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isLight
              ? const Color(0xFFF0F0F3)
              : const Color(0xFF161616),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            AppLocalizations.of(ctx).permissionDenied,
            style: TextStyle(
              color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: getFontFamily(_activeFont),
            ),
          ),
          content: Text(
            AppLocalizations.of(ctx).scopedStorageWarning,
            style: TextStyle(
              color: isLight ? Colors.black54 : Colors.white70,
              height: 1.4,
              fontFamily: getFontFamily(_activeFont),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                AppLocalizations.of(ctx).cancel,
                style: TextStyle(
                  color: isLight ? Colors.black45 : Colors.white54,
                  fontFamily: getFontFamily(_activeFont),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final prefs = await SharedPreferences.getInstance();
                _hiddenTrackIds.add(track.id);
                await prefs.setStringList(
                  'hidden_track_ids',
                  _hiddenTrackIds.toList(),
                );
                setState(() {
                  _allTracks.removeWhere((t) => t.id == track.id);
                  _cachedDetailKey = null;
                });
                _MainScreenState.mainScreenState!
                    ._removeFromQueueAndPlayer(track.id);
                final serialized =
                    _allTracks.map((t) => t.toMap()).toList();
                await prefs.setString(
                  'cached_tracks_list',
                  jsonEncode(serialized),
                );
                showFlowToast(
                  lookupAppLocalizations(
                    Locale(FlowStrings.currentLang),
                  ).trackDeleted,
                );
              },
              child: Text(
                AppLocalizations.of(ctx).hideTrack,
                style: TextStyle(
                  color: _activeAccentColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: getFontFamily(_activeFont),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
