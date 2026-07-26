// ignore_for_file: invalid_use_of_protected_member
part of '../main.dart';

extension _ModalsPlaylistUI on _MainScreenState {
  void _showMultiSelectSongsModal(
    BuildContext context, {
    required List<Track> candidateTracks,
    String? predefinedTargetPlaylist,
  }) {
    Set<String> selectedTrackIds = {};

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
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) {
                return Column(
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Songs',
                            style: TextStyle(
                              color: isLight
                                  ? const Color(0xFF1A1A1A)
                                  : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: getFontFamily(_activeFont),
                            ),
                          ),
                          TextButton(
                            onPressed: selectedTrackIds.isEmpty
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    final selectedTracks = candidateTracks
                                        .where(
                                          (t) =>
                                              selectedTrackIds.contains(t.id),
                                        )
                                        .toList();
                                    if (predefinedTargetPlaylist != null) {
                                      setState(() {
                                        _userPlaylists[predefinedTargetPlaylist]!
                                            .addAll(selectedTrackIds);
                                        _cachedDetailKey = null;
                                        _saveUserPlaylists();
                                      });
                                      showFlowToast(
                                        AppLocalizations.of(context)
                                            .toastAddedSongsToSimple
                                            .replaceFirst(
                                              '{}',
                                              '${selectedTrackIds.length}',
                                            )
                                            .replaceFirst(
                                              '{}',
                                              predefinedTargetPlaylist,
                                            ),
                                      );
                                    } else {
                                      _showAddToPlaylistModal(
                                        context,
                                        selectedTracks,
                                      );
                                    }
                                  },
                            child: Text(
                              predefinedTargetPlaylist != null
                                  ? AppLocalizations.of(context).save
                                  : AppLocalizations.of(context).next,
                              style: TextStyle(
                                color: selectedTrackIds.isEmpty
                                    ? (isLight
                                          ? Colors.black12
                                          : Colors.white24)
                                    : _activeAccentColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: getFontFamily(_activeFont),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: isLight
                          ? Colors.black.withValues(alpha: 0.08)
                          : Colors.white10,
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: candidateTracks.length,
                        itemBuilder: (context, index) {
                          final track = candidateTracks[index];
                          final isSelected = selectedTrackIds.contains(
                            track.id,
                          );
                          return ListTile(
                            leading: _buildTrackArtwork(
                              track,
                              size: 44,
                              radius: 6,
                            ),
                            title: Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isLight
                                    ? const Color(0xFF1A1A1A)
                                    : Colors.white,
                                fontFamily: getFontFamily(_activeFont),
                              ),
                            ),
                            subtitle: Text(
                              track.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isLight
                                    ? Colors.black54
                                    : Colors.white54,
                                fontSize: 12,
                                fontFamily: getFontFamily(_activeFont),
                              ),
                            ),
                            trailing: Checkbox(
                              value: isSelected,
                              activeColor: _activeAccentColor,
                              checkColor: isLight ? Colors.white : Colors.black,
                              onChanged: (val) {
                                setModalState(() {
                                  if (val == true) {
                                    selectedTrackIds.add(track.id);
                                  } else {
                                    selectedTrackIds.remove(track.id);
                                  }
                                });
                              },
                            ),
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  selectedTrackIds.remove(track.id);
                                } else {
                                  selectedTrackIds.add(track.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showEditPlaylistSongsModal(BuildContext context, String playlistName) {
    final trackIds = _userPlaylists[playlistName] ?? <String>[];
    final playlistSongs = _allTracks
        .where((t) => trackIds.contains(t.id))
        .toList();

    Set<String> selectedForDeletion = {};
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
        return StatefulBuilder(
          builder: (context, setModalState) {
            final hasSelection = selectedForDeletion.isNotEmpty;
            final isAllSelected =
                playlistSongs.isNotEmpty &&
                selectedForDeletion.length == playlistSongs.length;

            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) {
                return Column(
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${AppLocalizations.of(context).editPlaylistTitle} "$playlistName"',
                              style: TextStyle(
                                color: isLight
                                    ? const Color(0xFF1A1A1A)
                                    : Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: getFontFamily(_activeFont),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              AppLocalizations.of(context).done,
                              style: TextStyle(
                                color: _activeAccentColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: getFontFamily(_activeFont),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: isLight
                          ? Colors.black.withValues(alpha: 0.08)
                          : Colors.white10,
                    ),

                    // Toolbar for Add Songs, Select All, and Delete
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          // Add Songs Pill
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showMultiSelectSongsModal(
                                context,
                                candidateTracks: _allTracks,
                                predefinedTargetPlaylist: playlistName,
                              );
                            },
                            icon: Icon(
                              Icons.add,
                              size: 16,
                              color: isLight ? Colors.black87 : Colors.white,
                            ),
                            label: Text(
                              AppLocalizations.of(context).addSongs,
                              style: TextStyle(
                                color: isLight ? Colors.black87 : Colors.white,
                                fontSize: 12,
                                fontFamily: getFontFamily(_activeFont),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isLight
                                    ? Colors.black12
                                    : Colors.white24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Select All text
                          TextButton(
                            onPressed: playlistSongs.isEmpty
                                ? null
                                : () {
                                    setModalState(() {
                                      if (isAllSelected) {
                                        selectedForDeletion.clear();
                                      } else {
                                        selectedForDeletion = playlistSongs
                                            .map((t) => t.id)
                                            .toSet();
                                      }
                                    });
                                  },
                            child: Text(
                              isAllSelected
                                  ? AppLocalizations.of(context).deselectAll
                                  : AppLocalizations.of(context).selectAll,
                              style: TextStyle(
                                color: isLight
                                    ? Colors.black54
                                    : Colors.white70,
                                fontSize: 12,
                                fontFamily: getFontFamily(_activeFont),
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: !hasSelection
                                ? null
                                : () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        backgroundColor: isLight
                                            ? const Color(0xFFF0F0F3)
                                            : const Color(0xFF1E1E1E),
                                        title: Text(
                                          AppLocalizations.of(
                                            context,
                                          ).removeSongsConfirm,
                                          style: TextStyle(
                                            color: isLight
                                                ? const Color(0xFF1A1A1A)
                                                : Colors.white,
                                            fontFamily: getFontFamily(_activeFont),
                                          ),
                                        ),
                                        content: Text(
                                          AppLocalizations.of(
                                            context,
                                          ).removeSongsBody,
                                          style: TextStyle(
                                            color: isLight
                                                ? Colors.black54
                                                : Colors.white70,
                                            fontFamily: getFontFamily(_activeFont),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: Text(
                                              AppLocalizations.of(
                                                context,
                                              ).cancel,
                                              style: TextStyle(
                                                color: isLight
                                                    ? Colors.black38
                                                    : Colors.white38,
                                                fontFamily: getFontFamily(_activeFont),
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              setState(() {
                                                _userPlaylists[playlistName]!
                                                    .removeWhere(
                                                      (id) =>
                                                          selectedForDeletion
                                                              .contains(id),
                                                    );
                                                _cachedDetailKey = null;
                                                _saveUserPlaylists();
                                              });
                                              Navigator.pop(
                                                context,
                                              ); // Close sheet
                                              showFlowToast(
                                                AppLocalizations.of(
                                                  context,
                                                ).removedSongsToast,
                                              );
                                            },
                                            child: Text(
                                              AppLocalizations.of(
                                                context,
                                              ).remove,
                                              style: TextStyle(
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: getFontFamily(_activeFont),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                            icon: Icon(
                              Icons.delete_outline,
                              color: hasSelection
                                  ? Colors.redAccent
                                  : (isLight ? Colors.black12 : Colors.white24),
                            ),
                            tooltip: AppLocalizations.of(context).delete,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: isLight
                          ? Colors.black.withValues(alpha: 0.08)
                          : Colors.white10,
                    ),

                    Expanded(
                      child: playlistSongs.isEmpty
                          ? Center(
                              child: Text(
                                AppLocalizations.of(context).noSongsInPlaylist,
                                style: TextStyle(
                                  color: isLight
                                      ? Colors.black38
                                      : Colors.white30,
                                  fontFamily: getFontFamily(_activeFont),
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: playlistSongs.length,
                              itemBuilder: (context, index) {
                                final track = playlistSongs[index];
                                final isSelected = selectedForDeletion.contains(
                                  track.id,
                                );
                                return ListTile(
                                  onTap: () {
                                    setModalState(() {
                                      if (isSelected) {
                                        selectedForDeletion.remove(track.id);
                                      } else {
                                        selectedForDeletion.add(track.id);
                                      }
                                    });
                                  },
                                  leading: _buildTrackArtwork(
                                    track,
                                    size: 44,
                                    radius: 6,
                                  ),
                                  title: Text(
                                    track.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isLight
                                          ? const Color(0xFF1A1A1A)
                                          : Colors.white,
                                      fontFamily: getFontFamily(_activeFont),
                                    ),
                                  ),
                                  subtitle: Text(
                                    track.artist,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isLight
                                          ? Colors.black54
                                          : Colors.white54,
                                      fontSize: 12,
                                      fontFamily: getFontFamily(_activeFont),
                                    ),
                                  ),
                                  trailing: Checkbox(
                                    value: isSelected,
                                    activeColor: Colors.redAccent,
                                    onChanged: (val) {
                                      setModalState(() {
                                        if (isSelected) {
                                          selectedForDeletion.remove(track.id);
                                        } else {
                                          selectedForDeletion.add(track.id);
                                        }
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

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
                      _showCreatePlaylistModal(
                        context,
                        tracksToAdd: tracksToAdd,
                      );
                    },
                  ),
                  if (_userPlaylists.isNotEmpty)
                    Divider(
                      color: isLight
                          ? Colors.black.withValues(alpha: 0.08)
                          : Colors.white10,
                      height: 1,
                    ),
                  ..._userPlaylists.keys.map((playlistName) {
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isLight
              ? const Color(0xFFF0F0F3)
              : const Color(0xFF282828),
          title: Text(
            AppLocalizations.of(context).newPlaylist,
            style: TextStyle(
              color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
              fontFamily: getFontFamily(_activeFont),
            ),
          ),
          content: TextField(
            controller: nameController,
            style: TextStyle(
              color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
              fontFamily: getFontFamily(_activeFont),
            ),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).playlistNamePlaceholder,
              hintStyle: TextStyle(
                color: isLight ? Colors.black38 : Colors.white54,
                fontFamily: getFontFamily(_activeFont),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: isLight ? Colors.black12 : Colors.white24,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: _activeAccentColor),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context).cancel,
                style: TextStyle(
                  color: isLight ? Colors.black45 : Colors.white54,
                  fontFamily: getFontFamily(_activeFont),
                ),
              ),
            ),
            TextButton(
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
                  Navigator.pop(context);
                  showFlowToast(
                    AppLocalizations.of(
                      context,
                    ).playlistCreatedFormat.replaceFirst('[placeholder]', name),
                  );
                }
              },
              child: Text(
                AppLocalizations.of(context).createPlaylist.split(' ')[0],
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

  void _showRenamePlaylistModal(BuildContext context, String oldName) {
    final TextEditingController nameController = TextEditingController(
      text: oldName,
    );
    final isLight = isAppLight;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isLight
              ? const Color(0xFFF0F0F3)
              : const Color(0xFF282828),
          title: Text(
            AppLocalizations.of(context).renamePlaylist,
            style: TextStyle(
              color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
              fontFamily: getFontFamily(_activeFont),
            ),
          ),
          content: TextField(
            controller: nameController,
            style: TextStyle(
              color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
              fontFamily: getFontFamily(_activeFont),
            ),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).playlistNamePlaceholder,
              hintStyle: TextStyle(
                color: isLight ? Colors.black38 : Colors.white54,
                fontFamily: getFontFamily(_activeFont),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: isLight ? Colors.black12 : Colors.white24,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: _activeAccentColor),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context).cancel,
                style: TextStyle(
                  color: isLight ? Colors.black45 : Colors.white54,
                  fontFamily: getFontFamily(_activeFont),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty &&
                    newName != oldName &&
                    !_userPlaylists.containsKey(newName)) {
                  setState(() {
                    final tracks = _userPlaylists.remove(oldName);
                    _userPlaylists[newName] = tracks!;
                    if (_playlistCovers.containsKey(oldName)) {
                      _playlistCovers[newName] = _playlistCovers.remove(
                        oldName,
                      )!;
                      _savePlaylistCovers();
                    }
                    if (_selectedPlaylistDetail == oldName) {
                      _selectedPlaylistDetail = newName;
                    }
                    _saveUserPlaylists();
                  });
                  Navigator.pop(context);
                  showFlowToast(AppLocalizations.of(context).playlistRenamed);
                } else if (_userPlaylists.containsKey(newName)) {
                  showFlowToast(
                    AppLocalizations.of(context).playlistNameExists,
                  );
                }
              },
              child: Text(
                AppLocalizations.of(context).save,
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

  void _showPlaylistOptions(
    BuildContext context,
    String title,
    List<Track> songs,
  ) {
    final isCustomPlaylist = _userPlaylists.containsKey(title);
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
                        _playlistCovers.remove(title);
                        _savePlaylistCovers();
                        if (_selectedPlaylistDetail == title) {
                          _selectedPlaylistDetail = null;
                        }
                      });
                      _saveUserPlaylists();
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
