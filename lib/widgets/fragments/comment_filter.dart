import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:flutter/material.dart';

class CommentFilter extends StatelessWidget {
  const CommentFilter({
    super.key,
    required this.commentSurfTypeNotifier,
    this.isUserContent = false,
    this.onCommentFilter
  });

  final ValueNotifier<BangumiCommentRelatedType> commentSurfTypeNotifier;
  final bool isUserContent;

  final Function(BangumiCommentRelatedType)? onCommentFilter;

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: 60,
      child: PopupMenuButton<BangumiCommentRelatedType>(
        tooltip: "评论筛选",
        initialValue: commentSurfTypeNotifier.value,
        position:PopupMenuPosition.under,
        itemBuilder: (_) {
          return List.generate(
          BangumiCommentRelatedType.values.length - 1,
          (index) => PopupMenuItem(
            enabled: BangumiCommentRelatedType.values[index] == BangumiCommentRelatedType.author ? isUserContent : true,
            value: BangumiCommentRelatedType.values[index],
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(BangumiCommentRelatedType.values[index].icon),
              Text(BangumiCommentRelatedType.values[index].typeName)
            ],),
          ),
          );
        },
                  
        onSelected: (selectFilter){
          onCommentFilter?.call(selectFilter);
          commentSurfTypeNotifier.value = selectFilter;
        },
                  
        child: SizedBox(
          height: 50,
          child: Row(
          children: [
            Expanded(
            child: Padding(
              padding: PaddingH6,
              child: Icon(commentSurfTypeNotifier.value.icon)
            ),
            ),
          
            const Icon(Icons.arrow_drop_down)
          
          ],
          ),
        ),
                        
      ),
    );

   
             
  }
}

List<EpCommentDetails> filterCommentList(
  BangumiCommentRelatedType selectFilter,
  List<EpCommentDetails>? commentListData,
  {int? referID}
){

  List<EpCommentDetails> resultFilterCommentList = [];
  if(commentListData == null || commentListData.isEmpty) return resultFilterCommentList;

  switch(selectFilter){
    case BangumiCommentRelatedType.normal:{
      return commentListData;
    }
    case BangumiCommentRelatedType.reversed:{
      return commentListData.reversed.toList();
    }

    //不仅是自己回帖 还有自己楼中楼回帖
    //但滤掉自己的主楼帖(Topic)
    case BangumiCommentRelatedType.involved:{
      //resultFilterCommentList = [...commentListData];

      final String? matchName = AccountModel.loginedUserInformations.userInformation?.userName;

      resultFilterCommentList = commentListData.where(
        (currentComment){
          return 
            currentComment.userInformation?.userName == matchName ||
            (currentComment.repliedComment?.any(
              (repliedComment){
                return repliedComment.userInformation?.userName == matchName;
              }
            ) ?? false)
          ;
        }
      ).toList();
    }

    //只看楼主(这里只指主楼是楼主发的)
    case BangumiCommentRelatedType.author:{

      resultFilterCommentList = commentListData.where(
        (currentComment) => currentComment.userInformation?.userID == referID
      ).toList();

    }

    case BangumiCommentRelatedType.id:{

      resultFilterCommentList = commentListData.where(
        (currentComment){
          return 
            currentComment.commentID == referID ||
            (currentComment.repliedComment?.any(
              (repliedComment){
                return repliedComment.commentID == referID;
              }
            ) ?? false)
          ;
        }
      ).toList();
    }
    
  }

  return resultFilterCommentList;

}