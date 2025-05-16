
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/providers/bangumi_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/skeleton_tile_template.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/bangu_lite_routes.dart';

import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/providers/comment_model.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_comment_tile.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BangumiHotComment extends StatefulWidget {
  const BangumiHotComment({
    super.key,
    required this.id,
	  this.name
  });

  final int id;
  final String? name;

  @override
  State<BangumiHotComment> createState() => _BangumiHotCommentState();
}

class _BangumiHotCommentState extends State<BangumiHotComment> {
  final ValueNotifier<bool> isOldCommentSort = ValueNotifier<bool>(false);

  Future? commentFuture; //better than in stateless.

  @override
  Widget build(BuildContext context) {

      if(widget.id == 0) return const SizedBox.shrink();

      final bangumiModel = context.read<BangumiModel>();
      final commentModel = context.read<CommentModel>();
      
      commentFuture ??= commentModel.loadComments();

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Selector<CommentModel, List<CommentDetails>>(
            selector: (_, commentModel){
        
              if(commentModel.commentsData.isEmpty) return [];

              //last 代表offset最靠前的位置 也就是最早的comments
              return isOldCommentSort.value ?
              commentModel.commentsData.values.last :
              commentModel.commentsData.values.first ;

            },
            
            shouldRebuild: (previous, next){
        
              if(previous.isEmpty || next.isEmpty) return true;
              debugPrint("comment rebuild received: ${previous[0].commentTimeStamp!=next[0].commentTimeStamp}");
              return previous[0].commentTimeStamp!=next[0].commentTimeStamp;
            },
            builder: (_,commentListData,child) {
        
              return FutureBuilder(
                future: commentFuture,
                builder: (_,__){

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      child!,
                      
                      Skeletonizer(
                        enabled: commentListData.isEmpty,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 20),
                          child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: commentListData.isEmpty ? 3 : commentListData.length,
                            separatorBuilder: (_, index) => const Divider(height: 2),
                            itemBuilder: (_,index){
                              
                              //原本获取过来的数据是 Offset: 390 391 392 ... 400 这样给你展示的 所以默认状态下会变成越滚动越晚的消息
                              //但一般人们的信息习惯是优先看到消息最新(晚)的消息才对 所以排序得更改一下
                              
                            
                              if(commentListData.isEmpty){
                                return const SkeletonListTileTemplate();
                              }
                              
                              //无评论的显示状态
                              if(commentListData.length == 1 && commentListData[0].commentID == 0){
                                return const Center(
                                  child: ScalableText("该番剧暂无人评论..."),
                                );
                              }
                                
                              return BangumiCommentTile(
                                contentID: commentListData[index].contentID ?? 0,
                                commentData: commentListData[index],
                                themeColor:judgeDetailRenderColor(context,bangumiModel.imageColor)
                              );
                            }
                          ),
                        ),
                      ),
                      
                            
                    ],
                  );
              
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  
                  children: [
                    const ScalableText("吐槽",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
        
                    Row(

                      children: [
        
                        DecoratedBox(
                          decoration: const BoxDecoration(
                            border: Border(right: BorderSide(width: 1.5,color: Colors.grey))
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            
                            child: TextButton(

                              onPressed: (){

                                if(
                                  commentModel.commentsData.values.first.length == 1 && 
                                  commentModel.commentsData.values.first[0].commentID == 0
                                ){
                                  debugPrint("no comment");
                                  return;
                                }

                                Navigator.pushNamed(
                                  context,
                                  Routes.subjectComment,
                                  arguments: {
                                    "commentModel":commentModel,
                                    "subjectID":widget.id,
                                    "name":widget.name,
                                    "bangumiThemeColor":bangumiModel.bangumiThemeColor
                                  }
                                );
                              },
                              child: const ScalableText("吐槽合集",style: TextStyle(decoration: TextDecoration.underline)),
                            ),
                          ),
                        ),
        
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: InkResponse(
                            radius: 16,
                            hoverDuration: const Duration(milliseconds: 200),
                            splashColor: const Color.fromARGB(255, 117, 117, 117),
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onTap: (){
                              debugPrint("change timeSort way");                              
                          
                              isOldCommentSort.value = !isOldCommentSort.value;
                          
                              if(
                                commentModel.commentsData.keys.contains(
                                  convertTotalCommentPage(
                                    commentModel.commentLength, 
                                    10
                                ))
                              ){
                                commentModel.notifyListeners();
                              }
                                  
                              else{
                                
                                commentModel.currentPageIndex = isOldCommentSort.value ? convertTotalCommentPage(commentModel.commentLength,10) : 1;
                                
                                //commentModel.loadComments(widget.id,isReverse: isOldCommentSort.value).then((_){
                                commentModel.loadComments(isReverse: isOldCommentSort.value).then((_){
                                  commentModel.changePage(commentModel.currentPageIndex);
                                });
                              }
                              
                            }, 
                            child: ValueListenableBuilder(
                              valueListenable: isOldCommentSort,
                              builder: (_,isOldCommentSort,child) {
                                return Icon(
                                  Icons.history_outlined,
                                  color: isOldCommentSort ? Colors.black : Colors.grey,
                                  semanticLabel: "从旧到新排序",
                                  size: 32,
                                );

                              }
                            )
                          ),
                        ),
                      
                      ],
                    )
                
                  ],
                ),
            ),
              
          ),
            
        );
      
  }
}