import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/models/providers/ep_model.dart';
import 'package:bangu_lite/widgets/components/ep_select.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class BuildEps extends StatelessWidget {
  const BuildEps({
    super.key,
    required this.subjectID,
    required this.informationList,
	  this.portialMode,
  });

  final int subjectID;
  final Map<String, dynamic> informationList;
  final bool? portialMode;

  @override
  Widget build(BuildContext context) {

    //注意 在这里 portial模式会在点击 放送详情之后才会加载EPModel 而 landscape则不会。。简直太神奇了

    final epModel = context.watch<EpModel>(); //那没办法 只能让你以watch形式监控了

    int totalEps = informationList["eps"] ?? 0;
    //String airDate = informationList["air_date"] ?? "";

    int airedEps = 0;

    if(totalEps != 0){
      
      if(epModel.epsData[epModel.epsData.length]?.airDate != null){
        epModel.epsData.values.any((currentEpInfo){
          
          //debugPrint("airedEps:$airedEps");

          //bool overlapAirDate = convertAirDateTime(currentEpInfo.airDate) - DateTime.now().millisecondsSinceEpoch >= 0;
          bool overlapAirDate = convertAirDateTime(currentEpInfo.airDate).difference(DateTime.now()) >= Duration.zero;
          overlapAirDate ? null : airedEps+=1;

          return overlapAirDate;

        });

      }
    }

    //airedEps = convertAiredEps(informationList["air_date"]);

    return totalEps == 0 ? 
      const SizedBox.shrink() :
      EpSelect(
        totalEps: totalEps,
        airedEps: airedEps,
        name: informationList["alias"],
        portialMode: portialMode,
        //outerContext: outerContext,
      );
  }
}
