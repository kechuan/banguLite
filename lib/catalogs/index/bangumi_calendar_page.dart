import 'dart:async';
import 'dart:math';

import 'package:bangu_lite/catalogs/subject/bangumi_detail_page.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/extension.dart';
import 'package:bangu_lite/internal/utils/get.dart';
import 'package:bangu_lite/internal/utils/judge.dart';
import 'package:bangu_lite/models/informations/subjects/bangumi_details.dart';
import 'package:bangu_lite/models/providers/calendar_model.dart';
import 'package:bangu_lite/widgets/components/bangumi_tab_content_select.dart';
import 'package:bangu_lite/widgets/components/transition_container.dart';
import 'package:bangu_lite/widgets/dialogs/warp_season_dialog.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
import 'package:bangu_lite/widgets/fragments/refresh_indicator.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:bangu_lite/widgets/views/bangumi_grid_tile_view.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class BangumiCalendarPage extends StatefulWidget {
  const BangumiCalendarPage({super.key});

  @override
  State<BangumiCalendarPage> createState() => _BangumiCalendarPageState();
}

class _BangumiCalendarPageState extends LifecycleState<BangumiCalendarPage> with AutomaticKeepAliveClientMixin{

  Future? calendarLoadFuture;
  Timer? carouselTimer;

  final InfiniteScrollController infiniteScrollController = InfiniteScrollController();

  final ValueNotifier<bool> transitionalSeasonNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> weekdaySelectOffstageNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> weekdaySelectOffstageAnimatedNotifier = ValueNotifier<bool>(false);

  Timer generateScrollList() {
    return Timer.periodic(const Duration(milliseconds: 3600), (timer) {

      if (!infiniteScrollController.hasClients) {
        carouselTimer?.cancel();
        return;
      }

      infiniteScrollController.nextItem(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );

    });
  }

  void carouselSpinTimer() {
    if (carouselTimer != null) { carouselTimer?.cancel();
    }
    carouselTimer = generateScrollList();
  }

  @override
  void initState() {
    carouselSpinTimer();
    calendarLoadFuture = context.read<CalendarModel>().loadCalendar();
    super.initState();
  }

  @override
  void onPause() {
    debugPrint("caleandar pause");
    if (carouselTimer != null) {
      carouselTimer?.cancel();
    }
    FocusScope.of(context).unfocus();
    super.onPause();
  }

  @override
  void onResume() {
    debugPrint("caleandar resume");
    carouselSpinTimer();
    super.onResume();

  }

  @override
  void dispose() {
    carouselTimer?.cancel();
    infiniteScrollController.dispose();

    transitionalSeasonNotifier.dispose();
    weekdaySelectOffstageNotifier.dispose();
    weekdaySelectOffstageAnimatedNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final calendarModel = context.read<CalendarModel>();

    return EasyRefresh.builder(
      header: const TextHeader(),
      onRefresh: () async {

        if (
        calendarModel.selectedYear == DateTime.now().year &&
          calendarModel.selectedSeason.seasonText == getSeasonRange(DateTime.now().month).seasonText
        ) {
          calendarLoadFuture = calendarModel.reloadCalendar();
          await calendarLoadFuture;
        }

      },

      childBuilder: (_, physic) {

        if (calendarLoadFuture == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: Selector<CalendarModel, DateTime>(
            selector: (_, model) => model.dataTime,
            builder: (_, updateTime, child) {
              return FutureBuilder(
                future: calendarLoadFuture,
                builder: (_, snapshot) {

                  //debugPrint("index rebuild: screenWidth:${MediaQuery.sizeOf(context).width}");
                  final hotBangumis = calendarModel.hotBangumis;

                  return CustomScrollView(
                    physics: const ClampingScrollPhysics(),
                    slivers: [

                      MultiSliver(
                        pushPinnedChildren: true,
                        children: [

                          SliverPinnedHeader(
                            child: Container(
                              padding: const EdgeInsets.only(left: 24),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: Divider.createBorderSide(context)
                                ),

                                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),

                              ),

                              height: 60,
                              child: Row(
                                spacing: 12,
                                children: [

                                  const ScalableText("本季热番", style: TextStyle(fontSize: 24)),
                                  //const Spacer(),
                                  UnVisibleResponse(

                                    containedInkWell: true,
                                    onTap: () => showSeasonDialog(context, calendarLoadFuture: calendarLoadFuture),

                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: judgeDarknessMode(context) == true ? Colors.grey.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surface.darken()
                                      ),
                                      child: Padding(
                                        padding: Padding6,
                                        child: Row(
                                          children: [
                                            //重建代价低
                                            Consumer<CalendarModel>(
                                              builder: (_, model, child) {
                                                return ScalableText("${model.selectedYear} ${model.selectedSeason.seasonText}", style: const TextStyle(fontSize: 24));
                                              }
                                            ),
                                            const Icon(Icons.arrow_drop_down)
                                          ],
                                        ),
                                      ),
                                    ),
                                  )

                                ],
                              )
                            )
                          ),

                          SliverPadding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            sliver: SliverFixedExtentList( 
                              itemExtent: MediaQuery.sizeOf(context).height / 4, //原本滚动组件主轴约束无限 锁定InfiniteCarousel的交叉轴高度
                              delegate: SliverChildListDelegate(
                                [

                                  Stack(
                                    children: [

                                      Positioned.fill(
                                        child: InfiniteCarousel.builder(
                                          center: false,
                                          loop: true,
                                          itemCount: hotBangumis.isEmpty ? 1 : hotBangumis.length,
                                          itemExtent: measureCarouselItemExtent(),
                                          velocityFactor: 0.8, //滚动速度
                                          controller: infiniteScrollController,
                                          itemBuilder: (_, currentIndex, itemCount) {

                                            final List<BangumiDetails> weeklyBangumisRecommend = hotBangumis;

                                            if (weeklyBangumisRecommend.isEmpty) {
                                              return const Center(
                                                child: ScalableText("暂无热门番剧"),
                                              );
                                            }

                                            return Container(
                                              padding: PaddingH12,
                                              child: TransitionContainer(
                                                builder: (_, openAciton) {
                                                  return UnVisibleResponse(                
                                                    containedInkWell: true,
                                                    onTap: () {
                                                      debugPrint("$currentIndex => ${weeklyBangumisRecommend[currentIndex].name}");            
                                                      openAciton();        
                                                    },
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(24),
                                                        border: Border.all(width: 1)
                                                      ),
                                                      child: Stack(

                                                        children: [

                                                          Positioned.fill(
                                                            child: CachedImageLoader(imageUrl: weeklyBangumisRecommend[currentIndex].coverUrl!)
                                                          ),

                                                          Positioned.fill(

                                                            child: LayoutBuilder(
                                                              builder: (_, constriant) {
                                                                return DecoratedBox(
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(16),
                                                                    gradient: const LinearGradient(
                                                                      begin: Alignment.bottomCenter,
                                                                      end: Alignment(0, 0.2),

                                                                      colors: [Color.fromARGB(255, 35, 35, 35), Colors.transparent]
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
                                                                            weeklyBangumisRecommend[currentIndex].name ?? "loading",
                                                                            maxLines: 2,
                                                                            style: const TextStyle(color: Colors.white),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                          trailing: Container(
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(12),
                                                                              color: AppThemeColor.macha.color
                                                                            ),
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                                              child: ScalableText(
                                                                                "${weeklyBangumisRecommend[currentIndex].ratingList["score"]?.toDouble() ?? "-.-"}",
                                                                                style: const TextStyle(fontSize: 14, color: Colors.black)
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
                                                  );  
                                                },
                                                next: BangumiDetailPage(
                                                  subjectID: weeklyBangumisRecommend[currentIndex].id ?? 0,
                                                  injectBangumiInfoDetail: weeklyBangumisRecommend[currentIndex],
                                                ),
                                              ),
                                            );

                                          }
                                        ),
                                      ),

                                      ValueListenableBuilder(
                                        valueListenable: transitionalSeasonNotifier,
                                        builder: (_, noticeStatus, __) {
                                          return Offstage(
                                            offstage: !judgeTransitionalSeason() || noticeStatus,
                                            child: Transform.translate( 
                                              //妥协产物 毕竟再写一次SliverStack是需要重编排非常多的事情
                                              offset: const Offset(0, -12),
                                              child: Container(
                                                height: 50,
                                                color: getCurrentThemeColor(context).withValues(alpha: 0.6),

                                                child: Row(

                                                  children: [
                                                    const Spacer(),
                                                    const ScalableText("番剧信息正值刚换季,可能会带来频繁的榜单变化"),
                                                    const Spacer(),
                                                    IconButton(
                                                      onPressed: () => transitionalSeasonNotifier.value = true,
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

                      Selector<CalendarModel, int>(
                        selector: (_, model) => model.selectedWeekDay,
                        shouldRebuild: (previous, next) {
                          debugPrint("receive rebuild day:$previous => $next");
                          return previous != next;
                        },
                        builder: (_, weekday, selectChild) {

                          final selectedDay = calendarModel.selectedWeekDay;

                          return MultiSliver(
                            pushPinnedChildren: true,
                            children: [

                              SliverPinnedHeader(

                                child: ColoredBox(
                                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
                                  child: ValueListenableBuilder(
                                    valueListenable: weekdaySelectOffstageNotifier,
                                    builder: (_, weekDayOffstage, child) {
                                      return SizedBox(
                                        height: !weekDayOffstage ? 133 : 73,
                                        child: child!
                                      );
                                    },
                                    child: Column(
                                      spacing: 6,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        Padding(
                                          padding: PaddingH12,
                                          child: SizedBox(
                                            height: 59, // Border:bottom = 1
                                            child: Row(
                                              spacing: 6,

                                              children: [

                                                ScalableText("星期${WeekDay.values[selectedDay - 1].dayText}", style: const TextStyle(fontSize: 18)),

                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(12),
                                                    color: judgeDarknessMode(context) == true ? Colors.grey.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surface.darken()
                                                  ),
                                                  child: InkResponse(
                                                    focusColor: Theme.of(context).colorScheme.surface,
                                                    hoverColor: Colors.transparent,     // 悬浮时圆点
                                                    highlightColor: Theme.of(context).colorScheme.surface, // 点击时的圆点
                                                    splashColor: Theme.of(context).colorScheme.surface,    // 扩散水圈

                                                    //containedInkWell: true,
                                                    child: const Icon(Icons.arrow_drop_down),

                                                    onTap: () {
                                                      if (weekdaySelectOffstageNotifier.value) {
                                                        weekdaySelectOffstageNotifier.value = false;
                                                      }

                                                      if (weekdaySelectOffstageAnimatedNotifier.value) {
                                                        weekdaySelectOffstageAnimatedNotifier.value = false;
                                                      }

                                                      else {
                                                        weekdaySelectOffstageAnimatedNotifier.value = true;
                                                      }
                                                    },
                                                  ),
                                                )

                                              ],
                                            ),
                                          ),
                                        ),

                                        BangumiTabContentSelect(
                                          selectOffstageNotifier: weekdaySelectOffstageNotifier,
                                          selectOffstageAnimatedNotifier: weekdaySelectOffstageAnimatedNotifier,
                                          selectedList: WeekDay.values,
                                          initialIndex: calendarModel.selectedWeekDay - 1,
                                          onTap: (selectedIndex) {
                                            calendarModel.updateSelectedWeekDay(selectedIndex + 1);
                                          },

                                        ),

                                        const Divider(height: 1)

                                      ],
                                    ),
                                  ),
                                ),

                              ),

                              Provider<List<BangumiDetails>>.value(
                                value: calendarModel.getWeekdayBangumis(selectedDay),
                                child: const SliverToBoxAdapter(
                                  child: BangumiGridTileView(),
                                ),
                              )

                            ]

                          );
                        }

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

  double measureCarouselItemExtent() {

    final hotBangumis = context.read<CalendarModel>().hotBangumis;

    if (hotBangumis.isEmpty) return MediaQuery.sizeOf(context).width;
    if (MediaQuery.orientationOf(context) == Orientation.portrait) return ((MediaQuery.sizeOf(context).width) - (12 / 2)) / 2;
    //if(MediaQuery.orientationOf(context) == Orientation.portrait) return 160;

    //主轴模糊约束
    return max(200, MediaQuery.sizeOf(context).width / 4);

  }

  @override
  bool get wantKeepAlive => true;
}




