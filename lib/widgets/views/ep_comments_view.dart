import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/extension.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/widgets/fragments/ep_comment_tile.dart';
import 'package:bangu_lite/widgets/fragments/ep_replied_tile.dart';
import 'package:flutter/material.dart';

class EpCommentView extends StatelessWidget {
  const EpCommentView({
    super.key, 
    required this.epCommentData,
    this.postCommentType,
    this.onUpdateComment, 
    this.authorID,
    
  });
  
  final EpCommentDetails epCommentData;
  final PostCommentType? postCommentType;
  final Function(String?)? onUpdateComment;

  final int? authorID;
  
  @override
  Widget build(BuildContext context) {

    BangumiCommentAuthorType? authorType;

    AccountModel.loginedUserInformations.userInformation.let(
      (it){
        if(it?.userID == authorID ){
          authorType = BangumiCommentAuthorType.self;
        }
      }
    );

    if(authorID == epCommentData.userInformation?.userID){
      authorType = BangumiCommentAuthorType.author;
    }

    //if(authorID == (epCommentData.userInformation?.userID)){
    //  authorType = BangumiCommentAuthorType.levelAuthor;
    //}



    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      title: EpCommentTile(
        epCommentData: epCommentData,
        postCommentType:postCommentType,
        themeColor: Theme.of(context).scaffoldBackgroundColor,
        onUpdateComment: onUpdateComment,
        authorType: authorType,
      ),
      subtitle: EpRepliedTile(
        epCommentData: epCommentData,
        postCommentType:postCommentType,
        themeColor: Theme.of(context).scaffoldBackgroundColor,
        onUpdateComment: onUpdateComment,
        authorType: authorType,
        
        
      ),
    );

  }
}