import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/models/comment_details.dart';
import 'package:bangu_lite/widgets/fragments/ep_comment_tile.dart';
import 'package:bangu_lite/widgets/fragments/ep_replied_tile.dart';
import 'package:flutter/material.dart';

class EpCommentView extends StatelessWidget {
  const EpCommentView({
    super.key, 
    required this.epCommentData,
    this.postCommentType,
    this.onUpdateComment,
  });
  
  final EpCommentDetails epCommentData;
  final PostCommentType? postCommentType;
  final Function(String?)? onUpdateComment;
  
  @override
  Widget build(BuildContext context) {

    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      title: EpCommentTile(
        epCommentData: epCommentData,
        postCommentType:postCommentType,
        themeColor: Theme.of(context).scaffoldBackgroundColor,
        onUpdateComment: onUpdateComment,
      ),
      subtitle: EpRepliedTile(
        epCommentData: epCommentData,
        postCommentType:postCommentType,
        themeColor: Theme.of(context).scaffoldBackgroundColor,
        onUpdateComment: onUpdateComment,
        
      ),
    );

  }
}