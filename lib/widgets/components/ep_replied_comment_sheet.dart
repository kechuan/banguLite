import 'package:bangu_lite/models/ep_details.dart';
import 'package:bangu_lite/widgets/fragments/ep_comment_tile.dart';
import 'package:flutter/material.dart';

class EpRepliedCommentDialog extends StatelessWidget {
  const EpRepliedCommentDialog({
    super.key,
    required this.currentComment,
    this.commentIndex,
  });

  final EpCommentDetails currentComment;
  final int? commentIndex;
  
  @override
  Widget build(BuildContext context) {

    if(commentIndex!=null) debugPrint("打开了第${commentIndex!+1}个评论");

    return ListView.builder(
      itemCount: (currentComment.repliedComment?.length ?? 1)+1,
      
      itemBuilder: (_,index){
        
        //和回帖评论的 Divider作区分 才这么写 
        //因为 其divider长度 受padding影响 不一致区分
        if(index == 0){
            return Column(  
              children: [
                EpCommentTile(epCommentData: currentComment),
                const Divider(height: 1),
              ],
            );
         }

        if(currentComment.repliedComment!.isNotEmpty){
          return EpCommentTile(epCommentData: currentComment.repliedComment![index-1]);
        }

        else{
          return const SizedBox.shrink();
        }

    
      }
    );


  }
}