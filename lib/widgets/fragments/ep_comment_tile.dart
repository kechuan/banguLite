import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/models/ep_details.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
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
            
            commentBlockStatus ?
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScalableText("发言已隐藏"),
                  ScalableText("原因: ${CommentState.values[epCommentData.state!].reason}")
                ],
              )
            : const SizedBox.shrink(),

            !commentBlockStatus ? 
              BBCodeText(
                data: convertBangumiCommentSticker(epCommentData.comment ?? "comment"),
                stylesheet: BBStylesheet(
                  tags: allEffectTag,
                  selectableText: true,
                  defaultText: TextStyle(fontFamily: 'MiSansFont',fontSize: AppFontSize.s16)
                ),
              ) 
            : const SizedBox.shrink(),
        
             Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                

                //贴表情区域 When?
                ...List.generate(
                  epCommentData.commentReactions?.length ?? 0,
                  (index){
                    
                      int dataLikeIndex = epCommentData.commentReactions!.keys.elementAt(index);

                      int stickerIndex = dataLikeIndex - 39 + 23;

                      //我也不知道为什么别人前端的里 大部分 data-like-value 的差异都是39 就只有 0 是 44
                      //data-like-value = 0 => "/img/smiles/tv/44.gif"
                      //至于为什么是+23 那就是因为 bgm 与 tv 包的差异了 bgm包刚好是23个表情 因此偏移23
                      
                      if(dataLikeIndex == 0){
                        stickerIndex = dataLikeIndex - 44 + 23;
                      }


                      return SizedBox(
                        width: 70,
                        height: 50,
                        child: Container(
							padding: const EdgeInsets.symmetric(horizontal: 6),
							decoration: BoxDecoration(
								border: Border.all(),
								borderRadius: BorderRadius.circular(16),
								color: Colors.grey.withValues(alpha: 0.4)
							),
							child: Tooltip(
								message: "${epCommentData.commentReactions?[dataLikeIndex]?.join("、")}",
								child: Row(
									mainAxisAlignment: MainAxisAlignment.spaceEvenly,
									children: [
									
										Image.asset(
											"assets/bangumiSticker/bgm$stickerIndex.gif",
											scale: stickerIndex == 124 || stickerIndex == 125 ? 1.6 : 0.8,
										),
									
										ScalableText("${epCommentData.commentReactions?[dataLikeIndex]?.length}"),
									],
								),
							),
						),
                      );
                    }
                ),
        
              ],
            ),
        
            const Padding(padding: PaddingV6),
        
          ],
        ),
      ),
    );
             
  }
}
