import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/star_score_list.dart';
import 'package:flutter/material.dart';

class StarSliderPanel extends StatelessWidget {
  const StarSliderPanel({
    super.key,
    required this.valueNotifier,
    required this.onChanged,
  });

  final ValueNotifier<double> valueNotifier;
  final Function(double) onChanged;

@override
  Widget build(BuildContext context) {

    return ValueListenableBuilder(
      valueListenable: valueNotifier,
      builder: (_, score, child){

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
                    ),
                  ),

                  Opacity(
                    opacity: 0.0,
                    child: SizedBox(
                      width: 200,
                      child: Slider(
                        value: score,
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
              offstage: score*10~/1 >= 1,
              child: const ScalableText("(在星星栏滑动以进行评分)"),
            )


          ],
        );
      },
      
    );

    
  }
}

