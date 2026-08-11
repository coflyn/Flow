// ignore_for_file: invalid_use_of_protected_member, deprecated_member_use
part of '../main.dart';

extension _PlaylistManageUI on _MainScreenState {
  void _showAddToPlaylistModal(BuildContext context, List<Track> tracksToAdd) {
    final isLight = isAppLight;
    showModalBottomSheet(
      context: context,
      backgroundColor: isLight
          ? const Color(0xFFF0F0F3)
          : const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      AppLocalizations.of(context).addToPlaylist,
                      style: TextStyle(
                        color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: getFontFamily(_activeFont),
                      ),
                    ),
                  ),
                  Divider(
                    color: isLight
                        ? Colors.black.withValues(alpha: 0.08)
                        : Colors.white10,
                    height: 1,
                  ),
                  ListTile(
                    leading: Icon(Icons.add, color: _activeAccentColor),
                    title: Text(
                      AppLocalizations.of(context).createNewPlaylist,
                      style: TextStyle(
                        color: _activeAccentColor,
                        fontFamily: getFontFamily(_activeFont),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (_searchSourceIndex == 1 || (tracksToAdd.isNotEmpty && tracksToAdd.first.isOnline)) {
                        _showCreateOnlinePlaylistModal(context);
                      } else {
                        _showCreatePlaylistModal(
                          context,
                          tracksToAdd: tracksToAdd,
                        );
                      }
                    },
                  ),
                  if ((_searchSourceIndex == 1 || (tracksToAdd.isNotEmpty && tracksToAdd.first.isOnline) ? _userOnlinePlaylists : _userPlaylists).isNotEmpty)
                    Divider(
                      color: isLight
                          ? Colors.black.withValues(alpha: 0.08)
                          : Colors.white10,
                      height: 1,
                    ),
                  ...(_searchSourceIndex == 1 || (tracksToAdd.isNotEmpty && tracksToAdd.first.isOnline) ? _userOnlinePlaylists : _userPlaylists).keys.map((playlistName) {
                    final isOnlineMode = _searchSourceIndex == 1 || (tracksToAdd.isNotEmpty && tracksToAdd.first.isOnline);
                    return ListTile(
                      leading: Icon(
                        Icons.queue_music,
                        color: isLight ? Colors.black54 : Colors.white70,
                      ),
                      title: Text(
                        playlistName,
                        style: TextStyle(
                          color: isLight
                              ? const Color(0xFF1A1A1A)
                              : Colors.white,
                          fontFamily: getFontFamily(_activeFont),
                        ),
                      ),
                      onTap: () {
                        int addedCount = 0;
                        int skippedCount = 0;
                        setState(() {
                          if (isOnlineMode) {
                            final pl = _userOnlinePlaylists[playlistName]!;
                            for (final track in tracksToAdd) {
                              if (!pl.any((t) => t.id == track.id || (track.videoId != null && t.videoId == track.videoId))) {
                                pl.add(track);
                                addedCount++;
                              } else {
                                skippedCount++;
                              }
                            }
                            if (addedCount > 0) {
                              InnerTubeService().saveUserOnlinePlaylists(_userOnlinePlaylists);
                            }
                          } else {
                            for (final track in tracksToAdd) {
                              if (!_userPlaylists[playlistName]!.contains(
                                track.id,
                              )) {
                                _userPlaylists[playlistName]!.add(track.id);
                                addedCount++;
                                if (_MainScreenState
                                        .mainScreenState!
                                        ._playingFromName ==
                                    playlistName) {
                                  _MainScreenState.mainScreenState!
                                      ._addTrackToQueueDynamically(track.id);
                                }
                              } else {
                                skippedCount++;
                              }
                            }
                            if (addedCount > 0) {
                              _cachedDetailKey = null;
                              _saveUserPlaylists();
                            }
                          }
                        });
                        Navigator.pop(context);
                        if (tracksToAdd.length == 1) {
                          if (skippedCount > 0) {
                            showFlowToast(
                              AppLocalizations.of(context)
                                  .toastSongAlreadyInPlaylist
                                  .replaceFirst(
                                    '[placeholder]',
                                    tracksToAdd.first.title,
                                  )
                                  .replaceFirst('[placeholder]', playlistName),
                            );
                          } else {
                            showFlowToast(
                              AppLocalizations.of(context).toastAddedSongTo
                                  .replaceFirst(
                                    '[placeholder]',
                                    tracksToAdd.first.title,
                                  )
                                  .replaceFirst('[placeholder]', playlistName),
                            );
                          }
                        } else {
                          if (addedCount == 0) {
                            showFlowToast(
                              AppLocalizations.of(context)
                                  .toastSelectedSongsAlreadyIn
                                  .replaceFirst('[placeholder]', playlistName),
                            );
                          } else if (skippedCount > 0) {
                            showFlowToast(
                              AppLocalizations.of(context)
                                  .toastAddedSongsSkipped
                                  .replaceFirst('[placeholder]', '$addedCount')
                                  .replaceFirst('[placeholder]', playlistName)
                                  .replaceFirst(
                                    '[placeholder]',
                                    '$skippedCount',
                                  ),
                            );
                          } else {
                            showFlowToast(
                              AppLocalizations.of(context)
                                  .toastAddedSongsToSimple
                                  .replaceFirst('[placeholder]', '$addedCount')
                                  .replaceFirst('[placeholder]', playlistName),
                            );
                          }
                        }
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCreatePlaylistModal(
    BuildContext context, {
    List<Track>? tracksToAdd,
  }) {
    final TextEditingController nameController = TextEditingController();
    final isLight = isAppLight;
    final loc = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: isLight ? const Color(0xFFFAF9F6) : const Color(0xFF1E1E1E),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isLight ? Colors.black26 : Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _activeAccentColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.queue_music_rounded,
                        color: _activeAccentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        loc.newPlaylist,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                          fontFamily: getFontFamily(_activeFont),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLight
                        ? Colors.black.withValues(alpha: 0.04)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isLight ? Colors.black12 : Colors.white12,
                    ),
                  ),
                  child: TextField(
                    controller: nameController,
                    autofocus: true,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                      fontFamily: getFontFamily(_activeFont),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      hintText: loc.playlistNamePlaceholder,
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: isLight ? Colors.black38 : Colors.white38,
                        fontFamily: getFontFamily(_activeFont),
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.edit_note_rounded,
                        color: _activeAccentColor,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        loc.cancel,
                        style: TextStyle(
                          color: isLight ? Colors.black54 : Colors.white54,
                          fontFamily: getFontFamily(_activeFont),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _activeAccentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isNotEmpty && !_userPlaylists.containsKey(name)) {
                          setState(() {
                            _userPlaylists[name] = tracksToAdd != null
                                ? tracksToAdd.map((t) => t.id).toList()
                                : [];
                            _cachedDetailKey = null;
                            _saveUserPlaylists();
                          });
                          Navigator.pop(ctx);
                          showFlowToast(
                            loc.playlistCreatedFormat.replaceFirst('[placeholder]', name),
                          );
                        }
                      },
                      child: Text(
                        loc.create,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: getFontFamily(_activeFont),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRenamePlaylistModal(BuildContext context, String oldName) {
    final TextEditingController nameController = TextEditingController(
      text: oldName,
    );
    final isLight = isAppLight;
    final loc = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: isLight ? const Color(0xFFFAF9F6) : const Color(0xFF1E1E1E),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isLight ? Colors.black26 : Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _activeAccentColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        color: _activeAccentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        loc.renamePlaylist,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                          fontFamily: getFontFamily(_activeFont),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLight
                        ? Colors.black.withValues(alpha: 0.04)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isLight ? Colors.black12 : Colors.white12,
                    ),
                  ),
                  child: TextField(
                    controller: nameController,
                    autofocus: true,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                      fontFamily: getFontFamily(_activeFont),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      hintText: loc.playlistNamePlaceholder,
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: isLight ? Colors.black38 : Colors.white38,
                        fontFamily: getFontFamily(_activeFont),
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.drive_file_rename_outline_rounded,
                        color: _activeAccentColor,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        loc.cancel,
                        style: TextStyle(
                          color: isLight ? Colors.black54 : Colors.white54,
                          fontFamily: getFontFamily(_activeFont),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _activeAccentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        final newName = nameController.text.trim();
                        final bool isLocal = _userPlaylists.containsKey(oldName);
                        final bool isOnline = _userOnlinePlaylists.containsKey(oldName);
                        final bool exists = _userPlaylists.containsKey(newName) ||
                            _userOnlinePlaylists.containsKey(newName);

                        if (newName.isNotEmpty && newName != oldName && !exists) {
                          setState(() {
                            if (isLocal) {
                              final tracks = _userPlaylists.remove(oldName);
                              if (tracks != null) _userPlaylists[newName] = tracks;
                              _saveUserPlaylists();
                            }
                            if (isOnline) {
                              final tracks = _userOnlinePlaylists.remove(oldName);
                              if (tracks != null) _userOnlinePlaylists[newName] = tracks;
                              InnerTubeService().saveUserOnlinePlaylists(_userOnlinePlaylists);
                            }
                            if (_playlistCovers.containsKey(oldName)) {
                              _playlistCovers[newName] = _playlistCovers.remove(
                                oldName,
                              )!;
                              _savePlaylistCovers();
                            }
                            if (_selectedPlaylistDetail == oldName) {
                              _selectedPlaylistDetail = newName;
                            }
                          });
                          Navigator.pop(ctx);
                          showFlowToast(loc.playlistRenamed);
                        } else if (exists) {
                          showFlowToast(loc.playlistNameExists);
                        }
                      },
                      child: Text(
                        loc.save,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: getFontFamily(_activeFont),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPlaylistOptions(
    BuildContext context,
    String title,
    List<Track> songs,
  ) {
    final isCustomPlaylist = _userPlaylists.containsKey(title) || _userOnlinePlaylists.containsKey(title);
    final isLight = isAppLight;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isLight
          ? const Color(0xFFF0F0F3)
          : const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isLight ? Colors.black12 : Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: getFontFamily(_activeFont),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 24),
                _buildOptionItem(
                  Icons.play_arrow,
                  AppLocalizations.of(context).playAll,
                  () {
                    Navigator.pop(context);
                    if (songs.isNotEmpty) {
                      _playTrack(0, sourceList: songs);
                    } else {
                      showFlowToast(AppLocalizations.of(context).playlistEmpty);
                    }
                  },
                ),
                _buildOptionItem(
                  Icons.queue_music,
                  AppLocalizations.of(context).addToQueue,
                  () {
                    Navigator.pop(context);
                    if (songs.isNotEmpty) {
                      _playbackQueue.addAll(songs);
                      showFlowToast(
                        AppLocalizations.of(context).addedSongsToQueue,
                      );
                    }
                  },
                ),
                _buildOptionItem(
                  Icons.playlist_add,
                  AppLocalizations.of(context).addToPlaylist,
                  () {
                    Navigator.pop(context);
                    _showMultiSelectSongsModal(context, candidateTracks: songs);
                  },
                ),
                if (songs.any((t) => t.isOnline))
                  _buildOptionItem(
                    Icons.download_for_offline_rounded,
                    'Download All Tracks',
                    () async {
                      Navigator.pop(context);
                      final onlineSongs =
                          songs.where((t) => t.isOnline).toList();
                      if (onlineSongs.isEmpty) return;
                      showFlowToast(
                        'Downloading ${onlineSongs.length} tracks in background...',
                      );
                      for (final song in onlineSongs) {
                        try {
                          await _downloadOnlineTrack(song);
                        } catch (_) {}
                      }
                    },
                  ),
                _buildOptionItem(
                  Icons.image,
                  AppLocalizations.of(context).editCover,
                  () async {
                    Navigator.pop(context);
                    final String? imagePath = await _showCoverSourceSelector(
                      this.context,
                    );
                    if (imagePath != null) {
                      setState(() {
                        if (imagePath == 'reset') {
                          _playlistCovers.remove(title);
                        } else {
                          _playlistCovers[title] = imagePath;
                        }
                      });
                      _savePlaylistCovers();
                      showFlowToast(
                        imagePath == 'reset'
                            ? lookupAppLocalizations(
                                Locale(FlowStrings.currentLang),
                              ).coverResetSuccess
                            : lookupAppLocalizations(
                                Locale(FlowStrings.currentLang),
                              ).playlistCoverUpdated,
                      );
                    }
                  },
                ),
                if (isCustomPlaylist) ...[
                  Divider(
                    color: isLight
                        ? Colors.black.withValues(alpha: 0.08)
                        : Colors.white10,
                    height: 1,
                  ),
                  _buildOptionItem(
                    Icons.add,
                    AppLocalizations.of(context).addSongs,
                    () {
                      Navigator.pop(context);
                      _showMultiSelectSongsModal(
                        context,
                        candidateTracks: _allTracks,
                        predefinedTargetPlaylist: title,
                      );
                    },
                  ),
                  _buildOptionItem(
                    Icons.edit,
                    AppLocalizations.of(context).renamePlaylist,
                    () {
                      Navigator.pop(context);
                      _showRenamePlaylistModal(context, title);
                    },
                  ),
                  _buildOptionItem(
                    Icons.delete_outline,
                    AppLocalizations.of(context).deletePlaylist,
                    () async {
                      Navigator.pop(context);
                      final bool? confirm = await showConfirmationDialog(
                        this.context,
                        title: AppLocalizations.of(context).confirmDelete,
                        content: AppLocalizations.of(
                          context,
                        ).confirmDeletePlaylist,
                        confirmText: AppLocalizations.of(context).delete,
                      );
                      if (confirm != true) return;

                      setState(() {
                        _userPlaylists.remove(title);
                        _userOnlinePlaylists.remove(title);
                        _playlistCovers.remove(title);
                        _savePlaylistCovers();
                        if (_selectedPlaylistDetail == title) {
                          _selectedPlaylistDetail = null;
                        }
                      });
                      _saveUserPlaylists();
                      InnerTubeService().saveUserOnlinePlaylists(_userOnlinePlaylists);
                      showFlowToast(
                        lookupAppLocalizations(
                          Locale(FlowStrings.currentLang),
                        ).playlistDeleted,
                      );
                    },
                    iconColor: Colors.redAccent,
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
