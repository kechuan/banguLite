import 'package:flutter/material.dart';

class BuildInfoBox extends StatelessWidget{

  const BuildInfoBox({
    super.key,
    required this.informationList
  });

  final Map<String, dynamic> informationList;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("放送日期: ${informationList["air_date"]}",style: const TextStyle(fontWeight: FontWeight.bold),),
          Text("总集数: ${informationList["eps"]}",style: const TextStyle(fontWeight: FontWeight.bold),),
          Text("更新日期: ${informationList["air_weekday"]}",style: const TextStyle(fontWeight: FontWeight.bold),)
        ],
      ),
    );
  }
  
}
