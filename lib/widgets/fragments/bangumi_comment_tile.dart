import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/fragments/comment_reaction.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/models/comment_details.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

class BangumiCommentTile extends StatelessWidget {
  const BangumiCommentTile({
    super.key,
    required this.commentData,
    this.themeColor
  });

  final CommentDetails commentData;
  final Color? themeColor;

  @override
  Widget build(BuildContext context) {

    int ratingScore = commentData.rate ?? 0;

    DateTime commentStamp = DateTime.fromMillisecondsSinceEpoch(commentData.commentTimeStamp!*1000);

    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          spacing: 12,
          children: [
            
            Builder(builder: (_){
              if(commentData.avatarUrl==null) return Image.asset("assets/icons/icon.png",height: 50,width: 50,);

              return SizedBox(
                height: 50,
                width: 50,
                child: CachedImageLoader(imageUrl: commentData.avatarUrl!,photoViewStatus: true,)
              );

            }),

            ScalableText(commentData.nickName ?? "nameID",style: TextStyle(color: themeColor)),

            const Spacer(),

            //因为tile的title给的交叉轴也是unbounded的 所以需要约束
            SizedBox(
              height: 30,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemExtent: 25,
                shrinkWrap: true,
                itemCount: ratingScore != 0 ? 5 : 0,
                
                itemBuilder: (_,score){
                  if(ratingScore >= (score+1)*2){
                    return Icon(Icons.star,color: themeColor);
                  }

                  else if(ratingScore == (score*2)+1){
                    return Icon(Icons.star_half,color: themeColor);
                  }

                  else{
                    return Icon(Icons.star_outline,color: themeColor);
                  }

                },
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ScalableText("${commentStamp.year}-${convertDigitNumString(commentStamp.month)}-${convertDigitNumString(commentStamp.day)} ${convertDigitNumString(commentStamp.hour)}:${convertDigitNumString(commentStamp.minute)}"),
              CommentReaction(commentReactions: commentData.commentReactions,)
            ],
          )

        ],
      ),
    );
                            
  }
}