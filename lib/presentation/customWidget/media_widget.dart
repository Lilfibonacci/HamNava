import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/core/network/pocket_base_config.dart';

class MediaWidget extends StatefulWidget {
  final String url;
  final bool isVideo;
  final String fileName;
  final double? width;
  final BoxFit fit;

  const MediaWidget({
    super.key,
    required this.url,
    required this.isVideo,
    required this.fileName,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  State<MediaWidget> createState() => _MediaWidgetState();
}

class _MediaWidgetState extends State<MediaWidget> {
  VideoPlayerController? _videoController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    try {
      if (widget.isVideo) {
        final pb = locator.get<PocketBaseConfig>().client;
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.url),
          httpHeaders: {'Authorization': pb.authStore.token},
        )..initialize().then((_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }).catchError((e) {
            debugPrint('Error loading video: $e');
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error setting up media: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: 150,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white10
            : Colors.black12,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF0ED0D3),
          ),
        ),
      );
    }

    if (_hasError) {
      return Container(
        width: widget.width,
        height: 150,
        color: Colors.grey.withValues(alpha: .2),
        child: const Center(
          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
        ),
      );
    }

    if (widget.isVideo) {
      return _videoController != null && _videoController!.value.isInitialized
          ? AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_videoController!),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_videoController!.value.isPlaying) {
                          _videoController!.pause();
                        } else {
                          _videoController!.play();
                        }
                      });
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        _videoController!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              width: widget.width,
              height: 150,
              color: Colors.black12,
              child: const Center(child: CupertinoActivityIndicator()),
            );
    }

    // Image rendering
    if (_isImageFile(widget.fileName)) {
      final pb = locator.get<PocketBaseConfig>().client;
      return Image.network(
        widget.url,
        width: widget.width,
        fit: widget.fit,
        headers: {'Authorization': pb.authStore.token},
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: widget.width,
            height: 150,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white10
                : Colors.black12,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: const Color(0xFF0ED0D3),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          width: widget.width,
          height: 150,
          color: Colors.grey.withValues(alpha: .2),
          child: const Center(
            child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
          ),
        ),
      );
    }

    // Generic file rendering
    return Container(
      width: widget.width,
      padding: const EdgeInsets.all(16),
      color: Colors.black.withValues(alpha: .05),
      child: Row(
        children: [
          const Icon(CupertinoIcons.doc_fill, size: 36, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.fileName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'CR', fontSize: 14),
              textDirection: TextDirection.ltr,
            ),
          ),
        ],
      ),
    );
  }

  bool _isImageFile(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }
}
