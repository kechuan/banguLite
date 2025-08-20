import 'dart:math';

import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/widgets/components/custom_bbcode_text.dart';
import 'package:bangu_lite/internal/utils/extension.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_comment_action_button.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_user_avatar.dart';
import 'package:bangu_lite/widgets/fragments/comment_reaction.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:flutter/material.dart';

class EpCommentTile extends StatefulWidget {
  const EpCommentTile({
    super.key,
    required this.contentID,
    required this.epCommentData,
	  required this.postCommentType,
    this.themeColor, 
    this.onUpdateComment,
    this.authorType,
    this.isEllipsis = false
  });

  final int contentID;
  
  final EpCommentDetails epCommentData;
  final PostCommentType? postCommentType;
  final BangumiCommentAuthorType? authorType;
  final Color? themeColor;
  final bool isEllipsis;

  final Function(String?)? onUpdateComment;

  @override
  State<EpCommentTile> createState() => _EpCommentTileState();
}

class _EpCommentTileState extends State<EpCommentTile> {

  final GlobalKey<AnimatedListState> animatedTagsListKey = GlobalKey<AnimatedListState>();

  final ValueNotifier<int> reactDataLikeNotifier = ValueNotifier(-1);

  late final ValueNotifier<bool?> expandedReplyNotifier;

  @override
  void initState() {
    debugPrint("EpCommentTile initState: ${widget.epCommentData.epCommentIndex}: length: ${widget.epCommentData.comment?.length}");
    expandedReplyNotifier = ValueNotifier(((widget.epCommentData.comment?.length ?? 0) > 300) ? false : null);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    bool commentBlockStatus = false;

    if(
      widget.epCommentData.state != null && (widget.epCommentData.state?.isNotAvaliable() ?? true)
    ){
      commentBlockStatus = true;
    }

    DateTime commentStamp = DateTime.fromMillisecondsSinceEpoch((widget.epCommentData.commentTimeStamp ?? 0)*1000);


    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.center,
            
            children: [

              BangumiUserAvatar(
                size: 50,
                userInformation: widget.epCommentData.userInformation,
              ),

              //可压缩信息 Expanded
              Expanded(
                flex: 2,
                child: Row(
                  spacing: 6,
                  children: [

                    Expanded(
                      child: ScalableText(
                        widget.epCommentData.userInformation?.nickName ?? widget.epCommentData.userInformation?.userName ?? "no data"
                        "${widget.authorType?.typeName}",
                          style: TextStyle(
                            color: widget.epCommentData.userInformation?.getName() == AccountModel.loginedUserInformations.userInformation?.getName()
                              ? judgeCurrentThemeColor(context)
                              :Colors.blue,
                            
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    ScalableText(
                      widget.authorType?.typeName == null ? "" : "(${widget.authorType?.typeName})",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold
                      ),

                    ),

                  ],
                ),
              ),

              //优先完整实现 size约束盒
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                //constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width/3),
                //这个长度一般是 "YEAR-MO-DA HO:MI" 的长度
                //但如果设备上的字体是不一样的话。。我就不好说了
                child: Wrap(
                  spacing: 6,
                  alignment: WrapAlignment.end,
                  children: [
                          
                    ScalableText(widget.epCommentData.epCommentIndex== null ? "" : "#${widget.epCommentData.epCommentIndex}"),
                          
                    ScalableText(
                      "${commentStamp.year}-${convertDigitNumString(commentStamp.month)}-${convertDigitNumString(commentStamp.day)}"
                    ),

                    ScalableText(
                      "${convertDigitNumString(commentStamp.hour)}:${convertDigitNumString(commentStamp.minute)}",
                    )

                  ],
                ),
              ),

              BangumiCommentActionButton(
                contentID: widget.contentID,
                commentData: widget.epCommentData,
                commentBlockStatus: commentBlockStatus,
                postCommentType: widget.postCommentType,
                onUpdateComment: widget.onUpdateComment,
                onSticker: (datalikeIndex){

                  int repeatIndex = unExistID;

                  widget.epCommentData.commentReactions?.let((commentReactions){

                    bool isReactionExist = commentReactions.keys.every(
                      (currentDataLike) => currentDataLike == datalikeIndex
                    );

                    commentReactions.entries.any((userList){
                      if(
                        userList.value.any((currentName)=> currentName == (AccountModel.loginedUserInformations.userInformation?.getName() ?? ""))
                      ){
                        repeatIndex = userList.key;
                        return true;
                      }

                      return false;
                    });
        
                    if(!isReactionExist){

                      //如果已经存在，则删除然后等待后续重新 insert 以更新的 数值
                      if(repeatIndex != -1){
                        commentReactions.remove(repeatIndex);

                        animatedTagsListKey.currentState?.removeItem(
                          repeatIndex == -1 ? max(0,commentReactions.length-1) : 0,
                          (_,animation)=> FadeTransition(opacity: animation,child: const SizedBox.shrink())
                        );
                      }

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        animatedTagsListKey.currentState?.insertItem(
                          repeatIndex == -1 ? max(0,commentReactions.length-1) : 0,
                          duration: const Duration(milliseconds: 300)
                        );
                      });

                    }


                    else{
                      if(repeatIndex == datalikeIndex){
                        commentReactions[datalikeIndex]!.remove(AccountModel.loginedUserInformations.userInformation?.getName() ?? "");
                        reactDataLikeNotifier.value = unExistID;
                        return;
                      }
                    }

                    reactDataLikeNotifier.value = datalikeIndex;

                    commentReactions[datalikeIndex] = {
                      ...commentReactions[datalikeIndex] ?? {},
                      AccountModel.loginedUserInformations.userInformation?.getName() ?? ""
                    };

                    


                  });

                },
              ),
              
            ],
          ),

          Builder(builder: (_){
            if(widget.epCommentData.userInformation?.sign == null || widget.epCommentData.userInformation!.sign!.isEmpty){
                return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ScalableText("(${widget.epCommentData.userInformation?.sign})",style:const TextStyle(color: Colors.grey)),
            );
          }),

          
        ],
      ),

      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [

          ValueListenableBuilder(
            valueListenable: expandedReplyNotifier,
            builder: (_, expandedStatus, child) {
          
          
              return Stack(
				alignment: Alignment.bottomCenter,
                children: [
          
					AnimatedContainer(
						height: expandedStatus == false ? MediaQuery.sizeOf(context).height/3 : null,
						duration: const Duration(milliseconds: 300),
						child: Padding(
						padding: const EdgeInsets.only(top: 16),
						child: LayoutBuilder(
							builder: (_,constraint) {

							return Column(
								spacing: 12,
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
								
									Column(
										children: [
									
										...?(!commentBlockStatus && widget.epCommentData.comment?.isNotEmpty == true) ? 
										[

											SizedBox(
												height: expandedStatus == false ? constraint.maxHeight - 12 : null,
												child: AdapterBBCodeText(
													data:convertBangumiCommentSticker(widget.epCommentData.comment ?? ""),
													stylesheet: appDefaultStyleSheet(context,selectableText: true),
													errorBuilder: (context, error, stackTrace) {
														debugPrint("renderError: ${widget.epCommentData.epCommentIndex} err:$error ");
														return ScalableText("${widget.epCommentData.comment}");
													},
												),
											),
									
											
											
										] : null,
									
									],
									),
								
									expandedStatus == true ?
									Align(
										alignment: const Alignment(1.0, 0),
										child: DecoratedBox(
										decoration: BoxDecoration(
											border: Border.all(width: 1,color: Colors.green),
											borderRadius: BorderRadius.circular(24),
											
										),
										child: TextButton(
											onPressed: ()=> expandedReplyNotifier.value = false, 
											child: const ScalableText("收起")
										),
									)) :
									const SizedBox.shrink()
								
								
								]
								);
							}
						)
						),
					),

					

					

					Positioned.fill(
						bottom: 0,
						child: Offstage(
						offstage: expandedStatus != false,
							child: Stack(
								alignment: Alignment.bottomCenter,
								children: [

									SizedBox(
										height: 50,
										child: Text("点击展开更多内容")
									),

									Positioned.fill(
										bottom: 0,
										child: UnVisibleResponse(
										onTap: ()=> expandedReplyNotifier.value = true,
										child: DecoratedBox(
											decoration: BoxDecoration(
											borderRadius: BorderRadius.circular(16),
											gradient: LinearGradient(
												begin: Alignment.bottomCenter,
												end: Alignment(0,0.15),
												colors: [

													judgeDarknessMode(context) ? Colors.white : Color.fromRGBO(162, 167, 146, 0.329),
													Colors.transparent
												]
											)
											),
										),
										),
									),
								],
							)
						),
					)

                
                ],
              );
            },
            child: 
				commentBlockStatus ?
				Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
					const ScalableText("发言已隐藏"),
					ScalableText("原因: ${widget.epCommentData.state?.reason}")
					],
				)
				: null
			,
          ),


          //commentReaction Area
          Builder(
            builder: (_) {
                      
              int? commentIndex = int.tryParse(widget.epCommentData.epCommentIndex?.split('-').first ?? '');
              int? replyIndex = int.tryParse(widget.epCommentData.epCommentIndex?.split('-').length == 1 ? '' : widget.epCommentData.epCommentIndex?.split('-').last ?? '');
                      
              return Align(
                alignment: Alignment.centerRight,
                child: CommentReaction(
                  animatedReactionsListKey: animatedTagsListKey,
                  themeColor: widget.themeColor,
                  postCommentType: widget.postCommentType,
                  commentID: widget.epCommentData.commentID,
                  commentIndex: commentIndex,
                  replyIndex: replyIndex,
                  commentReactions: widget.epCommentData.commentReactions,
                  reactDataLikeNotifier: reactDataLikeNotifier
                ),
              );
            }
          ),
      
          //commentAction Area
    
    
          // 楼主: null 
          // 层主: 3
          // 回帖: 3-1(详情界面特供)
          ...?widget.epCommentData.epCommentIndex?.contains("-") ?? false ? 
          [const Divider()] :
          null,
        
        
        ],
      ),
    );
             
  }
}
