import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

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

    final FixedExtentScrollController yearSelectorController = FixedExtentScrollController(initialItem: (selectedYear - 2013)+1);  

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
                        width: 150,
                        child: ListWheelScrollView.useDelegate(
                          onSelectedItemChanged: (value) {
                            yearNotifier.value = value+2013;
                          },
                          itemExtent: 50,
                          controller: yearSelectorController,
                          physics: const FixedExtentScrollPhysics(),
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: (selectedYear - 2013)+1,
                            builder: (_,index){
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ScalableText("${2013+index}"),
                                  const Divider(height: 1)
                                ],
                              );
                            }
                          ),
                      
                        ),
                      ),

                      SizedBox(
                        height: 50,
                        width: 300,
                        child: DefaultTabController(
                          initialIndex: convertPassedSeason(currentYear,currentMonth),
                          length: SeasonType.values.length,
                          child: TabBar(
                            labelPadding: const EdgeInsets.all(0),
                            dividerColor: Colors.transparent,
                            indicatorSize: TabBarIndicatorSize.label,
							onTap: (seasonType) {
								if(seasonType < convertPassedSeason(yearNotifier.value,currentMonth)){
									seasonTypeNotifier.value = SeasonType.values[seasonType];
								}
							},
                            tabs: List.generate(
                              SeasonType.values.length,
                              (seasonTypeIndex){
                                return ValueListenableBuilder(
                                  valueListenable: yearNotifier,
                                  builder: (_,year,child) {
                                    
                                    return DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.horizontal(
                                          left: seasonTypeIndex == 0 ? const Radius.circular(16) : Radius.zero,
                                          right: seasonTypeIndex == SeasonType.values.length-1 ? const Radius.circular(16) : Radius.zero,
                                        ),
                                        
                                      ),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        color: convertPassedSeason(year, currentMonth)-1 < seasonTypeIndex ? Colors.grey : BangumiThemeColor.values[seasonTypeIndex].color , //unable will be grey.,,
                                        child: Center(child: Text(SeasonType.values[seasonTypeIndex].seasonText)),
                                      )
                                    );
                                  }
                                );
                              }
                            )
                            
                          ),
                        ),
                      ),

                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: ()=> Navigator.of(context).pop(),
                      child: const ScalableText("取消")
                    ),
                    TextButton(
                      onPressed: (){
                        Navigator.of(context).pop({yearNotifier.value:seasonTypeNotifier.value});
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