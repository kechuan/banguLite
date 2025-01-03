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
            crossAxisAlignment: CrossAxisAlignment.center,
            
            children: [
          
              epCommentData.avatarUrl!=null ? 
              SizedBox(
                height: 50,
                width: 50,
                child: CachedImageLoader(imageUrl: epCommentData.avatarUrl!)
              ) : 
              Image.asset("assets/icons/icon.png"),
          
              const Padding(padding: PaddingH6),
          
              ScalableText(epCommentData.nickName ?? "nameID",style: const TextStyle(color: Colors.blue)),
          
              const Padding(padding: PaddingH6),
          
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

          epCommentData.sign!.isEmpty ?
          const SizedBox.shrink() :
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ScalableText("(${epCommentData.sign})",style:const TextStyle(color: Colors.grey)),
          ),
        
        
          
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
        
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
        
        
                 Padding(padding: EdgeInsets.symmetric(horizontal: 12)),
        
        
                //贴表情区域 When?
                //...List.generate(
                //  1,(index){
                //      return Padding(
                //        padding: const EdgeInsets.symmetric(horizontal: 6),
                //        child: DecoratedBox(
                //          decoration: BoxDecoration(
                //            border: Border.all(),
                //            borderRadius: BorderRadius.circular(12)
                //          ),
                //          child: const ScalableText("test 3"),
                //        ),
                //      );
                //    }
                //),
        
              ],
            ),
        
            const Padding(padding: PaddingV6),
        
          ],
        ),
      ),
    );
             
  }
}
