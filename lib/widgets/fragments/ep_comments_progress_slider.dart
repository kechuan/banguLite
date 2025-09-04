import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';

class EpCommentsProgressSlider extends StatelessWidget {
  const EpCommentsProgressSlider({
    super.key,
    this.commnetProgress = 0.0,
    this.onChanged,
    required this.offstage,
  });

  final double commnetProgress;
  final Function(double)? onChanged;
  final bool offstage;
  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: PaddingH6,
      child: Row(
        children: [
      
          SizedBox(
            width: 60,
            child: Center(
              child: ScalableText(
                "${(commnetProgress*100).toStringAsFixed(1)}%",
                style: const TextStyle(
                  
                ),
              ),
            ),
          ),
      
          const Padding(padding: PaddingH6),
      
          Expanded(
            child: Offstage(
              offstage: offstage,
              child: Slider(                          
                value: commnetProgress, 
                onChanged: onChanged,
              ),
            ),
          ),
      
          
        ],
      ),
    );
  }
}