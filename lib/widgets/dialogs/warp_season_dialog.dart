import 'dart:math';

import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/search_handler.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const int bangumiBaseYear = 2013;

class WarpSeasonDialog extends StatelessWidget {
  const WarpSeasonDialog({
    super.key,
    required this.selectedYear,
    required this.selectedSeasonType
  });

  final int selectedYear;
  final SeasonType selectedSeasonType;

  @override
  Widget build(BuildContext context) {

    final FixedExtentScrollController yearSelectorController = FixedExtentScrollController(initialItem: (selectedYear - bangumiBaseYear));  

    final ValueNotifier<int> yearNotifier = ValueNotifier<int>(selectedYear);
	  final ValueNotifier<SeasonType> seasonTypeNotifier = ValueNotifier<SeasonType>(selectedSeasonType);

    DateTime currentTime = DateTime.now();
    int currentYear = currentTime.year;
    int currentMonth = currentTime.month;

    return Dialog(
      child: SizedBox(
        height: 250,
        width: 550,
        child: Padding(
          padding: Padding16,
          child: EasyRefresh(
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScalableText("季度选择",style: TextStyle(fontSize: 24)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    	SizedBox(
                        height: 120,
                        width: max(100,MediaQuery.sizeOf(context).width < 500 ? 100 : 150),
                        child: ListWheelScrollView.useDelegate(
                        onSelectedItemChanged: (value) => yearNotifier.value = value+2013,
                        itemExtent: 50,
                        controller: yearSelectorController,
                        physics: const FixedExtentScrollPhysics(),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: (currentYear - bangumiBaseYear)+1,
                          builder: (_,index){
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                            ScalableText("${bangumiBaseYear+index}"),
                            const Divider(height: 1)
                            ],
                          );
                          }
                        ),
                      
                        ),
                      ),

                      MediaQuery.orientationOf(context) == Orientation.landscape ?
                      SelectSeasonLandscape(yearNotifier: yearNotifier, seasonTypeNotifier: seasonTypeNotifier, selectedYear: selectedYear, currentMonth: currentMonth) :
                      SelectSeasonPortrait(yearNotifier: yearNotifier, seasonTypeNotifier: seasonTypeNotifier, selectedYear: selectedYear, currentMonth: currentMonth)

                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: ()=>Navigator.of(context).pop(),
                      child: const ScalableText("取消")
                    ),
                    TextButton(
                      onPressed: (){

                        debugPrint("season:${seasonTypeNotifier.value}");

                        Navigator.of(context).pop(DateTime(yearNotifier.value,seasonTypeNotifier.value.month));
                      },
                      child: const ScalableText("确认")
                    )
                  ],
                )

              ],
            ),
          ),
        )
      )
    );
  }
}

class SelectSeasonLandscape extends StatelessWidget {
  const SelectSeasonLandscape({
	super.key,
	required this.yearNotifier,
	required this.seasonTypeNotifier,
	required this.selectedYear,
	required this.currentMonth,
});

	final ValueNotifier<int> yearNotifier;
	final ValueNotifier<SeasonType> seasonTypeNotifier;
	final int selectedYear;
	final int currentMonth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
		height: 50,
		width: 300,
		child: DefaultTabController(
		//tabbar 无法透过 rebuild 刷新 initialIndex.
		initialIndex: convertPassedSeason(selectedYear,seasonTypeNotifier.value.month),
		length: SeasonType.values.length,
		child: TabBar(
		  labelPadding: const EdgeInsets.all(0),
		  dividerColor: Colors.transparent,
		  indicatorSize: TabBarIndicatorSize.label,
		  onTap: (seasonTypeIndex) {
        if(seasonTypeIndex <= convertPassedSeason(yearNotifier.value,currentMonth)){
          seasonTypeNotifier.value = SeasonType.values[seasonTypeIndex];
        }

        //debugPrint("value :${seasonTypeNotifier.value}");
		  },
		  tabs: List.generate(
		    SeasonType.values.length,
		    (seasonTypeIndex){
		      return ValueListenableBuilder(
		      valueListenable: yearNotifier,
		      builder: (_,year,child) {
		
		        if(convertPassedSeason(year,currentMonth) < seasonTypeNotifier.value.index){
		          seasonTypeNotifier.value = SeasonType.values[convertPassedSeason(year,currentMonth)];
		        }
		        
		        return DecoratedBox(
		          decoration: BoxDecoration(
		            borderRadius: BorderRadius.horizontal(
		              left: seasonTypeIndex == 0 ? const Radius.circular(16) : Radius.zero,
		              right: seasonTypeIndex == SeasonType.values.length-1 ? const Radius.circular(16) : Radius.zero,
		            ),
		            
		          ),
		          child: AnimatedContainer(
		            duration: const Duration(milliseconds: 300),
		            color: convertPassedSeason(year, currentMonth) < seasonTypeIndex ? Colors.grey : BangumiThemeColor.values[seasonTypeIndex].color , //unable will be grey.,,
		            child: SizedBox(child: Center(child: Text(SeasonType.values[seasonTypeIndex].seasonText))),
		          )
		        );
		      }
		      );
		    }
		    )
		    
		  ),
		),
	);
  }
}

class SelectSeasonPortrait extends StatelessWidget {
  const SelectSeasonPortrait({
	super.key,
	required this.yearNotifier,
	required this.seasonTypeNotifier,
	required this.selectedYear,
	required this.currentMonth,
});

	final ValueNotifier<int> yearNotifier;
	final ValueNotifier<SeasonType> seasonTypeNotifier;
	final int selectedYear;
	final int currentMonth;

  @override
  Widget build(BuildContext context) {

    return SizedBox(
		height: 100,
		width: 150,
		child: ValueListenableBuilder(
			valueListenable: yearNotifier,
			builder: (_,year,child) {

				if(convertPassedSeason(year,currentMonth) < seasonTypeNotifier.value.index){
					seasonTypeNotifier.value = SeasonType.values[convertPassedSeason(year,currentMonth)];
				}
				
				return Wrap(
					
					children: List.generate(
						SeasonType.values.length,
						(seasonTypeIndex){
							return UnVisibleResponse(
								onTap: (){
									if(seasonTypeIndex <= convertPassedSeason(yearNotifier.value,currentMonth)){
										seasonTypeNotifier.value = SeasonType.values[seasonTypeIndex];
									}
								},
								child: Stack(
									children: [
										AnimatedContainer(
										duration: const Duration(milliseconds: 300),
										decoration: BoxDecoration(
											borderRadius: BorderRadius.only(
												topLeft: seasonTypeIndex == SeasonType.winter.index ? const Radius.circular(16) : Radius.zero,
												topRight: seasonTypeIndex == SeasonType.spring.index ? const Radius.circular(16) : Radius.zero,
												bottomLeft: seasonTypeIndex == SeasonType.summer.index ? const Radius.circular(16) : Radius.zero,
												bottomRight: seasonTypeIndex == SeasonType.autumn.index ? const Radius.circular(16) : Radius.zero,
											),
											color: convertPassedSeason(year, currentMonth) < seasonTypeIndex ? Colors.grey : BangumiThemeColor.values[seasonTypeIndex].color , //unable will be grey.,,
										),
										
										child: SizedBox(
                      width: 150/2,
                      height: 100/2,
                      child: Center(
                        child: ScalableText(
                          SeasonType.values[seasonTypeIndex].seasonText,style: const TextStyle(color: Colors.black)
                          )
                        )
                      ),
										),

										Positioned(
											left: 50,
											top: 25,
											child: Builder(
											  builder: (context) {
											    return ValueListenableBuilder(
													valueListenable: seasonTypeNotifier,
													builder: (_,seasonType,child) {
														return Offstage(
															offstage: seasonTypeIndex != seasonType.index,
															child: Icon(Icons.done,color: judgeCurrentThemeColor(context))
														);
													}
												);
											  
											    
											  }
											)
										),

										
																
									],
								)								  
							);
						}
					)
				    
					
				  
				);
			}
		)
	);
  }
}

void showSeasonDialog(BuildContext context,Future? calendarLoadFuture){

  invokeAsyncToasterExec() => fadeToaster(context: context, message: "正在切换季节番剧信息");

  final indexModel = context.read<IndexModel>();
  
    showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "'!barrierDismissible || barrierLabel != null' is not true",
      context: context,
      pageBuilder: (_,inAnimation,outAnimation)=> WarpSeasonDialog(
        selectedYear: indexModel.selectedYear,
        selectedSeasonType: indexModel.selectedSeason
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation,child: child),
      transitionDuration: const Duration(milliseconds: 300)
    )
    .then((selectSeason) async {

      DateTime currentTime = DateTime.now();

      if(selectSeason==null) return;

      if(selectSeason is! DateTime) return;
      
      if(
        selectSeason.year == currentTime.year &&
        selectSeason.month == currentTime.month
      ){
        calendarLoadFuture = indexModel.reloadCalendar();
      }

  
      else{

        int searchYear = selectSeason.year;
        int searchMonth = selectSeason.month;

        List<String> requestDateRange = [
          ">=$searchYear-${convertDigitNumString(searchMonth)}-01",
          "<${(searchMonth+3)/12 > 1 ? searchYear+1 : searchYear}-${convertDigitNumString((searchMonth+3)%12)}-01"
        ];

        debugPrint("requestDateRange:$requestDateRange");

        invokeAsyncToasterExec();

        sortSearchHandler(
          airDateRange: requestDateRange,
          searchLimit: 1 //因为api限制最大20页 那就直接试探包算了
        ).then((response){
          if(response.data != null){
          int totalBangumiLength = response.data["total"];

          calendarLoadFuture = indexModel.reloadCalendar(
            switchCalendar: (()=>bangumiTimeRangeSearch(
            totalBangumiLength: totalBangumiLength,
            airDateRange: requestDateRange,
            ))
          );

          }
        });
      }

      indexModel.selectedYear = selectSeason.year;
      indexModel.selectedSeason = judgeSeasonRange(selectSeason.month,currentTime: true);

    });

}
