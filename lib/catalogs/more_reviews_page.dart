
import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

@FFAutoImport()
import 'package:bangu_lite/models/providers/review_model.dart';


@FFRoute(name: '/moreReviews')
class MoreReviewsPage extends StatelessWidget {
  const MoreReviewsPage({
    super.key,
    required this.reviewModel,
    this.bangumiThemeColor,
    this.title
  });

  final String? title;
  final Color? bangumiThemeColor;
  final ReviewModel reviewModel;

  @override
  Widget build(BuildContext context) {

    final reviewsList = reviewModel.contentListData;

    return Theme(
      data: ThemeData(
        brightness: Theme.of(context).brightness,
        colorSchemeSeed: judgeDetailRenderColor(context,bangumiThemeColor),
        fontFamily: 'MiSansFont',
      ),
      child: Scaffold(
        appBar: AppBar(
          title: ScalableText("长评板块: $title"),
        ),
        body: EasyRefresh(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: reviewsList.length,
            itemBuilder: (_,index){
              
              return Card(
                color: judgeDetailRenderColor(context,bangumiThemeColor),
                child: ListTile(
                  onTap: () {
                    Navigator.pushNamed(
                    context,
                    Routes.blog,
                    arguments: {
                      "reviewModel":reviewModel,
                      "selectedBlogIndex": index,
                      "themeColor": judgeDetailRenderColor(context,bangumiThemeColor),
                    }
                );
                  },
                  title: ScalableText("${reviewsList[index].contentTitle}",maxLines: 2,overflow: TextOverflow.ellipsis,),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                    
                        ScalableText("${reviewsList[index].userInformation?.nickName}"),
                    
                        const Spacer(),
                    
                        Wrap(
                          spacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            ScalableText(convertDateTimeToString(DateTime.fromMillisecondsSinceEpoch(reviewsList[index].createdTime!*1000))),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 3,
                              children: [
                                Icon(MdiIcons.chat,size: 12),
                                ScalableText("${reviewsList[index].repliesCount}"),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
          )
        ),
      ),
    );
  }
}