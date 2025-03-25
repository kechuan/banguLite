import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/models/bangumi_details.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';

class BuildInfoBox extends StatelessWidget{

  const BuildInfoBox({
    super.key,
    required this.informationList,
    this.type = 2
  });

  final Map<String, dynamic> informationList;
  final int? type;


  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(12),
      child: 
        type == SubjectType.anime.subjectType ?
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScalableText("放送日期: ${informationList["air_date"]}",style: const TextStyle(fontWeight: FontWeight.bold),),
            ScalableText("总集数: ${informationList["eps"]}",style: const TextStyle(fontWeight: FontWeight.bold),),
            ScalableText("更新日期: ${informationList["air_weekday"]}",style: const TextStyle(fontWeight: FontWeight.bold),)
          ],
        ):
        null
    );
  }
  
}
