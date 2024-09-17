import 'dart:async';
import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bangumi/flutter_bangumi_routes.dart';
import 'package:flutter_bangumi/internal/convert.dart';
import 'package:flutter_bangumi/models/bangumi_details.dart';
import 'package:flutter_bangumi/models/providers/bangumi_model.dart';
import 'package:flutter_bangumi/models/providers/index_model.dart';
import 'package:flutter_bangumi/widgets/components/weekday_select_overlay.dart';
import 'package:flutter_bangumi/widgets/fragments/cached_image_loader.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class BangumiCalendarPage extends StatefulWidget {
  const BangumiCalendarPage({super.key});

  @override
  State<BangumiCalendarPage> createState() => _BangumiCalendarPageState();
}

class _BangumiCalendarPageState extends State<BangumiCalendarPage> {

  Future? calendarLoadFuture;
  Timer? carouselTimer;

  final InfiniteScrollController _infiniteScrollController = InfiniteScrollController();
  final LayerLink buttonLayerLink = LayerLink(); //composition

  Timer generateScrollList(){
    return Timer.periodic(const Duration(milliseconds: 3600), (timer) {
      
      if(!_infiniteScrollController.hasClients) {
        carouselTimer?.cancel();
        return;
      }

      _infiniteScrollController.nextItem(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );


    });
  }

  void carouselSpinTimer(){
    if(carouselTimer!=null){
      carouselTimer?.cancel();
    }
    carouselTimer = generateScrollList();
  }

  @override
  void initState() {
    carouselSpinTimer();
    calendarLoadFuture = context.read<IndexModel>().loadCalendar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.builder(
      header: const MaterialHeader(),
      onRefresh: ()=> calendarLoadFuture = context.read<IndexModel>().loadCalendar(),
      childBuilder: (_,physic){

        if(calendarLoadFuture==null){
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
  
        return Scaffold(
          body: Selector<IndexModel, DateTime>(
            selector: (_, indexModel) => indexModel.dataTime,
            shouldRebuild: (previous, next) => previous!=next,
            builder: (_, updateTime, child) {
              return FutureBuilder(
                future: calendarLoadFuture,
                builder: (_, snapshot) {
  
                  debugPrint("index rebuild: screenWidth:${MediaQuery.sizeOf(context).width}");
                  //问题: 更改screenWidth会重新请求 calendarBangumis
                  final calendarBangumis = context.read<IndexModel>().calendarBangumis;
  
                  return CustomScrollView(
                    physics: physic, //需要传递physic进去触发easyRefresh的回调
                    slivers: [
                      
                      //SliverSafeArea(
                      //  sliver: SliverAppBar(
                          
                      //    floating: true,
                      //    leadingWidth: 12,
                      //    title: const Text("MainPage"),
                      //    //flexibleSpace: SizedBox.expand(
                      //    //  child: DecoratedBox(
                      //    //    decoration: BoxDecoration(
                      //    //      border: Border(
                      //    //        bottom: Divider.createBorderSide(context) 
                      //    //      )
                      //    //    )
                      //    //  ),
                      //    //),
                      //    leading: const SizedBox.shrink(),
                      //    actions: [
                      //      Padding(
                      //        padding: const EdgeInsets.symmetric(horizontal: 12),
                      //        child: IconButton(
                      //          onPressed: ()=> showSearch(
                      //            context: context,
                      //            delegate: CustomSearchDelegate()
                      //          ),
                      //          icon: const Icon(Icons.search)),
                      //      )
                      //    ],
                          
                          
                      //  ),
                      //),
  
                      MultiSliver(
                        pushPinnedChildren: true,
                        children: [
                            
                          SliverPinnedHeader(
                            child: Container(
                              padding: const EdgeInsets.only(left: 24),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: Divider.createBorderSide(context) //
                                ),

                                color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
                                
                              ),
                              
                              height: 60,
                              child: const Align(
                                alignment: Alignment.centerLeft,
                                child: Text("本周热番",style: TextStyle(fontSize: 24)
                              ))
                            )
                          ),
                          
  
  
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            sliver: SliverFixedExtentList( 
                              itemExtent:MediaQuery.sizeOf(context).height/4, //原本滚动组件主轴约束无限 锁定InfiniteCarousel的交叉轴高度
                              delegate: SliverChildListDelegate(
                                [
                            
                                  InfiniteCarousel.builder(
                                    center: false,
                                    loop: true,
                                    itemCount: calendarBangumis["最热门"]?.length ?? 8,
                                    itemExtent: max(200,MediaQuery.sizeOf(context).width/4), //主轴约束
                                    velocityFactor:0.8, //滚动速度
                                    controller: _infiniteScrollController,
                                    itemBuilder: (_, currentIndex, itemCount){
                                      
                                      List<BangumiDetails>? weeklyBangumisRecommend = calendarBangumis["最热门"];
                            
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: InkResponse( 
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            containedInkWell: true,
                                            borderRadius: BorderRadius.circular(24),
                                            onTap: (){
                            
                                              if(weeklyBangumisRecommend!=null){
                                                debugPrint("$currentIndex => ${currentIndex % weeklyBangumisRecommend.length} => ${weeklyBangumisRecommend[currentIndex % weeklyBangumisRecommend.length].name} ");

                                                context.read<BangumiModel>().routesIDList.add(weeklyBangumisRecommend[currentIndex % weeklyBangumisRecommend.length].id!);
                                                  
                                                Navigator.pushNamed(
                                                  context,
                                                  Routes.subjectDetail,
                                                  arguments: {"bangumiID":weeklyBangumisRecommend[currentIndex % weeklyBangumisRecommend.length].id},
                                                );

                                                
                                              }
                            
                                            },
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(24),
                                                border: Border.all(width: 1)
                                              ),
                                              child: Stack(
                            
                                                children: [
                                                  
                                                  Positioned.fill(
                                                    child: weeklyBangumisRecommend!=null ?
                                                    CachedImageLoader(imageUrl: weeklyBangumisRecommend[currentIndex].coverUri!) :
                                                    const Center(child: Text("Loading"))
                                                  ),
                                                  
                                                  Positioned.fill(
                                                    
                                                      child: LayoutBuilder(
                                                        builder: (_,constriant) {
                                                          return DecoratedBox(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(16),
                                                              gradient: const LinearGradient(
                                                                begin:Alignment.bottomCenter,
                                                                end:Alignment(0, 0.2),
                                                                
                                                                colors:[Color.fromARGB(255, 35, 35, 35),Colors.transparent]
                                                              ),
                                                            ),
                                                            child: Row(
                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                                                                    
                                                                SizedBox(
                                                                  width: constriant.maxWidth,
                                                                  child: ListTile(
                                                                    title: Text(
                                                                      weeklyBangumisRecommend?[currentIndex].name ?? "loading",
                                                                      maxLines: 2,
                                                                      style: const TextStyle(fontSize: 16,color: Colors.white),
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                    trailing: Container(
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(12),
                                                                        color: const Color.fromARGB(255, 183, 228, 206)
                                                                      ),
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 2),
                                                                        child: Text("${weeklyBangumisRecommend?[currentIndex].ratingList["score"]?.toDouble() ?? "-.-"}",style: const TextStyle(fontSize: 14,color: Colors.white),),
                                                                      )
                                                                    ),
                                                                  ),
                                                                )
                                                                                                                    
                                                              ],
                                                            ),
                                                          );
                                                        }
                                                      ),
                                                    
                                                  ),
                                                  
                                                ]
                                                
                                              ),
                                            )
                                          ),
                                        );
                                    }
                                  ),
                                  
                                ]
                                
                              )
                            ),
                          ),
  
                        ]
                      ),
  
                      Selector<IndexModel, int>(
                        selector: (_, indexModel) => indexModel.selectedWeekDay,
                        shouldRebuild: (previous, next){
                          debugPrint("receive rebuild ${previous}/${next}");
                          return previous!=next;
                        },
                        builder: (_, weekday, child) {
                          final selectedDay = context.read<IndexModel>().selectedWeekDay;
  
                          return MultiSliver(
                            pushPinnedChildren: true,
                            children: [
                          
                              SliverPinnedHeader(
                                child: Container(
                                  height: 60,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: Divider.createBorderSide(context)
                                    ),
                                    color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
                                  ),
                                  child: Row(
                                    children: [
                                  
                                      Text("星期${WeekDay.values[selectedDay%7].dayText}",style: const TextStyle(fontSize: 18)),
                                  
                                      child!
                                  
                                    ],
                                  ),
                                ),
                              ),
                          
                              SliverToBoxAdapter(
                                child: Builder(
                                  builder: (_) {
                          
                                    if(calendarBangumis.isEmpty) return const SizedBox.shrink();
  
                                    List<BangumiDetails> currentDayBangumi = calendarBangumis.values.elementAt(max(0,selectedDay - 1));
                          
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(18),
                                        child: Wrap(
                                          spacing: 24,
                                          runSpacing: 16,
                                          children: [
                                        
                                            ...List.generate(
                                              calendarBangumis.values.elementAt(max(0,selectedDay - 1)).length,
                                              (currentBangumi){
  
                                                return Column(
                                                  children: [
                                                                                                  
                                                    Container(
                                                      constraints: BoxConstraints(
                                                        //minWidth: 120,
                                                        //默认期望 一个列表里显示4个 空间不足时显示 2/3个
                                                        maxWidth: MediaQuery.sizeOf(context).width > 600 ? 
                                                        (MediaQuery.sizeOf(context).width/5 < 120 ? 120 : MediaQuery.sizeOf(context).width/5) :
                                                        (MediaQuery.sizeOf(context).width/3) < 100 ? 120 : MediaQuery.sizeOf(context).width/2 - 48, //48 = 2*Wrap(spacing)
                                                                                
                                                        minHeight: 80,
                                                        maxHeight: MediaQuery.sizeOf(context).height/4 < 80 ? 80 : MediaQuery.sizeOf(context).height/4,
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                                                        
                                                          Positioned.fill(
                                                            child: CachedImageLoader(imageUrl: currentDayBangumi[currentBangumi].coverUri!),
                                                          ),
                                                                                        
                                                          Positioned.fill(
                                                            child: DecoratedBox(
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(16),
                                                                gradient: const LinearGradient(
                                                                  begin:Alignment.bottomCenter,
                                                                  end:Alignment(0, 0.2),
                                                                  
                                                                  colors:[Color.fromARGB(255, 35, 35, 35),Colors.transparent]
                                                                ),
                                                              ),
                                                            )
                                                          ),
                                                                                                    
                                                          
                                                          Positioned.fill(
                                                            child: InkResponse(
                                                              containedInkWell: true,
                                                              hoverColor: Colors.transparent,
                                                              highlightColor: Colors.transparent,
                                                              onTap: () {
                                                                if(currentDayBangumi[currentBangumi].name!=null){

                                                                  context.read<BangumiModel>().routesIDList.add(currentDayBangumi[currentBangumi].id!);

                                                                  Navigator.pushNamed(
                                                                    context,
                                                                    Routes.subjectDetail,
                                                                    arguments: {"bangumiID":currentDayBangumi[currentBangumi].id},
                                                                  );
                                                                }
                                                              },
                                                            )
                                                          )
                                                      
                                                        ],
                                                      ),
                                                    ),
                                                                                                  
                                                    Container(
                                                      constraints: BoxConstraints(
                                                        //minWidth: 120,
                                                        
                                                        //默认期望 一个列表里显示4个 空间不足时显示 2/3个
                                                        maxWidth: MediaQuery.sizeOf(context).width > 600 ? 
                                                        (MediaQuery.sizeOf(context).width/5 < 120 ? 120 : MediaQuery.sizeOf(context).width/5) :
                                                        (MediaQuery.sizeOf(context).width/3) < 100 ? 120 : MediaQuery.sizeOf(context).width/2 - 48, //48 = 2*Wrap(spacing)
                                                                                
                                                        //minHeight: 80,
                                                        //maxHeight: MediaQuery.sizeOf(context).height/4 < 80 ? 80 : MediaQuery.sizeOf(context).height/4,
                                                        maxHeight: 80,
                                                      ),
                                                      decoration: const BoxDecoration(
                                                          //border: Border.all(width: 2)
                                                          //border: Border(
                                                          //  bottom: BorderSide(width: 1,color: Colors.lightGreen),
                                                          //  left: BorderSide(width: 1,color: Colors.lightGreen),
                                                          //  right: BorderSide(width: 1,color: Colors.lightGreen),
                                                          //)
                                                        ),
                                                      
                                                      child: ListTile(
                                                        title: Center(
                                                          child: Text(
                                                            currentDayBangumi[currentBangumi].name ?? "loading",
                                                            maxLines: 2,
                                                            style: const TextStyle(fontSize: 16,color: Colors.black),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        )
                                                      ),
                                                    )
                                                                                                  
                                                                                                  
                                                  ],
                                                );
  
                                              }
                                            ) 
                                            
                                            
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                ),
                              ),
  
                            ]
                              
                          );
                        },
                        child: CompositedTransformTarget(
                          link: buttonLayerLink,
                          child: InkResponse(
                            borderRadius: BorderRadius.circular(24),
                            containedInkWell: true,
                            hoverColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: (){
                              debugPrint("show seasons Select");
                    
                              WeekDaySelectOverlay(
                                context: context,
                                buttonLayerLink:buttonLayerLink,
                              );
                            },
                            child: const Icon(Icons.arrow_drop_down,size: 32),
                          ),
                        ),
                        
                      ),

                      
                    ],
                  );
  
                }
              );
          
            },
            
          ),
        );
  
      }
      
    );
  }
}



