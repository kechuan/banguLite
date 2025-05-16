import 'dart:math';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';

import 'package:bangu_lite/widgets/components/sticker_select_overlay.dart';
import 'package:bangu_lite/widgets/dialogs/general_transition_dialog.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BangumiCommentActionButton extends StatefulWidget {
  const BangumiCommentActionButton({
    super.key,
    // 有些 commentData 字段缺失 主ID 导致无法回帖
    required this.contentID,
    required this.commentData,
    this.commentBlockStatus,

    this.postCommentType,
    this.onReplyComment,
    this.onUpdateComment,
    this.onReportComment,
    this.onSticker,

  });

  final int contentID;
  
  final BaseComment commentData;
  final PostCommentType? postCommentType;
  final bool? commentBlockStatus;

  /// commentID理应是一致的 只不过是引用的内容会有区别 不会存在三层评论这种情况
  final Function(int,String)? onReplyComment;

  /// Null => Delete , Exist => Edit
  final Function(String?)? onUpdateComment;

  /// reportType,Reason?
  final Function(int,String?)? onReportComment;

  /// isExist in default reactionList?
  final Function(int)? onSticker;

  @override
  State<BangumiCommentActionButton> createState() => _BangumiCommentActionButtonState();
}

class _BangumiCommentActionButtonState extends State<BangumiCommentActionButton> {

  late final StickerSelectOverlay stickerSelectOverlay;
  final LayerLink stickerLayerLink = LayerLink();

  @override
  void initState() {
    stickerSelectOverlay = StickerSelectOverlay(
      context: context,
      buttonLayerLink: stickerLayerLink,
      postCommentType: widget.postCommentType,
      onStick: widget.onSticker
    );
    super.initState();
  }

  @override 
  void dispose() {
    stickerSelectOverlay.closeStickerSelectFieldOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final accountModel = context.read<AccountModel>();
    final indexModel = context.read<IndexModel>();

    return CompositedTransformTarget(
      link: stickerLayerLink,
      child: PopupMenuButton<CommentActionType>(
        onSelected: (commentAction){

          debugPrint("contentID: ${widget.contentID}, reply:${widget.commentData.commentID}");

          invokeRequestSnackBar({String? message,bool? requestStatus}) => showRequestSnackBar(
            context,
            message: message,
            requestStatus: requestStatus,
          );

          invokeSendComment(String message)=> accountModel.toggleComment(
            /// widget.commentData.contentID 并不可靠 因为部分获取的字段并不包含它
            contentID: widget.contentID,
            commentID: widget.commentData.commentID,
            commentContent: message,
            postCommentType: widget.postCommentType,
            actionType : commentAction == CommentActionType.edit ? UserContentActionType.edit : UserContentActionType.post,
            fallbackAction: (message){
              fadeToaster(context: context, message: message,duration: const Duration(seconds: 5));
            }
          ); 


          switch(commentAction){

            case CommentActionType.reply:{

              Navigator.pushNamed(
                context,
                Routes.sendComment,
                arguments: {
                  'contentID':widget.contentID,
                  'replyID':widget.commentData.commentID,
                  'postCommentType':widget.postCommentType,
                  'title': '回复 ${widget.commentData.userInformation?.nickName ?? widget.commentData.userInformation?.userName}',
                  'referenceObject': '${widget.commentData.comment}',
                  'preservationContent': indexModel.draftContent[widget.commentData.commentID]
                }
              ).then((content) async{

                if(content is String){

                  invokeRequestSnackBar();

                  //网络层 Callback
                  await invokeSendComment(content).then((resultID){

                    if(resultID != 0){
                      debugPrint("[PostContent] sendMessageresultID:$resultID SendContent: $content");
                      //UI层 Callback

                      widget.onReplyComment?.call(widget.commentData.commentID!,content);
                    }

   
                    invokeRequestSnackBar(requestStatus: resultID != 0);
                    

                  });

                
                }
              });
                
              
            }
              
            case CommentActionType.sticker:{
              stickerSelectOverlay.showStickerSelectOverlay(
                widget.commentData.commentID
              );
            }
              
            case CommentActionType.report:{
              //Dialog reportReason 暂且不做
              debugPrint("report");
            }
              
              
            case CommentActionType.edit:{

              Navigator.pushNamed(
                context,
                Routes.sendComment,
                arguments: {
                  'contentID':widget.commentData.commentID,
                  'postCommentType':widget.postCommentType,
                  'title': '编辑这段评论',
                  'preservationContent': widget.commentData.comment
                }
              ).then((content) async{
                if(content is String){

                  invokeRequestSnackBar();

                  //widget.onUpdateComment?.call(content);

                  //网络层 Callback
                  await invokeSendComment(content).then((resultID){
                    if(resultID != 0){
                      debugPrint("[EditContent] sendMessageresultID:$resultID SendContent: $content");
                      //UI层 Callback
                      widget.onUpdateComment?.call(content);
                      //widget.onReplyComment?.call(widget.commentData.commentID!,content);
                    }

                    invokeRequestSnackBar(requestStatus: resultID != 0);
                    

                  });

                }
              });

            }
      
            case CommentActionType.delete:{

              showTransitionAlertDialog(
                context,
                title: "删除内容确认",
                content: "确认删除这条内容吗?",
                confirmAction: () {
                  widget.onUpdateComment?.call(null);
                },
              );


            }
              
              
          }
        
        },
        itemBuilder: (_){
          return List.generate(
            CommentActionType.values.length, (index){

              CommentActionType currentCommentActionType = CommentActionType.values[index];

              bool isActionAvaliable = 
                widget.commentBlockStatus == true ? false : true;

                if(isActionAvaliable && accountModel.isLogined()){

                  switch(currentCommentActionType){

                      case CommentActionType.reply:{
                        if(
                          [
                            PostCommentType.subjectComment,
                          ].contains(widget.postCommentType)
                        ){
                          isActionAvaliable = false;
                        }
                      }
                        
                      case CommentActionType.sticker:{
                        if(
                          [
                            PostCommentType.replyBlog,
                            PostCommentType.postTimeline,
                            PostCommentType.replyTimeline,
                          ].contains(widget.postCommentType)
                        ){
                          isActionAvaliable = false;
                        }
                      }

                      case CommentActionType.edit:{
                        if(
                          [
                            PostCommentType.postTimeline,
                            PostCommentType.replyTimeline,
                          ].contains(widget.postCommentType)
                        ){
                          isActionAvaliable = false;
                        }
                      }
                      case CommentActionType.delete:{
                        if(
                          widget.postCommentType == PostCommentType.subjectComment ||
                          widget.postCommentType == PostCommentType.replyTimeline
                        ){
                          isActionAvaliable = false;
                        }

                        if(widget.commentData.userInformation?.userID != AccountModel.loginedUserInformations.userInformation?.userID){
                          isActionAvaliable = false;
                        }
                      }

                      case CommentActionType.report:{
                        isActionAvaliable = false;
                      }

                      
                  }

                }

                else{
                  isActionAvaliable = false;
                }
              

      
              return PopupMenuItem(
                
                  height: 50,
                  enabled: isActionAvaliable,
                  value: CommentActionType.values[index],
                  child: Builder(
                    builder: (_) {
                      
                      if(CommentActionType.values[index] == CommentActionType.sticker){
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
      
                            ScalableText(CommentActionType.values[index].actionTypeString),
      
                            Transform.rotate(
                              angle: 90 * pi / 180,
                              child: const Icon(Icons.arrow_drop_up)
                            )
                          ]
                        );
                      }
                      
                      return ScalableText(CommentActionType.values[index].actionTypeString);
      
                    }
                  ),
                );
            }
          );
        }
      ),
    );

  }
}

