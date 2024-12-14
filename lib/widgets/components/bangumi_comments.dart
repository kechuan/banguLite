import 'dart:async';
import 'dart:math';

import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/models/providers/comment_model.dart';
import 'package:bangu_lite/widgets/views/comment_cache_view.dart';
import 'package:provider/provider.dart';

class CommentView extends StatefulWidget {
  const CommentView({
    super.key,
    required this.totalPageLength,
    required this.subjectID,
    required this.commentPageController,
  });

  final int totalPageLength;
  final int subjectID;
  final PageController commentPageController;

  @override
  State<CommentView> createState() => _CommentViewState();
}

class _CommentViewState extends State<CommentView> with SingleTickerProviderStateMixin {

  late TabController commentController;

  //final PageController widget.commentPageController = PageController();
  final ScrollController tabScrollController = ScrollController();
  //final Map<int,List<CommentDetails>> commentsData = {}; 

  //既然我没办法做到pageView预先加载 但预先填充数据这点 我还是能做到的

  @override
  void initState() {

    commentController = TabController(
      vsync: this,
      length: widget.totalPageLength
    );

    commentController.addListener((){
        widget.commentPageController.jumpToPage(
          commentController.index, 
        );
    });

    super.initState();
  }

  @override
  void dispose() {
    commentController.dispose();
    widget.commentPageController.dispose();
    tabScrollController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(widget.totalPageLength == 0 || widget.subjectID == 0) return const CommentLoading();

    final commentModel = context.read<CommentModel>();

    //数据预装载 最大期望3页
    int loadPageCount = convertTotalCommentPage(widget.totalPageLength,10);

    unawaited(
      Future.wait(
        List.generate(
          min(3,loadPageCount),
          (index) => commentModel.loadComments(widget.subjectID,pageIndex: index+1),
        )
      )
    );

    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox.shrink(),  
        flexibleSpace: Theme(
          data: ThemeData(
            scrollbarTheme: const ScrollbarThemeData(
              thickness: WidgetStatePropertyAll(0.0) //it work
              //trackVisibility: WidgetStatePropertyAll(false), //not work. strange.
              //thumbVisibility: WidgetStatePropertyAll(false),
            )
          ),
          child: EasyRefresh(
            child: TabBar(
              controller: commentController,
              isScrollable: true,
              indicatorColor: BangumiThemeColor.sea.color,
              unselectedLabelColor: BangumiThemeColor.sea.color,
              labelColor: BangumiThemeColor.sea.color,
              
              tabs: 
                List.generate(
                  widget.totalPageLength,
                  (index) => SizedBox(
                    height: 60,
                    width: MediaQuery.sizeOf(context).width/(widget.totalPageLength).clamp(1, 6), //最多存在6个
                    child: Center(child: Text("${index+1}"))
                  )
                ),
            ),
          ),
        ),
        toolbarHeight: 60,
        
      ),
      body: PageView.builder(
        controller: widget.commentPageController,
        onPageChanged: (newPageIndex){

          context.read<CommentModel>().changePage(newPageIndex+1);

          debugPrint("PageView Changed:${newPageIndex+1}");
          
          //用于解决移动端允许拖拽commentPage以响应上方的tabController
          //但是它会令 tabController本身被受限 其本质原因是animateToPage。
          if(newPageIndex != commentController.index){
            debugPrint("redirect commentController:$newPageIndex");
            commentController.animateTo(newPageIndex);
          }

        },
        itemCount: widget.totalPageLength,
        itemBuilder: (_,index)=> CachePage(
          currentPageIndex: index,
          //commentsData: commentsData, //在loading的途中直接载入
          id: widget.subjectID,
        ),
      )
    );
  
  }
}

class CommentLoading extends StatelessWidget {
  const CommentLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 1,
        child: Scaffold(
          appBar: AppBar(
            leading: const SizedBox.shrink(),  
            flexibleSpace: const TabBar(
              tabs: [
                SizedBox(
                  height: 60,
                  child: Center(child: Text("1"))
                )
              ],
            ),
        
            toolbarHeight: 50,
            
          ),
          body: const TabBarView(
            children: [
              Center(child: CircularProgressIndicator())
            ],
          ),
        ),
      );
  }
}
