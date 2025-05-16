import 'dart:async';
import 'dart:math';

import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/models/providers/comment_model.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_comment_tile.dart';
import 'package:provider/provider.dart';


class CommentCachePage extends StatefulWidget {
  const CommentCachePage({
    super.key,
    required this.id,
    required this.currentPageIndex,
  });

  final int id;
  final int currentPageIndex;

  @override
  State<CommentCachePage> createState() => _CommentCachePageState();

}

class _CommentCachePageState extends State<CommentCachePage> with AutomaticKeepAliveClientMixin {

  static const int disactivePageRange = 3; //差值为3

  bool judgeDisactive(){

    final commentModel = context.read<CommentModel>();

    //判断页面是否为disactive状态: 透过 其在Model里的 currentPageIndex 与当前Page的相差值判断

    if(commentModel.currentPageIndex.compareTo(widget.currentPageIndex+1) == 1){
      
      if(commentModel.currentPageIndex>=(widget.currentPageIndex+1)+disactivePageRange){
        
        commentModel.commentsData.remove(widget.currentPageIndex+1); //移除 以腾出内存

        debugPrint("rebuild: [${widget.currentPageIndex+1}] it should be disposed"); 
        debugPrint("data:${commentModel.commentsData.keys}");
        return true;
      }
    }

    else if(commentModel.currentPageIndex.compareTo(widget.currentPageIndex+1) == -1){
      if(commentModel.currentPageIndex<=(widget.currentPageIndex+1)-disactivePageRange){
        
        commentModel.commentsData.remove(widget.currentPageIndex+1); //移除 以腾出内存

        debugPrint("rebuild: [${widget.currentPageIndex+1}] it should be disposed");
        debugPrint("data:${commentModel.commentsData}");
        
        return true;
      }
    }

    return false; // == 0 的情况 即是 Comment页面与UI当前浏览匹配 为活跃
  }

  @override 
  void dispose(){
    debugPrint("${widget.currentPageIndex+1} was disposed"); //并在UI方面也将其移除
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    debugPrint("page rebuild: ${widget.currentPageIndex+1}");

    return Selector<CommentModel,int>(
      selector: (_, commentModel) => commentModel.currentPageIndex,
      shouldRebuild: (previous, next){

        final commentModel = context.read<CommentModel>();

        debugPrint("recived notify ${widget.currentPageIndex+1}"); 

        if(commentModel.currentPageIndex == widget.currentPageIndex+1) return true;

        //每次被通知更新的时候 先检查当前的页面是否还在alive范围内
        updateKeepAlive(); 
        return !wantKeepAlive; //如果发现不在alive范围内 rebuild => dispose.
        
      },
      builder: (_, currentPageIndex, __){
        
        final commentModel = context.read<CommentModel>();
        final currentPageComments = commentModel.commentsData[widget.currentPageIndex+1];

        //Status:Pending
        if(currentPageComments == null){
          //空数据 null 加载 尝试触发notifiedRebuild
          debugPrint("null!: reLoading ${widget.currentPageIndex+1}");
          //commentModel.loadComments(widget.id,pageIndex: widget.currentPageIndex+1);
          commentModel.loadComments(pageIndex: widget.currentPageIndex+1);

          //等待notfiyListener通知 再过一遍 commentModel.commentsData[currentPageIndex]!=null 检查
          return WaitingBuilder(currentIndex: widget.currentPageIndex+1, subjectID: widget.id);
        }

        //Status:Activing
        if(currentPageComments.isEmpty){
          //只给占位符时 [] 则说明数据已经在处理中 应多等一会.
          //如果超时 则应直接remove掉key 当作此页未进行加载

          debugPrint("waiting ${widget.currentPageIndex+1}");
          return WaitingBuilder(
            subjectID: widget.id,
            currentIndex: widget.currentPageIndex,
          );
        }
        
        //Status:done
        if(currentPageComments.isNotEmpty){
          debugPrint("widget.currentPageIndex: ${widget.currentPageIndex+1} loadData");
          //isDataLoaded = true;

          WidgetsBinding.instance.addPostFrameCallback((timestamp){
            context.read<CommentModel>().loadComments(
              //widget.id,
              pageIndex: min(
                widget.currentPageIndex+2,
                convertTotalCommentPage(commentModel.commentLength,10)
              )

            );
          });



          int? itemCount = currentPageComments.length;

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 20),
            child: ListView.separated(
              itemCount: itemCount == 0 ? 1 : itemCount,
              itemBuilder: (_, index){
            
                if(itemCount == 0){
                  return const Center(child: ScalableText("空空如也..."));
                }
            
                return BangumiCommentTile(
                  //commentData: currentPageComments[itemCount-1 - index]
                  contentID: currentPageComments[index].contentID ?? 0,
                  commentData: currentPageComments[index],
                  themeColor: Theme.of(context).colorScheme.primary,
                );
            
              },
              separatorBuilder: (_, index) => const Divider(height: 2),
            ),
          );
        }


        return const SizedBox.shrink();

       
        
      }
    );
  
  
  }

  @override
  bool get wantKeepAlive => !judgeDisactive(); //Disactive == !wantKeepAlive

}

class WaitingBuilder extends StatelessWidget {
  const WaitingBuilder({
    super.key,
    required this.currentIndex,
    required this.subjectID
  });

  final int currentIndex;
  final int subjectID;

  @override
  Widget build(BuildContext context) {
    final commentModel = context.read<CommentModel>();

    return FutureBuilder(
      //通知等待时间——10s
      future: Future.delayed(const Duration(seconds: 10)).then((value){
        if(commentModel.commentsData[currentIndex]!.isEmpty){
          commentModel.commentsData.remove(currentIndex);
        }
      }),
      builder: (_,snapshot) {
        //这里实际上是等待上层的notifyListener Rebuild 
        //而不是等待Future 如果Future的10s通过了 那么就意味着这次请求肯定失败了

        switch(snapshot.connectionState){
    
          case ConnectionState.done:{

            return InkResponse(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: () {

                debugPrint("$currentIndex: rePull data");

                final commentModel = context.read<CommentModel>();

                //reset Page Status.
                
                commentModel.commentsData.remove(currentIndex);
                commentModel.changePage(currentIndex);
                commentModel.loadComments(
                  //subjectID,
                  pageIndex: currentIndex,
                );
              },
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children:  [
                  ScalableText("数据加载失败, 请点击重试"),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.refresh),
                  )
                ],
              ),
            );
            
          }
    
          default: return const Center(
            child: CircularProgressIndicator(),
          );
    
        }
        
      }
    );

  }
}