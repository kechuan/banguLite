
import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/catalogs/subject/bangumi_general_more_content_page.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFAutoImport()
import 'package:bangu_lite/models/review_details.dart';

@FFAutoImport()
import 'package:bangu_lite/models/providers/review_model.dart';

@FFRoute(name: '/moreReviews')
class MoreReviewsPage extends StatefulWidget {
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
  State<MoreReviewsPage> createState() => MoreReviewsPageState();
}

class MoreReviewsPageState extends BangumiGeneralMoreContentPageState
<
  MoreReviewsPage,
  ReviewModel,
  ReviewInfo
>{

  @override
  ReviewModel getContentModel() => widget.reviewModel;
  
  @override
  Future<void> loadSubjectTopics({int? offset})=> getContentModel().loadSubjectReviews(offset: offset);

  @override
  String? get title => '长评板块: ${widget.title}'; 

  @override
  Color? get bangumiThemeColor => widget.bangumiThemeColor;

  @override
  Function(int index)? get onTap => (index){
    Navigator.pushNamed(
      context,
        Routes.blog,
        arguments: {
          "reviewModel":getContentModel(),
		  "selectedBlogIndex": index,
          "themeColor": judgeDetailRenderColor(context,bangumiThemeColor),
        }
      );
  }; 
             
  

}