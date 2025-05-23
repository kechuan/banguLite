import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/models/providers/bangumi_model.dart';
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

    this.subjectName,
  });

  final int subjectID;
  final Map<String, dynamic> informationList;
  final bool? portialMode;

  final String? subjectName;

  @override
  Widget build(BuildContext context) {

    //注意 在这里 portial模式会在点击 放送详情之后才会加载EPModel 而 landscape则不会。。简直太神奇了
    //回答: 因为portal展示是 透过 Dialog 机制 这也就导致它在 layout Tree 上是和 indexModel 仅次一级的 自然读取不了任何信息

    final epModel = context.read<EpModel>();
    final bangumiModel = context.read<BangumiModel>();

    int totalEps = informationList["eps"] ?? 0;
    int airedEps = 0;

    if(totalEps != 0){
      
      if(epModel.epsData[epModel.epsData.length]?.airDate != null){
        epModel.epsData.values.any((currentEpInfo){
          
          //debugPrint("airedEps:$airedEps");

          //bool overlapAirDate = convertDateTime(currentEpInfo.airDate) - DateTime.now().millisecondsSinceEpoch >= 0;
          bool overlapAirDate = convertDateTime(currentEpInfo.airDate).difference(DateTime.now()) >= Duration.zero;
          overlapAirDate ? null : airedEps+=1;

          return overlapAirDate;

        });

      }
    }
    
    return totalEps == 0 ? 
      const SizedBox.shrink() :
      EpSelect(
        totalEps: totalEps,
        airedEps: airedEps,
        name: informationList["alias"].isEmpty ? subjectName : informationList["alias"],
        portialMode: portialMode,
        bangumiThemeColor: bangumiModel.bangumiThemeColor
        
      );
  }
}
