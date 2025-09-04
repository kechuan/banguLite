import 'dart:math';

import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
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
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(12),
          color: judgeDarknessMode(context) ? const Color.fromARGB(255, 118, 121, 119) : const Color.fromARGB(225, 212, 232, 215),
        ),
        child: ListTile(
          title: Center(

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                /// 拼接显示方案
                ...List.generate(
                  min(3, epCommentData.repliedComment!.length), 
                  (index) {
                    final repliedComment = epCommentData.repliedComment![index];

                      debugPrint('${epCommentData.state}: ${repliedComment.epCommentIndex}');

                      

                      final quoteContent = quoteBBcodeContentRegexp
                        .firstMatch(repliedComment.comment ?? "")
                        ?.group(1) ?? ""
                      ;

                      final mainContent = repliedComment.comment
                        ?.split(quoteBBcodeRegexp)
                        .last
                        .replaceAll(bbcodeRegexp, '') ?? ""
                      ;

                        return Padding(
                          padding: PaddingV6,
                          child: ShowCommentTap(
                            contentID: contentID,
                            postCommentType: postCommentType,
                            epCommentData: epCommentData,
                            commentIndex: index,
                            child: Row(
                              spacing: 12,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
							                 textBaseline: TextBaseline.alphabetic,
							  
                              children: [
                                ScalableText(
                                  "${repliedComment.userInformation?.nickName}:",
                                  style:TextStyle(fontWeight: FontWeight.w500)
                                ),

                                epCommentData.repliedComment![index].state?.isNotAvaliable() == true ?
                                ScalableText("发言已隐藏",style: TextStyle(fontStyle: FontStyle.italic)) :
                                Expanded(
                                  child: RichText(  // 使用 RichText 合并文本
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamilyFallback: convertSystemFontFamily(),
                                        fontSize: AppFontSize.s16,
                                      ),
                                      children: [
                                                              
                                        if (quoteContent.isNotEmpty) ...[
                                          WidgetSpan(
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                border: Border.all(),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Padding(
                                                padding: Padding6,
                                                child: ScalableText(
                                                  quoteContent.length > 30 
                                                  ? "${quoteContent.substring(0, 30).replaceAll(bbcodeRegexp, '')}...\n"
                                                  : "${quoteContent.replaceAll(bbcodeRegexp, '')}\n",
                                                  maxLines: 1,
                                                  style: TextStyle(color: judgeCurrentThemeColor(context)),
                                                ),
                                              )
                                            )
                                          ),
                                        ],
                                                              
                                        //WidgetSpan(
                                        //  child: AdapterBBCodeText(
                                        //    data: mainContent,
                                        //    stylesheet: appDefaultStyleSheet(context,richless: true,selectableText: true),
                                        //    maxLine: 3,
                                        //  ),
                                        //),
                                                              
                                        TextSpan( 
                                          text: mainContent,
                                          style: TextStyle(
                                            color: judgeDarknessMode(context) ? Colors.white : Colors.black,
                                          ),
                                  											
                                        ),
                                        
                                        
                                      ],
                                    ),
                                    maxLines: 4,  // 引用1行 + 内容3行
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              
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