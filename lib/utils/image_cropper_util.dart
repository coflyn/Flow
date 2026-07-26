import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:crop_image/crop_image.dart';
import 'package:path_provider/path_provider.dart';
import 'globals.dart';

class ImageCropperUtil {
  static Future<String?> cropImage({
    required BuildContext context,
    required String sourcePath,
    bool squareOnly = false,
  }) async {
    return await Navigator.push<String?>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _CustomCropScreen(sourcePath: sourcePath, squareOnly: squareOnly),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class _CustomCropScreen extends StatefulWidget {
  final String sourcePath;
  final bool squareOnly;

  const _CustomCropScreen({required this.sourcePath, required this.squareOnly});

  @override
  State<_CustomCropScreen> createState() => _CustomCropScreenState();
}

class _CustomCropScreenState extends State<_CustomCropScreen> {
  late CropController _controller;
  double? _currentAspectRatio;

  @override
  void initState() {
    super.initState();
    _currentAspectRatio = widget.squareOnly ? 1.0 : null;
    _controller = CropController(
      aspectRatio: _currentAspectRatio,
      defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setAspectRatio(double? ratio) {
    if (widget.squareOnly) return;
    setState(() {
      _currentAspectRatio = ratio;
      _controller.aspectRatio = ratio;
    });
  }

  void _rotateImage() {
    _controller.rotation =
        CropRotation.values[(_controller.rotation.index + 1) % 4];
  }

  Future<void> _cropAndSave() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF1DB954)),
      ),
    );

    try {
      final bitmap = await _controller.croppedBitmap();
      final data = await bitmap.toByteData(format: ui.ImageByteFormat.png);
      if (data != null) {
        final bytes = data.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        await file.writeAsBytes(bytes);
        if (mounted) {
          Navigator.pop(context); // pop loading
          Navigator.pop(context, file.path); // pop screen
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context, null);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context, null);
      }
    }
  }

  Widget _buildAspectRatioButton(String label, double? ratio, IconData icon) {
    final isSelected = _currentAspectRatio == ratio;
    return GestureDetector(
      onTap: () => _setAspectRatio(ratio),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? const Color(0xFF1DB954).withValues(alpha: 0.15)
                  : const Color(0xFF1A1A1A),
            ),
            child: Icon(
              icon,
              color: isSelected ? const Color(0xFF1DB954) : Colors.white54,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF1DB954) : Colors.white54,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontFamily: getFontFamily(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Cropper
            Expanded(
              child: CropImage(
                image: Image.file(File(widget.sourcePath)),
                controller: _controller,
                gridColor: Colors.white.withValues(alpha: 0.8),
                scrimColor: Colors.black.withValues(alpha: 0.85),
                gridCornerSize: 20,
                gridThinWidth: 1,
                gridThickWidth: 2,
                alwaysMove: true,
                paddingSize: 0,
              ),
            ),

            // Bottom Controls Section
            Container(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              color: Colors.black,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!widget.squareOnly) ...[
                    // Rotation Icon
                    IconButton(
                      icon: const Icon(
                        Icons.rotate_90_degrees_cw,
                        color: Colors.white70,
                      ),
                      onPressed: _rotateImage,
                    ),
                    const SizedBox(height: 10),

                    // Aspect Ratio Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _buildAspectRatioButton(
                            'Custom',
                            null,
                            Icons.crop_free,
                          ),
                          const SizedBox(width: 24),
                          _buildAspectRatioButton(
                            '1:1',
                            1.0,
                            Icons.crop_square,
                          ),
                          const SizedBox(width: 24),
                          _buildAspectRatioButton(
                            '4:3',
                            4.0 / 3.0,
                            Icons.crop_5_4,
                          ),
                          const SizedBox(width: 24),
                          _buildAspectRatioButton(
                            '9:16',
                            9.0 / 16.0,
                            Icons.crop_16_9,
                          ),
                          const SizedBox(width: 24),
                          _buildAspectRatioButton(
                            '16:9',
                            16.0 / 9.0,
                            Icons.crop_16_9,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    const SizedBox(height: 40),
                  ],

                  // Bottom Actions (Cancel, Crop, Done)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white70,
                            size: 28,
                          ),
                          onPressed: () => Navigator.pop(context, null),
                        ),
                        Text(
                          'Crop',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: getFontFamily(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.check,
                            color: Color(0xFF1DB954),
                            size: 28,
                          ),
                          onPressed: _cropAndSave,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
