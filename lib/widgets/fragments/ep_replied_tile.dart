import 'dart:math';

import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/models/ep_details.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/components/ep_replied_comment_sheet.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
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
    ) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: ListTile(
        tileColor: Theme.of(context).brightness == Brightness.light ? const Color.fromARGB(225, 212, 232, 215) : const Color.fromARGB(255, 118, 121, 119),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
            ...List.generate(
              min(3,epCommentData.repliedComment!.length), 
              (index){
      
                return Padding(
                  padding: PaddingV6,
                  child: ShowCommentTap(
                    epCommentData: epCommentData,
                    commentIndex: index,
                    child: Row(
                      spacing: 12,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScalableText("${epCommentData.repliedComment![index].userInformation?.nickName}:"),

                        Expanded(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: AppFontSize.s16 * 6, //字符的字高普遍比字宽大1倍
                              maxWidth: double.infinity
                               
                            ),
                            child: ScalableText(
                              "${epCommentData.repliedComment![index].comment}",
                              maxLines: 3,
                              style: const TextStyle(overflow: TextOverflow.ellipsis,),
                              
                            ),
                          ),
                        )

                      ],
                    ),
                    
                  ),
                );
      
              }
            ),
    
            if(epCommentData.repliedComment!.length > 3) 
              ShowCommentTap(
                epCommentData: epCommentData,
                child: ScalableText(
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

class ShowCommentTap extends InkResponse {
  const ShowCommentTap({
    super.key,
    super.child,
    required this.epCommentData,
    this.commentIndex
  });

  final EpCommentDetails epCommentData;
  final int? commentIndex;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      containedInkWell: true,
      onTap: (){
        showModalBottomSheet(
          isScrollControlled: true,
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width,maxHeight:MediaQuery.sizeOf(context).height*3/4),
          context: context,
          builder: (_)=> EpRepliedCommentDialog(currentComment: epCommentData,commentIndex: commentIndex)
        );
      },
      child: child,
    );
  }
}