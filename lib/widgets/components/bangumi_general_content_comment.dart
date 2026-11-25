import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/widgets/views/ep_comments_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BangumiGeneralContentComment extends StatefulWidget {
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
    State<BangumiGeneralContentComment> createState() => _BangumiGeneralContentCommentState();
}

class _BangumiGeneralContentCommentState extends State<BangumiGeneralContentComment> {
    final ValueNotifier<int> commentUpdateFlag = ValueNotifier(0);

    @override
    void dispose() {
      commentUpdateFlag.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {

        return ValueListenableBuilder(
            valueListenable: commentUpdateFlag,
            builder: (_, __, ___) {
                //final currentEpCommentDetails = resultFilterCommentList[contentCommentIndex];
                return MultiProvider(
                  providers: [
                    Provider<EpCommentDetails>.value(value: widget.currentEpCommentDetails),
                    Provider<EpCommentViewConfig>.value(value: EpCommentViewConfig(
                      contentID: widget.contentID,
                                            
                      postCommentType: widget.postCommentType,
                      /// 用户更改拥有的内容时
                      onUpdateComment: (content) {
                          widget.onUpdateComment?.call(content);
                          if (content != null) {
                            commentUpdateFlag.value += 1;
                          }
                      },
                      
                      authorID: widget.authorID,
                      themeColor: widget.themeColor,
                    )),
                  ],
                  child: const EpCommentView(),
                );
            }
        );

    }
}
