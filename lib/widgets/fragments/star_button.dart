import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/bangumi_details.dart';
import 'package:bangu_lite/models/providers/bangumi_model.dart';
import 'package:bangu_lite/models/providers/ep_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/models/star_details.dart';
import 'package:bangu_lite/widgets/dialogs/star_subject_dialog.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
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

    return ElevatedButton(
      style: ButtonStyle(
        elevation: const WidgetStatePropertyAll(0),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        overlayColor: WidgetStatePropertyAll(judgeCurrentThemeColor(context)),
      ),
      onPressed: () {

        final bangumiModel = context.read<BangumiModel>();

        invokeLocalUpdateStaredBangumi() => updateLocalStaredBangumi(
          context,
          isStaredNotifier,
          bangumiDetails,
        );

        showStarSubjectDialog(
          context,
          invokeLocalUpdateStaredBangumi,
          themeColor:judgeDetailRenderColor(context, bangumiModel.imageColor)
        );
      },
      child: SizedBox(
        height: 40,
        child: Container(
          padding: PaddingH12V6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.6)
          ),
          child: ValueListenableBuilder(
            valueListenable: isStaredNotifier,
            builder: (_,isStared,child){
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 6,
                children: [
                  isStared ? const Icon(Icons.star) : const Icon(Icons.star_outline),
                  isStared ? const ScalableText("已收藏") : const ScalableText("加入收藏"),
                ],
              );
            }
          ),
        ),
      ),
    );

  }

}


void updateLocalStaredBangumi(
  BuildContext context,
  ValueNotifier<bool> isStaredNotifier,
  BangumiDetails bangumiDetails
){

  final indexModel = context.read<IndexModel>();
  final epModel = context.read<EpModel>();

  if(isStaredNotifier.value){
    MyHive.starBangumisDataBase.delete(bangumiDetails.id);
    isStaredNotifier.value = false;
  }

  else{

    debugPrint("lastEP: ${epModel.epsData.values.last.airDate}");

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

    indexModel.starsUpdateRating.add({
      "score": bangumiDetails.ratingList["score"],
      "rank": bangumiDetails.ratingList["rank"]
    });

    isStaredNotifier.value = true;
  }

  indexModel.updateStar();
}
