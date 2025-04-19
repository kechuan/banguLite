import 'dart:math';

import 'package:bangu_lite/models/comment_details.dart';
import 'package:bangu_lite/models/timeline_details.dart';
import 'package:bangu_lite/models/user_details.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_user_avatar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BangumiTimelineTile extends StatelessWidget {

  const BangumiTimelineTile({
    super.key,
    required this.timelineDetails,
    this.userInformation,
    this.commentDetails
  });

  final TimelineDetails timelineDetails;
  final UserInformation? userInformation;
  final CommentDetails? commentDetails;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        spacing: 6,
        children: [

          BangumiUserAvatar(
            size: 50,
            userInformation: userInformation,
          ),

          Expanded(
            child: LayoutBuilder(
              builder: (_,constraint) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: min(constraint.maxWidth*2/3, 250),
                            maxWidth: constraint.maxWidth - 80,
                          ),
                          child: const ScalableText("这里是标题LongLongLongLongLongLongLongLong",maxLines: 2,overflow: TextOverflow.ellipsis)
                        ),
                        Row(
                          children: [
                            Icon(MdiIcons.chat,size: 16,color: Colors.grey.shade700),
                            ScalableText("100",style: TextStyle(fontSize: 14,color: Colors.grey.shade700)),
                          ],
                        ),
                      ],
                    ),
                
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 6,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: min(constraint.maxWidth/2, 150)),
                          child: ScalableText(
                            "小组 · 靠谱人生茶话会LongLongLong",
                            style: TextStyle(fontSize: 14,color: Colors.grey)
                          ),
                        ),
                
                        Row(
                          spacing: 6,
                          
                          children: [
                            ScalableText("Author",style: TextStyle(fontSize: 14,color: Colors.grey.shade700)),
                            ScalableText("X分钟前",style: TextStyle(fontSize: 14,color: Colors.grey.shade700)),
                          ],
                        ),
                      ],
                    )
                
                  ],
                );
              }
            ),
          )


          
        ],
      ),

    );
  }
}