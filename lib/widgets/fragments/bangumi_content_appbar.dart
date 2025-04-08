import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BangumiContentAppbar extends StatelessWidget {
  const BangumiContentAppbar({
    super.key,
    this.contentID,
    this.titleText,
    this.webUrl,
    this.postCommentType,
    this.surfaceColor,
    this.onSendMessage
  });

  final int? contentID;

  final String? titleText;
  final String? webUrl;
  final PostCommentType? postCommentType;
  final Color? surfaceColor;

  final Function(String)? onSendMessage;

  @override
  Widget build(BuildContext context) {
    
    final indexModel = context.read<IndexModel>();
    final accountModel = context.read<AccountModel>();

    return Container(
      color: surfaceColor,
      height: kToolbarHeight,
      child: Row(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
      
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back),
          ),
            
          Expanded(
            child: ScalableText(
              '$titleText',
              overflow: TextOverflow.ellipsis,
            ),
          ),
            
          IconButton(
            onPressed: (){
              Navigator.of(context).pushNamed(
                Routes.sendComment,
                arguments: {
                  'contentID':contentID,
                  'postCommentType':postCommentType,
                  'title': titleText,
                  'preservationContent': indexModel.draftContent[contentID]?.values.first
                }
              ).then((content){
                if(content != null && content is String){
                  debugPrint("finished Send: $content");
                  if(onSendMessage != null){
                    onSendMessage!(content);
                  }
                }


                
              });
            },
            icon: Icon(Icons.edit_document,color: accountModel.isLogined() ? null : Colors.grey)
          ),
      
          IconButton(
            onPressed: () async {
              if(await canLaunchUrlString(webUrl ?? '')){
                await launchUrlString(webUrl ?? '');
              }
            },
            icon: Transform.rotate(
              angle: -45,
              child: const Icon(Icons.link),
            )
          ),
        ],
      ),
    );
                                    
  }
}