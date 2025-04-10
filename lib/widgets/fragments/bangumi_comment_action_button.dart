import 'dart:math';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/const.dart';
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
    required this.commentBlockStatus,

    this.postCommentType,
    this.onReplyComment,
    this.onUpdateComment,
    this.onReportComment,
    this.onSticker,

  });
  
  final BaseComment commentData;
  final PostCommentType? postCommentType;
  final bool? commentBlockStatus;

  /// commentID理应是一致的 只不过是引用的内容会有区别 不会存在三层评论这种情况
  final Function(int,String)? onReplyComment;

  /// Null => Delete , Exist => Edit
  final Function(String?)? onUpdateComment;

  /// reportType,Reason?
  final Function(int,String?)? onReportComment;

  /// dataLikeIndex,commentID
  final Function(int?,int?)? onSticker;

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
              ).then((content){
                if(
                  widget.onReplyComment!=null &&
                  content is String &&
                  widget.commentData.commentID != null
                ){
                  widget.onReplyComment!(widget.commentData.commentID!,content);
                }
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
                  'actionType': UserContentActionType.edit,
                  'preservationContent': widget.commentData.comment
                }
              ).then((content){
                if(widget.onUpdateComment!=null && content!=null && content is String){
                  widget.onUpdateComment!(content);
                }
              });

            }
      
            case CommentActionType.delete:{
              if(widget.onUpdateComment!=null){
                widget.onUpdateComment!(null);
              }
            }
              
              
          }
        },
        itemBuilder: (_){
          return List.generate(
            CommentActionType.values.length, (index){

              CommentActionType currentCommentActionType = CommentActionType.values[index];

              bool isActionAvaliable = 
                //widget.commentBlockStatus == true || widget.commentData.commentID == null ?
                widget.commentBlockStatus == true ?
                false :
                true;

                if(isActionAvaliable && accountModel.isLogined()){

                  switch(currentCommentActionType){

                      case CommentActionType.reply:{
                        if(widget.postCommentType == PostCommentType.subjectComment){
                          isActionAvaliable = false;
                        }
                      }
                        
                      case CommentActionType.sticker:{
                        if(
                          widget.postCommentType == PostCommentType.postBlog || 
                          widget.postCommentType == PostCommentType.replyBlog
                        ){
                          isActionAvaliable = false;
                        }
                      }

                      case CommentActionType.edit:
                      case CommentActionType.delete:{
                        if(widget.commentData.userInformation?.userID != accountModel.loginedUserInformations.userInformation?.userID){
                          isActionAvaliable = false;
                        }
                      }

                      default:{}


                      
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

