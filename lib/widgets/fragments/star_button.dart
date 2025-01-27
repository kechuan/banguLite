import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/models/bangumi_details.dart';
import 'package:bangu_lite/models/providers/ep_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/models/star_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StarButton extends StatelessWidget{
  const StarButton({
    super.key, 
    required this.bangumiDetails
  });

  final BangumiDetails bangumiDetails;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isStaredNotifier = ValueNotifier(MyHive.starBangumisDataBase.containsKey(bangumiDetails.id));
    final indexModel = context.read<IndexModel>();

    return IconButton(
      onPressed: (){

        //manage Function

        if(isStaredNotifier.value){
          MyHive.starBangumisDataBase.delete(bangumiDetails.id);
          isStaredNotifier.value = false;
        }

        else{

          final epModel = context.read<EpModel>();

          //context.read<EpModel>().getEpsInformation();
          debugPrint("lastEP: ${epModel.epsData.values.last.airDate}");
          //EpModel(subjectID: subjectID, selectedEp: selectedEp)

          MyHive.starBangumisDataBase.put(
            bangumiDetails.id!, 
            StarBangumiDetails()
              ..bangumiID = bangumiDetails.id
              ..name = bangumiDetails.name
              ..rank = bangumiDetails.ratingList["rank"]
              ..coverUrl = bangumiDetails.coverUrl
              ..eps =  bangumiDetails.informationList["eps"]
              ..score = bangumiDetails.ratingList["score"]?.toDouble()
              ..joinDate = DateTime.now().toIso8601String().substring(0,10)
              ..airDate = bangumiDetails.informationList["air_date"]
              ..finishedDate = epModel.epsData.values.last.airDate
              ..airWeekday = bangumiDetails.informationList["air_weekday"]
              
              
          );

          isStaredNotifier.value = true;
        }

        indexModel.updateStar();
        
      
    }, icon: ValueListenableBuilder(
      valueListenable: isStaredNotifier,
      builder: (_,isStared,child){
        return isStared ? const Icon(Icons.star) : const Icon(Icons.star_outline);
      }
    )
    
  );
                        

  }

}
