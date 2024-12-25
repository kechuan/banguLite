
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/widgets/fragments/skeleton_tile_template.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/bangu_lite_routes.dart';

import 'package:bangu_lite/models/comment_details.dart';
import 'package:bangu_lite/models/providers/comment_model.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_comment_tile.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

      commentFuture ??= context.read<CommentModel>().loadComments(widget.id);

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

                  //以后学聪明点 要不就直接写进initState 然后刷新携带flag 
                  //要不然就是返回Completer 然后从Models里导入数据 
                  //真的该好好想想 就为了节省这Model里多存放一份的数据有必要像这次这样
                  //写一大堆反rebuild的措施吗？ 这从头到尾起码也有三四天的时间去折腾这里了

                builder: (_,__){
        
                  //Selector虽然不rebuild 但不代表不会真不需要layout. 
                  //所以如果size改变的时候 这里的builder流程还是会触发. 但如果你使用的是selector提供的值 这里的值会尽量保持的像静态child!处理的一样
        
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    
                    children: [
                      
                      child!,
                      
                      Skeletonizer(
                        enabled: commentListData.isEmpty,
                        child: ListView.separated(
                          physics: const ScrollPhysics(),
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
                            if(commentListData.length == 1 && commentListData[0].userId == 0){
                              return const Center(
                                child: Text("该番剧暂无人评论..."),
                              );
                            }
                              
                            return BangumiCommentTile(commentData: commentListData[index]);
                          }
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
                    const Text("吐槽",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
        
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

                                final commentModel = context.read<CommentModel>();

                                if(commentModel.commentsData.values.first.length == 1 && commentModel.commentsData.values.first[0].userId == 0){
                                  debugPrint("no comment");
                                  return;
                                }

                                Navigator.pushNamed(
                                  context,
                                  Routes.subjectComment,
                                  arguments: {"commentModel":context.read<CommentModel>(),"subjectID":widget.id,"name":widget.name}
                                );
                              },
                              child: const Text("吐槽合集",style: TextStyle(decoration: TextDecoration.underline,fontSize: 16)),
                            ),
                          ),
                        ),
        
                        //const Padding(
                        //  padding: EdgeInsets.only(left: 16,right: 4), // right:4 + right:12
                        //),

                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: InkResponse(
                            radius: 16,
                            hoverDuration: const Duration(milliseconds: 200),
                            splashColor: const Color.fromARGB(255, 117, 117, 117),
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onTap: (){
                              debugPrint("change way");
                              //context.read<CommentModel>().toggleAutoRebuildStatus();
                                  
                              final commentModel = context.read<CommentModel>();
                          
                              isOldCommentSort.value = !isOldCommentSort.value;
                          
                              if(
                                commentModel.commentsData.keys.contains(
                                  convertTotalCommentPage(
                                    context.read<CommentModel>().commentLength, 
                                    10
                                ))
                              ){
                                context.read<CommentModel>().notifyListeners();
                              }
                                  
                              else{
                                
                                commentModel.currentPageIndex = isOldCommentSort.value ? convertTotalCommentPage(commentModel.commentLength,10) : 1;
                                
                                context.read<CommentModel>().loadComments(widget.id,isReverse: isOldCommentSort.value).then((_){
                                  commentModel.changePage(commentModel.currentPageIndex);
                                });
                              }
                              
                            }, 
                            child: ValueListenableBuilder(
                              valueListenable: isOldCommentSort,
                              builder: (_,isOldCommentSort,child) {
                                return SvgPicture.asset(
                                  'assets/icons/time_sort_old.svg',
                                  semanticsLabel: "从旧到新排序",
                                  height: 32,
                                  width: 32,
                                  color: isOldCommentSort ?Colors.black : null,
                                  
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