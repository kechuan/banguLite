import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/models/comment_details.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_comment_action_button.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_user_avatar.dart';
import 'package:bangu_lite/widgets/fragments/comment_reaction.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

class EpCommentTile extends StatelessWidget {
  const EpCommentTile({
    super.key,
    required this.epCommentData,
	  this.postCommentType,
    this.themeColor, 
    this.onUpdateComment,
    this.authorType
  });
  
  final EpCommentDetails epCommentData;
  final PostCommentType? postCommentType;
  final BangumiCommentAuthorType? authorType;
  final Color? themeColor;

  final Function(String?)? onUpdateComment;

  @override
  Widget build(BuildContext context) {

    bool commentBlockStatus = false;

    if(
      epCommentData.state != null &&
      ( epCommentData.state == CommentState.adminCloseTopic.index ||
        epCommentData.state == CommentState.userDelete.index ||
        epCommentData.state == CommentState.adminDelete.index
      )
    ){
      commentBlockStatus = true;
    }

    DateTime commentStamp = DateTime.fromMillisecondsSinceEpoch((epCommentData.commentTimeStamp ?? 0)*1000);


    return ListTile(
      
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.center,
            
            children: [

              BangumiUserAvatar(
                size: 50,
                userInformation: epCommentData.userInformation,
              ),

              //可压缩信息 Expanded
              Expanded(
                flex: 2,
                child: Row(
                  spacing: 6,
                  children: [

                    Expanded(
                      child: ScalableText(
                        epCommentData.userInformation?.nickName ?? epCommentData.userInformation?.userName ?? "no data"
                        "${authorType?.typeName}",
                          style: const TextStyle(color: Colors.blue),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    ScalableText(
                      authorType?.typeName == null ? "" : "(${authorType?.typeName})",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold
                      ),

                    ),

                  ],
                ),
              ),

              //优先完整实现 size约束盒
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                //constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width/3),
                //这个长度一般是 "YEAR-MO-DA HO:MI" 的长度
                //但如果设备上的字体是不一样的话。。我就不好说了
                child: Wrap(
                  spacing: 6,
                  alignment: WrapAlignment.end,
                  children: [
                          
                    ScalableText(epCommentData.epCommentIndex== null ? "" : "#${epCommentData.epCommentIndex}"),
                          
                    ScalableText(
                      "${commentStamp.year}-${convertDigitNumString(commentStamp.month)}-${convertDigitNumString(commentStamp.day)}"
                    ),

                    ScalableText(
                      "${convertDigitNumString(commentStamp.hour)}:${convertDigitNumString(commentStamp.minute)}",
                    )

                  ],
                ),
              ),

              BangumiCommentActionButton(
                commentData: epCommentData,
                commentBlockStatus: commentBlockStatus,
                postCommentType: postCommentType,
                onUpdateComment: onUpdateComment,
              ),
              
            ],
          ),

          Builder(builder: (_){
            if(epCommentData.userInformation?.sign == null || epCommentData.userInformation!.sign!.isEmpty){
                return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ScalableText("(${epCommentData.userInformation?.sign})",style:const TextStyle(color: Colors.grey)),
            );
          }),

          
        ],
      ),

      subtitle: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ...?commentBlockStatus ?
            [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScalableText("发言已隐藏"),
                  ScalableText("原因: ${CommentState.values[epCommentData.state!].reason}")
                ],
              )
            ] : null,


            ...?(!commentBlockStatus && epCommentData.comment?.isNotEmpty == true) ? 
            [
               BBCodeText(
                data: convertBangumiCommentSticker(epCommentData.comment ?? ""),
                stylesheet: appDefaultStyleSheet(context,selectableText: true),
                errorBuilder: (context, error, stackTrace) {
                  return ScalableText("${epCommentData.comment}",
                  );
                },
              ) 
            
            ] : null,
            
            //commentReaction Area
            Row(
              //mainAxisAlignment: MainAxisAlignment.end, 不生效 因为主轴已经被 Expanded 占满
              children: [
                Expanded(
                  //那么只能在内部插入松约束 Align 来调节方位
                  child: Builder(
                    builder: (_) {

                      int? commentIndex = int.tryParse(epCommentData.epCommentIndex?.split('-').first ?? '');
                      int? replyIndex = int.tryParse(epCommentData.epCommentIndex?.split('-').length == 1 ? '' : epCommentData.epCommentIndex?.split('-').last ?? '');

                      return Align(
                        alignment: Alignment.centerRight,
                        child: CommentReaction(
                          themeColor: themeColor,
                          postCommentType: postCommentType,
                          commentID: epCommentData.commentID,
                          commentIndex: commentIndex,
                          replyIndex: replyIndex,
                          commentReactions: epCommentData.commentReactions
                        ),
                      );
                    }
                  ),
                ),
              ],
            ),
        
            //commentAction Area


            // 楼主: null 
            // 层主: 3
            // 回帖: 3-1(详情界面特供)
            ...?epCommentData.epCommentIndex?.contains("-") ?? false ? 
            [const Divider()] :
            null,
        
          ],
        ),
      ),
    );
             
  }
}
