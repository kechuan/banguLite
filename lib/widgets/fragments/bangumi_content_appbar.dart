
import 'dart:math';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/foundation.dart';
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

  final Function((int?,Object))? onSendMessage;

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
            onPressed: (){
              debugPrint("back Trigger");
              Navigator.of(context).maybePop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
            
          Expanded(
            child: ScalableText(
              '$titleText',
              overflow: TextOverflow.ellipsis,
            ),
          ),


          if(kDebugMode)
            IconButton(
              onPressed: (){
                debugPrint('new replied in UI');
                onSendMessage?.call(
                  (
                    //null,
                    Random().nextInt(65535),
                    "一个回帖测试"
                  )
                );
              }, 
              icon: const Icon(Icons.download_outlined)
            ),
            
          IconButton(
            onPressed: (){

              invokeToaster({String? message})=> fadeToaster(context: context, message: message ?? "请求中");

              if(postCommentType == PostCommentType.postBlog){
                invokeToaster(message: '暂不支持发送长评');
                return;
              }

              invokeRequestSnackBar({String? message,bool? requestStatus}) => showRequestSnackBar(
                message: message,
                requestStatus: requestStatus,
                backgroundColor: judgeCurrentThemeColor(context)
              );

              invokeSendComment(String message) => accountModel.toggleComment(
                contentID: contentID,
                commentContent: message,
                postCommentType: postCommentType,
                actionType : UserContentActionType.post,
                fallbackAction: (errorMessage)=> invokeRequestSnackBar(message: errorMessage,requestStatus: false)
              );

              invokePostContent((String,String) content) => accountModel.postContent(
                subjectID: contentID,
                title: content.$1,
                content: content.$2,
                postContentType: postCommentType,
                actionType : UserContentActionType.post,
                fallbackAction: (errorMessage)=> invokeRequestSnackBar(message: errorMessage,requestStatus: false)
              );

              if(accountModel.isLogined() == false){
                invokeToaster(message: "评论功能需要先经过登录");
                return;
              }

                
              Navigator.of(context).pushNamed(
                Routes.sendComment,
                arguments: {
                  'contentID':contentID,
                  'postCommentType':postCommentType,
                  'title': titleText,
                  'preservationContent': indexModel.draftContent[contentID]
                }
              ).then((content) async {

                debugPrint("[PostContent] id:$contentID/$postCommentType");

                //invokeRequestSnackBar(message: "回帖成功",requestStatus: true);
                //onSendMessage?.call(content as String);

                if(content is String){

                  //网络层 Callback
                  await invokeSendComment(content).then((result){
                    debugPrint("[PostContent] sendMessageResult:$result SendContent: $content");
                    //UI层 Callback
                    if(result != 0){
                      invokeRequestSnackBar(message: "回帖成功",requestStatus: true);
                      onSendMessage?.call((result,content));
                    }

                    else{
                      invokeToaster(message: "因错误未能发送 内容已保留至草稿纸");

                      indexModel.draftContent.addAll({
                        contentID : ("",content)
                      });

                    }
                    
                  });

                }

                if(content is (String,String)){

                  //invokeRequestSnackBar(message: "UI回帖成功",requestStatus: true);
                  //onSendMessage?.call((result,content));

                  await invokePostContent(content).then((result){
                    debugPrint("[PostContent] sendMessageResult:$result SendContent: $content");
                    //UI层 Callback
                    if(result != 0){
                      invokeRequestSnackBar(message: "回帖成功",requestStatus: true);
                      onSendMessage?.call((result,content));
                    }

                    else{
                      invokeToaster(message: "因错误而未能发送 内容已保留至草稿纸");

                      indexModel.draftContent.addAll({
                        contentID : (content.$1,content.$2)
                      });

                    }
                    
                  });

                }
                
              });
            },
            icon: Icon(Icons.edit_document,color: accountModel.isLogined() ? null : Colors.grey)
          ),

          if(webUrl != null)
            IconButton(
              onPressed: () async {
                if(await canLaunchUrlString(webUrl ?? '')){
                  await launchUrlString(webUrl ?? '');
                }
              },
              icon: Transform.rotate(
                angle: -45 * pi / 180,
                child: const Icon(Icons.link),
              )
            ),

        ],
      ),
    );
                                    
  }
}