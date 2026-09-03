import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Visionneuse d'image plein écran avec zoom interactif (pinch-to-zoom).
class FullScreenImageViewer extends StatelessWidget {
  final String base64String;
  final String? tag;

  const FullScreenImageViewer({
    super.key,
    required this.base64String,
    this.tag,
  });

  /// Ouvre la visionneuse plein écran de façon fluide
  static void open(BuildContext context, {required String base64String, String? tag}) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.92),
        pageBuilder: (context, _, __) => FullScreenImageViewer(
          base64String: base64String,
          tag: tag,
        ),
        transitionsBuilder: (context, anim, _, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? bytes;
    try {
      bytes = base64Decode(base64String);
    } catch (_) {
      bytes = null;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // Zone cliquable pour zoomer et déplacer
            Center(
              child: bytes == null
                  ? const Icon(
                      Icons.broken_image_rounded,
                      color: Colors.white54,
                      size: 64,
                    )
                  : InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.8,
                      maxScale: 4.5,
                      child: tag != null
                          ? Hero(
                              tag: tag!,
                              child: Image.memory(
                                bytes,
                                fit: BoxFit.contain,
                              ),
                            )
                          : Image.memory(
                              bytes,
                              fit: BoxFit.contain,
                            ),
                    ),
            ),

            // Bouton de fermeture en haut à droite
            Positioned(
              top: 16,
              right: 16,
              child: Material(
                color: Colors.black.withValues(alpha: 0.5),
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
