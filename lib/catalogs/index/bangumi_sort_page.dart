

import 'dart:math';

import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/widgets/fragments/animated/animated_wave_footer.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/search_handler.dart';
import 'package:bangu_lite/models/informations/subjects/bangumi_details.dart';
import 'package:bangu_lite/widgets/components/search_fliter.dart';
import 'package:bangu_lite/widgets/fragments/animated/animated_sort_selector.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_tile.dart';
import 'package:sliver_tools/sliver_tools.dart';


class BangumiSortPage extends StatefulWidget {
  const BangumiSortPage({super.key});

  @override
  State<BangumiSortPage> createState() => _BangumiSortPageState();
}

class _BangumiSortPageState extends State<BangumiSortPage>{

  final GlobalKey<SliverAnimatedListState> messageListStreamKey = GlobalKey<SliverAnimatedListState>();
  final GlobalKey<SliverAnimatedGridState> messageGridStreamKey = GlobalKey<SliverAnimatedGridState>();

  final ScrollController sortScrollController = ScrollController();

  final ValueNotifier<ViewType> viewTypeNotifier = ValueNotifier<ViewType>(ViewType.listView);
  final ValueNotifier<SortType> browserSortTypeNotifier = ValueNotifier<SortType>(SortType.rank);

  final ValueNotifier<String> appBarTitleNotifier = ValueNotifier<String>("");
  final ValueNotifier<bool> fliterShowNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<int> loadCountNotifier = ValueNotifier<int>(0);

  final List<BangumiDetails> messageList = [];
  final Map currentSearchConfig = {};

  @override
  void initState() {

    bus.on('sortSubmit',(arg){
      assert(arg is Map<String,dynamic>);
      debugPrint("recived sortSubmit: $arg");
      loadNewData(arg);
    });
    super.initState();

  }


  @override
  Widget build(BuildContext context) {

    return EasyRefresh.builder(
      scrollController: sortScrollController,
      //header: const MaterialHeader(),
      footer: const MaterialFooter(),

      onLoad: () {
        if(messageList.isEmpty) return;
        loadMoreData(currentSearchConfig);
      },
      
      childBuilder: (_,physic){ // scroll Action by: CustomScrollView. just sync notice the physicAction.

        //debugPrint("${MediaQuery.devicePixelRatioOf(context)}");
        return Scaffold(
          body: NotificationListener<ScrollUpdateNotification>(
            onNotification: (notification) {
              
              final double scrollOffset = notification.metrics.pixels;
              //debugPrint("NotificationListener:$scrollOffset");
              scrollOffset >= 95 ? appBarTitleNotifier.value = "筛选动画" : appBarTitleNotifier.value = "";
              return true;
            },
            
            child: CustomScrollView(
              controller: sortScrollController,
              physics: physic,
              slivers: [
          
                SliverPadding(
                  padding: const EdgeInsets.only(top: 24),
                  sliver: SliverAppBar(
                    leadingWidth: 12,
                    title: Padding(
                      padding: const EdgeInsets.only(right: 16),
          
                      child: ValueListenableBuilder(
                        valueListenable: browserSortTypeNotifier,
                        builder: (_, browserSortType, child) {
                          return Row(
                          
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              InkResponse(
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                child: Wrap(
                                  
                                  crossAxisAlignment : WrapCrossAlignment.center,
                                  spacing: 12,
                                  children:  [
                                
                                    const ScalableText("筛选动画"),
                                
                                    Icon(Icons.filter_list,size: min(35,MediaQuery.sizeOf(context).width/20)),
                                  ],
                                ),
                                onTap: () => fliterShowNotifier.value = !fliterShowNotifier.value,
                              ),
                           
                              

                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 16,
                                children: [
          
                                  Container(
                                    height: 35,
                                    decoration: const BoxDecoration(
                                      border: Border(right: BorderSide(width: 1.5))
                                    ),
                                    child: InkResponse(
                                      containedInkWell: true,
                                      highlightColor: Colors.transparent,
                                      radius: 12,
                                      onTap: (){
                                        viewTypeNotifier.value ==  ViewType.gridView ? 
                                        viewTypeNotifier.value = ViewType.listView :
                                        viewTypeNotifier.value = ViewType.gridView ;
                                      },
                                      child: ValueListenableBuilder(
                                        valueListenable: viewTypeNotifier,
                                        builder: (_,viewType,child) {
                                          return  Padding(
                                            padding: const EdgeInsets.only(right: 16),
                                            child:  viewType == ViewType.gridView ? 
                                                    Icon(Icons.grid_view,size: min(35,MediaQuery.sizeOf(context).width/20)) : 
                                                    Icon(Icons.format_list_bulleted,size: min(35,MediaQuery.sizeOf(context).width/20)),
                                          );
                                        }
                                      ),
                                    ),
                                  ),
                                                  
                                  AnimatedSortSelector(
                                    currentType: browserSortType,
                                    selectedType: SortType.rank,
                                    onTap: (){

                                      browserSortTypeNotifier.value = SortType.rank;
                                      if(currentSearchConfig.isEmpty) return;
                                      loadNewData(currentSearchConfig);
          
                                    },
                                    labelIcon: Icons.leaderboard_outlined,
                                    labelText: "排名",
                                  ),
                                                  
                                  AnimatedSortSelector(
                                    currentType: browserSortType,
                                    selectedType: SortType.heat,
                                    onTap: (){
                                      
                                      browserSortTypeNotifier.value = SortType.heat;
                                      if(currentSearchConfig.isEmpty) return;
                                      loadNewData(currentSearchConfig);
                                    
                                    },
                                    labelIcon: Icons.favorite_outline,
                                    labelText: "收藏",
                                  ),
                                                  
                                  AnimatedSortSelector(
                                    currentType: browserSortType,
                                    selectedType: SortType.score,
                                    onTap: (){
        
                                      browserSortTypeNotifier.value = SortType.score;
                                      if(currentSearchConfig.isEmpty) return;
                                      loadNewData(currentSearchConfig);
                                      
                                    },
                                    labelIcon: Icons.numbers,
                                    labelText: "分数",
                                  )
                                                  
                                ],
                              ),
                          
                            ],
                          );
                        }
                      ),
                    ),
                    leading: const SizedBox.shrink(),
                  ),
                ),
          
                ValueListenableBuilder(
                  valueListenable: fliterShowNotifier,
                  builder: (_,fliterShow,child) {
                    return SliverToBoxAdapter(
                      child: AnimatedContainer(
                        height: fliterShow ? (kDebugMode ? 400 : 300) : 0,
                        duration: const Duration(milliseconds: 300),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: fliterShow ? const Searchfliter() : const SizedBox.shrink()
                          
                        ),
                      ),
                    );
                  }
                ),

                ValueListenableBuilder(
                  valueListenable: viewTypeNotifier,
                  builder: (_,viewType,child){

                    return ValueListenableBuilder(
                      valueListenable: loadCountNotifier,
                      builder: (_,loadCount,child) {
                        return SliverStack(
                          children: [
                        
                            SliverOffstage(
                              offstage: viewType != ViewType.listView || loadCount == 0,
                              sliver: SliverAnimatedList(
                                key: messageListStreamKey,
                                initialItemCount: messageList.isEmpty ? 1 : messageList.length,
                                
                                itemBuilder: (_, index, animation) {
                        
                                  debugPrint("index:$index");
                              
                                  if(messageList.isEmpty){
                                    return const Center(child: ScalableText("没有搜索到内容.."));
                                  }
                                      
                                  if(index>messageList.length - 1){
                                    debugPrint("prevent strangeOverFlow rebuild");
                                    return const SizedBox.shrink();
                                  }
                        
                                  return FadeTransition(
                                    opacity: animation,
                                    child: BangumiListTile(
										bangumiDetails: messageList[index],
                                      	imageSize: const Size(100,150),
										onTap: () {
											Navigator.pushNamed(
											context,
											Routes.subjectDetail,
											arguments: {"subjectID":messageList[index].id}
											);
										},
                              
                              
                                    )
                              
                                  
                                  );
                                  
                                  },
                              ),
                            ),

                            SliverOffstage(
                              offstage: viewType != ViewType.gridView || loadCount == 0,


                              sliver: SliverPadding(
                                padding: const EdgeInsets.all(16),
                                sliver: SliverAnimatedGrid(
                                  key: messageGridStreamKey,
                                  initialItemCount: messageList.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 32,
                                    crossAxisSpacing: 16,
                                  ),
                                  itemBuilder: (context, currentBangumiIndex, animation) {
                                
                                    if(currentBangumiIndex > messageList.length - 1){
                                      debugPrint("prevent strangeOverFlow rebuild");
                                      return const SizedBox.shrink();
                                    }
                                
                                    debugPrint("gridIndex:$currentBangumiIndex");
                                
                                    return NotificationListener<ScrollUpdateNotification>(
                                      onNotification: (notification) => true,
                                        child:  FadeTransition(
                                        opacity: animation,
                                          child:  BangumiGridTile(
                                            bangumiTitle: messageList[currentBangumiIndex].name,
                                            imageUrl: messageList[currentBangumiIndex].coverUrl,
                                            onTap: () {
                                              if(messageList[currentBangumiIndex].name!=null){
                                    
                                                Navigator.pushNamed(
                                                  context,
                                                  Routes.subjectDetail,
                                                  arguments: {"subjectID":messageList[currentBangumiIndex].id},
                                                );
                                              }
                                            },
                                          )
                                      )
                                    );
                                  },
                                ),
                              )

                              //  child: Padding(
                              //    padding: const EdgeInsets.all(16),
                              //    child: NotificationListener<ScrollUpdateNotification>(
                              //      onNotification: (notification) => true,
                              //      child: BanguTileGridView(
                              //        keyDeliver: messageGridStreamKey,
                              //        bangumiLists: messageList,
                              //      ),
                              //    ),
                              //  ),
                              //),

                              //sliver: SliverToBoxAdapter(
                              //  child: Padding(
                              //    padding: const EdgeInsets.all(16),
                              //    child: NotificationListener<ScrollUpdateNotification>(
                              //      onNotification: (notification) => true,
                              //      child: BanguTileGridView(
                              //        keyDeliver: messageGridStreamKey,
                              //        bangumiLists: messageList,
                              //      ),
                              //    ),
                              //  ),
                              //),


                            )

                         
                        
                          ],
                        );
                      }
                    );

                  }
                ),
      
          
                const SliverPadding(padding: EdgeInsets.only(bottom: 60)),

                SliverToBoxAdapter(
                //SliverFillRemaining(
                  child: ValueListenableBuilder(
                    valueListenable: loadCountNotifier,
                    builder: (_,loadCount,child) {
          
                      String showMessage = loadCount == 0 ? "透过筛选以获取番剧信息" : "已经到底了 上滑载入更多信息";
          
                      return Stack(
                        children: [

                          Offstage(
                            offstage: loadCount==0,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: AnimatedWaveFooter(
                                waveHeight: 60,
                                painter: Paint(),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 80,
                            child: Center(
                              child: ScalableText(showMessage),
                            ),
                          ),

                        ],
                      );
                    }
                  ),
                ),
          
          
                
              ],
            ),
          ),
          floatingActionButton: 
            ValueListenableBuilder(
              valueListenable: appBarTitleNotifier,
              builder: (_,appBarTitleNotifierContent,child) {
                return AnimatedOpacity(
                  opacity: appBarTitleNotifierContent.isEmpty ? 0 : 1,
                  duration: const Duration(milliseconds: 150),
                  child: child!
                );
              },
              child: SizedBox(
                  height: 70,
                  child: ElevatedButton(
                    onPressed: (){
                      messageList.length > 30 ?
                      sortScrollController.jumpTo(0) :
                      sortScrollController.animateTo(0,duration: const Duration(milliseconds: 300), curve: Curves.linear);
                    },
                    child: const Icon(Icons.arrow_upward)
                  ),
                )
            ),
        );
      }
    );
  }


  void loadData(
    {
      String? keyword,
      SortType? sortType,
      int? searchOffset,
      List<String>? tagsList,

      List<String>? airDateRange,
      List<String>? rankRange,
      List<String>? ratingRange,
    }

  ){

    int recordLength = messageList.length;


    sortSearchHandler(
      keyword: keyword,
      airDateRange: airDateRange,
      rankRange: rankRange,
      ratingRange: ratingRange,
      tagsList: tagsList,

      sortType: sortType?.name,
      searchOffset:searchOffset,

      
    ).then((searchResponse){

      if(searchResponse.data!=null){
        
        messageList.addAll(loadSearchData(searchResponse.data));

        //debugPrint("bangumiSort: ${messageList}");

        messageListStreamKey.currentState?.insertAllItems(
          recordLength == 0 ? 0 : recordLength - 1 ,
          messageList.length - recordLength,
          duration: const Duration(milliseconds: 500)
        );

        messageGridStreamKey.currentState?.insertAllItems(
          recordLength == 0 ? 0 : recordLength - 1 ,
          messageList.length - recordLength,
          duration: const Duration(milliseconds: 500)
        );


        loadCountNotifier.value+=1;

        WidgetsBinding.instance.addPostFrameCallback((timestamp){
          if(searchResponse.data.isEmpty) return;

          sortScrollController.animateTo(
            sortScrollController.position.pixels + (166*3), // BangumiListTile的iconSize是150 加上padding就是 166
            //sortScrollController.position.maxScrollExtent, //直接滚到底部
            duration: const Duration(milliseconds: 150),  
            //滚动实际效果和动画时间相关。越长实际滚的offset越低 这实在太离谱了
            curve: Curves.linear
          );
        });
        
      }

      
    });
  }

  void loadNewData(Map configData){

    loadCountNotifier.value=0;
    messageList.clear();

    messageListStreamKey.currentState?.removeAllItems(
      (_,animation){
        return FadeTransition(
          opacity: animation.drive(Tween<double>(begin: 1, end:0)),
          child: const SizedBox.shrink() ,
        );
      },
      duration: const Duration(milliseconds: 500)
    );

    currentSearchConfig.addAll( //recover
      {
        "tag":configData["tag"],
        "rank":configData["rank"],
        "rating":configData["rating"],
        "air_date":configData["air_date"],
      }
    );

    
    loadData(
      sortType: browserSortTypeNotifier.value,
      searchOffset: loadCountNotifier.value*10,
      airDateRange:configData["air_date"],
      rankRange:configData["rank"],
      ratingRange:configData["rating"],
      tagsList:configData["tag"],
    );

  }

  void loadMoreData(Map configData){

    loadCountNotifier.value+=1;

    loadData(
      sortType: browserSortTypeNotifier.value,
      searchOffset: loadCountNotifier.value*10,
      airDateRange:configData["air_date"],
      rankRange:configData["rank"],
      ratingRange:configData["rating"],
      tagsList:configData["tag"],
    );

  }

}


