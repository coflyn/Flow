// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, invalid_use_of_protected_member
part of 'settings_screen.dart';

extension SettingsThemeAccentModals on _SettingsScreenState {
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
                                    ? (isLight
                                          ? const Color(0xFF1A1A1A)
                                          : Colors.white)
                                    : (isLight
                                          ? Colors.black87
                                          : Colors.white70),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              p['desc'] as String,
                              style: TextStyle(
                                color: isLight
                                    ? Colors.black45
                                    : Colors.white30,
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
}
