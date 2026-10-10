import "package:flutter/foundation.dart";
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/core/network/pocket_base_config.dart';


class UserAvatarWidget extends StatelessWidget {
  final String? userId;
  final String? avatarFileName;
  final double radius;
  final Color? backgroundColor;
  final Color? iconColor;

  const UserAvatarWidget({
    super.key,
    required this.userId,
    required this.avatarFileName,
    this.radius = 24,
    this.backgroundColor,
    this.iconColor,
  });

  String? get _avatarUrl {
    if (userId == null ||
        userId!.isEmpty ||
        avatarFileName == null ||
        avatarFileName!.isEmpty) {
      return null;
    }
    final baseUrl =
        locator.get<PocketBaseConfig>().client.baseURL;
    return '$baseUrl/api/files/users/$userId/$avatarFileName';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = backgroundColor ??
        (isDark ? Colors.grey.shade800 : Colors.grey.shade200);
    final defaultIconColor =
        iconColor ?? (isDark ? Colors.grey.shade500 : Colors.grey.shade400);

    final url = _avatarUrl;

    if (url == null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: defaultBg,
        child: Icon(
          CupertinoIcons.person_fill,
          size: radius * 0.9,
          color: defaultIconColor,
        ),
      );
    }

    if (kIsWeb) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: defaultBg,
        backgroundImage: NetworkImage(url),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
        backgroundColor: defaultBg,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: defaultBg,
        child: Icon(
          CupertinoIcons.person_fill,
          size: radius * 0.9,
          color: defaultIconColor,
        ),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: radius,
        backgroundColor: defaultBg,
        child: Icon(
          CupertinoIcons.person_fill,
          size: radius * 0.9,
          color: defaultIconColor,
        ),
      ),
    );
  }
}

