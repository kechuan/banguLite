
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
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

  @override
  void initState() {
    localCommentReactions = widget.commentReactions ?? {};
    
    localCommentReactions.entries.any((userList){
      if(userList.value.contains(AccountModel.loginedUserInformations.userInformation?.getName())){
        widget.reactDataLikeNotifier.value = userList.key;
        selectedRecordDataLike = userList.key;
        return true;
      }

      return false;
    });

    widget.reactDataLikeNotifier.addListener((){
      updateReactionList();
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

    if(localCommentReactions.isEmpty){
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 40,
      child: AnimatedList.separated(
        key: widget.animatedReactionsListKey,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        initialItemCount: localCommentReactions.length,
        separatorBuilder: (_, index_,animation) => const Padding(padding: PaddingH6),
        removedSeparatorBuilder:  (_, index, animation) => const SizedBox.shrink(),
        itemBuilder: (_, index,animation) {
      
          //AnimatedList 策略
          if(localCommentReactions.isEmpty && widget.reactDataLikeNotifier.value == -1) return const SizedBox.shrink();
          //个人的改变最多会+1 绝对不会再多
          if(index >= localCommentReactions.length ) return const SizedBox.shrink();
          
          int dataLikeIndex = localCommentReactions.keys.elementAt(index);
          int stickerIndex = convertStickerDatalike(dataLikeIndex);
      
          //localCommentReactions[dataLikeIndex]!.add(AccountModel.loginedUserInformations.userInformation!.getName()); 
      
          //Color? buttonColor = 
          //  isReactAble ? 
          //  (widget.reactDataLikeNotifier.value == dataLikeIndex ? widget.themeColor?.withValues(alpha: 0.8) : widget.themeColor?.withValues(alpha: 0.3)) : 
          //  Colors.grey.withValues(alpha: 0.8)
          //;
      
          return SlideTransition(
            position: animation.drive(Tween<Offset>(begin: const Offset(-1, 0),end: Offset.zero)),
            child: FadeTransition(
              opacity: animation,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: judgeDarknessMode(context) ? Colors.white : Colors.grey.withValues(alpha: 0.8),
                  ),
                  borderRadius: BorderRadius.circular(20)
                ),
                width: 80,
                child: TextButton(
                  style: ButtonStyle(
                    padding: const WidgetStatePropertyAll(EdgeInsets.all(0)),
                  ),
                  onPressed:  () {
                      debugPrint("dataLikeIndex:$dataLikeIndex, stickerIndex:$stickerIndex");
              
                      if(!isReactAble) return;
                
                      invokeRequestSnackBar({String? message,bool? requestStatus}) => showRequestSnackBar(
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
                          fallbackAction: (message){
                            invokeRequestSnackBar(message: message,requestStatus: false);
                          }
                        ).then((result){
                          if(result){
                
                            if(widget.reactDataLikeNotifier.value == dataLikeIndex){
                              widget.reactDataLikeNotifier.value = unExistID;
                            }
                
                            else{
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

  void updateReactionList(){
    if(selectedRecordDataLike == widget.reactDataLikeNotifier.value) return;

      if(selectedRecordDataLike != -1){

        if(localCommentReactions[selectedRecordDataLike] != null){
          localCommentReactions[selectedRecordDataLike]!.remove(
            AccountModel.loginedUserInformations.userInformation!.getName()
          );
        }



        if(widget.reactDataLikeNotifier.value != -1){
          localCommentReactions[widget.reactDataLikeNotifier.value]!.add(
            AccountModel.loginedUserInformations.userInformation!.getName()
          );
        }

      }

      else{

        localCommentReactions[widget.reactDataLikeNotifier.value] ??= {};

        localCommentReactions[widget.reactDataLikeNotifier.value]!.add(
          AccountModel.loginedUserInformations.userInformation!.getName()
        );
      }

      selectedRecordDataLike = widget.reactDataLikeNotifier.value;

      setState(() {});
  }
}