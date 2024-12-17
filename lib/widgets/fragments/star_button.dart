import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/models/bangumi_details.dart';
import 'package:flutter/material.dart';

class StarButton extends StatelessWidget{
  const StarButton({
    super.key, 
    required this.bangumiDetails
  });

  final BangumiDetails bangumiDetails;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isStaredNotifier = ValueNotifier(MyHive.starBangumisDataBase.containsKey(bangumiDetails.id));

    return IconButton(
      onPressed: (){

        //manage Function

        if(isStaredNotifier.value){
          MyHive.starBangumisDataBase.delete(bangumiDetails.id);
          isStaredNotifier.value = false;
        }

        else{
          MyHive.starBangumisDataBase.put(
            bangumiDetails.id!, {
              "name": bangumiDetails.name,
              "coverUri": bangumiDetails.coverUri,
              "eps": bangumiDetails.informationList["eps"],
              "score": bangumiDetails.ratingList["score"],
            }
          );

          isStaredNotifier.value = true;
        }

        bus.emit("star");
        
      
    }, icon: ValueListenableBuilder(
      valueListenable: isStaredNotifier,
      builder: (_,isStared,child){
        return isStared ? const Icon(Icons.star) : const Icon(Icons.star_outline);
      }
    )
    
  );
                        

  }

}
