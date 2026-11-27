import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/get.dart';
import 'package:bangu_lite/models/informations/local/star_details.dart';
import 'package:bangu_lite/models/informations/subjects/bangumi_details.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/providers/bangumi_model.dart';
import 'package:bangu_lite/models/providers/comment_model.dart';
import 'package:bangu_lite/models/providers/ep_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
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
  void dispose() {
    starInformationNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Selector<CommentModel, CommentDetails?>(
      selector: (_, commentModel) => commentModel.userCommentDetails,
      shouldRebuild: (previous, next) => previous != next,
      builder: (_, userCommentDetails, child) {
        return ElevatedButton(
          style: ButtonStyle(
            elevation: const WidgetStatePropertyAll(0),
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
            overlayColor: WidgetStatePropertyAll(getCurrentThemeColor(context)),
          ),
          onPressed: () {

            final bangumiModel = context.read<BangumiModel>();
            final commentModel = context.read<CommentModel>();

            /// context 环节迁移到 button 区域 而非 Dialog区域(特指)
            /// 以免造成 deactive Context use.

            invokeLocalUpdateStaredBangumi() => updateLocalStaredBangumi(
              context,
              starInformationNotifier,
              widget.bangumiDetails,
            );

            invokeRequestSnackBar({String? message, bool? requestStatus}) => showRequestSnackBar(
              message: message,
              requestStatus: requestStatus,
              backgroundColor: getCurrentThemeColor(context)
            );

            showStarSubjectDialog(
              context,
              bangumiDetails: widget.bangumiDetails,
              onUpdateLocalStar: invokeLocalUpdateStaredBangumi,
              onUpdateBangumiStar: invokeRequestSnackBar,
              onSaveCommentDetails: (updatedDetails) {
                commentModel.updateUserCommentDetails(updatedDetails);
              },

              commentDetails:
              userCommentDetails == null
                ? null
                : (userCommentDetails..type = localStarType ?? userCommentDetails.type),
              themeColor: getDetailRenderColor(context, bangumiModel.imageColor)
            ).then((result) {
              if (!mounted) return;

              if (result != null) {
                localStarType = result;
              }

              starInformationNotifier.value += 1;
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
              builder: (_, __, child) {

                //会出现 账号收藏 本地未收藏的状态...
                final isStared = MyHive.starBangumisDataBase.containsKey(widget.bangumiDetails.id);
                final activeStarType = localStarType ?? userCommentDetails?.type;
                final isOnlineStared = activeStarType != null && activeStarType != StarType.none;

                String starText = isStared ? "已收藏" : "加入收藏";

                if (isOnlineStared) {
                  starText = activeStarType.starTypeName;
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 6,
                  children: [
                    (isStared || isOnlineStared) ? const Icon(Icons.star) : const Icon(Icons.star_outline),
                    ScalableText(starText),
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
) {

  final indexModel = context.read<IndexModel>();
  final epModel = context.read<EpModel>();

  final isStared = MyHive.starBangumisDataBase.containsKey(bangumiDetails.id);

  if (isStared) {
    MyHive.starBangumisDataBase.delete(bangumiDetails.id);
  }

  else {

    debugPrint("lastEP: ${epModel.epsData.values.last.airDate}");

    MyHive.starBangumisDataBase.put(
      bangumiDetails.id!, 
      StarBangumiDetails()
        ..bangumiID = bangumiDetails.id
        ..name = bangumiDetails.name
        ..rank = bangumiDetails.ratingList["rank"]
        ..coverUrl = bangumiDetails.coverUrl
        ..eps = bangumiDetails.informationList["eps"]
        ..score = bangumiDetails.ratingList["score"]?.toDouble()
        ..joinDate = DateTime.now().toIso8601String().substring(0, 10)
        ..airDate = bangumiDetails.informationList["air_date"]
        ..finishedDate = epModel.epsData.values.last.airDate
        ..airWeekday = bangumiDetails.informationList["air_weekday"]
    );

    indexModel.starsUpdateRating.addAll(
    {
      bangumiDetails.id!: {
        "score": bangumiDetails.ratingList["score"],
        "rank": bangumiDetails.ratingList["rank"]
      }
    }
    );

  }

  starNotifier.value += 1;

  indexModel.updateStar();
}
