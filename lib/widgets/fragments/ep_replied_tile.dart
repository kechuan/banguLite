import 'dart:math';

import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/dialogs/comment_replied_sheet.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';

class EpRepliedTile extends ListTile {
  const EpRepliedTile({
    super.key,
    required this.contentID,
    required this.epCommentData,
    this.postCommentType,
    this.themeColor, 
    this.onUpdateComment,

    this.authorType


  });

  final int contentID;

  final EpCommentDetails epCommentData;
  final PostCommentType? postCommentType;
  final Color? themeColor;
  final Function(String?)? onUpdateComment;

  final BangumiCommentAuthorType? authorType;

  @override
  Widget build(BuildContext context) {
    if( 
      epCommentData.repliedComment == null ||
      epCommentData.repliedComment!.isEmpty
    ) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: Padding16,
      child: Container(
        decoration: BoxDecoration(border: Border.all()),
        child: ListTile(
          tileColor: judgeDarknessMode(context) ? const Color.fromARGB(255, 118, 121, 119) : const Color.fromARGB(225, 212, 232, 215),
          title: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            
                ...List.generate(
                  min(3,epCommentData.repliedComment!.length), 
                  (index){
                    
                    return Padding(
                      padding: PaddingV6,
                      child: ShowCommentTap(
                        contentID: contentID,
                        postCommentType:postCommentType,
                        epCommentData: epCommentData,
                        commentIndex: index,
                        child: Row(
                          spacing: 12,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScalableText("${epCommentData.repliedComment![index].userInformation?.nickName}:"),
                  
                            Expanded(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: AppFontSize.s16 * 6, //字符的字高普遍比字宽大1倍
                                  maxWidth: double.infinity
                                   
                                ),
                                child: Builder(
                                  builder: (_) {
                                    return ScalableText(
                                      "${
                                        epCommentData.repliedComment![index].comment
                                        ?.replaceAll(quoteBBcodeRegexp, '"')
                                        .replaceAll(bbcodeRegexp, '')
                                      }",
                                      maxLines: 3,
                                      style: const TextStyle(overflow: TextOverflow.ellipsis),
                                    );

                                  }
                                ),
                              ),
                            )
                  
                          ],
                        ),
                        
                      ),
                    );
                    
                  }
                ),
                  
                if(epCommentData.repliedComment!.length > 3) 
                  ShowCommentTap(
                    contentID: contentID,
                    themeColor: themeColor,
                    postCommentType: postCommentType,
                    epCommentData: epCommentData,
                    child: ScalableText(
                      "> 点击查看 ${epCommentData.repliedComment!.length} 条评论",
                      style: TextStyle(color: judgeDarknessMode(context) ? const Color.fromARGB(225, 212, 232, 215) : Colors.blueAccent),
                    )
                  ),
                  
              ],
            ),
          ),
        ),
      ),
    );

    
  }

}

class ShowCommentTap extends InkResponse {
  const ShowCommentTap({
    super.key,
    super.child,
    required this.contentID,
    required this.epCommentData,
    this.commentIndex,
    this.postCommentType,
    this.themeColor,

  });

  final int contentID;

  final EpCommentDetails epCommentData;
  final int? commentIndex;
  final PostCommentType? postCommentType;

  final Color? themeColor;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      containedInkWell: true,
      onTap: (){
        showModalBottomSheet(
          isScrollControlled: true,
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width,maxHeight:MediaQuery.sizeOf(context).height*3/4),
          context: context,
          builder: (_){
            return EpRepliedCommentBottomSheet(
              contentID: contentID,
              currentComment: epCommentData,
              commentIndex: commentIndex,
              postCommentType: postCommentType,
              themeColor: themeColor,
            );
            
          }
        );
      },
      child: child,
    );
  }
}