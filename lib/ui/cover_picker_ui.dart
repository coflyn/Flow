// ignore_for_file: invalid_use_of_protected_member, deprecated_member_use
part of '../main.dart';

extension _CoverPickerUI on _MainScreenState {
  Future<String?> _showCoverSourceSelector(BuildContext context) async {
    final isLight = isAppLight;
    return await showModalBottomSheet<String?>(
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
                  AppLocalizations.of(context).selectImageSource,
                  style: TextStyle(
                    color: isLight ? const Color(0xFF1A1A1A) : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: getFontFamily(_activeFont),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildOptionItem(
                Icons.photo_library,
                AppLocalizations.of(context).chooseFromGallery,
                () {
                  Navigator.pop(context, 'gallery');
                },
              ),
              _buildOptionItem(
                Icons.music_note,
                AppLocalizations.of(context).chooseFromSong,
                () {
                  Navigator.pop(context, 'song');
                },
              ),
              _buildOptionItem(
                Icons.no_photography_outlined,
                AppLocalizations.of(context).removeCustomCover,
                () {
                  Navigator.pop(context, 'reset');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    ).then((source) async {
      if (source == 'gallery') {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) {
          if (!context.mounted) return null;
          final cropped = await ImageCropperUtil.cropImage(
            context: context,
            sourcePath: image.path,
            squareOnly: true,
          );
          return cropped;
        }
        return null;
      } else if (source == 'song') {
        if (!context.mounted) return null;
        return await _showSongCoverPicker(context);
      } else if (source == 'reset') {
        return 'reset';
      }
      return null;
    });
  }
}
