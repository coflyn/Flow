// ignore_for_file: invalid_use_of_protected_member
part of '../main.dart';

extension _ModalsUtilityUI on _MainScreenState {

  void _showEqualizerSheet(BuildContext context) {
    final isLight = isAppLight;
    showModalBottomSheet(
      context: context,
      backgroundColor: isLight
          ? const Color(0xFFF0F0F3)
          : const Color(0xFF121212),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return _EqualizerSheetContent(
          player: _audioPlayer,
          activeFont: _activeFont,
          accentColor: _activeAccentColor,
        );
      },
    );
  }
}
