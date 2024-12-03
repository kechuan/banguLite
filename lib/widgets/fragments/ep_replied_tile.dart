import 'dart:math';

import 'package:bangu_lite/models/ep_details.dart';
import 'package:bangu_lite/widgets/components/ep_replied_comment_dialog.dart';
import 'package:flutter/material.dart';

class EpRepliedTile extends ListTile {
  const EpRepliedTile({
    super.key,
    required this.epCommentData,

  });

  final EpCommentDetails epCommentData;

  @override
  Widget build(BuildContext context) {
    if( 
      epCommentData.repliedComment == null ||
      epCommentData.repliedComment!.isEmpty
    ) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        //color: Colors.blue,
      ),
      child: ListTile(
        tileColor: const Color.fromARGB(225, 212, 232, 215),
        title: const SizedBox.shrink(),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
            ...List.generate(
              min(3,epCommentData.repliedComment!.length), 
              (index){
      
                return InkResponse(
                  containedInkWell: true,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: (){
                    showModalBottomSheet(
                      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width),
                      context: context,
                      builder: (_)=> EpRepliedCommentDialog(currentComment: epCommentData,commentIndex: index)
                    );
                  },

                  child: Row(
                    children: [
                      Text("${epCommentData.repliedComment![index].nickName}:"),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 6)),
                      Text("${epCommentData.repliedComment![index].comment}")
                    ],
                  ),
                );
      
              }
            ),
    
            if(epCommentData.repliedComment!.length > 3) 
              InkResponse(
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                containedInkWell: true,
                onTap: (){
                    showModalBottomSheet(
                      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width),
                      context: context,
                      builder: (_)=> EpRepliedCommentDialog(currentComment: epCommentData)
                    );
                },
                
                
                child: Text(
                  "> 点击查看 ${epCommentData.repliedComment!.length} 条评论",
                  style: const TextStyle(color: Colors.blueAccent),
      
                )
              ),
        
        
            
          ],
        ),
      ),
    );

    
  }
}