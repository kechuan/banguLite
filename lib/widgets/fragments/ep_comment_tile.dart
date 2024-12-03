import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/models/ep_details.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
import 'package:flutter/material.dart';

class EpCommentTile extends StatelessWidget {
  const EpCommentTile({
    super.key,
    required this.epCommentData
  });
  
  final EpCommentDetails epCommentData;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          
          children: [
        
            epCommentData.avatarUri!=null ? 
            SizedBox(
              height: 50,
              width: 50,
              child: CachedImageLoader(imageUrl: epCommentData.avatarUri!)
            ) : 
            Image.asset("asset/icons/icon.png"),

            const Padding(padding: PaddingH6),
        
            Text(epCommentData.nickName ?? "nameID",style: const TextStyle(color: Colors.blue)),

            const Padding(padding: PaddingH6),

            Text("${epCommentData.sign}",style:const TextStyle(fontSize: 16,color: Colors.grey)),

            const Spacer(),

            Row(
              children: [

                Text("#楼层编号"),

                const Padding(padding: PaddingH6),

                Builder(
                  builder: (_){
                    DateTime commentStamp = DateTime.fromMillisecondsSinceEpoch(epCommentData.commentTimeStamp!*1000);
                    return Text(
                      "${commentStamp.year}-${convertDigitNumString(commentStamp.month)}-${convertDigitNumString(commentStamp.day)} ${convertDigitNumString(commentStamp.hour)}:${convertDigitNumString(commentStamp.minute)}"
                    );
                  }
                ),
              ],
            )

            
          ],
        ),
      ),

      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(epCommentData.comment ?? "comment"),

          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [


               Padding(padding: EdgeInsets.symmetric(horizontal: 12)),


              //贴表情区域
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
    );
             
  }
}