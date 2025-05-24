import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/star_score_list.dart';
import 'package:flutter/material.dart';

class StarSliderPanel extends StatelessWidget {
  const StarSliderPanel({
    super.key,
    required this.valueNotifier,
    required this.onChanged,
	  this.themeColor,
  });
  

  final ValueNotifier<double> valueNotifier;
  final Function(double) onChanged;
  final Color? themeColor;

@override
  Widget build(BuildContext context) {

    return ValueListenableBuilder(
      valueListenable: valueNotifier,
      builder: (_, score, child){

        if(score~/1 > 1){
          WidgetsBinding.instance.addPostFrameCallback((_){
            valueNotifier.value = score/10;
          });
          
        }

        return Column(
          children: [

            SizedBox(
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    child: StarScoreList(
                      ratingScore: score*10~/1,
                      showEmpty: true,
                      itemExtent: 30,
					            themeColor: themeColor,
                    ),
                  ),

                  Opacity(
                    opacity: 0.0,
                    child: SizedBox(
                      width: 200,
                      child: Slider(
                        value: score.clamp(0.0, 1.0),
                        onChanged: (value)=> valueNotifier.value = value,
                        divisions: 10,
                      ),
                    ),
                  ),


                ],
              ),
            ),

            ScalableText("${score*10~/1}  ${convertScoreRank((score*10~/1).toDouble())}"),

            Offstage(
              offstage: score~/1 >= 1,
              child: const ScalableText("(在星星栏滑动以进行评分)"),
            )


          ],
        );
      },
      
    );

    
  }
}

