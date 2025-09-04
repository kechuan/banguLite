import 'package:flutter/material.dart';

class StarScoreList extends StatelessWidget {
  const StarScoreList({
    super.key,
    required this.ratingScore,
    this.showEmpty = false,
    this.itemExtent = 25,
    this.themeColor,
  });

  final int ratingScore;
  final double? itemExtent;
  final bool showEmpty;
  final Color? themeColor;
  

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(iconTheme: IconThemeData(color: themeColor)),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemExtent: itemExtent,
        shrinkWrap: true,
        itemCount: showEmpty ? 5 : ratingScore != 0 ? 5 : 0,
        
        itemBuilder: (_,score){
          if(ratingScore >= (score+1)*2) {return const Icon(Icons.star);}
          else if(ratingScore == (score*2)+1) {return const Icon(Icons.star_half);}
          else {return const Icon(Icons.star_outline);}
        },
      ),
    );
  }
}