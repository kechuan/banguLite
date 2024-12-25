import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/models/ep_details.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
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
          
              Text(epCommentData.nickName ?? "nameID",style: const TextStyle(color: Colors.blue)),
          
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
                          
                    //Text("#${epCommentData.epCommentIndex}"),
                    Text(epCommentData.epCommentIndex== null ? "" : "#${epCommentData.epCommentIndex}"),
                          
                    Builder(
                      builder: (_){
                        DateTime commentStamp = DateTime.fromMillisecondsSinceEpoch(epCommentData.commentTimeStamp!*1000);
                        return Text(
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
            child: SelectableText("(${epCommentData.sign})",style:const TextStyle(fontSize: 16,color: Colors.grey)),
          ),
        
        
          
        ],
      ),

      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Text("${epCommentData.state}"),
            if(
              ( epCommentData.state == CommentState.adminCloseTopic.index ||
                epCommentData.state == CommentState.userDelete.index ||
                epCommentData.state == CommentState.adminDelete.index
              ) &&  epCommentData.state != null
            )
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("发言已隐藏",style: TextStyle(fontSize: 16)),
                  Text("原因: ${CommentState.values[epCommentData.state!].reason}")
                ],
              ),
            
            BBCodeText(
              data: convertBangumiCommentSticker(epCommentData.comment ?? "comment"),
              stylesheet: BBStylesheet(
                tags: allEffectTag,
                selectableText: true,
                defaultText: const TextStyle(fontFamily: 'MiSansFont',fontSize: 16)
              ),
            ),
        
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
                //          child: const Text("test 3"),
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
