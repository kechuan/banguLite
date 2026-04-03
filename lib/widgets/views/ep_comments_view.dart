import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/utils/extension.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/widgets/fragments/ep_comment_tile.dart';
import 'package:bangu_lite/widgets/fragments/ep_replied_tile.dart';
import 'package:flutter/material.dart';

class EpCommentView extends StatelessWidget {
  const EpCommentView({
    super.key, 
    required this.contentID,
    required this.epCommentData,
    this.postCommentType,
    this.onUpdateComment,
    this.authorID, 
    this.themeColor
    
  });

  final int contentID;
  
  final EpCommentDetails epCommentData;
  final PostCommentType? postCommentType;
  final Function(String?)? onUpdateComment;

  final int? authorID;

  final Color? themeColor;
  
  @override
  Widget build(BuildContext context) {
    
    /// [BangumiCommentAuthorType] 楼顶端
    BangumiCommentAuthorType? authorType;

    epCommentData.userInformation?.let(
      (it){
        //自身 大于 楼主 大于 层主
        if(it.userID == authorID ){
          authorType = BangumiCommentAuthorType.author;
        }


        if(it.userID == AccountModel.loginedUserInformations.userInformation?.userID ){
          authorType = BangumiCommentAuthorType.self;
        }
      }
    );


    return Column(
      spacing: 6,
      children: [
        EpCommentTile(
          contentID: contentID,
          epCommentData: epCommentData,
          postCommentType:postCommentType,
          readableThemeColor: themeColor,
          onUpdateComment: onUpdateComment,
          authorType: authorType,
        ),
        EpRepliedTile(
          contentID: contentID,
          epCommentData: epCommentData,
          floorHostUserID: authorID,
        )
      ]
    
    );
      
 
  }
}