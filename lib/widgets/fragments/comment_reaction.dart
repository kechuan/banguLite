import 'dart:ffi';

import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/ep_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//这个变更数据。。恐怕得靠 subjectModel 存储了 因为 commentReactions 的数据是固定的
//除非 我直接去修改 commentReactions 的数据 然后只要包含我的 id 就直接标特殊就行
class CommentReaction extends StatelessWidget {
  const CommentReaction({
    super.key,
    this.commentID,
    this.commentReactions,
    this.commentIndex,
    this.replyIndex,
  });

  final int? commentID;
  final Map<int, Set<String>>? commentReactions;

  //1 / 1-1 这种 commentIndex
  final int? commentIndex;
  final int? replyIndex;

  @override
  Widget build(BuildContext context) {

    //ValueNotifier<int> reactDataLikeNotifier = ValueNotifier(-1);
    final accountModel = context.read<AccountModel>();
    bool isReactAble = accountModel.isLogined() && commentID != null;

    if(commentReactions == null || commentReactions!.isEmpty){
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 60,
      child: Consumer<EpModel>(
        builder: (_,epModel,child){

          debugPrint("rebuild epModel");

          int? selectedDataLikeIndex;

          bool isServerDataContain = false;

          
          if(replyIndex == null){
            selectedDataLikeIndex = epModel.userCommentLikeData[epModel.selectedEp]?[double.parse('$commentIndex')];
          }

          else{
            selectedDataLikeIndex = epModel.userCommentLikeData[epModel.selectedEp]?[double.parse('$commentIndex.$replyIndex')];
          }

          commentReactions!.entries.any((userList){

            if(userList.value.contains(accountModel.loginedUserInformations.userInformation!.getName())){
              isServerDataContain = true;

              if(selectedDataLikeIndex == null){
                  epModel.updateUserEpCommentDataLike(
                  commentID!,
                  userList.key,
                  commentIndex:commentIndex,
                  replyCommentIndex:replyIndex,
                );

                selectedDataLikeIndex = userList.key;
              }

              return true;
            }

            return false;
          });

          
          

          return ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            itemCount: commentReactions!.length,
            itemBuilder: (_, index) {

              //恐怕 需要变成 reactDataLikeNotifier 驱动了
              
              int dataLikeIndex = commentReactions!.keys.elementAt(index);
              int stickerIndex = convertStickerDatalike(dataLikeIndex);
          
              return SizedBox(
                width: 70,
                height: 50,
                child: InkResponse(
                  enableFeedback: isReactAble ? true : false,
                  onLongPress: () {
                    if(!isReactAble) return;

                    final epModel = context.read<EpModel>();
          
                    bool? isExist = epModel.updateUserEpCommentDataLike(
                      commentID!,
                      dataLikeIndex,
                      commentIndex:commentIndex,
                      replyCommentIndex:replyIndex,
                    );

                    if(isExist != null && commentID != null){

                      //这里是 目标行为 而非当前状态
                      if(!isExist){
                        accountModel.actionEpCommentLike(
                          commentID!,
                          dataLikeIndex,
                          actionType: UserContentActionType.delete
                        );
                      }

                      else{
                        accountModel.actionEpCommentLike(
                          commentID!,
                          dataLikeIndex
                        );
                      }
                    }

                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(16),
                      color: 
                        isReactAble ? 
                        (selectedDataLikeIndex == dataLikeIndex ? const Color.fromARGB(255, 169, 186, 216) : null) : 
                        Colors.grey.withValues(alpha: 0.4)
                    ),
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
                              selectedDataLikeIndex == dataLikeIndex ? 
                                (
                                  isServerDataContain ? 
                                  selectedDataLikeIndex != dataLikeIndex ? -1 : 0 :
                                  selectedDataLikeIndex == dataLikeIndex ? 1 : 0
                                ) :
                              selectedDataLikeIndex == dataLikeIndex ? 1 : 0
                            )
                          }"),
                        ],
                      ),
                    ),
                  ),
                    
                ),
              );
          
            },
          
            separatorBuilder: (_, index) => const Padding(padding: PaddingH6)
          );
         
        }

          
        
      ),
    );
  }
}