
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Row.End排序 Horizion无约束
class CommentReaction extends StatefulWidget {
  const CommentReaction({
    super.key,
    this.commentID,
    this.commentReactions,
    this.commentIndex,
    this.replyIndex,
    this.postCommentType,

    this.themeColor,

    this.animatedReactionsListKey,
    required this.reactDataLikeNotifier,
  });

  final ValueNotifier<int> reactDataLikeNotifier;

  final int? commentID;
  final Map<int, Set<String>>? commentReactions;

  //1 / 1-1 这种 commentIndex
  final int? commentIndex;
  final int? replyIndex;

  final PostCommentType? postCommentType;

  final Color? themeColor;

  final GlobalKey<AnimatedListState>? animatedReactionsListKey;

  @override
  State<CommentReaction> createState() => _CommentReactionState();
}

class _CommentReactionState extends State<CommentReaction> {

  late final Map<int, Set<String>> localCommentReactions;

  int selectedRecordDataLike = unExistID;

  int reactionStickerGroupCount = 0;

  @override
  void initState() {
    localCommentReactions = widget.commentReactions ?? {};

    localCommentReactions.entries.any((userList) {
        if (userList.value.contains(AccountModel.loginedUserInformations.userInformation?.getName())) {
          widget.reactDataLikeNotifier.value = userList.key;
          selectedRecordDataLike = userList.key;
          return true;
        }

        return false;
      });

    reactionStickerGroupCount = localCommentReactions.length;

    widget.reactDataLikeNotifier.addListener(() {
      updateReactionList();
      reactionStickerGroupCount = localCommentReactions.length;
    });

    //reactDataLikeNotifiers
    super.initState();
  }

  @override
  void dispose() {
    widget.reactDataLikeNotifier.removeListener(updateReactionList);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountModel = context.read<AccountModel>();
    bool isReactAble = accountModel.isLogined() && widget.commentID != null;

    if (localCommentReactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final reactionBoxDecoration = BoxDecoration(
      border: Border.all(
        color: widget.themeColor ?? Colors.grey.withValues(alpha: 0.8),
        width: 1.5
      ),
      borderRadius: BorderRadius.circular(20)
    );

    const double chipWidth = 80;
    const double separatorWidth = 6*2;
    
    
    // 内容实际需要的宽度
    final double contentWidth = 
        reactionStickerGroupCount * chipWidth + (reactionStickerGroupCount - 1) * separatorWidth;

    // 可用宽度上限，留出 item 左右 padding
    final double maxWidth = 
        MediaQuery.sizeOf(context).width - 32; // 按你的 item 内边距调整


    return SizedBox(
      height: 40,
       width: contentWidth.clamp(0, maxWidth), // ← 给定有界宽度
      child: AnimatedList.separated(
        key: widget.animatedReactionsListKey,
        
        //shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        initialItemCount: localCommentReactions.length,
        separatorBuilder: (_, index_, animation) => const Padding(padding: PaddingH6),
        removedSeparatorBuilder: (_, index, animation) => const SizedBox.shrink(),
        itemBuilder: (_, index, animation) {

          //AnimatedList 策略
          if (localCommentReactions.isEmpty && widget.reactDataLikeNotifier.value == -1) return const SizedBox.shrink();
          //个人的改变最多会+1 绝对不会再多
          if (index >= localCommentReactions.length) return const SizedBox.shrink();

          int dataLikeIndex = localCommentReactions.keys.elementAt(index);
          int stickerIndex = convertStickerDatalike(dataLikeIndex);

          return SlideTransition(
            position: animation.drive(Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)),
            child: FadeTransition(
              opacity: animation,
              child: Container(
                decoration: reactionBoxDecoration,
                width: 80,
                child: TextButton(
                  style: const ButtonStyle(
                    padding: WidgetStatePropertyAll(EdgeInsets.zero),
                  ),
                  onPressed: () {
                    debugPrint("dataLikeIndex:$dataLikeIndex, stickerIndex:$stickerIndex");
          
                    if (!isReactAble) return;
          
                    invokeRequestSnackBar({String? message, bool? requestStatus}) => showRequestSnackBar(
                      message: message,
                      requestStatus: requestStatus,
                      backgroundColor: judgeCurrentThemeColor(context)
                    );
          
                    debugPrint("widget.reactDataLikeNotifier.value:$widget.reactDataLikeNotifier.value, dataLikeIndex:$dataLikeIndex, subject:${widget.commentID}");
          
                    //invokeRequestSnackBar(message: "UI贴条成功",requestStatus: true);
          
                    invokeRequestSnackBar();
          
                    accountModel.toggleCommentLike(
                      widget.commentID,
                      dataLikeIndex,
                      widget.postCommentType,
                      actionType: widget.reactDataLikeNotifier.value == dataLikeIndex ? UserContentActionType.delete : UserContentActionType.post,
                      fallbackAction: (message) {
                        invokeRequestSnackBar(message: message, requestStatus: false);
                      }
                    ).then((result) {
                          if (result) {
          
                            if (widget.reactDataLikeNotifier.value == dataLikeIndex) {
                              widget.reactDataLikeNotifier.value = unExistID;
                            }
          
                            else {
                              widget.reactDataLikeNotifier.value = dataLikeIndex;
                            }
          
                            invokeRequestSnackBar(message: "贴条成功", requestStatus: true);
          
                          }
          
                        });
          
                    debugPrint("postCommentType:${widget.postCommentType}, id: ${widget.commentID}");
          
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        convertBangumiStickerPath(stickerIndex),
                        scale: 0.8,
                      ),
          
                      Tooltip(
                        triggerMode: TooltipTriggerMode.tap,
                        message: 
                        "${localCommentReactions[dataLikeIndex]?.take(6).join("、")}等"
                        "${(localCommentReactions[dataLikeIndex]?.length ?? 0)}人",
                        textStyle: TextStyle(
                          color: judgeDarknessMode(context) ? Colors.black : Colors.white
                        ),
          
                        child: ScalableText(
                          "${localCommentReactions[dataLikeIndex]?.length ?? 0}"
                        )
                      ),
          
                    ],
                  )
                ),
          
              ),
            ),
          
          );

        },

      ),
    );
  }

  void updateReactionList() {
    if (selectedRecordDataLike == widget.reactDataLikeNotifier.value) return;

    if (selectedRecordDataLike != -1) {

      if (localCommentReactions[selectedRecordDataLike] != null) {
        localCommentReactions[selectedRecordDataLike]!.remove(
          AccountModel.loginedUserInformations.userInformation!.getName()
        );
      }

      if (widget.reactDataLikeNotifier.value != -1) {
        localCommentReactions[widget.reactDataLikeNotifier.value]!.add(
          AccountModel.loginedUserInformations.userInformation!.getName()
        );
      }

    }

    else {

      localCommentReactions[widget.reactDataLikeNotifier.value] ??= {};

      localCommentReactions[widget.reactDataLikeNotifier.value]!.add(
        AccountModel.loginedUserInformations.userInformation!.getName()
      );
    }

    selectedRecordDataLike = widget.reactDataLikeNotifier.value;

    setState(() {});
  }
}
