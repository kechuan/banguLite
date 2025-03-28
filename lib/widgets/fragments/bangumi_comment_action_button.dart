import 'dart:math';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/models/comment_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/widgets/components/sticker_select_overlay.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BangumiCommentActionButton extends StatefulWidget {
  const BangumiCommentActionButton({
    super.key,
    required this.commentData,
    required this.isSubjectComment
    
  });
  
  final BaseComment commentData;
  final bool isSubjectComment;
  

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
                  'isReply': true,
                  'title': widget.commentData.userInformation?.nickName ?? widget.commentData.userInformation?.userName,
                  'referenceObject': widget.commentData.comment,
                }
              );
            }
              
              
            case CommentActionType.sticker:{
              if(!widget.isSubjectComment){
                stickerSelectOverlay.showStickerSelectOverlay(widget.commentData.commentID);
              }

              else{
                fadeToaster(context: context, message: "官方API暂只支持 剧集/讨论 的表情贴纸");
              }
              
            }
              
              
            case CommentActionType.report:{
              //Dialog reportReason 暂且不做
            }
              
              
            case CommentActionType.edit:{
              Navigator.pushNamed(
                context,
                Routes.sendComment,
                arguments: {
                  'isReply': false,
                  'title': '修改你的评论',
                  'referenceObject': widget.commentData.comment,
                }
              );
            }
      
            case CommentActionType.delete:{
              //accountModel.
            }
              
              
          }
        },
        itemBuilder: (_){
          return List.generate(
            CommentActionType.values.length, (index){
      
              bool isActionAvaliable = 
                accountModel.isLogined() ? 
                (
                  index >= CommentActionType.delete.index ? 
                  accountModel.loginedUserInformations.userInformation?.userID == widget.commentData.userInformation?.userID : 
                  true
                ) 
                : false
              ;
      
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

