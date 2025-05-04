
import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
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

          //IconButton(
          //  onPressed: (){
          //    final userModel = context.read<UserModel>();
              
          //    fadeToaster(context: context, message: "删除user信息");

          //    userModel.userData.remove('user');
          //  }, 
          //  icon: const Icon(Icons.abc)
          //),
            
          IconButton(
            onPressed: (){

              invokeRequestSnackBar({String? message,bool? requestStatus}) => showRequestSnackBar(
                context,
                message: message,
                requestStatus: requestStatus,
              );

              invokeSendComment(String message) => accountModel.toggleComment(
                contentID: contentID,
                commentContent: message,
                postCommentType: postCommentType,
                actionType : UserContentActionType.post,
                fallbackAction: (errorMessage)=> invokeRequestSnackBar(message: errorMessage,requestStatus: false)
              );

              if(accountModel.isLogined() == false){
                fadeToaster(context: context, message: "评论功能需求登录用户");
                return;
              }

              Navigator.of(context).pushNamed(
                Routes.sendComment,
                arguments: {
                  'contentID':contentID,
                  'postCommentType':postCommentType,
                  'title': titleText,
                  'preservationContent': indexModel.draftContent[contentID]?.values.first
                }
              ).then((content) async {

                debugPrint("[PostContent] id:$contentID/$postCommentType");

                if(content is String){

                                      
                  //invokeRequestSnackBar(message: "UI回帖成功",requestStatus: true);
                  //onSendMessage?.call(content);
                    

                  invokeRequestSnackBar();

                  //网络层 Callback
                  await invokeSendComment(content).then((result){
                    debugPrint("[PostContent] sendMessageResult:$result SendContent: $content");
                    //UI层 Callback
                    if(result){
                      invokeRequestSnackBar(message: "回帖成功",requestStatus: true);
                      onSendMessage?.call(content);
                    }
                    
                  });

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
              angle: 45,
              child: const Icon(Icons.link),
            )
          ),
        ],
      ),
    );
                                    
  }
}