import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';

class CommentReaction extends StatelessWidget {
  const CommentReaction({
    super.key,
    this.commentReactions,
  });

  final Map<int, Set<String>>? commentReactions;

  @override
  Widget build(BuildContext context) {

    if(commentReactions == null || commentReactions!.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 60,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: commentReactions?.length ?? 0,
        itemBuilder: (_, index) {
          
          int dataLikeIndex = commentReactions!.keys.elementAt(index);
          int stickerIndex = convertStickerDatalike(dataLikeIndex);
          
      
          //我也不知道为什么别人前端的里 大部分 data-like-value 的差异都是39 就只有 0 指向的是 44
          //data-like-value = 0 => "/img/smiles/tv/44.gif"
          //至于为什么是+23 那就是因为 bgm 与 tv 包的差异了 bgm包刚好是23个表情 因此偏移23
          
          //但唯有 0 dataLikeIndex 是需求增加 
          //而其他的 dataLikeIndex 都是 减少偏移数值
         
      
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
                triggerMode: TooltipTriggerMode.tap,
                message: "${commentReactions?[dataLikeIndex]?.take(6).join("、")}等${commentReactions?[dataLikeIndex]?.length}人",
                textStyle: TextStyle(
                  color: judgeDarknessMode(context) ? Colors.black : Colors.white
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                  
                    Image.asset(
                      "assets/bangumiSticker/bgm$stickerIndex.gif",
                      scale: 0.8,
                    ),
                  
                    ScalableText("${commentReactions?[dataLikeIndex]?.length}"),
                  ],
                ),
              ),
            ),
          );
      
        },
      
        separatorBuilder: (_, index) => const Padding(padding: PaddingH6),
       
        
      ),
    );
  }
}