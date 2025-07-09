import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:flutter/material.dart';

class CommentFilter extends StatefulWidget {
  const CommentFilter({
    super.key,
    required this.commentSurfTypeNotifier,
    this.onCommentFilter
  });

  final ValueNotifier<BangumiCommentRelatedType> commentSurfTypeNotifier;

  final Function(BangumiCommentRelatedType)? onCommentFilter;

  @override
  State<CommentFilter> createState() => _CommentFilterState();
}

class _CommentFilterState extends State<CommentFilter> {
  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: 60,
        child: ValueListenableBuilder(
          valueListenable: widget.commentSurfTypeNotifier,
          builder: (context, commentSurfType, child) {
            return PopupMenuButton<BangumiCommentRelatedType>(
              tooltip: "评论筛选",
              initialValue: commentSurfType,
              position:PopupMenuPosition.under,
              itemBuilder: (_) {
                return List.generate(
                  BangumiCommentRelatedType.values.length - 1,
                  (index) => PopupMenuItem(
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
                //filterCommentList(selectFilter,commentListData);
                widget.onCommentFilter?.call(selectFilter);
                widget.commentSurfTypeNotifier.value = selectFilter;
                
              },
                                
              child: SizedBox(
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: PaddingH6,
                        child: Icon(widget.commentSurfTypeNotifier.value.icon)
                      ),
                    ),
                
                    const Icon(Icons.arrow_drop_down)
                
                  ],
                ),
              ),
                                
            );
          }
        ),
      );
             
  }
}

List<EpCommentDetails> filterCommentList(
  BangumiCommentRelatedType selectFilter,
  List<EpCommentDetails> commentListData,
){

  List<EpCommentDetails> resultFilterCommentList = [];
  if(commentListData.isEmpty) return resultFilterCommentList;

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
    
    //case BangumiCommentRelatedType.friend:{

    //}
    default:{}
  }

  return resultFilterCommentList;

}