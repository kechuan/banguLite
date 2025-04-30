
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentReaction extends StatelessWidget {
  const CommentReaction({
    super.key,
    this.commentID,
    this.commentReactions,
    this.commentIndex,
    this.replyIndex,
    this.postCommentType,

    this.themeColor
  });

  final int? commentID;
  final Map<int, Set<String>>? commentReactions;

  //1 / 1-1 这种 commentIndex
  final int? commentIndex;
  final int? replyIndex;

  final PostCommentType? postCommentType;

  final Color? themeColor;

  @override
  Widget build(BuildContext context) {

    ValueNotifier<int> reactDataLikeNotifier = ValueNotifier(-1);

    final accountModel = context.read<AccountModel>();
    bool isReactAble = accountModel.isLogined() && commentID != null;

    if(commentReactions == null || commentReactions!.isEmpty){
      return const SizedBox.shrink();
    }

    bool isServerDataContain = commentReactions!.entries.any((userList){
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
          return ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            itemCount: commentReactions!.length,
            itemBuilder: (_, index) {
          
              //恐怕 需要变成 reactDataLikeNotifier 驱动了
              
              int dataLikeIndex = commentReactions!.keys.elementAt(index);
              int stickerIndex = convertStickerDatalike(dataLikeIndex);

              Color? buttonColor = 
                isReactAble ? 
                (reactDataLike == dataLikeIndex ? themeColor?.withValues(alpha: 0.8) : themeColor?.withValues(alpha: 0.3)) : 
                Colors.grey.withValues(alpha: 0.8)
              ;

              return Container(
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

                    debugPrint("reactDataLike:$reactDataLike, dataLikeIndex:$dataLikeIndex, subject:$commentID");

                    invokeRequestSnackBar();

                      accountModel.toggleCommentLike(
                        commentID,
                        dataLikeIndex,
                        postCommentType,
                        actionType: reactDataLike == dataLikeIndex ? UserContentActionType.delete : UserContentActionType.post,
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

                              
                    debugPrint("postCommentType:$postCommentType, id: $commentID");
                              
                  },
                  child: Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    message: 
                      "${commentReactions![dataLikeIndex]?.take(6).join("、")}等"
                      "${(commentReactions![dataLikeIndex]?.length ?? 0)}人",
                    textStyle: TextStyle(
                      color: judgeDarknessMode(context) ? Colors.black : Colors.white
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                      
                        Image.asset(
                          "assets/bangumiSticker/bgm$stickerIndex.gif",
                          scale: 0.8,
                        ),
                        
                        ScalableText("${(commentReactions![dataLikeIndex]?.length ?? 0) + (
                            reactDataLike == dataLikeIndex ? 
                              (
                                isServerDataContain ? 
                                reactDataLike != dataLikeIndex ? -1 : 0 :
                                reactDataLike == dataLikeIndex ? 1 : 0
                              ) :
                            reactDataLike == dataLikeIndex ? 1 : 0
                          )
                        }"),
                      ],
                    ),
                  ),
                    
                ),
              );
          
            },
          
            separatorBuilder: (_, index) => const Padding(padding: PaddingH6)
          );
        },
        
      ),
    );
  }
}