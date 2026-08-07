// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, invalid_use_of_protected_member
part of 'settings_screen.dart';

extension SettingsThresholdModals on _SettingsScreenState {
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
}
