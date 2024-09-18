

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:bangu_lite/flutter_bangumi_routes.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/search_handler.dart';
import 'package:bangu_lite/models/bangumi_details.dart';
import 'package:bangu_lite/widgets/components/searchFliter.dart';
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
  final ValueNotifier<int> browserSortTypeNotifier = ValueNotifier<int>(0);

  final ValueNotifier<bool> fliterShowNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<int> loadCountNotifier = ValueNotifier<int>(0);

  final List<BangumiDetails> messageList = [];
  final Map currentSearchConfig = {};

  @override
  void initState() {

    bus.on('sortSubmit',(arg){
      assert(arg is Map<String,dynamic>);

      debugPrint("recived sortSubmit: $arg");

      loadNewData(
        "",
        airDateRange:arg["air_date"],
        rankRange:arg["rank"],
        ratingRange:arg["rating"],
        tagsList:arg["tag"],
      );

      currentSearchConfig.addAll(
        {
          "tag":arg["tag"],
          "rank":arg["rank"],
          "rating":arg["rating"],
          "air_date":arg["air_date"],
        }
      );

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
          body: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom + 20
            ),
            child: NotificationListener<ScrollUpdateNotification>(
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
                                
                                //Builder(
                                //  builder: (_){
                                //    if(browserSortTypeNotifier.value != 1) return const Text("筛选动画");
            
                                //    return Container(
                                //      height: 60,
                                //      decoration: BoxDecoration(
                                //        borderRadius: BorderRadius.circular(12)
                                //      ),
                                //      child: Center(
                                //        child: InkResponse(
                                          
                                //          hoverColor: Colors.transparent,
                                          
                                //          highlightColor: Colors.transparent,
                                //          onTap: (){},
                                //          child: Wrap(
                                //            spacing: 12,
                                //            children: [

                                              
                                        
                                //              Text("${browserSortTypeNotifier.value}"),
                                        
                                //              const Icon(Icons.arrow_drop_down)
                                        
                                              
                                        
                                //            ],
                                //          )
                                //        ),
                                //      ),
                                //    );
                                    
                                //  }
                                //),
                            
                                //AnimatedSwitcher?
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
                                      currentIndexPage: browserSortTypeNotifier.value,
                                      selectedIndexPage: 1,
                                      onTap: () => browserSortTypeNotifier.value = 1,
                                      labelIcon: Icons.date_range,
                                      labelText: "日期",
                                    ),
                                                    
                                    AnimatedSortSelector(
                                      currentIndexPage: browserSortTypeNotifier.value,
                                      selectedIndexPage: 2,
                                      onTap: () => browserSortTypeNotifier.value = 2,
                                      labelIcon: Icons.format_list_numbered,
                                      labelText: "排行",
                                    ),
                                                    
                                    AnimatedSortSelector(
                                      currentIndexPage: browserSortTypeNotifier.value,
                                      selectedIndexPage: 3,
                                      onTap: () => browserSortTypeNotifier.value = 3,
                                      labelIcon: Icons.grid_view,
                                      labelText: "窗格",
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
                    builder: (_,loadCount,child) {
                      return SliverOffstage(
                        offstage: messageList.isEmpty,
                        sliver: SliverAnimatedList(
                          key: messageStreamKey,
                          initialItemCount: messageList.isEmpty ? 1 : messageList.length,
                          itemBuilder: (_, index, animation) {
                        
                            if(messageList.isEmpty){
                              return const Center(child: Text("没有搜索到内容.."));
                            }

                            if(index>messageList.length - 1){
                              debugPrint("prevent strangeOverFlow rebuild");
                              return const SizedBox.shrink();
                            }

                            debugPrint("index:$index");
                        
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
                      );
                    }
                  ),
            
                  SliverToBoxAdapter(
                    child: ValueListenableBuilder(
                      valueListenable: loadCountNotifier,
                      builder: (_,loadCount,child) {

                        String showMessage = loadCount == 0 ? "透过筛选以获取番剧信息" : "已经到底了";

                        return SizedBox(
                          height: 60,
                          child: Center(
                            child: Text(
                              showMessage
                            ),
                          ),
                        );
                      }
                    ),
                  ),
            
            
                  
                ],
              ),
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
                  height: 60,
                  child: ElevatedButton(
                    onPressed: (){
                      messageList.length > 30 ?
                      sortScrollController.jumpTo(0) :
                      sortScrollController.animateTo(0,duration: const Duration(milliseconds: 300), curve: Curves.bounceIn);
                    },
                    child: const Icon(Icons.arrow_upward,)
                  ),
                )
            ),
        );
      }
    );
  }

  void loadNewData(
    String keyword,

    //int? year,Season? selectedSeason, 
    // ['$year-${selectedSeason.month}-01','$year-${selectedSeason.month}-01']
    ////前端处理的 dateStart 只按季节分开
    {
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

      searchOffset:searchOffset,
      airDateRange: airDateRange,
      rankRange: rankRange,
      ratingRange: ratingRange,
      tagsList: tagsList
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

  void loadMoreData(Map configData){

    loadCountNotifier.value+=1;

    loadNewData(
      '',
      searchOffset: loadCountNotifier.value*10,
      airDateRange:configData["air_date"],
      rankRange:configData["rank"],
      ratingRange:configData["rating"],
      tagsList:configData["tag"],
    );

  }

}

