import 'dart:math';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/utils/extension.dart';
import 'package:bangu_lite/internal/utils/extract.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/components/sticker_select_overlay.dart';
import 'package:bangu_lite/widgets/dialogs/general_transition_dialog.dart';
import 'package:bangu_lite/widgets/dialogs/report_dialog.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final Function(int, String)? onReplyComment;

    /// Null => Delete , Exist => Edit
    final Function(String?)? onUpdateComment;

    /// reportType,Reason?
    final Function(int, String?)? onReportComment;

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

    void invokeToaster({String? message}) => fadeToaster(context: context, message: message ?? "请求中");

    void invokeRequestSnackBar({String? message, bool? requestStatus}) => showRequestSnackBar(
        message: message,
        requestStatus: requestStatus,
        backgroundColor: judgeCurrentThemeColor(context)
    );

    @override
    Widget build(BuildContext context) {

        final accountModel = context.read<AccountModel>();
        final indexModel = context.read<IndexModel>();

        final ModalRoute<dynamic>? currentRoute = ModalRoute.of(context);

        return CompositedTransformTarget(
            link: stickerLayerLink,
            child: PopupMenuButton<CommentActionType>(
                constraints:const BoxConstraints(
                  maxHeight: 3*kToolbarHeight
                ),
                iconSize: 22,
                style: const ButtonStyle(
                  alignment: Alignment.bottomCenter,
                ),
                onOpened: (){
                  debugPrint("contentID: ${widget.contentID}, reply:${widget.commentData.commentID}, action:${widget.postCommentType}");
                },
                onSelected: (commentAction) {
            
                    debugPrint("${currentRoute.runtimeType}");
            
                    invokeCommentToggle(String message) => accountModel.toggleComment(
                        /// widget.commentData.contentID 并不可靠 因为部分获取的字段并不包含它
                        contentID: widget.contentID,
                        commentID: widget.commentData.commentID,
                        commentContent: message,
                        postCommentType: widget.postCommentType,
                        actionType: commentAction == CommentActionType.edit ? UserContentActionType.edit : UserContentActionType.post,
                        fallbackAction: (errorMessage) {
            
                            debugPrint("[ToggleContent] ${widget.contentID} SendContent: $errorMessage");
            
                            if (currentRoute is ModalBottomSheetRoute) {
            
                                invokeToaster(message: errorMessage);
                            }
            
                            else {
                                invokeRequestSnackBar(
                                    message: errorMessage,
                                    requestStatus: false,
                                );
                            }
            
                            indexModel.draftContent.addAll({
                                widget.contentID : ("",message)
                            });
            
                        }
                    ); 
            
                    switch (commentAction){
            
                        case CommentActionType.copy:{
            
                            Clipboard.setData(
                              ClipboardData(
                                text: extractBBCodeSelectableContent(widget.commentData.comment ?? "")
                              )
                            );
            
                        }
            
            
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
                            ).then((content) async {
            
                                        /// 此处回复的内容应只有 content 也就是 String
            
                                        if (content is String) {
            
                                            invokeRequestSnackBar();
            
                                            //网络层 Callback
                                            await invokeCommentToggle(content).then((resultID) {
            
                                                    if (resultID != 0) {
                                                        debugPrint("[PostContent] sendMessageresultID:$resultID SendContent: $content");
                                                        //UI层 Callback
            
                                                        widget.onReplyComment?.call(widget.commentData.commentID!, content);
            
                                                        if (currentRoute is ModalBottomSheetRoute) {
                                                            invokeToaster(message: "回复成功");
                                                        }
            
                                                        else {
                                                            invokeRequestSnackBar(requestStatus: true);
                                                        }
            
                                                    }
            
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
                            showReportDialog(
                              context,
                              contentID: widget.contentID,
                              postCommentType: widget.postCommentType!
                            );
                        }
            
                        case CommentActionType.edit:{
            
                            //invokeToaster({String? message})=> fadeToaster(context: context, message: message ?? "修改成功");
            
                            final throwFlag = widget.commentData.takeCondition((it) {
                                    if (it is EpCommentDetails) {
                                        if (it.repliedComment?.isNotEmpty == true) {
                                            invokeToaster(message: "一般用户无法更改携带回复的评论");
            
                                            return true;
                                        }
                                    }
            
                                    return false;
                                });
            
                            if (throwFlag == true) return;
            
                            Navigator.pushNamed(
                                context,
                                Routes.sendComment,
                                arguments: {
                                    'contentID':widget.commentData.commentID,
                                    'postCommentType':widget.postCommentType,
                                    'title': '编辑这段评论',
                                    'preservationContent': ("",widget.commentData.comment)
                                }
                            ).then((content) async{
                                        if (content is String) {
            
                                            if (currentRoute is ModalBottomSheetRoute) {
                                                invokeToaster(message: "请求中",);
                                            }
            
                                            else {
                                                invokeRequestSnackBar();
                                            }
            
                                            //invokeRequestSnackBar();
            
                                            //widget.onUpdateComment?.call(content);
            
                                            //网络层 Callback
                                            await invokeCommentToggle(content).then((resultID) {
                                                    debugPrint("[EditContent] sendMessageresultID:$resultID SendContent: $content");
            
                                                    if (resultID != 0) {
                                                        //UI层 Callback
                                                        widget.onUpdateComment?.call(content);
            
                                                        if (currentRoute is ModalBottomSheetRoute) {
                                                            invokeToaster(message: "发送成功");
                                                        }
            
                                                        else {
                                                            invokeRequestSnackBar(requestStatus: true);
                                                        }
            
                                                    }
            
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
                itemBuilder: (_) {
                    return List.generate(
                        accountModel.isLogined() ? CommentActionType.values.length : 1,
                        //CommentActionType.values.length,
                        (index) {
            
                            CommentActionType currentCommentActionType = CommentActionType.values[index];
            
                            bool isActionAvaliable = !(widget.commentBlockStatus ?? false);
            
                            if (
                                isActionAvaliable && 
                                accountModel.isLogined() &&
                                widget.commentData.commentID != null
                            ) {
                              isActionAvaliable = judgeActionAvaliable(currentCommentActionType);
                            }
            
                            else {
                              isActionAvaliable = currentCommentActionType == CommentActionType.copy ? true : false;
                            }
            
                            return PopupMenuItem(
                                height: 50,
                                enabled: isActionAvaliable,
                                value: CommentActionType.values[index],
                                child: Builder(
                                    builder: (_) {
            
                                        if (CommentActionType.values[index] == CommentActionType.sticker) {
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

    bool judgeActionAvaliable(
      CommentActionType currentCommentActionType,
    ) {
        bool isActionAvaliable = true;

        switch (currentCommentActionType){

            case CommentActionType.reply:{
                if (widget.postCommentType == PostCommentType.subjectComment) {
                    isActionAvaliable = false;
                }
            }

            case CommentActionType.sticker:{
                if (
                [
                    PostCommentType.replyBlog,
                    PostCommentType.postTimeline,
                    PostCommentType.replyTimeline,
                ].contains(widget.postCommentType)
                ) {
                    isActionAvaliable = false;
                }
            }

            case CommentActionType.edit:{

                if (
                [
                    /// Blog有点特殊 一般人无法修改带有replies 的 comment
                    /// "you don't have permission to edit a comment with replies"
                    PostCommentType.subjectComment,
                    PostCommentType.postTimeline,
                    PostCommentType.replyTimeline,
                ].contains(widget.postCommentType)
                ) {

                    isActionAvaliable = false;

                }

                else {

                    if (widget.commentData.userInformation?.userID != AccountModel.loginedUserInformations.userInformation?.userID) {
                        isActionAvaliable = false;
                    }

                }
            }

            case CommentActionType.delete:{

                if (widget.commentData.userInformation?.userID != AccountModel.loginedUserInformations.userInformation?.userID) {
                    isActionAvaliable = false;
                }

                if (
                [
                    PostCommentType.subjectComment,
                    PostCommentType.replyTimeline,
                ].contains(widget.postCommentType)
                ) {
                    isActionAvaliable = false;
                }

            }

            /// 基本上只要登陆就被允许 但不适用于收藏评论里 详情看 [ReportSubjectType]
            case CommentActionType.report:{
                if (
                [
                  PostCommentType.subjectComment,
                ].contains(widget.postCommentType)
                ) {
                    isActionAvaliable = false;
                }

            }

            default:{}
        }

          

        return isActionAvaliable;
    }

}

