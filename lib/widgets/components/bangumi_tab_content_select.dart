import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';


class BangumiTabContentSelect extends StatelessWidget {
  const BangumiTabContentSelect({
    super.key,
    required this.selectOffstageNotifier,
    required this.selectOffstageAnimatedNotifier,
    required this.selectedList,

    this.initalIndex = 0,
    this.onTap,
  });

  final ValueNotifier<bool> selectOffstageNotifier;
  final ValueNotifier<bool> selectOffstageAnimatedNotifier;

  final List selectedList;
  final int initalIndex;
  final Function(int)? onTap;
  

  @override
  Widget build(BuildContext context) {
    
    

    return ValueListenableBuilder(
      valueListenable: selectOffstageNotifier,
      builder: (_, selectOffstage, tabRow) {
        return Offstage(
          offstage: selectOffstage,
          child: SizedBox(
            height: 60,
            child: ValueListenableBuilder(
              valueListenable: selectOffstageAnimatedNotifier,
              builder: (_, animatedStatus, animated) {
                return TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 200),
                  tween: Tween(
                    begin: 0,
                    end: animatedStatus ? 0 : 1.0 ,
                  ),
                  onEnd: (){
                    if(!animatedStatus) selectOffstageNotifier.value = true;
                  },
                  
                  builder: (_,animationProgress,child){
                    return Opacity(
                      opacity: 1.0-animationProgress,
                      child: Transform.translate(
                        offset: Offset(0, -animationProgress*60),
                        child: tabRow!,
                      ),
                    );
                  }
                );
            }
            ),
          )
        );
      },
      child: ColoredBox(
        color: judgeCurrentThemeColor(context).withValues(alpha: 0.8),
        child: DefaultTabController(
          initialIndex: initalIndex,
          length: selectedList.length,
          child: TabBar(
            labelPadding: const EdgeInsets.all(0),
            onTap: onTap,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: List.generate(
              WeekDay.values.length, (currentDay)=> Center(child: ScalableText(WeekDay.values[currentDay].dayText)),
            )
          ),
        ),
      ),
                          
    );
  }
}