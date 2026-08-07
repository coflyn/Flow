// ignore_for_file: invalid_use_of_protected_member, deprecated_member_use
part of '../main.dart';

extension _SortModalUI on _MainScreenState {
  void _showSortModal(BuildContext context) {
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
            Widget buildSortItem(String value, String label, IconData icon) {
              final isSelected = _sortBy == value;
              return ListTile(
                onTap: () async {
                  final nav = Navigator.of(context);
                  setState(() {
                    _sortBy = value;
                    _animatedTrackIds.addAll(_allTracks.map((t) => t.id));
                    _animatedArtistIds.addAll(_allTracks.map((t) => t.artist));
                    _animatedAlbumIds.addAll(_allTracks.map((t) => t.album));
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('sortBy', value);
                  nav.pop();
                },
                leading: Icon(
                  icon,
                  color: isSelected
                      ? _activeAccentColor
                      : (isLight ? Colors.black54 : Colors.white60),
                ),
                title: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? _activeAccentColor
                        : (isLight ? const Color(0xFF1A1A1A) : Colors.white),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontFamily: getFontFamily(_activeFont),
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: _activeAccentColor)
                    : null,
              );
            }

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      AppLocalizations.of(context).sortBy,
                      style: TextStyle(
                        color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: getFontFamily(_activeFont),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(
                    color: isLight
                        ? Colors.black.withValues(alpha: 0.08)
                        : Colors.white10,
                    height: 1,
                  ),
                  buildSortItem(
                    'date',
                    AppLocalizations.of(context).sortRecentlyAdded,
                    Icons.calendar_today_rounded,
                  ),
                  buildSortItem(
                    'date_oldest',
                    AppLocalizations.of(context).sortOldest,
                    Icons.history_toggle_off_rounded,
                  ),
                  buildSortItem(
                    'title',
                    AppLocalizations.of(context).sortTitleAz,
                    Icons.sort_by_alpha_rounded,
                  ),
                  buildSortItem(
                    'artist',
                    AppLocalizations.of(context).sortArtistAz,
                    Icons.person_search_rounded,
                  ),
                  buildSortItem(
                    'album',
                    AppLocalizations.of(context).sortAlbumAz,
                    Icons.album_rounded,
                  ),
                  buildSortItem(
                    'duration_longest',
                    AppLocalizations.of(context).sortDurationLongest,
                    Icons.hourglass_top_rounded,
                  ),
                  buildSortItem(
                    'duration_shortest',
                    AppLocalizations.of(context).sortDurationShortest,
                    Icons.hourglass_bottom_rounded,
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
