import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/models/comment_details.dart';
import 'package:bangu_lite/widgets/fragments/ep_comment_tile.dart';
import 'package:bangu_lite/widgets/fragments/ep_replied_tile.dart';
import 'package:flutter/material.dart';

class EpCommentView extends StatelessWidget {
  const EpCommentView({
    super.key, 
    required this.epCommentData,
    this.postCommentType,
  });
  
  final EpCommentDetails epCommentData;
  final PostCommentType? postCommentType;
  
  @override
  Widget build(BuildContext context) {

    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      title: EpCommentTile(
        epCommentData: epCommentData,
        postCommentType:postCommentType,
        themeColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 1),
      ),
      subtitle: EpRepliedTile(
        epCommentData: epCommentData,
        postCommentType:postCommentType,
        themeColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 1),
        
      ),
    );

  }
}