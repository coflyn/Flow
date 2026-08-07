// ignore_for_file: invalid_use_of_protected_member, deprecated_member_use
part of '../main.dart';

extension _FolderScanUI on _MainScreenState {
  void _showFolderScanDialog(BuildContext context) {
    final Future<List<SongModel>> queryFuture = _audioQuery.querySongs(
      sortType: SongSortType.DATE_ADDED,
      orderType: OrderType.DESC_OR_GREATER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

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
            return FutureBuilder<List<SongModel>>(
              future: queryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _activeAccentColor,
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).noMusicFolders,
                        style: TextStyle(
                          color: isLight ? Colors.black45 : Colors.white30,
                          fontSize: 14,
                          fontFamily: getFontFamily(_activeFont),
                        ),
                      ),
                    ),
                  );
                }

                // Group songs by parent directory path
                final Map<String, List<SongModel>> folderGroups = {};
                for (final song in snapshot.data!) {
                  if (song.data.isEmpty) continue;
                  final parentDir = _getParentDirectory(song.data);
                  if (parentDir.isEmpty) continue;
                  folderGroups.putIfAbsent(parentDir, () => []).add(song);
                }

                final List<String> allFolders = folderGroups.keys.toList()
                  ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

                // Parse current allowed folders
                List<String> currentAllowed = [];
                if (_specificFolderScan.isNotEmpty) {
                  try {
                    currentAllowed = List<String>.from(
                      jsonDecode(_specificFolderScan),
                    );
                  } catch (_) {}
                }

                // If allowed folders is empty, visually treat all folders as enabled
                final bool isFilteringActive = currentAllowed.isNotEmpty;

                return Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  padding: const EdgeInsets.only(
                    top: 12,
                    left: 24,
                    right: 24,
                    bottom: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isLight ? Colors.black12 : Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context).specificFolderScan,
                            style: TextStyle(
                              color: isLight
                                  ? const Color(0xFF1A1A1A)
                                  : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: getFontFamily(_activeFont),
                            ),
                          ),
                          if (isFilteringActive)
                            TextButton(
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString('specificFolderScan', '');
                                setState(() {
                                  _specificFolderScan = '';
                                });
                                _requestPermissionAndScan(showLoading: false);
                                setModalState(() {});
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                AppLocalizations.of(context).resetFilter,
                                style: TextStyle(
                                  color: _activeAccentColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  fontFamily: getFontFamily(_activeFont),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).folderScanDesc,
                        style: TextStyle(
                          color: isLight ? Colors.black54 : Colors.white54,
                          fontSize: 12,
                          fontFamily: getFontFamily(_activeFont),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: allFolders.length,
                          itemBuilder: (context, index) {
                            final folderPath = allFolders[index];
                            final songsInFolder =
                                folderGroups[folderPath] ?? [];
                            final folderName = folderPath.split('/').last;
                            final bool isEnabled =
                                !isFilteringActive ||
                                currentAllowed.contains(folderPath);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isLight
                                    ? Colors.black.withValues(alpha: 0.04)
                                    : const Color(0xFF22222B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SwitchListTile(
                                activeThumbColor: _activeAccentColor,
                                activeTrackColor: _activeAccentColor.withValues(
                                  alpha: 0.2,
                                ),
                                inactiveThumbColor: isLight
                                    ? Colors.black26
                                    : Colors.white24,
                                inactiveTrackColor: isLight
                                    ? Colors.black12
                                    : Colors.white12,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.folder,
                                      color: _activeAccentColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        folderName.isEmpty
                                            ? AppLocalizations.of(
                                                context,
                                              ).folderRoot
                                            : folderName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isLight
                                              ? const Color(0xFF1A1A1A)
                                              : Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          fontFamily: getFontFamily(
                                            _activeFont,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isLight
                                            ? Colors.black.withValues(
                                                alpha: 0.05,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.05,
                                              ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${songsInFolder.length}',
                                        style: TextStyle(
                                          color: isLight
                                              ? Colors.black54
                                              : Colors.white70,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: getFontFamily(
                                            _activeFont,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 30,
                                  ),
                                  child: Text(
                                    folderPath,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isLight
                                          ? Colors.black38
                                          : Colors.white30,
                                      fontSize: 11,
                                      fontFamily: getFontFamily(_activeFont),
                                    ),
                                  ),
                                ),
                                value: isEnabled,
                                onChanged: (value) async {
                                  List<String> newAllowed = List.from(
                                    currentAllowed,
                                  );
                                  if (!isFilteringActive) {
                                    newAllowed = List.from(allFolders);
                                  }

                                  if (value) {
                                    if (!newAllowed.contains(folderPath)) {
                                      newAllowed.add(folderPath);
                                    }
                                  } else {
                                    newAllowed.remove(folderPath);
                                  }

                                  if (newAllowed.length == allFolders.length) {
                                    newAllowed.clear();
                                  }

                                  final String jsonStr = newAllowed.isNotEmpty
                                      ? jsonEncode(newAllowed)
                                      : '';
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                    'specificFolderScan',
                                    jsonStr,
                                  );

                                  setState(() {
                                    _specificFolderScan = jsonStr;
                                  });
                                  _requestPermissionAndScan(showLoading: false);
                                  setModalState(() {});
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
