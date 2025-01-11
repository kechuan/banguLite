import 'dart:async';
import 'dart:math';

import 'package:bangu_lite/internal/bus_register_method.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
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
    required this.commentPageController,
  });

  final int totalPageLength;
  final int subjectID;
  final PageController commentPageController;

  @override
  State<CommentView> createState() => _CommentViewState();
}

class _CommentViewState extends LifecycleRouteState<CommentView> with SingleTickerProviderStateMixin {

  late TabController commentTabController;

  //bool handleTabChange = false;

  //既然我没办法做到pageView预先加载 但预先填充数据这点 我还是能做到的

  bool isActived = true; 
  
  //在极端状况之下 说不定会出现 (BangumiDetailPageA)EpPage => BangumiDetailPageB => EpPageB...
  //此时 整个路由链存活的 EpPageState 都会触发这个 AppRoute 那就麻烦了, 因此需要加以管控


  @override
  void didPushNext() {
    isActived = false;
    super.didPushNext();
  }

  @override
  void didPopNext() {
    isActived = true;
    super.didPopNext();
  }

  @override
  void initState() {

    bus.on(
      'AppRoute',
      (link) {
        if(!isActived) return;
        if(!context.mounted) return;
        appRouteMethod(context,link);
      }
    );

    commentTabController = TabController(
      vsync: this,
      length: widget.totalPageLength
    );
    
      commentTabController.addListener((){

       
        if(commentTabController.index - widget.commentPageController.page!.toInt().abs() < 2) return;
        widget.commentPageController.jumpToPage(
          commentTabController.index, 
        );
      });
    



    super.initState();
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
    final indexModel = context.read<IndexModel>();

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
              controller: commentTabController,
              isScrollable: true,
              indicatorColor: judgeCurrentThemeColor(context),
              unselectedLabelColor: judgeCurrentThemeColor(context),
              labelColor: judgeCurrentThemeColor(context),
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: EdgeInsets.symmetric(horizontal: MediaQuery.sizeOf(context).width/min(widget.totalPageLength*2.5,16)), // 同屏数量*2
              
              tabs: 
                List.generate(
                  widget.totalPageLength,
                  (index) => SizedBox(
                    child: Tab(child: ScalableText("${index+1}"))
                  )
                ),
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
