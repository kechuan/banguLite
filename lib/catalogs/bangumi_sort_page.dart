

import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/widgets/fragments/animated_wave_footer.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:bangu_lite/flutter_bangumi_routes.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/search_handler.dart';
import 'package:bangu_lite/models/bangumi_details.dart';
import 'package:bangu_lite/widgets/components/search_fliter.dart';
import 'package:bangu_lite/widgets/fragments/animated_sort_selector.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_tile.dart';


class BangumiSortPage extends StatefulWidget {
  const BangumiSortPage({super.key});

  @override
  State<BangumiSortPage> createState() => _BangumiSortPageState();
}

class _BangumiSortPageState extends State<BangumiSortPage> {

  final GlobalKey<SliverAnimatedListState> messageStreamKey = GlobalKey();
  final ScrollController sortScrollController = ScrollController();

  final ValueNotifier<String> appBarTitle = ValueNotifier<String>("");
  final ValueNotifier<SortType> browserSortTypeNotifier = ValueNotifier<SortType>(SortType.rank);

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
      header: const MaterialHeader(),
      footer: const MaterialFooter(),

      onLoad: () {
        if(messageList.isEmpty) return;
        loadMoreData(currentSearchConfig);
      },
      
      //onRefresh: (){},
      childBuilder: (_,physic){ // scroll Action by: CustomScrollView . just sync notice the physicAction.
        return Scaffold(
          body: NotificationListener<ScrollUpdateNotification>(
            onNotification: (notification) {
              
              final double scrollOffset = notification.metrics.pixels;
              //debugPrint("NotificationListener:$scrollOffset");
              scrollOffset >= 95 ? appBarTitle.value = "筛选动画" : appBarTitle.value = "";
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
                        builder: (_, __, child) {
                          return Row(
                          
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
          
                              const Text("筛选动画"),
                           
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
                                      onTap: ()=> fliterShowNotifier.value = !fliterShowNotifier.value,
                                      child: const Padding(
                                        padding:  EdgeInsets.only(right: 16),
                                        child:  Icon(Icons.filter_list,size: 35),
                                      ),
                                    ),
                                  ),
                                                  
                                  AnimatedSortSelector(
                                    currentType: browserSortTypeNotifier.value,
                                    selectedType: SortType.rank,
                                    onTap: (){

                                      browserSortTypeNotifier.value = SortType.rank;
                                      if(currentSearchConfig.isEmpty) return;
                                      loadNewData(currentSearchConfig);
          
                                    },
                                    labelIcon: Icons.format_list_numbered,
                                    labelText: "排名",
                                  ),
                                                  
                                  AnimatedSortSelector(
                                    currentType: browserSortTypeNotifier.value,
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
                                    currentType: browserSortTypeNotifier.value,
                                    selectedType: SortType.score,
                                    onTap: (){
        
                                      browserSortTypeNotifier.value = SortType.score;
                                      if(currentSearchConfig.isEmpty) return;
                                      loadNewData(currentSearchConfig);
                                      
                                    },
                                    labelIcon: Icons.grid_view,
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
                        height: fliterShow ? 
                        kDebugMode ? 400 : 300 : 
                        0,
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
                  valueListenable: loadCountNotifier,
                  builder: (_,loadCount,sliverList) {
                    //debugPrint("loadCount:$loadCount");

                    return SliverOffstage(
                      offstage: loadCount == 0,
                      sliver: sliverList!
                    );
                  },

                  child: SliverAnimatedList(
                    key: messageStreamKey,
                    initialItemCount: messageList.isEmpty ? 1 : messageList.length,
                    
                    itemBuilder: (_, index, animation) {

                      debugPrint("index:$index");
                  
                      if(messageList.isEmpty){
                        return const Center(child: Text("没有搜索到内容.."));
                      }
      
                      if(index>messageList.length - 1){
                        debugPrint("prevent strangeOverFlow rebuild");
                        return const SizedBox.shrink();
                      }
      
                      
                  
                      return FadeTransition(
                        opacity: animation,
                        child: BangumiTile(
                          bangumiTitle: messageList[index].name,
                          imageUrl: messageList[index].coverUri,
                          imageSize: const Size(100,150),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                                Routes.subjectDetail,
                              arguments: {"bangumiID":messageList[index].id}
                            );
                          },
                  
                  
                        )
                  
                      
                      );
                      
                      },
                  ),
                ),
          
                const SliverPadding(padding: EdgeInsets.only(bottom: 60)),

                
                SliverToBoxAdapter(
                  child: ValueListenableBuilder(
                    valueListenable: loadCountNotifier,
                    builder: (_,loadCount,child) {
          
                      String showMessage = loadCount == 0 ? "透过筛选以获取番剧信息" : "已经到底了 上滑载入更多信息";
          
                      return Stack(
                        children: [

                          Offstage(
                            offstage: loadCount==0,
                            child: AnimatedWaveFooter(
                              waveHeight: 60,
                              painter: Paint(),
                            ),
                          ),

                          Container(
                            color: const Color.fromARGB(255, 222, 238, 252),
                            height: 80,
                            child: Center(
                              child: Text(showMessage),
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
              valueListenable: appBarTitle,
              builder: (_,appBarTitleContent,child) {
                return AnimatedOpacity(
                  opacity: appBarTitleContent.isEmpty ? 0 : 1,
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
                      sortScrollController.animateTo(0,duration: const Duration(milliseconds: 300), curve: Curves.bounceIn);
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
    String keyword,

    {
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
      keyword,

      airDateRange: airDateRange,
      rankRange: rankRange,
      ratingRange: ratingRange,
      tagsList: tagsList,

      sortType: sortType?.name,
      searchOffset:searchOffset,

      
    ).then((bangumiDetails){

      messageList.addAll(bangumiDetails);

      //debugPrint("bangumiSort: ${messageList}");

      messageStreamKey.currentState?.insertAllItems(
        recordLength == 0 ? 0 : recordLength - 1 ,
        messageList.length - recordLength,
        duration: const Duration(milliseconds: 500)
      );

      loadCountNotifier.value+=1;

      WidgetsBinding.instance.addPostFrameCallback((timestamp){
        if(bangumiDetails.isEmpty) return;

        sortScrollController.animateTo(
          sortScrollController.position.pixels + (166*3), // BangumiTile的iconSize是150 加上padding就是 166
          //sortScrollController.position.maxScrollExtent, //直接滚到底部
          duration: const Duration(milliseconds: 150),  
          //滚动实际效果和动画时间相关。越长实际滚的offset越低 这实在太离谱了
          curve: Curves.linear
        );
      });
    });
  }

  void loadNewData(Map configData){

    loadCountNotifier.value=0;
    messageList.clear();

    messageStreamKey.currentState?.removeAllItems(
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
      '',
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
      '',
      sortType: browserSortTypeNotifier.value,
      searchOffset: loadCountNotifier.value*10,
      airDateRange:configData["air_date"],
      rankRange:configData["rank"],
      ratingRange:configData["rating"],
      tagsList:configData["tag"],
    );

  }

}


