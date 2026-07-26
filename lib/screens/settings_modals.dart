// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, invalid_use_of_protected_member
part of 'settings_screen.dart';

extension SettingsModals on _SettingsScreenState {
  void _showSleepTimerDialog() {
    final isLight = isAppLight;
    showModalBottomSheet(
      context: context,
      backgroundColor: isLight
          ? const Color(0xFFF0F0F3)
          : const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Drag Handle
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
              const SizedBox(height: 16),
              Center(
                child: Text(
                  AppLocalizations.of(context).sleepTimerTitle,
                  style: TextStyle(
                    color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Divider(
                color: isLight ? Colors.black12 : Colors.white10,
                height: 1,
              ),
              _buildTimerOption(
                '5 ${AppLocalizations.of(context).minutesFormat}',
                5,
              ),
              _buildTimerOption(
                '10 ${AppLocalizations.of(context).minutesFormat}',
                10,
              ),
              _buildTimerOption(
                '15 ${AppLocalizations.of(context).minutesFormat}',
                15,
              ),
              _buildTimerOption(
                '30 ${AppLocalizations.of(context).minutesFormat}',
                30,
              ),
              _buildTimerOption(
                '45 ${AppLocalizations.of(context).minutesFormat}',
                45,
              ),
              _buildTimerOption(AppLocalizations.of(context).hour1, 60),
              _buildCustomTimerOption(context),
              _buildTimerOption(
                AppLocalizations.of(context).endOfTrackShort,
                -1,
              ),
              _buildTimerOption(AppLocalizations.of(context).turnOff, 0),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomTimerOption(BuildContext context) {
    final isLight = isAppLight;
    final loc = AppLocalizations.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Row(
        children: [
          Icon(
            Icons.edit_calendar_rounded,
            size: 20,
            color: isLight ? const Color(0xFF1A1A1A) : Colors.white70,
          ),
          const SizedBox(width: 12),
          Text(
            loc.customTimer,
            style: TextStyle(
              color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        _showCustomTimerDialog(context);
      },
    );
  }

  void _showCustomTimerDialog(BuildContext context) {
    final isLight = isAppLight;
    final loc = AppLocalizations.of(context);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1E1E26),
          title: Text(
            loc.customTimer,
            style: TextStyle(color: isLight ? Colors.black : Colors.white),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: TextStyle(color: isLight ? Colors.black : Colors.white),
            decoration: InputDecoration(
              hintText: loc.enterMinutes,
              hintStyle: TextStyle(
                color: isLight ? Colors.black45 : Colors.white38,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: isLight ? Colors.black26 : Colors.white24,
                ),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1DB954)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                loc.cancel,
                style: const TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () {
                final val = int.tryParse(controller.text.trim());
                if (val != null && val > 0) {
                  widget.onSetSleepTimer(val);
                }
                Navigator.pop(dialogContext);
              },
              child: Text(
                loc.save,
                style: const TextStyle(color: Color(0xFF1DB954)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimerOption(String title, int minutes) {
    final isLight = isAppLight;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        title,
        style: TextStyle(
          color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: () {
        widget.onSetSleepTimer(minutes);
        Navigator.pop(context);
      },
    );
  }

  Future<void> _handleBackup() async {
    final bool? confirm = await showConfirmationDialog(
      context,
      title: AppLocalizations.of(context).confirmBackup,
      content: AppLocalizations.of(context).confirmBackupBody,
      confirmText: AppLocalizations.of(context).backup,
      confirmColor: _activeAccentColor,
    );
    if (confirm != true) return;

    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    try {
      if (await Permission.storage.isGranted ||
          await Permission.manageExternalStorage.isGranted) {
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys();
        final Map<String, dynamic> prefsMap = {};
        for (String key in keys) {
          prefsMap[key] = prefs.get(key);
        }
        final String jsonString = jsonEncode(prefsMap);

        final directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        final file = File('${directory.path}/Flow_Backup.json');
        await file.writeAsString(jsonString);

        if (!mounted) return;
        showFlowToast(AppLocalizations.of(context).backupSuccess);
      } else {
        if (!mounted) return;
        showFlowToast(AppLocalizations.of(context).permissionDenied);
      }
    } catch (e) {
      if (!mounted) return;
      showFlowToast('${AppLocalizations.of(context).backupFailed}: $e');
    }
  }

  Future<void> _handleRestore() async {
    final bool? confirm = await showConfirmationDialog(
      context,
      title: AppLocalizations.of(context).confirmRestore,
      content: AppLocalizations.of(context).confirmRestoreBody,
      confirmText: AppLocalizations.of(context).restore,
      confirmColor: _activeAccentColor,
    );
    if (confirm != true) return;

    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    try {
      if (await Permission.storage.isGranted ||
          await Permission.manageExternalStorage.isGranted) {
        final directory = Directory('/storage/emulated/0/Download');
        final file = File('${directory.path}/Flow_Backup.json');

        if (await file.exists()) {
          final String jsonString = await file.readAsString();
          final Map<String, dynamic> prefsMap = jsonDecode(jsonString);

          final prefs = await SharedPreferences.getInstance();
          for (String key in prefsMap.keys) {
            final value = prefsMap[key];
            if (value is String) {
              await prefs.setString(key, value);
            } else if (value is int) {
              await prefs.setInt(key, value);
            } else if (value is double) {
              await prefs.setDouble(key, value);
            } else if (value is bool) {
              await prefs.setBool(key, value);
            } else if (value is List<dynamic>) {
              await prefs.setStringList(key, List<String>.from(value));
            }
          }

          if (!mounted) return;
          showFlowToast(AppLocalizations.of(context).restoreSuccess);
          widget.onRescanLibrary();
        } else {
          if (!mounted) return;
          showFlowToast(AppLocalizations.of(context).noBackupFound);
        }
      } else {
        if (!mounted) return;
        showFlowToast(AppLocalizations.of(context).permissionDenied);
      }
    } catch (e) {
      if (!mounted) return;
      showFlowToast('${AppLocalizations.of(context).restoreFailed}: $e');
    }
  }

  Future<void> _showResetConfirmation() async {
    final bool? confirm = await showConfirmationDialog(
      context,
      title: AppLocalizations.of(context).resetConfirmTitle,
      content: AppLocalizations.of(context).resetConfirmBody,
      confirmText: AppLocalizations.of(context).reset,
    );
    if (confirm == true) {
      if (mounted) {
        Navigator.pop(context); // close settings
      }
      widget.onResetData();
    }
  }

  Future<void> _showHiddenTracksSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0A0A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FutureBuilder<List<SongModel>>(
              future: _songsFuture,
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

                final allSongs = snapshot.data ?? [];
                final List<SongModel> displaySongs =
                    allSongs.where((song) {
                      final bool isManuallyHidden = _hiddenTrackIds.contains(
                        song.id.toString(),
                      );
                      final bool isShortAudio =
                          _filterShortAudio && (song.duration ?? 0) < 30000;
                      return isManuallyHidden || isShortAudio;
                    }).toList()..sort(
                      (a, b) => a.title.toLowerCase().compareTo(
                        b.title.toLowerCase(),
                      ),
                    );

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
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(
                              context,
                            ).hiddenFilteredTracksTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${displaySongs.length}${AppLocalizations.of(context).tracksCountSuffix}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).hiddenTracksDesc,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: displaySongs.isEmpty
                            ? Center(
                                child: Text(
                                  AppLocalizations.of(context).noHiddenTracks,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: displaySongs.length,
                                itemBuilder: (context, index) {
                                  final song = displaySongs[index];
                                  final bool isManuallyHidden = _hiddenTrackIds
                                      .contains(song.id.toString());
                                  final bool isShortAudio =
                                      _filterShortAudio &&
                                      (song.duration ?? 0) < 30000;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF161616),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                song.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      (song.artist == null ||
                                                              song.artist ==
                                                                  '<unknown>')
                                                          ? AppLocalizations.of(
                                                              context,
                                                            ).unknownArtist
                                                          : song.artist!,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: Colors.white
                                                            .withOpacity(0.3),
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  if (isManuallyHidden)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors.orange
                                                              .withOpacity(0.3),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        ).badgeHidden,
                                                        style: const TextStyle(
                                                          color: Colors.orange,
                                                          fontSize: 8,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  if (isShortAudio)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.cyan
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors.cyan
                                                              .withOpacity(0.3),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        ).badgeShortAudio,
                                                        style: const TextStyle(
                                                          color: Colors.cyan,
                                                          fontSize: 8,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        if (isManuallyHidden)
                                          IconButton(
                                            icon: Icon(
                                              Icons.visibility_outlined,
                                              color: _activeAccentColor,
                                              size: 20,
                                            ),
                                            tooltip: AppLocalizations.of(
                                              context,
                                            ).unhideTrack,
                                            onPressed: () async {
                                              final prefs =
                                                  await SharedPreferences.getInstance();
                                              setState(() {
                                                _hiddenTrackIds.remove(
                                                  song.id.toString(),
                                                );
                                              });
                                              await prefs.setStringList(
                                                'hidden_track_ids',
                                                _hiddenTrackIds,
                                              );
                                              widget.onRescanLibrary();
                                              setModalState(() {});
                                              showFlowToast(
                                                "${song.title} restored to library",
                                              );
                                            },
                                          )
                                        else
                                          IconButton(
                                            icon: const Icon(
                                              Icons.info_outline_rounded,
                                              color: Colors.white30,
                                              size: 20,
                                            ),
                                            tooltip: AppLocalizations.of(
                                              context,
                                            ).autoHiddenTooltip,
                                            onPressed: () {
                                              showFlowToast(
                                                AppLocalizations.of(
                                                  context,
                                                ).autoHiddenToast,
                                              );
                                            },
                                          ),
                                      ],
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

  String _getThresholdLabel(int seconds) {
    if (seconds == -1) return AppLocalizations.of(context).endOfTrackShort;
    if (seconds == 60) return AppLocalizations.of(context).minute1;
    return '$seconds ${AppLocalizations.of(context).secondsFormat}';
  }

  void _showThresholdDialog() {
    final isLight = isAppLight;
    showModalBottomSheet(
      context: context,
      backgroundColor: isLight
          ? const Color(0xFFF0F0F3)
          : const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
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
              const SizedBox(height: 16),
              Center(
                child: Text(
                  AppLocalizations.of(context).mostPlayedThresholdTitle,
                  style: TextStyle(
                    color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Divider(
                color: isLight ? Colors.black12 : Colors.white10,
                height: 1,
              ),
              _buildThresholdOption(
                '5 ${AppLocalizations.of(context).secondsFormat}',
                5,
              ),
              _buildThresholdOption(
                '10 ${AppLocalizations.of(context).secondsDefaultFormat}',
                10,
              ),
              _buildThresholdOption(
                '30 ${AppLocalizations.of(context).secondsFormat}',
                30,
              ),
              _buildThresholdOption(AppLocalizations.of(context).minute1, 60),
              _buildThresholdOption(
                AppLocalizations.of(context).endOfTrackShort,
                -1,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThresholdOption(String label, int seconds) {
    final isSelected = _playCountThreshold == seconds;
    final isLight = isAppLight;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? _activeAccentColor
              : (isLight ? const Color(0xFF1A1A1A) : Colors.white),
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: _activeAccentColor)
          : null,
      onTap: () {
        ref
            .read(settingsProvider.notifier)
            .updateSetting(playCountThreshold: seconds);
        setState(() {
          _playCountThreshold = seconds;
        });
        widget.onSettingsChanged();
        Navigator.pop(context);
      },
    );
  }

  String _getFontSizeLabel(double scale) {
    if (scale == 0.85) return AppLocalizations.of(context).sizeSmall;
    if (scale == 1.15) return AppLocalizations.of(context).sizeLarge;
    if (scale == 1.3) return AppLocalizations.of(context).sizeExtraLarge;
    return AppLocalizations.of(context).sizeDefault;
  }

  void _showTypographyPreviewDialog() {
    String tempFont = _activeFont;
    double tempFontScale = _fontScale;
    final isLight = isAppLight;

    showModalBottomSheet(
      context: context,
      backgroundColor: isLight
          ? const Color(0xFFF0F0F3)
          : const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            TextStyle previewTextStyle({
              double size = 14,
              FontWeight weight = FontWeight.normal,
              Color? color,
            }) {
              final baseStyle = TextStyle(
                fontSize: size * tempFontScale,
                fontWeight: weight,
                color: color ?? (isLight ? const Color(0xFF1A1A1A) : Colors.white),
              );
              if (tempFont == 'Spotify Style') {
                return GoogleFonts.figtree(textStyle: baseStyle);
              } else if (tempFont == 'Apple Music Style') {
                return GoogleFonts.inter(textStyle: baseStyle);
              } else {
                return GoogleFonts.plusJakartaSans(textStyle: baseStyle);
              }
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
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
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          AppLocalizations.of(context).typographyFontSize,
                          style: TextStyle(
                            color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Live Preview Section Header
                      Row(
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            color: _activeAccentColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context).livePreview,
                            style: TextStyle(
                              color: isLight ? Colors.black54 : Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Live Simulated Library Window
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF0A0A0A), Color(0xFF0A0A0A)],
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Simulated Header App Bar
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Flow',
                                        style: previewTextStyle(
                                          size: 32,
                                          weight: FontWeight.w800,
                                        ).copyWith(letterSpacing: -1.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                    size: 24 * tempFontScale,
                                  ),
                                ],
                              ),
                            ),

                            // Simulated Search Bar & Sort Button Row
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF161616),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 12),
                                          Icon(
                                            Icons.search,
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                            size: 20 * tempFontScale,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              AppLocalizations.of(
                                                context,
                                              ).searchSongs,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: previewTextStyle(
                                                size: 13,
                                                color: Colors.white.withOpacity(
                                                  0.3,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF161616),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.sort_rounded,
                                      color: Colors.white.withOpacity(0.5),
                                      size: 20 * tempFontScale,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Simulated Filter Capsules
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 24,
                                right: 24,
                                top: 16,
                                bottom: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildSimulatedFilterCapsule(
                                      AppLocalizations.of(context).songsTitle,
                                      true,
                                      previewTextStyle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildSimulatedFilterCapsule(
                                      AppLocalizations.of(context).playlists,
                                      false,
                                      previewTextStyle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildSimulatedFilterCapsule(
                                      AppLocalizations.of(context).artists,
                                      false,
                                      previewTextStyle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildSimulatedFilterCapsule(
                                      AppLocalizations.of(context).albums,
                                      false,
                                      previewTextStyle,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Simulated Song List (Padding left/right 16)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                children: [
                                  _buildSimulatedSongRow(
                                    title: 'Alexandra',
                                    artist: 'Reality Club',
                                    duration: '4:08',
                                    textStyleHelper: previewTextStyle,
                                    tempFontScale: tempFontScale,
                                  ),
                                  const SizedBox(height: 4),
                                  _buildSimulatedSongRow(
                                    title: 'About You',
                                    artist: 'The 1975',
                                    duration: '5:26',
                                    textStyleHelper: previewTextStyle,
                                    tempFontScale: tempFontScale,
                                  ),
                                  const SizedBox(height: 4),
                                  _buildSimulatedSongRow(
                                    title: 'Apocalypse',
                                    artist: 'Cigarettes After Sex',
                                    duration: '4:50',
                                    textStyleHelper: previewTextStyle,
                                    tempFontScale: tempFontScale,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Typography Selection Row
                      Text(
                        AppLocalizations.of(context).fontFamily,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFontSelectorChip(
                              label: 'Plus Jakarta',
                              value: 'Plus Jakarta Sans',
                              selectedValue: tempFont,
                              onTap: () => setModalState(
                                () => tempFont = 'Plus Jakarta Sans',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFontSelectorChip(
                              label: 'Spotify Style',
                              value: 'Spotify Style',
                              selectedValue: tempFont,
                              onTap: () => setModalState(
                                () => tempFont = 'Spotify Style',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFontSelectorChip(
                              label: 'Apple Style',
                              value: 'Apple Music Style',
                              selectedValue: tempFont,
                              onTap: () => setModalState(
                                () => tempFont = 'Apple Music Style',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Font Size Selection List
                      Text(
                        AppLocalizations.of(context).fontSize,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildFontSizeSelectorRow(
                        '${AppLocalizations.of(context).sizeSmall} (85%)',
                        0.85,
                        tempFontScale,
                        (val) {
                          setModalState(() => tempFontScale = val);
                        },
                      ),
                      _buildFontSizeSelectorRow(
                        '${AppLocalizations.of(context).sizeDefault} (100%)',
                        1.0,
                        tempFontScale,
                        (val) {
                          setModalState(() => tempFontScale = val);
                        },
                      ),
                      _buildFontSizeSelectorRow(
                        '${AppLocalizations.of(context).sizeLarge} (115%)',
                        1.15,
                        tempFontScale,
                        (val) {
                          setModalState(() => tempFontScale = val);
                        },
                      ),
                      _buildFontSizeSelectorRow(
                        '${AppLocalizations.of(context).sizeExtraLarge} (130%)',
                        1.3,
                        tempFontScale,
                        (val) {
                          setModalState(() => tempFontScale = val);
                        },
                      ),

                      const SizedBox(height: 32),

                      // Bottom actions Close & Save
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.05),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context).close,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString('activeFont', tempFont);
                                await prefs.setDouble(
                                  'fontScale',
                                  tempFontScale,
                                );
                                ref
                                    .read(settingsProvider.notifier)
                                    .updateSetting(activeFont: tempFont);
                                ref
                                    .read(settingsProvider.notifier)
                                    .updateSetting(fontScale: tempFontScale);
                                setState(() {
                                  _activeFont = tempFont;
                                  _fontScale = tempFontScale;
                                });
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                                showFlowToast(
                                  "Typography & size updated successfully!",
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _activeAccentColor,
                                      _activeAccentColor.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _activeAccentColor.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context).save,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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

  String _getThemeAccentLabel(String preset) {
    switch (preset) {
      case 'dynamic':
        return AppLocalizations.of(context).dynamicArtwork;
      case 'spotify':
        return AppLocalizations.of(context).accentSpotify;
      case 'apple':
        return AppLocalizations.of(context).accentApple;
      case 'purple':
        return AppLocalizations.of(context).accentPurple;
      case 'tidal':
        return AppLocalizations.of(context).accentTidal;
      case 'orange':
        return AppLocalizations.of(context).accentOrange;
      case 'sakura':
        return AppLocalizations.of(context).accentSakura;
      case 'gold':
        return AppLocalizations.of(context).accentGold;
      case 'blue':
        return AppLocalizations.of(context).accentBlue;
      case 'lime':
        return AppLocalizations.of(context).accentLime;
      default:
        return AppLocalizations.of(context).accentSpotify;
    }
  }

  void _showThemeAccentSelectionDialog() {
    final isLight = isAppLight;
    showModalBottomSheet(
      context: context,
      backgroundColor: isLight
          ? const Color(0xFFF0F0F3)
          : const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              minChildSize: 0.4,
              maxChildSize: 0.85,
              expand: false,
              builder: (context, scrollController) {
                final presets = [
                  {
                    'id': 'dynamic',
                    'label': AppLocalizations.of(context).dynamicArtwork,
                    'desc': AppLocalizations.of(context).accentDescDynamic,
                    'color': _activeAccentColor,
                  },
                  {
                    'id': 'spotify',
                    'label': AppLocalizations.of(context).accentSpotify,
                    'desc': AppLocalizations.of(context).accentDescSpotify,
                    'color': const Color(0xFF1DB954),
                  },
                  {
                    'id': 'apple',
                    'label': AppLocalizations.of(context).accentApple,
                    'desc': AppLocalizations.of(context).accentDescApple,
                    'color': const Color(0xFFFC3C44),
                  },
                  {
                    'id': 'purple',
                    'label': AppLocalizations.of(context).accentPurple,
                    'desc': AppLocalizations.of(context).accentDescPurple,
                    'color': const Color(0xFF8E2DE2),
                  },
                  {
                    'id': 'tidal',
                    'label': AppLocalizations.of(context).accentTidal,
                    'desc': AppLocalizations.of(context).accentDescTidal,
                    'color': const Color(0xFF00F2FE),
                  },
                  {
                    'id': 'orange',
                    'label': AppLocalizations.of(context).accentOrange,
                    'desc': AppLocalizations.of(context).accentDescOrange,
                    'color': const Color(0xFFFF9233),
                  },
                  {
                    'id': 'sakura',
                    'label': AppLocalizations.of(context).accentSakura,
                    'desc': AppLocalizations.of(context).accentDescSakura,
                    'color': const Color(0xFFFF2A6D),
                  },
                  {
                    'id': 'gold',
                    'label': AppLocalizations.of(context).accentGold,
                    'desc': AppLocalizations.of(context).accentDescGold,
                    'color': const Color(0xFFDFBA59),
                  },
                  {
                    'id': 'blue',
                    'label': AppLocalizations.of(context).accentBlue,
                    'desc': AppLocalizations.of(context).accentDescBlue,
                    'color': const Color(0xFF007AFF),
                  },
                  {
                    'id': 'lime',
                    'label': AppLocalizations.of(context).accentLime,
                    'desc': AppLocalizations.of(context).accentDescLime,
                    'color': const Color(0xFFCCFF00),
                  },
                ];

                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isLight ? Colors.black12 : Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).themeAccentColor,
                      style: TextStyle(
                        color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).accentDialogSubtitle,
                      style: TextStyle(
                        color: isLight ? Colors.black54 : Colors.white54,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Divider(color: isLight ? Colors.black12 : Colors.white10),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: presets.length,
                        itemBuilder: (context, index) {
                          final p = presets[index];
                          final id = p['id'] as String;
                          final isSelected = _selectedThemeAccent == id;
                          final color = p['color'] as Color;

                          return ListTile(
                            onTap: () {
                              setModalState(() {
                                _selectedThemeAccent = id;
                              });
                              setState(() {
                                _selectedThemeAccent = id;
                              });
                              ref
                                  .read(settingsProvider.notifier)
                                  .updateSetting(themeAccentPreset: id);
                            },
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 4,
                            ),
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color.withValues(alpha: 0.15),
                                border: Border.all(
                                  color: isSelected
                                      ? color
                                      : (isLight
                                          ? Colors.black12
                                          : Colors.white10),
                                  width: isSelected ? 2.5 : 1,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: id == 'dynamic'
                                        ? const SweepGradient(
                                            colors: [
                                              Colors.red,
                                              Colors.yellow,
                                              Colors.green,
                                              Colors.blue,
                                              Colors.red,
                                            ],
                                          )
                                        : null,
                                    color: id == 'dynamic' ? null : color,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              p['label'] as String,
                              style: TextStyle(
                                color: isSelected
                                    ? (isLight ? const Color(0xFF1A1A1A) : Colors.white)
                                    : (isLight ? Colors.black87 : Colors.white70),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              p['desc'] as String,
                              style: TextStyle(
                                color: isLight ? Colors.black45 : Colors.white30,
                                fontSize: 11,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: color,
                                    size: 22,
                                  )
                                : null,
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

  Widget _buildSimulatedFilterCapsule(
    String label,
    bool isSelected,
    TextStyle Function({double size, FontWeight weight, Color? color})
    styleHelper,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : const Color(0xFF161616),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: styleHelper(
              size: 12,
              weight: FontWeight.w600,
              color: isSelected ? Colors.black : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimulatedSongRow({
    required String title,
    required String artist,
    required String duration,
    required TextStyle Function({double size, FontWeight weight, Color? color})
    textStyleHelper,
    required double tempFontScale,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Center(
              child: Icon(
                Icons.music_note,
                color: _activeAccentColor,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyleHelper(size: 14, weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyleHelper(size: 12, color: Colors.white38),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                duration,
                style: textStyleHelper(size: 12, color: Colors.white38),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.more_vert,
                color: Colors.white54,
                size: 18 * tempFontScale,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFontSelectorChip({
    required String label,
    required String value,
    required String selectedValue,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedValue == value;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? _activeAccentColor.withOpacity(0.1)
              : Colors.white.withOpacity(0.04),
          border: Border.all(
            color: isSelected
                ? _activeAccentColor
                : Colors.white.withOpacity(0.05),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? _activeAccentColor : Colors.white70,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFontSizeSelectorRow(
    String label,
    double scale,
    double currentValue,
    Function(double) onChanged,
  ) {
    final isSelected = currentValue == scale;
    return ListTile(
      onTap: () => onChanged(scale),
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? _activeAccentColor
              : Colors.white.withOpacity(0.9),
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
        ),
      ),
      leading: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? _activeAccentColor : Colors.white30,
            width: 2,
          ),
        ),
        child: isSelected
            ? Center(
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: _activeAccentColor,
                ),
              )
            : null,
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: _activeAccentColor, size: 18)
          : null,
    );
  }

  String _getPlayerBackgroundStyleLabel(String style) {
    switch (style) {
      case 'gradient':
        return AppLocalizations.of(context).gradientDynamic;
      case 'blur':
        return AppLocalizations.of(context).blurredCover;
      case 'amoled':
        return AppLocalizations.of(context).amoledBlack;
      case 'custom':
        return AppLocalizations.of(context).customImage;
      default:
        return AppLocalizations.of(context).gradientDynamic;
    }
  }

  void _showPlayerBackgroundStyleDialog() {
    final isLight = isAppLight;
    showModalBottomSheet(
      context: context,
      backgroundColor: isLight
          ? const Color(0xFFF0F0F3)
          : const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.3,
              maxChildSize: 0.75,
              expand: false,
              builder: (context, scrollController) {
                final options = [
                  {
                    'id': 'gradient',
                    'label': AppLocalizations.of(context).gradientDynamic,
                    'desc': AppLocalizations.of(context).playerBgDescGradient,
                  },
                  {
                    'id': 'blur',
                    'label': AppLocalizations.of(context).blurredCover,
                    'desc': AppLocalizations.of(context).playerBgDescBlur,
                  },
                  {
                    'id': 'amoled',
                    'label': AppLocalizations.of(context).amoledBlack,
                    'desc': AppLocalizations.of(context).playerBgDescAmoled,
                  },
                  {
                    'id': 'custom',
                    'label': AppLocalizations.of(context).customImage,
                    'desc': AppLocalizations.of(context).playerBgDescCustom,
                  },
                ];

                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isLight ? Colors.black12 : Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).playerBackground,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: getFontFamily(_activeFont),
                        color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final opt = options[index];
                          final id = opt['id'] as String;
                          final label = opt['label'] as String;
                          final desc = opt['desc'] as String;
                          final isSelected = _playerBackgroundStyle == id;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 4,
                            ),
                            onTap: () async {
                              if (id == 'custom') {
                                if (_playerCustomBgPath != null &&
                                    File(_playerCustomBgPath!).existsSync()) {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                    'playerBackgroundStyle',
                                    'custom',
                                  );
                                  if (!mounted) return;
                                  setState(() {
                                    _playerBackgroundStyle = 'custom';
                                  });
                                  setModalState(() {
                                    _playerBackgroundStyle = 'custom';
                                  });
                                  ref
                                      .read(settingsProvider.notifier)
                                      .updateSetting(
                                        playerBackgroundStyle: 'custom',
                                      );
                                  showFlowToast(
                                    '${lookupAppLocalizations(Locale(FlowStrings.currentLang)).toastBgStyleSet} $label',
                                  );
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                } else {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (image != null) {
                                    if (!context.mounted) return;
                                    final croppedPath =
                                        await ImageCropperUtil.cropImage(
                                          context: context,
                                          sourcePath: image.path,
                                        );
                                    if (croppedPath != null) {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString(
                                        'playerBackgroundStyle',
                                        'custom',
                                      );
                                      await prefs.setString(
                                        'playerCustomBgPath',
                                        croppedPath,
                                      );
                                      if (!mounted) return;
                                      setState(() {
                                        _playerBackgroundStyle = 'custom';
                                        _playerCustomBgPath = croppedPath;
                                      });
                                      setModalState(() {
                                        _playerBackgroundStyle = 'custom';
                                      });
                                      ref
                                          .read(settingsProvider.notifier)
                                          .updateSetting(
                                            playerBackgroundStyle: 'custom',
                                          );
                                      ref
                                          .read(settingsProvider.notifier)
                                          .updateSetting(
                                            playerCustomBgPath: croppedPath,
                                          );
                                      showFlowToast(
                                        '${lookupAppLocalizations(Locale(FlowStrings.currentLang)).toastBgStyleSet} $label',
                                      );
                                      if (!context.mounted) return;
                                      Navigator.pop(context);
                                    }
                                  }
                                }
                              } else {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString(
                                  'playerBackgroundStyle',
                                  id,
                                );
                                if (!mounted) return;
                                setState(() {
                                  _playerBackgroundStyle = id;
                                });
                                setModalState(() {
                                  _playerBackgroundStyle = id;
                                });
                                ref
                                    .read(settingsProvider.notifier)
                                    .updateSetting(playerBackgroundStyle: id);
                                showFlowToast(
                                  '${lookupAppLocalizations(Locale(FlowStrings.currentLang)).toastBgStyleSet} $label',
                                );
                                if (!context.mounted) return;
                                Navigator.pop(context);
                              }
                            },
                            title: Text(
                              label,
                              style: TextStyle(
                                color: isLight
                                    ? const Color(0xFF1A1A1A)
                                    : Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontFamily: getFontFamily(_activeFont),
                              ),
                            ),
                            subtitle: Text(
                              desc,
                              style: TextStyle(
                                color: isLight
                                    ? Colors.black54
                                    : Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (id == 'custom' &&
                                    _playerCustomBgPath != null) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.file(
                                      File(_playerCustomBgPath!),
                                      width: 28,
                                      height: 28,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: _activeAccentColor,
                                  ),
                              ],
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

  String _getThemeModeLabel(String mode) {
    switch (mode) {
      case 'light':
        return AppLocalizations.of(context).lightMode;
      case 'custom':
        return AppLocalizations.of(context).customTheme;
      case 'dark':
      default:
        return AppLocalizations.of(context).darkMode;
    }
  }

  void _showThemeModeSelectionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isLight = _selectedThemeMode == 'light';
        final cardColor = isLight ? Colors.white : const Color(0xFF161616);
        final titleColor = isLight ? const Color(0xFF1A1A1A) : Colors.white;

        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isLight
                      ? Colors.black.withOpacity(0.08)
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).themeMode,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildThemeModeItem(
                id: 'dark',
                title: AppLocalizations.of(context).darkMode,
                subtitle: AppLocalizations.of(context).themeModeDescDark,
                icon: Icons.dark_mode_outlined,
              ),
              _buildThemeModeItem(
                id: 'light',
                title: AppLocalizations.of(context).lightMode,
                subtitle: AppLocalizations.of(context).themeModeDescLight,
                icon: Icons.light_mode_outlined,
              ),
              _buildThemeModeItem(
                id: 'custom',
                title: AppLocalizations.of(context).customTheme,
                subtitle: AppLocalizations.of(context).themeModeDescCustom,
                icon: Icons.color_lens_outlined,
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeModeItem({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedThemeMode == id;
    final isLight = _selectedThemeMode == 'light';
    final primaryTextColor = isLight ? const Color(0xFF1A1A1A) : Colors.white;
    final secondaryTextColor = isLight ? Colors.black45 : Colors.white38;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? _activeAccentColor.withOpacity(0.1)
              : (isLight
                    ? Colors.black.withOpacity(0.04)
                    : Colors.white.withOpacity(0.05)),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected
              ? _activeAccentColor
              : (isLight ? Colors.black54 : Colors.white70),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: primaryTextColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: secondaryTextColor, fontSize: 12),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: _activeAccentColor)
          : null,
      onTap: () async {
        Navigator.pop(context);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('themeMode', id);
        setState(() {
          _selectedThemeMode = id;
        });
        ref.read(settingsProvider.notifier).updateSetting(themeMode: id);
      },
    );
  }

  Widget _buildStylePill(String id, String label) {
    final isSelected = _customThemeStyle == id;
    final isLight = _selectedThemeMode == 'light';

    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('customThemeStyle', id);
        setState(() {
          _customThemeStyle = id;
        });
        ref.read(settingsProvider.notifier).updateSetting(customThemeStyle: id);
        showFlowToast(
          '${lookupAppLocalizations(Locale(FlowStrings.currentLang)).toastThemeStyleSet} $label',
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? _activeAccentColor
              : (isLight
                    ? Colors.black.withOpacity(0.05)
                    : Colors.white.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? _activeAccentColor
                : (isLight ? Colors.black12 : Colors.white10),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isLight ? Colors.black87 : Colors.white70),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontFamily: getFontFamily(_activeFont),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomBgOption({
    required String id,
    required String name,
    required Color color,
  }) {
    final isSelected = _customThemeBg == id;
    final isLight = _selectedThemeMode == 'light';

    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('customThemeBg', id);
        setState(() {
          _customThemeBg = id;
        });
        ref.read(settingsProvider.notifier).updateSetting(customThemeBg: id);

        if (id == 'custom_image' && _customThemeBgPath == null) {
          final ImagePicker picker = ImagePicker();
          final XFile? image = await picker.pickImage(
            source: ImageSource.gallery,
          );
          if (image != null) {
            if (!mounted) return;
            final croppedPath = await ImageCropperUtil.cropImage(
              context: context,
              sourcePath: image.path,
            );
            if (croppedPath != null) {
              await prefs.setString('customThemeBgPath', croppedPath);
              setState(() {
                _customThemeBgPath = croppedPath;
              });
              ref
                  .read(settingsProvider.notifier)
                  .updateSetting(customThemeBgPath: croppedPath);
              showFlowToast(
                lookupAppLocalizations(
                  Locale(FlowStrings.currentLang),
                ).wallpaperUpdated,
              );
            }
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? _activeAccentColor.withOpacity(0.15)
              : (isLight
                    ? Colors.black.withOpacity(0.04)
                    : Colors.white.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _activeAccentColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: id == 'custom_image' && _customThemeBgPath != null
                    ? null
                    : color,
                image:
                    id == 'custom_image' &&
                        _customThemeBgPath != null &&
                        File(_customThemeBgPath!).existsSync()
                    ? DecorationImage(
                        image: FileImage(File(_customThemeBgPath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isLight ? Colors.black26 : Colors.white30,
                  width: 1,
                ),
              ),
              child: isSelected && id == 'dynamic'
                  ? const Icon(Icons.star, size: 8, color: Colors.white)
                  : (id == 'custom_image' && _customThemeBgPath == null
                        ? const Icon(Icons.add, size: 8, color: Colors.white)
                        : null),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                color: isSelected
                    ? _activeAccentColor
                    : (isLight ? const Color(0xFF1A1A1A) : Colors.white70),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelectionDialog() {
    final isLight = isAppLight;
    showModalBottomSheet(
      context: context,
      backgroundColor: isLight
          ? const Color(0xFFF0F0F3)
          : const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
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
              const SizedBox(height: 16),
              Center(
                child: Text(
                  AppLocalizations.of(context).language,
                  style: TextStyle(
                    color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Divider(
                color: isLight ? Colors.black12 : Colors.white10,
                height: 1,
              ),
              _buildLanguageOption('English', 'en', '🇺🇸'),
              _buildLanguageOption('Indonesia', 'id', '🇮🇩'),
              _buildLanguageOption('日本語', 'ja', '🇯🇵'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String label, String langCode, String flag) {
    final isSelected = _language == langCode;
    final isLight = isAppLight;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? _activeAccentColor
              : (isLight ? const Color(0xFF1A1A1A) : Colors.white),
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: _activeAccentColor)
          : null,
      onTap: () async {
        final nav = Navigator.of(context);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('language', langCode);
        languageNotifier.value = langCode;
        setState(() {
          _language = langCode;
        });
        nav.pop();
        // Force rebuild settings screen to apply new language
        setState(() {});
      },
    );
  }

  void _showLibraryDensityDialog() {
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
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
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
              const SizedBox(height: 16),
              Center(
                child: Text(
                  AppLocalizations.of(context).libraryDensity,
                  style: TextStyle(
                    color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Divider(
                color: isLight ? Colors.black12 : Colors.white10,
                height: 1,
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                leading: Icon(Icons.reorder_rounded, color: _libraryDensity == 'standard' ? _activeAccentColor : Colors.white54),
                title: Text(
                  AppLocalizations.of(context).densityStandard,
                  style: TextStyle(
                    color: _libraryDensity == 'standard'
                        ? _activeAccentColor
                        : (isLight ? const Color(0xFF1A1A1A) : Colors.white),
                    fontWeight: _libraryDensity == 'standard' ? FontWeight.bold : FontWeight.w400,
                  ),
                ),
                trailing: _libraryDensity == 'standard' ? Icon(Icons.check, color: _activeAccentColor) : null,
                onTap: () async {
                  final nav = Navigator.of(context);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('libraryDensity', 'standard');
                  setState(() => _libraryDensity = 'standard');
                  widget.onSettingsChanged();
                  nav.pop();
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                leading: Icon(Icons.density_small_rounded, color: _libraryDensity == 'compact' ? _activeAccentColor : Colors.white54),
                title: Text(
                  AppLocalizations.of(context).densityCompact,
                  style: TextStyle(
                    color: _libraryDensity == 'compact'
                        ? _activeAccentColor
                        : (isLight ? const Color(0xFF1A1A1A) : Colors.white),
                    fontWeight: _libraryDensity == 'compact' ? FontWeight.bold : FontWeight.w400,
                  ),
                ),
                trailing: _libraryDensity == 'compact' ? Icon(Icons.check, color: _activeAccentColor) : null,
                onTap: () async {
                  final nav = Navigator.of(context);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('libraryDensity', 'compact');
                  setState(() => _libraryDensity = 'compact');
                  widget.onSettingsChanged();
                  nav.pop();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showLyricFontSizeDialog() {
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isLight ? Colors.black12 : Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).lyricFontSize,
                      style: TextStyle(
                        color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isLight ? Colors.white : Colors.white10,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "Sample Lyric Line ♫",
                        style: GoogleFonts.getFont(
                          _activeFont == 'Spotify Style'
                              ? 'Figtree'
                              : _activeFont == 'Apple Music Style'
                              ? 'Inter'
                              : 'Plus Jakarta Sans',
                          fontSize: _lyricFontSize * _fontScale,
                          fontWeight: FontWeight.bold,
                          color: _activeAccentColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("14sp", style: TextStyle(color: isLight ? Colors.black54 : Colors.white54)),
                        Text("${_lyricFontSize.toInt()} sp", style: TextStyle(color: _activeAccentColor, fontWeight: FontWeight.bold)),
                        Text("30sp", style: TextStyle(color: isLight ? Colors.black54 : Colors.white54)),
                      ],
                    ),
                    Slider(
                      value: _lyricFontSize,
                      min: 14.0,
                      max: 30.0,
                      divisions: 16,
                      activeColor: _activeAccentColor,
                      onChanged: (val) {
                        setModalState(() {
                          _lyricFontSize = val;
                        });
                        setState(() {});
                      },
                      onChangeEnd: (val) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setDouble('lyricFontSize', val);
                        widget.onSettingsChanged();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPlaybackSpeedDialog() {
    final isLight = isAppLight;
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
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
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isLight ? Colors.black12 : Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).playbackSpeed,
                    style: TextStyle(
                      color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    color: isLight ? Colors.black12 : Colors.white10,
                    height: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SwitchListTile(
                      value: _pitchLock,
                      activeColor: _activeAccentColor,
                      title: Text(
                        AppLocalizations.of(context).pitchLock,
                        style: TextStyle(
                          color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onChanged: (val) async {
                        setModalState(() => _pitchLock = val);
                        setState(() => _pitchLock = val);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('pitchLock', val);
                        widget.onSettingsChanged();
                      },
                    ),
                  ),
                  Divider(
                    color: isLight ? Colors.black12 : Colors.white10,
                    height: 1,
                  ),
                  for (final spd in speeds)
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                      title: Text(
                        '${spd}x',
                        style: TextStyle(
                          color: _playbackSpeed == spd
                              ? _activeAccentColor
                              : (isLight ? const Color(0xFF1A1A1A) : Colors.white),
                          fontWeight: _playbackSpeed == spd ? FontWeight.bold : FontWeight.w400,
                        ),
                      ),
                      trailing: _playbackSpeed == spd ? Icon(Icons.check, color: _activeAccentColor) : null,
                      onTap: () async {
                        final nav = Navigator.of(context);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setDouble('playbackSpeed', spd);
                        setState(() => _playbackSpeed = spd);
                        widget.onSettingsChanged();
                        nav.pop();
                      },
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
}
