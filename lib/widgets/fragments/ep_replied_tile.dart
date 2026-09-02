import 'dart:math';

import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/utils/judge.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/components/custom_bbcode_text.dart';
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
    this.readableThemeColor,
    this.onUpdateComment,

    this.floorHostUserID, 

  });

  final int contentID;

  final EpCommentDetails epCommentData;
  final PostCommentType? postCommentType;
  final Color? themeColor;
  final Color? readableThemeColor;
  final Function(String?)? onUpdateComment;

  final int? floorHostUserID;

  @override
  Widget build(BuildContext context) {

    if ( 
    epCommentData.repliedComment == null ||
      epCommentData.repliedComment!.isEmpty
    ) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(12).subtract(const EdgeInsets.only(top: 12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          //color: judgeDarknessMode(context) ? const Color.fromARGB(255, 118, 121, 119).withValues(alpha: 0.4) : readableThemeColor?.withValues(alpha: 0.2),
          color: readableThemeColor?.withValues(alpha: 0.2),
        ),
        child: Padding(
          padding: Padding12,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                ListView.separated(
                  //孩子们 我忘记listview在安卓端会展示默认的padding了
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: min(3, epCommentData.repliedComment!.length),
                  itemBuilder: (_, index) {
                    final repliedComment = epCommentData.repliedComment![index];

                    debugPrint('[epCommentData.state] ${repliedComment.state}: ${repliedComment.epCommentIndex}');

                    final quoteContent = quoteBBcodeContentRegexp
                      .firstMatch(repliedComment.comment ?? "")
                      ?.group(1) ?? ""
                    ;

                    final mainContent = repliedComment.comment
                      ?.split(quoteBBcodeRegexp)
                      .last
                      .replaceAll(bbcodeRegexp, '')
                      //正则会匹配到\n符号 额外剔除它
                      .trimLeft()
                      ?? ""
                    ;

                    return Padding(
                      padding: Padding6,
                      child: ShowCommentTap(
                        contentID: contentID,
                        postCommentType: postCommentType,
                        epCommentData: epCommentData,
                        commentIndex: index,
                        themeColor: themeColor,
                        readableThemeColor: readableThemeColor,
                        floorHostUserID: floorHostUserID,

                        child: Row(
                          spacing: 12,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [

                            ScalableText(
                              "${repliedComment.userInformation?.nickName}:",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: AppFontSize.s14)
                            ),

                            epCommentData.repliedComment![index].state?.isContentNerf() == true ?
                            ScalableText("发言已隐藏", style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppFontSize.s14)) :
                            Expanded(
                              child: RichText(  // 使用 RichText 合并文本
                                text: TextSpan(
                                  style: TextStyle(
                                    fontFamilyFallback: convertSystemFontFamily(),
                                    fontSize: AppFontSize.s14,
                                  ),

                                  children: [

                                    if (quoteContent.isNotEmpty) ...[
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.bottom,
                                        child: Padding(
                                          padding: PaddingV6,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(6),
                                              //color: judgeDarknessMode(context) ? judgeCurrentThemeColor(context).withValues(alpha: 0.4) : Colors.blueGrey.withValues(alpha: 0.4),
                                              color: readableThemeColor?.withValues(alpha: 0.3),
                                            ),
                                            child: Padding(
                                              padding: Padding6,
                                              child: ScalableText(
                                                quoteContent.length > 40 ? 
                                                "${quoteContent.substring(0, 40).replaceAll(bbcodeRegexp, '')}..." : 
                                                quoteContent.replaceAll(bbcodeRegexp, ''),
                                                maxLines: 1,
                                                style: TextStyle(
                                                  //color: judgeDarknessMode(context) ? judgeCurrentThemeColor(context) : Colors.blueGrey,
                                                  fontSize: AppFontSize.s13
                                                ),
                                              ),
                                            )
                                          ),
                                        )
                                      ),

                                      /// 往上面的text内容增加\n没有用 必须在这里加才生效 因为上面已经规定了maxLine为1了
                                      const TextSpan(text: "\n"),

                                    ],

                                    WidgetSpan(
                                      child: AdapterBBCodeText(
                                        data: convertBangumiCommentSticker(mainContent),
                                        stylesheet: appDefaultBBStyleSheet(context, richless: true, fontSize: AppFontSize.s14),
                                        maxLine: 3,
                                      )
                                    )

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

                  },
                  separatorBuilder: (_, index) => const Divider(height: 0.5),
                ),

                if(epCommentData.repliedComment!.length > 3) 
                ShowCommentTap(
                  contentID: contentID,
                  themeColor: themeColor,
                  readableThemeColor: readableThemeColor,
                  postCommentType: postCommentType,
                  epCommentData: epCommentData,
                  //authorType:authorType,
                  floorHostUserID: floorHostUserID,
                  child: ScalableText(
                    "> 点击查看 ${epCommentData.repliedComment!.length} 条评论",
                    style: TextStyle(color: judgeDarknessMode(context) ? const Color.fromARGB(225, 212, 232, 215) : Colors.blueAccent, fontSize: AppFontSize.s14),
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

class ShowCommentTap extends InkResponse{
  const ShowCommentTap({
    super.key,
    super.child,
    required this.contentID,
    required this.epCommentData,
    this.commentIndex,
    this.postCommentType,
    this.themeColor, 
    this.readableThemeColor,
    this.floorHostUserID, 

  });

  final int contentID;

  final EpCommentDetails epCommentData;
  final int? commentIndex;
  final PostCommentType? postCommentType;

  final int? floorHostUserID;

  final Color? themeColor;

  final Color? readableThemeColor;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      containedInkWell: true,
      onTap: () {
        showModalBottomSheet(
          isScrollControlled: true,
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width, maxHeight: MediaQuery.sizeOf(context).height * 3 / 4),
          context: context,
          backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          builder: (_) {

            return EpRepliedCommentBottomSheet(
              contentID: contentID,
              currentLevelComment: epCommentData,
              commentIndex: commentIndex,
              floorHostUserID: floorHostUserID,
              postCommentType: postCommentType,
              readableThemeColor: readableThemeColor,
            );

          }
        );
      },
      child: child,
    );
  }
}
