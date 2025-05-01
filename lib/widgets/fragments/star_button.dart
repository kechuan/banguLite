import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/bangumi_details.dart';
import 'package:bangu_lite/models/comment_details.dart';
import 'package:bangu_lite/models/providers/bangumi_model.dart';
import 'package:bangu_lite/models/providers/comment_model.dart';
import 'package:bangu_lite/models/providers/ep_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/models/star_details.dart';
import 'package:bangu_lite/widgets/dialogs/star_subject_dialog.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StarButton extends StatefulWidget{
  const StarButton({
    super.key,
    required this.bangumiDetails,
    
  });

  final BangumiDetails bangumiDetails;
  

  @override
  State<StarButton> createState() => _StarButtonState();
}

class _StarButtonState extends State<StarButton> {

  StarType? localStarType;

  final ValueNotifier<int> starInformationNotifier = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {

    return Selector<CommentModel,CommentDetails?>(
      selector: (_, commentModel) => commentModel.userCommentDetails,
      shouldRebuild: (previous, next) => previous != next,
      builder: (_,userCommentDetails,child) {
        return ElevatedButton(
          style: ButtonStyle(
            elevation: const WidgetStatePropertyAll(0),
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
            overlayColor: WidgetStatePropertyAll(judgeCurrentThemeColor(context)),
          ),
          onPressed: () {
        
            final bangumiModel = context.read<BangumiModel>();
        
            /// context 环节迁移到 button 区域 而非 Dialog区域(特指)
            /// 以免造成 deactive Context use.
            
            invokeLocalUpdateStaredBangumi() => updateLocalStaredBangumi(
              context,
              starInformationNotifier,
              widget.bangumiDetails,
            );
        
            invokeRequestSnackBar({String? message,bool? requestStatus}) => showRequestSnackBar(
              context,
              message: message,
              requestStatus: requestStatus,
            );
        
            showStarSubjectDialog(
              context,
              bangumiDetails: widget.bangumiDetails,
              onUpdateLocalStar:invokeLocalUpdateStaredBangumi,
              onUpdateBangumiStar: invokeRequestSnackBar,
              
              commentDetails:
                userCommentDetails?..type = 
                  localStarType ?? userCommentDetails.type
              ,
              themeColor:judgeDetailRenderColor(context, bangumiModel.imageColor)
            ).then((result){
              starInformationNotifier.value += 1;
              localStarType = result;
            });
        
        
          },
          child: Container(
            height: 40,
            padding: PaddingH12V6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.6)
            ),
            child: ValueListenableBuilder(
              valueListenable: starInformationNotifier,
              builder: (_,__,child){
          
                final isStared = MyHive.starBangumisDataBase.containsKey(widget.bangumiDetails.id);
          
                String starText = "已收藏";
          
                if(userCommentDetails != null){
                  starText = (localStarType ?? userCommentDetails.type ?? StarType.none).starTypeName;
                }
                
          
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 6,
                  children: [
                    isStared ? const Icon(Icons.star) : const Icon(Icons.star_outline),
                    isStared ? ScalableText(starText) : const ScalableText("加入收藏"),
                  ],
                );
              }
            ),
          ),
        );
      }
    );

  }
}


void updateLocalStaredBangumi(
  BuildContext context,
  ValueNotifier<int> starNotifier,
  BangumiDetails bangumiDetails
){

  final indexModel = context.read<IndexModel>();
  final epModel = context.read<EpModel>();

  final isStared = MyHive.starBangumisDataBase.containsKey(bangumiDetails.id);

  if(isStared){
    MyHive.starBangumisDataBase.delete(bangumiDetails.id);
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

    
  }

  starNotifier.value+=1;

  indexModel.updateStar();
}
