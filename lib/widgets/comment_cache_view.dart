import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:bangu_lite/models/providers/comment_model.dart';
import 'package:bangu_lite/widgets/fragments/comment_tile.dart';
import 'package:provider/provider.dart';


class CachePage extends StatefulWidget {
  const CachePage({
    super.key,
    required this.id,
    required this.currentPageIndex,
  });

  final int id;
  final int currentPageIndex;

  @override
  State<CachePage> createState() => _CachePageState();

}

class _CachePageState extends State<CachePage> with AutomaticKeepAliveClientMixin {

  final int disactivePageRange = 3; //差值为3

  bool judgeDisactive(){

    final commentModel = context.read<CommentModel>();

    //判断页面是否为disactive状态: 透过 其在Model里的 currentPageIndex 与当前Page的相差值判断

    if(commentModel.currentPageIndex.compareTo(widget.currentPageIndex+1) == 1){
      
      if(commentModel.currentPageIndex>=(widget.currentPageIndex+1)+disactivePageRange){
        debugPrint("rebuild: [${widget.currentPageIndex+1}] it should be disposed, data remove;"); 
        commentModel.commentsData.remove(widget.currentPageIndex+1); //移除 以腾出内存
        debugPrint("data:${commentModel.commentsData.keys}");
        
        return true;
      }
    }

    else if(commentModel.currentPageIndex.compareTo(widget.currentPageIndex+1) == -1){
      if(commentModel.currentPageIndex<=(widget.currentPageIndex+1)-disactivePageRange){
        debugPrint("rebuild: [${widget.currentPageIndex+1}] it should be disposed");
        commentModel.commentsData.remove(widget.currentPageIndex+1); //移除 以腾出内存

        
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
        //被触发dispose的时候 shouldRebuild 被执行了两次!
        //也就是说 build的过程 也被执行了两次

        //而 dispose时 reboot状态下 直接回true
        // if(commentModel.currentPageIndex == widget.currentPageIndex+1) return true;



          //数据存在时 return false;取消rebuild
          //if(commentModel.currentPageIndex == widget.currentPageIndex+1){
          //  if(commentModel.commentsData[widget.currentPageIndex+1]!=null && commentModel.commentsData[widget.currentPageIndex+1]!.isNotEmpty){
          //    return true;
          //  }
          //}

        if(commentModel.currentPageIndex == widget.currentPageIndex+1) return true;

        updateKeepAlive();

        //刷新页面且 真的在当前页面时 rebuild
        return !wantKeepAlive;
        
      },
      builder: (_, currentPageIndex, __){
        
        //注意 这里的build过程 会被发生两次 因此必须要做好重复请求直接 return; 的准备
        //因为tabbar的申金原因 会使得
        final commentModel = context.read<CommentModel>();

        final currentPageComments = commentModel.commentsData[widget.currentPageIndex+1];

        if(currentPageComments!=null){

          //正常加载
          if(currentPageComments.isNotEmpty){
            debugPrint("widget.currentPageIndex: ${widget.currentPageIndex+1} loadData");
            //isDataLoaded = true;

            WidgetsBinding.instance.addPostFrameCallback((timestamp){
              context.read<CommentModel>().loadComments(
                widget.id,
                pageIndex: min(
                  widget.currentPageIndex+2,
                  commentModel.commentLength % 10 == 0 ?
                  commentModel.commentLength~/10 :
                  commentModel.commentLength~/10 + 1
                )

              );
            });

            int? itemCount = currentPageComments.length;

            return ListView.separated(
              itemCount: itemCount == 0 ? 1 : itemCount,
              itemBuilder: (_, index){

                if(itemCount == 0){
                  return const Center(child: Text("空空如也..."));
                }

                return CommentTile(
                  commentData: currentPageComments[itemCount-1 - index]
                );

              },
              separatorBuilder: (_, index) => const Divider(height: 2),
            );
          }

          //只给占位符时 [] 则说明数据已经在处理中 应多等一会.
          //如果超时 则应直接remove掉key 当作此页未进行加载
          else{
            debugPrint("waiting ${widget.currentPageIndex+1}");

            return WaitingBuilder(
              subjectID: widget.id,
              currentIndex: widget.currentPageIndex,
            );

          }

        }

        else{

          debugPrint("null!: reLoading ${widget.currentPageIndex+1}");
          
          //空数据 null 加载 尝试触发notifiedRebuild
          commentModel.loadComments(widget.id,pageIndex: widget.currentPageIndex+1);
        
          //等待notfiyListener通知 再过一遍 commentModel.commentsData[currentPageIndex]!=null 检查

          return WaitingBuilder(currentIndex: widget.currentPageIndex+1, subjectID: widget.id);

          
        }
        
      }
    );
  
  
  }

  @override
  bool get wantKeepAlive => !judgeDisactive(); //Disactive => !wantKeepAlive

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
      future: Future.delayed(const Duration(seconds: 10)).then((value){
        if(commentModel.commentsData[currentIndex]!.isEmpty){
          commentModel.commentsData.remove(currentIndex);
        }
      }), //15s(debug模式)后还停留在该loading页面 则提示应需要重新加载
      //future: context.read<CommentModel>().loadComments(widget.id,page: widget.currentPageIndex+1),
      builder: (_,snapshot) {
        switch(snapshot.connectionState){
    
          case ConnectionState.done:{

            return InkResponse(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: () {
                debugPrint("$currentIndex: rePull data");
                context.read<CommentModel>().commentsData.remove(currentIndex);

                context.read<CommentModel>().loadComments(
                  subjectID,
                  pageIndex: currentIndex,
                );
              },
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children:  [
                  Text("数据加载失败, 请点击重试"),
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