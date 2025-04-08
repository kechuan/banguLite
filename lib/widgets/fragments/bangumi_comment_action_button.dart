import 'dart:math';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/models/comment_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';

import 'package:bangu_lite/widgets/components/sticker_select_overlay.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BangumiCommentActionButton extends StatefulWidget {
  const BangumiCommentActionButton({
    super.key,
    required this.commentData,
    this.postCommentType,

    this.onReplyComment,
    this.onDeleteComment,
    this.onEditComment,
    this.onSticker,

    
  });
  
  final BaseComment commentData;
  final PostCommentType? postCommentType;

  final Function()? onReplyComment;
  final Function()? onDeleteComment;
  final Function()? onEditComment;
  final Function()? onSticker;

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
          switch(commentAction){
      
            case CommentActionType.reply:{
              Navigator.pushNamed(
                context,
                Routes.sendComment,
                arguments: {
                  'contentID':widget.commentData.commentID,
                  'postCommentType':widget.postCommentType,
                  'title': widget.commentData.userInformation?.nickName ?? widget.commentData.userInformation?.userName,
                  'referenceObject': widget.commentData.comment,
                  'preservationContent': indexModel.draftContent[widget.commentData.commentID]?.values.first
                }
              ).then((_){
                widget.onReplyComment!();
              });
                
              
            }
              
            case CommentActionType.sticker:{
              if(widget.postCommentType != PostCommentType.subjectComment){
                stickerSelectOverlay.showStickerSelectOverlay(
                  widget.commentData.commentID
                );
              }

              else{
                fadeToaster(context: context, message: "官方API暂只支持 剧集/讨论 的表情贴纸");
              }
              
            }
              
            case CommentActionType.report:{
              //Dialog reportReason 暂且不做
              debugPrint("report");
            }
              
              
            case CommentActionType.edit:{
              debugPrint("edit");

              Navigator.pushNamed(
                context,
                Routes.sendComment,
                arguments: {
                  'contentID':widget.commentData.commentID,
                  'postCommentType':widget.postCommentType,
                  'title': widget.commentData.userInformation?.nickName ?? widget.commentData.userInformation?.userName,
                  'referenceObject': widget.commentData.comment,
                  'preservationContent': indexModel.draftContent[widget.commentData.commentID]?.values.first
                }
              ).then((_){
                if(widget.onEditComment!=null){
                  widget.onEditComment!();
                }
              });

              

              //更改的话。。 恐怕需要透过 userCommentList ?? 那可不行。。
              // button 的位置所处的 能被太多地方所访问。。
              // 恐怕。。需要搞一大堆的 onEdit / onDelete / onSticker 的回调。。
              


              //Navigator.pushNamed(
              //  context,
              //  Routes.sendComment,
              //  arguments: {
              //    'contentID':widget.commentData.commentID,
              //    'title': '修改你的评论',
              //    'preservationContent': widget.commentData.comment
              //  }
              //);
            }
      
            case CommentActionType.delete:{

              if(widget.onDeleteComment!=null){
                widget.onDeleteComment!();
              }

           
              //accountModel.
              //animatedSliverListKey.currentState?.removeItem(index, builder);
            }
              
              
          }
        },
        itemBuilder: (_){
          return List.generate(
            CommentActionType.values.length, (index){

              bool isActionAvaliable = true;

              if(accountModel.isLogined()){

                 if(index == CommentActionType.reply.index){
                    if(widget.postCommentType == PostCommentType.subjectComment){
                      isActionAvaliable = false;
                    }
                 }

                 if(index == CommentActionType.sticker.index){
                    if(
                      widget.postCommentType == PostCommentType.postBlog || 
                      widget.postCommentType == PostCommentType.replyBlog
                    ){
                      isActionAvaliable = false;
                    }
                 }

                 if(index == CommentActionType.edit.index || index == CommentActionType.delete.index){
                    if(widget.commentData.userInformation?.userID != accountModel.loginedUserInformations.userInformation?.userID){
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

