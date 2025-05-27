import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/widgets/fragments/ep_comment_tile.dart';
import 'package:flutter/material.dart';

class EpRepliedCommentBottomSheet extends StatelessWidget {
  const EpRepliedCommentBottomSheet({
    super.key,
    required this.contentID,
    required this.currentComment,
    this.commentIndex,
    this.postCommentType,
    this.themeColor,

  });

  final int contentID;
  
  final EpCommentDetails currentComment;
  final int? commentIndex;
  final PostCommentType? postCommentType;
  final Color? themeColor;
  
  @override
  Widget build(BuildContext context) {

    if(commentIndex!=null) debugPrint("打开了第${commentIndex!+1}个评论");

    return ListView.builder(
      itemCount: (currentComment.repliedComment?.length ?? 1)+1,
      
      itemBuilder: (_,index){
        
        //和回帖评论的 Divider作区分 才这么写 
        //因为 其divider长度 受padding影响 不一致区分
        if(index == 0){
            return Column(  
              children: [
                EpCommentTile(
                  contentID: contentID,
                  postCommentType: postCommentType,
                  epCommentData: currentComment,
                  themeColor:themeColor
                ),
                const Divider(height: 1),
              ],
            );
         }

        if(currentComment.repliedComment!.isNotEmpty){
          return EpCommentTile(
            contentID: contentID,
            postCommentType: postCommentType,
            epCommentData: currentComment.repliedComment![index-1],
            themeColor: themeColor,
            authorType: 
              currentComment.repliedComment![index-1].userInformation?.userID == currentComment.userInformation?.userID ?
              BangumiCommentAuthorType.levelAuthor:
              null
            ,
          );
        }

        else{
          return const SizedBox.shrink();
        }

    
      }
    );


  }
}