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
    return ListView.builder(
      itemCount: currentComment.repliedComment?.length ?? 1,
      
      itemBuilder: (_,index){

        if(commentIndex!=null) debugPrint("打开了第${commentIndex!+1}个评论");

        if(index == 0){
          return Column(
            children: [
              EpCommentTile(epCommentData: currentComment),
              const Divider(height: 1),
            ],
          );
        }

        return EpCommentTile(epCommentData: currentComment.repliedComment![index]);
    
      }
    );


  }
}