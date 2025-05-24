import 'dart:async';
import 'dart:math';

import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/subjects/bangumi_details.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/bangumi_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/star_slider_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StarSubjectDialog extends StatelessWidget {
  const StarSubjectDialog({
    super.key,
    required this.subjectID,
    this.commentDetails,
    
    this.themeColor, 
    this.onUpdateLocalStar,
    this.onUpdateBangumiStar

  });

  final Function()? onUpdateLocalStar;
  final Function({String? message,bool? requestStatus})? onUpdateBangumiStar;
  
  final CommentDetails? commentDetails;
  final int subjectID;
  final Color? themeColor;

  @override
  Widget build(BuildContext context) {

	final accountModel = context.read<AccountModel>();

    final ValueNotifier<bool> commentExpandedStatusNotifier = ValueNotifier(commentDetails?.comment != null);
    final ValueNotifier<double> commentRankNotifier = ValueNotifier((commentDetails?.rate ?? 0).toDouble());
    final ValueNotifier<StarType> starTypeNotifier = ValueNotifier<StarType>(commentDetails?.type ?? StarType.none);

    final TextEditingController contentEditingController = TextEditingController(text: commentDetails?.comment);
    final ExpansionTileController commentExpansionTileController = ExpansionTileController();

    return Dialog(
      child: ValueListenableBuilder(
        valueListenable: commentExpandedStatusNotifier,
        builder: (_,commentExpandedStatus,child) {
          return AnimatedContainer(
            padding: Padding16,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
			      width: max(300, MediaQuery.sizeOf(context).height*9/16),
            height: max(250, MediaQuery.sizeOf(context).height/3) + (commentExpandedStatus ? 180 : 0),
            child: Column(
              spacing: 6,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                ScalableText(starTypeNotifier.value != StarType.none ? "修改该番剧的收藏状态" : "收藏该番剧",style: const TextStyle(fontSize: 20)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ScalableText("Bangumi收藏状态 :",style: TextStyle(color: Color.fromARGB(255, 233, 166, 206)),),
                    
                    ValueListenableBuilder(
                      valueListenable: starTypeNotifier,
                        builder: (_,starType,child) {
                        return PopupMenuButton<StarType>(
						              enabled: accountModel.isLogined(),
                          initialValue: starTypeNotifier.value,
                          position:PopupMenuPosition.under,
                          itemBuilder: (_) => List.generate(
                            StarType.values.length,
                            (index){
                              return PopupMenuItem(
                                value: StarType.values[index],
                                child: ScalableText(StarType.values[index].starTypeName)
                              );
                            }
                          ),
                          onSelected: (starType){
                            starTypeNotifier.value = starType;
                            if(starType == StarType.none){
                              commentExpandedStatusNotifier.value = false;

                              if(commentExpansionTileController.isExpanded){
                              commentExpansionTileController.collapse();
                              }

                            }
                            
                          },
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              children: [
                                Padding(
                                  padding: PaddingH6,
                                  child: ScalableText(
                                    starType.starTypeName,
                                    style: TextStyle(
                                      color: accountModel.isLogined() ? null : Colors.grey

                                    ),
                                  ),
                                ),
                            
                                Icon(Icons.arrow_drop_down,color: accountModel.isLogined() ? null : Colors.grey,)
                            
                              ],
                            ),
                          ),
                          
                          
                        );
                      }
                    )
                  ],
                ),

              	Expanded(
                  child: Center(
                    child: ValueListenableBuilder(
                      valueListenable: starTypeNotifier,
                        builder: (_,starType,child) {
                        return ExpansionTile(
                        controller: commentExpansionTileController,
                        enabled: starType != StarType.none,
                        onExpansionChanged: (value) => commentExpandedStatusNotifier.value = value,
                        initiallyExpanded: commentExpandedStatus,
                        title: const Text("展开评论与评分"),
                        children: [
                
                          Center(
                            child: StarSliderPanel(
                              valueNotifier: commentRankNotifier,
                              onChanged: (value) => commentRankNotifier.value = value,
                              themeColor:themeColor
                            ),
                          ),
                
                          const Padding(padding: PaddingV6),
                
                          TextField(
                            controller: contentEditingController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: '写下吐槽...',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(),
                            ),
                          )
                        ],
                        );
                      }
                      ),
                  ),
                ),

                Row(
				           mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    
                    TextButton(
                      onPressed: (){
                        onUpdateLocalStar?.call();
                        Navigator.of(context).pop();
                        },
                      child: const ScalableText("仅本地收藏")
                    ),


                  if(accountModel.isLogined())
                    	const Spacer(),

					if(accountModel.isLogined())
						Row(
							children: [
								TextButton(
								onPressed: ()=> Navigator.of(context).pop(), 
								child: const ScalableText("取消")
								),
								TextButton(
									onPressed: () async {

										invokeAsyncPop(StarType status)=> Navigator.of(context).pop(status);

										if(!MyHive.starBangumisDataBase.containsKey(subjectID)){
											onUpdateLocalStar?.call();
										}

                    onUpdateBangumiStar?.call();

										accountModel.postContent(
											subjectID:subjectID.toString(),
											postContentType:PostCommentType.subjectComment,
											actionType: UserContentActionType.edit,
											subjectCommentQuery:BangumiQuerys.subjectCommentQuery(
												content: contentEditingController.text,
												isPrivate: false,
												starType:starTypeNotifier.value,
											),
											fallbackAction: (errorMessage) => onUpdateBangumiStar?.call(message: errorMessage,requestStatus: false),
										).then((status){

                      status!= 0 ? onUpdateBangumiStar?.call(message: "收藏成功",requestStatus:true) : null;
                      status!= 0 ? invokeAsyncPop(starTypeNotifier.value) : invokeAsyncPop(commentDetails?.type ?? StarType.none);
										});

									}, 
									child: const ScalableText("确定")

								
								),
							],
						),
                  ],
                )
            
              ],
            ),
          );
        }
      ),
    );
  }
}

Future<StarType?> showStarSubjectDialog(
  BuildContext context,
  {
    Function()? onUpdateLocalStar,
    Function({String? message,bool? requestStatus})? onUpdateBangumiStar,
    BangumiDetails? bangumiDetails,
    CommentDetails? commentDetails,
    String? comment,
    Color? themeColor
  }
){
  
  Completer<StarType?> starTypeCompleter = Completer();

	showGeneralDialog(
		barrierDismissible: true,
		barrierLabel: "'!barrierDismissible || barrierLabel != null' is not true",
		context: context,
		pageBuilder: (_,inAnimation,outAnimation){
			final bangumiModel = context.read<BangumiModel>();

			return StarSubjectDialog(
				subjectID: bangumiModel.subjectID,
				commentDetails: commentDetails,
				onUpdateLocalStar: onUpdateLocalStar,
        onUpdateBangumiStar: onUpdateBangumiStar,
				themeColor: themeColor,

			);
		},
		transitionBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation,child: child),
		transitionDuration: const Duration(milliseconds: 300)
	).then((result){
		if(result is StarType?) starTypeCompleter.complete(result);
	});

	return starTypeCompleter.future;
}