
import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/catalogs/subject/bangumi_general_more_content_page.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/subjects/blog_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFAutoImport()
import 'package:bangu_lite/models/informations/subjects/review_details.dart';

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
          "reviewInfo": getContentModel().contentListData[index],
          "themeColor": bangumiThemeColor,
          "sourceTitle":widget.title
          
        }
      );
  };

  @override
  Function((String,String))? get onPostContent => (message){

    //添加获取用户 发布信息 .

    getContentModel().contentListData.add(
      ReviewInfo(
        id: -1,
        contentTitle: message.$1
      )
       
        ..updatedTime = DateTime.now().millisecondsSinceEpoch
        ..userInformation = AccountModel.loginedUserInformations.userInformation
    );
    

    getContentModel().contentDetailData[-1] = 
      BlogDetails()
        ..content = message.$2
        ..updatedTime = DateTime.now().millisecondsSinceEpoch
        ..userInformation = AccountModel.loginedUserInformations.userInformation
    ;


    Navigator.pushNamed(
      context, 
      Routes.blog,
      arguments: {
        "reviewModel":getContentModel(),
        "reviewInfo": getContentModel().contentListData.last,
        "themeColor": judgeDetailRenderColor(context,bangumiThemeColor),

        "sourceTitle":widget.title
      }
    );

  };

  @override
  PostCommentType? get postCommentType => PostCommentType.postBlog;

  @override
  String? get webUrl => BangumiWebUrls.subjectReviews(getContentModel().subjectID);
  
}