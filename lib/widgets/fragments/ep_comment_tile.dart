import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/models/ep_details.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
import 'package:bangu_lite/widgets/fragments/comment_reaction.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

class EpCommentTile extends StatelessWidget {
  const EpCommentTile({
    super.key,
    required this.epCommentData
  });
  
  final EpCommentDetails epCommentData;

  @override
  Widget build(BuildContext context) {

    bool commentBlockStatus = false;

    if(
      ( epCommentData.state == CommentState.adminCloseTopic.index ||
        epCommentData.state == CommentState.userDelete.index ||
        epCommentData.state == CommentState.adminDelete.index
      ) && epCommentData.state != null
    ){
      commentBlockStatus = true;
    }


    return ListTile(
      
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          Row(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.center,
            
            children: [
          
              epCommentData.avatarUrl!=null ? 
                SizedBox(
                  height: 50,
                  width: 50,
                  child: CachedImageLoader(imageUrl: epCommentData.avatarUrl!)
                ) : 
                //Image.asset("assets/icons/icon.png"),
              const SizedBox.shrink(),
          
              ScalableText("${epCommentData.nickName ?? epCommentData.userID ?? ""}",style: const TextStyle(color: Colors.blue)),
          
              const Spacer(),
          
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160), 
                //这个长度一般是 "YEAR-MO-DA HO:MI" 的长度
                //但如果设备上的字体是不一样的话。。我就不好说了
                child: Wrap(
                  //crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 6,
                  alignment: WrapAlignment.end,
                  children: [
                          
                    //ScalableText("#${epCommentData.epCommentIndex}"),
                    ScalableText(epCommentData.epCommentIndex== null ? "" : "#${epCommentData.epCommentIndex}"),
                          
                    Builder(
                      builder: (_){
                        DateTime commentStamp = DateTime.fromMillisecondsSinceEpoch(epCommentData.commentTimeStamp!*1000);
                        return ScalableText(
                          "${commentStamp.year}-${convertDigitNumString(commentStamp.month)}-${convertDigitNumString(commentStamp.day)} ${convertDigitNumString(commentStamp.hour)}:${convertDigitNumString(commentStamp.minute)}"
                        );
                      }
                    ),
                  ],
                ),
              )
          
              
            ],
          ),

          Builder(builder: (_){
            if(epCommentData.sign == null || epCommentData.sign!.isEmpty){
                return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ScalableText("(${epCommentData.sign})",style:const TextStyle(color: Colors.grey)),
            );
          }),

          
        ],
      ),

      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            (!commentBlockStatus) ?
            const SizedBox.shrink() :
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScalableText("发言已隐藏"),
                ScalableText("原因: ${CommentState.values[epCommentData.state!].reason}")
              ],
            ),

            commentBlockStatus ? 
            const SizedBox.shrink() :
            BBCodeText(
              data: convertBangumiCommentSticker(epCommentData.comment ?? "comment"),
              stylesheet: BBStylesheet(
                tags: allEffectTag,
                selectableText: true,
                defaultText: TextStyle(fontFamily: 'MiSansFont',fontSize: AppFontSize.s16)
              ),
            ),

            CommentReaction(commentReactions: epCommentData.commentReactions),
        
            const Padding(padding: PaddingV6),
        
          ],
        ),
      ),
    );
             
  }
}
