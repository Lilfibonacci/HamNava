import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/core/encryption/encryption_service.dart';
import 'package:flutter_chat_room_app/core/network/pocket_base_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:cryptography/cryptography.dart';

class EncryptedMediaWidget extends StatefulWidget {
  final String url;
  final bool isVideo;
  final String fileName;
  final Uint8List? messageKeyBytes;
  final double width;
  final BoxFit fit;

  const EncryptedMediaWidget({
    super.key,
    required this.url,
    required this.isVideo,
    required this.fileName,
    this.messageKeyBytes,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
  });

  @override
  State<EncryptedMediaWidget> createState() => _EncryptedMediaWidgetState();
}

class _EncryptedMediaWidgetState extends State<EncryptedMediaWidget> {
  Uint8List? _decryptedBytes;
  VideoPlayerController? _videoController;
  bool _isLoading = true;
  bool _hasError = false;
  double? _downloadProgress;

  @override
  void initState() {
    super.initState();
    _loadAndDecryptMedia();
  }

  Future<void> _loadAndDecryptMedia() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final String cacheFileName = '${widget.url.hashCode}_${widget.fileName}';
      final File cacheFile = File('${tempDir.path}/$cacheFileName');

      if (await cacheFile.exists()) {
        final lastModified = await cacheFile.lastModified();
        if (DateTime.now().difference(lastModified).inMinutes >= 10) {
          // Expire cache after 10 minutes
          await cacheFile.delete();
        } else {
          if (!mounted) return;

          if (widget.isVideo) {
            _videoController = VideoPlayerController.file(cacheFile)
              ..initialize().then((_) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              });
            return;
          } else {
            final fileBytes = await cacheFile.readAsBytes();
            _decryptedBytes = fileBytes;
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }
      }

      final dio = Dio();
      final pb = locator.get<PocketBaseConfig>().client;
      final response = await dio.get(
        widget.url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Authorization': pb.authStore.token},
        ),
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      final Uint8List encryptedBytes = response.data;

      Uint8List fileBytes = encryptedBytes;
      if (widget.messageKeyBytes != null) {
        final encryptionService = locator.get<EncryptionService>();
        final decryptedList = await encryptionService.decryptBytes(
          encryptedBytes,
          SecretKey(widget.messageKeyBytes!),
        );
        fileBytes = Uint8List.fromList(decryptedList);
      }

      await cacheFile.writeAsBytes(fileBytes);

      if (!mounted) return;

      if (widget.isVideo) {
        _videoController = VideoPlayerController.file(cacheFile)
          ..initialize().then((_) {
            if (mounted) {
              setState(() {});
            }
          });
      } else {
        _decryptedBytes = fileBytes;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error decrypting media: $e');
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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                value: _downloadProgress,
                color: const Color(0xFF0ED0D3),
              ),
              if (_downloadProgress != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${(_downloadProgress! * 100).toInt()}%',
                    style: const TextStyle(
                      color: Color(0xFF0ED0D3),
                      fontFamily: 'CR',
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ),
            ],
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
      if (_decryptedBytes != null) {
        return Image.memory(
          _decryptedBytes!,
          width: widget.width,
          fit: widget.fit,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image),
        );
      }
      return const SizedBox();
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
