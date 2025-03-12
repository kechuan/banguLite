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

              SizedBox(
                height: 50,
                width: 50,
                child: CachedImageLoader(imageUrl: epCommentData.userInformation?.avatarUrl)
              ),

              //可压缩信息 Expanded
              Expanded(
                flex: 2,
                child: ScalableText(
                  epCommentData.userInformation?.nickName ?? epCommentData.userInformation?.userName ?? "no data",
                    style: const TextStyle(color: Colors.blue),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ),

              const Spacer(),

              //优先完整实现 size约束盒
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
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
              )
          
              
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
        padding: EdgeInsets.only(
          top: epCommentData.userInformation?.sign == null || epCommentData.userInformation!.sign!.isEmpty ? 32 : 6
        ),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            commentBlockStatus ?
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScalableText("发言已隐藏"),
                ScalableText("原因: ${CommentState.values[epCommentData.state!].reason}")
              ],
            ) :
            const SizedBox.shrink(),

            (!commentBlockStatus) ? 
            BBCodeText(
              data: convertBangumiCommentSticker(epCommentData.comment ?? "comment"),
              stylesheet: BBStylesheet(
                tags: allEffectTag,
                selectableText: true,
                defaultText: TextStyle(
                  fontFamily: 'MiSansFont',
                  fontSize: AppFontSize.s16,
                )
              ),
            ) :
            const SizedBox.shrink(),

            //因为 CommentReaction 内部是 ListView 本身就是不固定长度
            //因此决定使用 Flex 来提醒 这是一个特殊方式

            Row(
              //mainAxisAlignment: MainAxisAlignment.end, 不生效 因为主轴已经被 Expanded 占满
              children: [
                Expanded(
                  //那么只能在内部插入松约束 Align 来调节方位
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: CommentReaction(commentReactions: epCommentData.commentReactions),
                  ),
                ),
              ],
            ),
        
            // 楼主: null 
            // 层主: 3
            // 回帖: 3-1(详情界面特供)
            epCommentData.epCommentIndex?.contains("-") ?? false ? 
            const Divider() :
            const SizedBox.shrink(),
        
          ],
        ),
      ),
    );
             
  }
}
