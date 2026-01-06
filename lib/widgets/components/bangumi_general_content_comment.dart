import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/widgets/views/ep_comments_view.dart';
import 'package:flutter/material.dart';

class BangumiGeneralContentComment extends StatelessWidget {
    const BangumiGeneralContentComment({
        super.key,
        required this.currentEpCommentDetails,
        required this.contentID,

        this.onUpdateComment,
        this.themeColor, 
        this.postCommentType, 

        this.authorID
    });

    final EpCommentDetails currentEpCommentDetails;
    final Function(String?)? onUpdateComment;

    final Color? themeColor;

    final PostCommentType? postCommentType;

    final int contentID;
    final int? authorID;

    @override
    Widget build(BuildContext context) {

        final ValueNotifier<int> commentUpdateFlag = ValueNotifier(0);

        return ValueListenableBuilder(
            valueListenable: commentUpdateFlag,
            builder: (_, __, ___) {
                //final currentEpCommentDetails = resultFilterCommentList[contentCommentIndex];
                return EpCommentView(
                    key: ValueKey(currentEpCommentDetails.commentID),
                    contentID: contentID,
                    postCommentType: postCommentType,
                    /// 用户更改拥有的内容时
                    onUpdateComment: (content) {
                        onUpdateComment?.call(content);
                        if (content != null) {
                          commentUpdateFlag.value += 1;
                        }
                    },
                    epCommentData: currentEpCommentDetails,
                    authorID: authorID,
                    themeColor: themeColor,
                
                );
            }
        );

    }
}
