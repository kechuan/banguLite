import 'dart:async';
import 'dart:math';

import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/views/bangutile_grid_view.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/models/bangumi_details.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/components/weekday_select_overlay.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class BangumiCalendarPage extends StatefulWidget {
  const BangumiCalendarPage({super.key});

  @override
  State<BangumiCalendarPage> createState() => _BangumiCalendarPageState();
}

class _BangumiCalendarPageState extends LifecycleState<BangumiCalendarPage> {

  Future? calendarLoadFuture;
  Timer? carouselTimer;

  final InfiniteScrollController _infiniteScrollController = InfiniteScrollController();
  final LayerLink buttonLayerLink = LayerLink(); //composition
  final ValueNotifier<bool> transitionalSeasonNotifier = ValueNotifier<bool>(false);

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

  @override
  void onPause() {
    debugPrint("caleandar pause");
    if(carouselTimer!=null){
      carouselTimer?.cancel();
    }

    //WeekDaySelectOverlay.weekDaySelectOverlay?.closeWeekDaySelectFieldOverlay();
    super.onPause();
  }

  @override
  void onResume() {
    debugPrint("caleandar resume");
    carouselSpinTimer();
    super.onResume();
  }


  @override
  void didPushNext() {
    //debugPrint("push");
    WeekDaySelectOverlay.weekDaySelectOverlay?.closeWeekDaySelectFieldOverlay();
    super.didPushNext();
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
      onRefresh: ()=> calendarLoadFuture = context.read<IndexModel>().reloadCalendar(),
      
      childBuilder: (_,physic){

        final indexModel = context.read<IndexModel>();

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
                  final calendarBangumis = indexModel.calendarBangumis;
            
                  return CustomScrollView(
                    physics: physic, //需要传递physic进去触发easyRefresh的回调
                    slivers: [
          
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
          
                                color: Theme.of(context).colorScheme.surface.withValues(alpha:0.6),
                                
                              ),
                              
                              height: 60,
                              child: const Align(
                                alignment: Alignment.centerLeft,
                                child: ScalableText("本季热番",style: TextStyle(fontSize: 24)
                              ))
                            )
                          ),


            
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            sliver: SliverFixedExtentList( 
                              itemExtent:MediaQuery.sizeOf(context).height/4, //原本滚动组件主轴约束无限 锁定InfiniteCarousel的交叉轴高度
                              delegate: SliverChildListDelegate(
                                [

                                  Stack(
                                    children: [

                                      Positioned.fill(
                                        child: InfiniteCarousel.builder(
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
                                                        
                                                      Navigator.pushNamed(
                                                        context,
                                                        Routes.subjectDetail,
                                                        arguments: {"subjectID":weeklyBangumisRecommend[currentIndex % weeklyBangumisRecommend.length].id},
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
                                                          CachedImageLoader(imageUrl: weeklyBangumisRecommend[currentIndex].coverUrl!) :
                                                          const Center(child: ScalableText("Loading"))
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
                                                                          title: ScalableText(
                                                                            weeklyBangumisRecommend?[currentIndex].name ?? "loading",
                                                                            maxLines: 2,
                                                                            style: const TextStyle(color: Colors.white),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                          trailing: Container(
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(12),
                                                                              color: BangumiThemeColor.macha.color
                                                                            ),
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 2),
                                                                              child: ScalableText(
                                                                                "${weeklyBangumisRecommend?[currentIndex].ratingList["score"]?.toDouble() ?? "-.-"}",
                                                                                style: const TextStyle(fontSize: 14,color: Colors.black)
                                                                              ),
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
                                      ),
                                      
                                      ValueListenableBuilder(
                                        valueListenable: transitionalSeasonNotifier,
                                        builder: (_,noticeStatus,child) {
                                          return Offstage(
                                            offstage: !judgeTransitionalSeason() || noticeStatus,
                                              child: Transform.translate( 
                                                //妥协产物 毕竟再写一次SliverStack是需要重编排非常多的事情
                                                offset: const Offset(0, -12),
                                                child: Container(
                                                  height: 50,
                                                  color: judgeCurrentThemeColor(context).withValues(alpha: 0.6),
                                                  
                                                  child: Row(
                                                                                            
                                                    children: [
                                                      const Spacer(),
                                                      const ScalableText("番剧信息正值刚换季,可能会带来频繁的榜单变化"),
                                                      const Spacer(),
                                                      IconButton(
                                                        onPressed: ()=> transitionalSeasonNotifier.value = true,
                                                        icon: const Icon(Icons.close)
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            );
                                        }
                                      ),
                                        
                                    ],
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
                          debugPrint("receive rebuild day:$previous => $next");
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
                                    color: Theme.of(context).colorScheme.surface.withValues(alpha:0.6),
                                  ),
                                  child: Row(
                                    children: [
                                  
                                      //ScalableText("星期${WeekDay.values[selectedDay].dayText}",style: const TextStyle(fontSize: 18)),
                                      ScalableText("星期${WeekDay.values[selectedDay - 1].dayText}",style: const TextStyle(fontSize: 18)),
                                  
                                      child!
                                  
                                    ],
                                  ),
                                ),
                              ),
          
                              SliverToBoxAdapter(
                                child: BanguTileGridView(
                                  bangumiLists: calendarBangumis.isEmpty ? [] : calendarBangumis.values.elementAt(selectedDay-1),
                                ),
                              )
            
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



