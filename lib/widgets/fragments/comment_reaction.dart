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
    return Row(
      spacing: 12,
      mainAxisAlignment: MainAxisAlignment.end,
      children: List.generate(
        commentReactions?.length ?? 0,
        (index){
          
            int dataLikeIndex = commentReactions!.keys.elementAt(index);

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
                  message: "${commentReactions?[dataLikeIndex]?.join("、")}",
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                    
                      Image.asset(
                        "assets/bangumiSticker/bgm$stickerIndex.gif",
                        scale: stickerIndex == 124 || stickerIndex == 125 ? 1.6 : 0.8,
                      ),
                    
                      ScalableText("${commentReactions?[dataLikeIndex]?.length}"),
                    ],
                  ),
                ),
              ),
            );
          }
      ),

      
    );
        
  }
}