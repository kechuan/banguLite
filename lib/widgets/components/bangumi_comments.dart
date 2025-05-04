import 'dart:async';
import 'dart:math';

import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
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
    this.bangumiThemeColor,
    required this.commentPageController,
  });

  final int totalPageLength;
  final int subjectID;
  final Color? bangumiThemeColor;
  final PageController commentPageController;

  @override
  State<CommentView> createState() => _CommentViewState();
}

class _CommentViewState extends LifecycleRouteState<CommentView> with SingleTickerProviderStateMixin,  RouteLifecycleMixin  {

  late TabController commentTabController;

  //bool handleTabChange = false;
  //既然我没办法做到pageView预先加载 但预先填充数据这点 我还是能做到的


  @override
  void initState() {

    super.initState();

    commentTabController = TabController(
      vsync: this,
      length: widget.totalPageLength
    );
    
      commentTabController.addListener((){
        //疑问:
        //如果不添加这种设置 在左右划屏幕的时候 就会直接被取消动画 而
        //但如果添加了这种设置 那么主动点击的时候。。就直接被return掉了

        //只能这样了 阈值设置在 1 之内 好在jumpPage的时候只能是整数值

        if((commentTabController.index - widget.commentPageController.page!).abs() < 0.9) return;

        widget.commentPageController.jumpToPage(commentTabController.index);
      });
    
  }

  @override
  void dispose() {
    commentTabController.dispose();
    widget.commentPageController.dispose();
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
          //(index) => commentModel.loadComments(widget.subjectID,pageIndex: index+1),
          (index) => commentModel.loadComments(pageIndex: index+1),
        )
      )
    );

    return Theme(
      data: ThemeData(
        brightness: Theme.of(context).brightness,
        colorSchemeSeed: widget.bangumiThemeColor,
        fontFamilyFallback: convertSystemFontFamily(),
        scrollbarTheme: const ScrollbarThemeData(
          thickness: WidgetStatePropertyAll(0.0) //it work

        ),
        
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: const SizedBox.shrink(),  
          flexibleSpace: EasyRefresh(
            child: TabBar(
              controller: commentTabController,
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: EdgeInsets.symmetric(horizontal: MediaQuery.sizeOf(context).width/min(widget.totalPageLength*2.5,14)), // 同屏数量*2
              
              tabs: 
                List.generate(
                  widget.totalPageLength,
                  (index) => SizedBox(
                    child: Tab(child: ScalableText("${index+1}"))
                  )
                ),
            ),
          ),
          toolbarHeight: 60,
          
        ),
        body: EasyRefresh(
          triggerAxis: Axis.horizontal,
          child: PageView.builder(
            controller: widget.commentPageController,
            onPageChanged: (newPageIndex){
              commentModel.changePage(newPageIndex+1);
              commentTabController.animateTo(newPageIndex);
              debugPrint("PageView Changed:${newPageIndex+1}");
            },
            itemCount: widget.totalPageLength,
            itemBuilder: (_,index)=> CommentCachePage(
              currentPageIndex: index,
              id: widget.subjectID,
            ),
          ),
        )
      ),
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
                  child: Center(child: ScalableText("1"))
                )
              ],
            ),
        
            toolbarHeight: 60,
            
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
