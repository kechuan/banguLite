import 'package:bangu_lite/models/user_details.dart';
import 'package:bangu_lite/widgets/dialogs/user_information_dialog.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:flutter/material.dart';

class BangumiUserAvatar extends StatelessWidget {
  const BangumiUserAvatar({
    super.key,
    this.size,
    this.userInformation,
  });

  final UserInformation? userInformation;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return UnVisibleResponse(
      onTap: () {
        if(userInformation?.userName == null) return;
        showUserInfomationDialog(context, userInformation);
      },
      child: SizedBox(
        height: size,
        width: size,
        child: CachedImageLoader(imageUrl: userInformation?.avatarUrl)
      ),
    );
  }
}