import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tabunganku/core/theme/app_colors.dart';

class CropPage extends StatefulWidget {
  final String imagePath;

  const CropPage({super.key, required this.imagePath});

  @override
  State<CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
  final GlobalKey _boundaryKey = GlobalKey();
  final TransformationController _transformationController = TransformationController();
  int _quarterTurns = 0;
  bool _isCropping = false;
  double? _imageWidth;
  double? _imageHeight;
  bool _isLoadingDimensions = true;

  @override
  void initState() {
    super.initState();
    _loadImageDimensions();
  }

  void _loadImageDimensions() {
    final image = FileImage(File(widget.imagePath));
    image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        if (mounted) {
          setState(() {
            _imageWidth = info.image.width.toDouble();
            _imageHeight = info.image.height.toDouble();
            _isLoadingDimensions = false;
          });
        }
      }),
    );
  }

  void _rotateImage() {
    setState(() {
      _quarterTurns = (_quarterTurns + 1) % 4;
      _transformationController.value = Matrix4.identity(); // Reset zoom/pan on rotate
    });
  }

  Future<void> _confirmCrop() async {
    if (_isCropping) return;
    setState(() {
      _isCropping = true;
    });

    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Boundary not found');

      // Capture the exact layout area inside the boundary
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('ByteData conversion failed');

      final bytes = byteData.buffer.asUint8List();

      // Save to a temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
          '${tempDir.path}/cropped_profile_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(bytes);

      if (mounted) {
        Navigator.pop(context, tempFile.path);
      }
    } catch (e) {
      debugPrint('Error cropping image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memotong gambar. Coba lagi.',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCropping = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const ui.Color(0xFF0F0F11),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Sesuaikan Foto',
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ── Centered Interactive Viewport ───────────────────────
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background dark overlay
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.5),
                ),

                // Cropping Box boundary
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.8),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: RepaintBoundary(
                      key: _boundaryKey,
                      child: Container(
                        width: 300,
                        height: 300,
                        color: Colors.black,
                        child: _isLoadingDimensions
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.tealAccent,
                                ),
                              )
                            : Builder(
                                builder: (context) {
                                  final aspectRatio = _imageWidth! / _imageHeight!;
                                  double childWidth;
                                  double childHeight;
                                  
                                  // Determine size so the image always covers the 300x300 viewport
                                  if (aspectRatio >= 1.0) {
                                    childHeight = 300;
                                    childWidth = 300 * aspectRatio;
                                  } else {
                                    childWidth = 300;
                                    childHeight = 300 / aspectRatio;
                                  }

                                  return InteractiveViewer(
                                    transformationController: _transformationController,
                                    minScale: 1.0,
                                    maxScale: 4.0,
                                    boundaryMargin: EdgeInsets.zero,
                                    constrained: false,
                                    child: RotatedBox(
                                      quarterTurns: _quarterTurns,
                                      child: SizedBox(
                                        width: childWidth,
                                        height: childHeight,
                                        child: Image.file(
                                          File(widget.imagePath),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ),

                // Thin elegant crop frame overlays
                IgnorePointer(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Thin elegant outer square boundary touching the circle for alignment guides!
                IgnorePointer(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.0),
                      borderRadius: BorderRadius.circular(8), // Modern subtle roundness for the outer box
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Panel with Exactly 3 Minimalist Buttons ──────
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. Cancel Button
                  _buildCropActionButton(
                    icon: Icons.close_rounded,
                    color: Colors.white.withOpacity(0.08),
                    borderColor: Colors.white.withOpacity(0.12),
                    iconColor: Colors.white,
                    onTap: () => Navigator.pop(context),
                  ),

                  // 2. Rotate Button
                  _buildCropActionButton(
                    icon: Icons.rotate_right_rounded,
                    color: Colors.white.withOpacity(0.08),
                    borderColor: Colors.white.withOpacity(0.12),
                    iconColor: Colors.tealAccent,
                    onTap: _rotateImage,
                  ),

                  // 3. Confirm Crop Button
                  _isCropping
                      ? Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      : _buildCropActionButton(
                          icon: Icons.check_rounded,
                          color: AppColors.primary,
                          borderColor: Colors.transparent,
                          iconColor: Colors.white,
                          hasShadow: true,
                          onTap: _confirmCrop,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropActionButton({
    required IconData icon,
    required Color color,
    required Color borderColor,
    required Color iconColor,
    required VoidCallback onTap,
    bool hasShadow = false,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}
