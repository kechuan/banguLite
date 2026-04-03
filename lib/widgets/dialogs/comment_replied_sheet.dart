import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/utils/extension.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/widgets/fragments/ep_comment_tile.dart';
import 'package:flutter/material.dart';

class EpRepliedCommentBottomSheet extends StatelessWidget {
  const EpRepliedCommentBottomSheet({
    super.key,
    required this.contentID,
    required this.currentLevelComment,
    this.commentIndex,
    this.postCommentType,
    this.readableThemeColor,
    this.floorHostUserID,

  });

  final int contentID;
  
  final EpCommentDetails currentLevelComment;
  final int? commentIndex;
  final PostCommentType? postCommentType;
  final Color? readableThemeColor;
  final int? floorHostUserID;

  
  @override
  Widget build(BuildContext context) {

    

    ///暂时没有用到这个参数的地方
    debugPrint('${currentLevelComment.state}: $commentIndex');
    if(commentIndex!=null) debugPrint("打开了第${commentIndex!+1}个评论");

    return ListView.builder(
      itemCount: (currentLevelComment.repliedComment?.length ?? 1)+1,
      
      itemBuilder: (_,index){
        
        //和回帖评论的 Divider作区分 才这么写 
        //因为 其divider长度 受padding影响 不一致区分
        if(index == 0){

            return Column(  
              children: [
            
                EpCommentTile(
                  contentID: contentID,
                  postCommentType: postCommentType,
                  epCommentData: currentLevelComment,
                  readableThemeColor: readableThemeColor,
                ),

                Divider(height: 2,color: readableThemeColor),
              ],
            );
        }

        if(currentLevelComment.repliedComment!.isNotEmpty){

          /// [BangumiCommentAuthorType] 楼中楼端
          BangumiCommentAuthorType? authorType;
  
          currentLevelComment.repliedComment?[index-1].let(
            (it){
              //自身 大于 楼主 大于 层主
              if(it.userInformation?.userID == floorHostUserID ){
                authorType = BangumiCommentAuthorType.author;
              }

              if(it.userInformation?.userID == currentLevelComment.userInformation?.userID ){
                authorType = BangumiCommentAuthorType.levelAuthor;
              }


              if(it.userInformation?.userID == AccountModel.loginedUserInformations.userInformation?.userID ){
                authorType = BangumiCommentAuthorType.self;
              }
            }
          );

          

          return EpCommentTile(
            contentID: contentID,
            postCommentType: postCommentType,
            epCommentData: currentLevelComment.repliedComment![index-1],
            readableThemeColor: readableThemeColor,
            authorType: authorType
          );
        }

        else{
          return const SizedBox.shrink();
        }

    
      }
    );


  }
}