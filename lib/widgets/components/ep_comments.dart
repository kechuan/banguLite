import 'package:bangu_lite/models/ep_details.dart';
import 'package:bangu_lite/widgets/fragments/ep_comment_tile.dart';
import 'package:bangu_lite/widgets/fragments/ep_replied_tile.dart';
import 'package:flutter/material.dart';

class EpCommentView extends StatelessWidget {
  const EpCommentView({
    super.key, 
    this.myKey,
    required this.epCommentData
  });
  
  final EpCommentDetails epCommentData;
  final GlobalKey? myKey;

  @override
  Widget build(BuildContext context) {

    return ListTile(
      key: myKey,
      title: EpCommentTile(epCommentData: epCommentData),
      subtitle: EpRepliedTile(epCommentData: epCommentData),
    );

  }
}