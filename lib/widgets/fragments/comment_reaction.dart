
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentReaction extends StatefulWidget {
  const CommentReaction({
    super.key,
    this.commentID,
    this.commentReactions,
    this.commentIndex,
    this.replyIndex,
    this.postCommentType,

    this.themeColor,

    this.animatedReactionsListKey
  });

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

  ValueNotifier<int> reactDataLikeNotifier = ValueNotifier(-1);

  late final Map<int, Set<String>> localCommentReactions;

  @override
  void initState() {
    localCommentReactions = widget.commentReactions ?? {};
    
    //reactDataLikeNotifier
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    

    final accountModel = context.read<AccountModel>();
    bool isReactAble = accountModel.isLogined() && widget.commentID != null;

    if(localCommentReactions.isEmpty){
      return const SizedBox.shrink();
    }

    bool isServerDataContain = localCommentReactions.entries.any((userList){
      if(userList.value.contains(AccountModel.loginedUserInformations.userInformation?.getName())){
        reactDataLikeNotifier.value = userList.key;
        return true;
      }

      return false;
    });



    return SizedBox(
      height: 40,
      child: ValueListenableBuilder(
        valueListenable: reactDataLikeNotifier,
        builder: (_,reactDataLike,child){
          //AnimatedList 策略 只增不删 允许显示出 0 
          return AnimatedList.separated(
            key: widget.animatedReactionsListKey,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            initialItemCount: localCommentReactions.length,
            separatorBuilder: (_, index_,animation) => const Padding(padding: PaddingH6),
            removedSeparatorBuilder:  (_, index, animation) => const SizedBox.shrink(),
            itemBuilder: (_, index,animation) {

              if(localCommentReactions.isEmpty && reactDataLikeNotifier.value == -1) return const SizedBox.shrink();
          
              //恐怕 需要变成 reactDataLikeNotifier 驱动了
              
              int dataLikeIndex = localCommentReactions.keys.elementAt(index);
              int stickerIndex = convertStickerDatalike(dataLikeIndex);

              Color? buttonColor = 
                isReactAble ? 
                (reactDataLike == dataLikeIndex ? widget.themeColor?.withValues(alpha: 0.8) : widget.themeColor?.withValues(alpha: 0.3)) : 
                Colors.grey.withValues(alpha: 0.8)
              ;

              return SlideTransition(
                position: animation.drive(Tween<Offset>(begin: const Offset(-1, 0),end: Offset.zero)),
                child: FadeTransition(
                  opacity: animation,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: judgeDarknessMode(context) ? Colors.white : buttonColor ?? Colors.grey.withValues(alpha: 0.8),
                      ),
                      borderRadius: BorderRadius.circular(20)
                    ),
                    width: 80,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(buttonColor),
                        padding: const WidgetStatePropertyAll(PaddingH6),
                      ),
                      onPressed:  () {
                  
                        if(!isReactAble) return;
                  
                        invokeRequestSnackBar({String? message,bool? requestStatus}) => showRequestSnackBar(
                          context,
                          message: message,
                          requestStatus: requestStatus,
                        );
                  
                        debugPrint("reactDataLike:$reactDataLike, dataLikeIndex:$dataLikeIndex, subject:${widget.commentID}");
                  
                       
                  
                        //invokeRequestSnackBar(message: "UI贴条成功",requestStatus: true);
                  
                        invokeRequestSnackBar();
                  
                          accountModel.toggleCommentLike(
                            widget.commentID,
                            dataLikeIndex,
                            widget.postCommentType,
                            actionType: reactDataLike == dataLikeIndex ? UserContentActionType.delete : UserContentActionType.post,
                            fallbackAction: (message){
                              invokeRequestSnackBar(message: message,requestStatus: false);
                            }
                          ).then((result){
                            if(result){
                  
                              if(reactDataLike == dataLikeIndex){
                                reactDataLikeNotifier.value = -1;
                              }
                  
                              else{
                                reactDataLikeNotifier.value = dataLikeIndex;
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
                            "assets/bangumiSticker/bgm$stickerIndex.gif",
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
                              child: ScalableText("${(localCommentReactions[dataLikeIndex]?.length ?? 0) + (
                                  reactDataLike == dataLikeIndex ? 
                                    (
                                      isServerDataContain ? 
                                      reactDataLike != dataLikeIndex ? -1 : 0 :
                                      reactDataLike == dataLikeIndex ? 1 : 0
                                    ) :
                                  reactDataLike == dataLikeIndex ? 1 : 0
                                )
                            }"),
                          ),
                        ],
                      ),
                        
                    ),
                  ),
                ),
              );
          
            },
          
            
          );
        },
        
      ),
    );
  }
}