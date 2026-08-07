// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, invalid_use_of_protected_member
part of 'settings_screen.dart';

extension SettingsSleepTimerModals on _SettingsScreenState {
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
          backgroundColor: isLight
              ? const Color(0xFFFFFFFF)
              : const Color(0xFF1E1E26),
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
}
