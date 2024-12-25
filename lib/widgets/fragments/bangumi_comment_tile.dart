import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/models/comment_details.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

class BangumiCommentTile extends StatelessWidget {
  const BangumiCommentTile({
    super.key,
    required this.commentData
  });

  final CommentDetails commentData;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          children: [
        
          commentData.avatarUrl!=null ? 
                
            SizedBox(
              height: 50,
              width: 50,
              child: CachedImageLoader(imageUrl: commentData.avatarUrl!,photoViewStatus: true,)
            ) : 
                
            //const FlutterLogo(),
            Image.asset("assets/icons/icon.png"),
        
            Text(commentData.nickName ?? "nameID",style: const TextStyle(color: Colors.blue)),
          ],
        ),
      ),

      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BBCodeText(
              data: convertBangumiCommentSticker(commentData.comment ?? "comment"),
              stylesheet: BBStylesheet(
                tags: allEffectTag,
                selectableText: true,
                defaultText: const TextStyle(fontFamily: 'MiSansFont',fontSize: 16)
              ),
            ),
          Row(
            children: [
  
              Builder(builder: (_){
                DateTime commentStamp = DateTime.fromMillisecondsSinceEpoch(commentData.commentTimeStamp!*1000);
                return Text(
                  "${commentStamp.year}-${convertDigitNumString(commentStamp.month)}-${convertDigitNumString(commentStamp.day)} ${convertDigitNumString(commentStamp.hour)}:${convertDigitNumString(commentStamp.minute)}"
                );
              }),
                
              const Spacer(),  
  
              Row(
                children: [
                  const Icon(Icons.arrow_upward_outlined),
                  Text('(${commentData.rate})')
                ],
              )
            ],
          )
        ],
      ),
    );
                            
  }
}