import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/group_details.dart';
import 'package:bangu_lite/models/group_topic_info.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/ep_model.dart';
import 'package:bangu_lite/models/providers/groups_model.dart';
import 'package:bangu_lite/models/providers/review_model.dart';
import 'package:bangu_lite/models/providers/topic_model.dart';
import 'package:bangu_lite/models/review_details.dart';
import 'package:bangu_lite/models/topic_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

final pathRegExp = RegExp('^[^?]*');

void appRouteMethodListener(BuildContext context,String link){

  final appRouteUri = Uri.parse(link);

  if(
    link.startsWith(BangumiWebUrls.baseUrl) || 
    link.startsWith(BangumiWebUrls.relativeUrl)
  ){

    debugPrint("detected BangumiWebUrls: $link");

    //example: https://bangumi.tv/ep/1471078?subjectID=1471078&selectedEp=2
    String? matchLink = pathRegExp.firstMatch(link)?.group(0);
    final int resID = int.tryParse(matchLink?.split(RegExp('/')).last ?? "") ?? 0;

    //if(resID == 0) return;

    //String appRoute = ""; 
    //如果后面需要匹配多个词条。。也许会用到呢。。
    //虽然我现在 topic/comment 之类的几乎全依赖在detailPage 但。。说不定其他页面会需要
    //比如说 可以单独拧出来的东西的 comment/topic 跳转?

    if(
      link == BangumiWebUrls.subject(resID) ||
      link == BangumiWebUrls.relativeSubject(resID)
    ){
      if(context.mounted) Navigator.pushNamed(context, Routes.subjectDetail,arguments: {"subjectID":resID});
    }

    
    else if(
      link.startsWith(BangumiWebUrls.ep(resID)) ||
      link.startsWith(BangumiWebUrls.relativeEp(resID)) 
    ){
      if(context.mounted){
        //EpModel(subjectID: widget.subjectID,selectedEp: 1)
        //难点在于怎么传递 subjectID 信息 答案: Params传递

        debugPrint("ep link: $link");

          Navigator.pushNamed(
          context, Routes.subjectEp,
          arguments: {
            //暂定 随后会自动获取totalEp信息
            'totalEps': 13,
            "epModel": EpModel(
              subjectID: int.parse(appRouteUri.queryParameters['subjectID']!),
              selectedEp: int.parse(appRouteUri.queryParameters['selectedEp']!)
            ),
          }
        );


      }
      
    }

    else if(
      link.startsWith(BangumiWebUrls.subjectTopic(resID)) ||
      link.startsWith(BangumiWebUrls.relativeSubjectTopic(resID)) 
    ){
      if(context.mounted){

        //那topic呢。。 一般的topic链接是不会拥有 subject/group 这种信息的
        //只有单独的 topic/postID
        debugPrint("topic link: $link");

        Navigator.pushNamed(
          context, 
          Routes.subjectTopic,
          arguments: {
            "topicModel":TopicModel(subjectID: 'topic'),
            "topicInfo":TopicInfo(id: resID,contentTitle: "topicID: $resID"),
          }
        );

      }
    }

    else if(
      link.startsWith(BangumiWebUrls.groupTopic(resID)) ||
      link.startsWith(BangumiWebUrls.relativeGroupTopic(resID)) 
    ){
      if(context.mounted){

        //那topic呢。。 一般的topic链接是不会拥有 subject/group 这种信息的
        //只有单独的 topic/postID
        debugPrint("group topic link: $link");

        Navigator.pushNamed(
          context, 
          Routes.groupTopic,
          arguments: {
            "groupsModel":GroupsModel(subjectID: 'groups'),
            "groupTopicInfo":GroupTopicInfo(id: resID),
          }
        );

      }
    }


    else if(
      link.startsWith(BangumiWebUrls.userBlog(resID)) ||
      link.startsWith(BangumiWebUrls.relativeBlog(resID)) 
    ){
      if(context.mounted){
        Navigator.pushNamed(
			context,
			Routes.blog,
            arguments: {
				"reviewModel":ReviewModel(subjectID: "blog"),
				"reviewInfo": ReviewInfo(id: resID),
         	}
        );
      }
    }

	else if(
      link.startsWith(BangumiWebUrls.group(resID)) ||
      link.startsWith(BangumiWebUrls.relativeGroup(resID)) 
    ){

		debugPrint("group link: $link, ${matchLink?.split(RegExp('/')).last}");


		if(context.mounted){

			Navigator.pushNamed(
				context,
				Routes.groups,
				arguments: {
					"selectedGroupInfo": GroupInfo(id: 0)..groupName = "${matchLink?.split(RegExp('/')).last}",
				}
			);
		}
    }

    else{
      launchUrlString(link);
    }


  }

  else{
    launchUrlString(link);
  }

        
}

void appLoginMethodListener(BuildContext context,String link) async {
  final accountModel = context.read<AccountModel>();
  
  debugPrint("detected BangumiLogin: $link");

  if(link.startsWith(APPInformationRepository.bangumiOAuthCallbackUri.scheme)){

    final code = link.split("code=").last;
    await accountModel.getAccessToken(code).then((result){
      accountModel.notifyListeners();
    });
  }
}