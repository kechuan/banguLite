import 'package:bangu_lite/models/comment_details.dart';
import 'package:bangu_lite/widgets/fragments/ep_comment_tile.dart';
import 'package:bangu_lite/widgets/fragments/ep_replied_tile.dart';
import 'package:flutter/material.dart';

class EpCommentView extends StatelessWidget {
  const EpCommentView({
    super.key, 
    required this.epCommentData
  });
  
  final EpCommentDetails epCommentData;
  
  @override
  Widget build(BuildContext context) {

    return ListTile(
      title: EpCommentTile(epCommentData: epCommentData),
      subtitle: EpRepliedTile(epCommentData: epCommentData),
    );

  }
}