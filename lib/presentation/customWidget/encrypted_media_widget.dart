import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/core/encryption/encryption_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:cryptography/cryptography.dart';

class EncryptedMediaWidget extends StatefulWidget {
  final String url;
  final bool isVideo;
  final String fileName;
  final Uint8List? messageKeyBytes; // If null, file is not encrypted (e.g. backward compatibility)
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
  File? _decryptedVideoFile;
  VideoPlayerController? _videoController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAndDecryptMedia();
  }

  Future<void> _loadAndDecryptMedia() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        widget.url,
        options: Options(responseType: ResponseType.bytes),
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

      if (!mounted) return;

      if (widget.isVideo) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/decrypted_${widget.fileName}');
        await file.writeAsBytes(fileBytes);
        _decryptedVideoFile = file;
        _videoController = VideoPlayerController.file(file)
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
    if (_decryptedVideoFile != null && _decryptedVideoFile!.existsSync()) {
      _decryptedVideoFile!.deleteSync();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: 150,
        color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.white10 : Colors.black12,
        child: const Center(
          child: SpinKitPulse(color: Color(0xFF0ED0D3), size: 30),
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
                      decoration: BoxDecoration(
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
    if (_decryptedBytes != null) {
      return Image.memory(
        _decryptedBytes!,
        width: widget.width,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
      );
    }

    return const SizedBox();
  }
}
