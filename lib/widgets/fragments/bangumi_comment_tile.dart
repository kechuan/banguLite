import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/dialogs/user_information_dialog.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_comment_action_button.dart';
import 'package:bangu_lite/widgets/fragments/comment_reaction.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/star_score_list.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/models/comment_details.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

class BangumiCommentTile extends StatelessWidget {
  const BangumiCommentTile({
    super.key,
    required this.commentData,
    this.themeColor,
  });

  final CommentDetails commentData;
  final Color? themeColor;


  @override
  Widget build(BuildContext context) {

    final int ratingScore = commentData.rate ?? 0;
    DateTime commentStamp = DateTime.fromMillisecondsSinceEpoch(commentData.commentTimeStamp!*1000);

    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          spacing: 12,
          children: [
            
            Builder(builder: (_){
              if(commentData.userInformation?.avatarUrl==null) return Image.asset("assets/icons/icon.png",height: 50,width: 50,);

              return UnVisibleResponse(
                onTap: () {
                  showUserInfomationDialog(context, commentData.userInformation);
                },
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CachedImageLoader(imageUrl: commentData.userInformation?.avatarUrl!,photoViewStatus: true,)
                ),
              );

            }),


            Expanded(
              child: ScalableText(
                  commentData.userInformation?.nickName ?? "nameID",
                  style: TextStyle(color: themeColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis
                ),
            ),

            //因为tile的title给的交叉轴也是unbounded的 所以需要约束
            SizedBox(
              height: 30,
              child: StarScoreList(
                ratingScore: ratingScore,
                themeColor: themeColor,
              ),
            )

          ],
        ),
      ),

      subtitle: Column(
        spacing: 6,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          //比直接使用Scaffold更轻量化的隔离scroll physic 手段
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(physics: const NeverScrollableScrollPhysics()),
            child: BBCodeText(
              data: convertBangumiCommentSticker(commentData.comment ?? "comment"),
              stylesheet: BBStylesheet(
                tags: allEffectTag,
                selectableText: true,
                defaultText: TextStyle(fontFamily: 'MiSansFont',fontSize: AppFontSize.s16)
              ),
            ),
          ),

          Row(
            //mainAxisAlignment: MainAxisAlignment.end, 不生效 因为主轴已经被 Expanded 占满
            children: [
              Expanded(
                //那么只能在内部插入松约束 Align 来调节方位
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CommentReaction(
                    commentReactions: commentData.commentReactions,
                    themeColor: themeColor,
                  ),
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ScalableText("${commentStamp.year}-${convertDigitNumString(commentStamp.month)}-${convertDigitNumString(commentStamp.day)} ${convertDigitNumString(commentStamp.hour)}:${convertDigitNumString(commentStamp.minute)}"),

              BangumiCommentActionButton(
                commentBlockStatus: true,
                postCommentType: PostCommentType.subjectComment,
                commentData: commentData,
              )

            ],
          )

        ],
      ),
    );
                            
  }
}