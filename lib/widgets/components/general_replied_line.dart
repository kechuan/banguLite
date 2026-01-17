

import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/widgets/fragments/comment_filter.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';

class GeneralRepliedLine extends StatelessWidget {
  const GeneralRepliedLine({
    super.key,
    required this.repliedCount,
    required this.commentFilterTypeNotifier,
    this.descHeadline,
    this.onCommentFilter,
    this.isUserContent = false
  });

  final int repliedCount;
  final String? descHeadline;
  final ValueNotifier<BangumiCommentRelatedType> commentFilterTypeNotifier;

  final bool isUserContent;

  final Function(BangumiCommentRelatedType)? onCommentFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          
          Row(
            spacing: 12,
            children: [
              ScalableText(descHeadline ?? "回复",style: const TextStyle(fontSize: 24)),
              ScalableText("$repliedCount",style: const TextStyle(color: Colors.grey)),
            ],
          ),

          CommentFilter(
            commentSurfTypeNotifier: commentFilterTypeNotifier,
            onCommentFilter: onCommentFilter,
            isUserContent: isUserContent
          )
        ],
      ),
    );
  }
}