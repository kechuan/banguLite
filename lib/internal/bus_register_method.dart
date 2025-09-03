import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/subjects/group_details.dart';
import 'package:bangu_lite/models/informations/subjects/group_topic_info.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/ep_model.dart';
import 'package:bangu_lite/models/providers/groups_model.dart';
import 'package:bangu_lite/models/providers/review_model.dart';
import 'package:bangu_lite/models/providers/topic_model.dart';
import 'package:bangu_lite/models/informations/subjects/review_details.dart';
import 'package:bangu_lite/models/informations/subjects/topic_info.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

final pathRegExp = RegExp(r'^[^?]*');

// 424493#post_3306858
final anchorRegExp = RegExp(r'#post_\d+');

void appRouteMethodListener(BuildContext context,String link){

  final appRouteUri = Uri.parse(link);

  if(
    link.startsWith(BangumiWebUrls.baseUrl) || 
    link.startsWith(BangumiWebUrls.relativeUrl) ||
    link.startsWith(BangumiAPIUrls.newUrl)
  ){

    debugPrint("detected BangumiUrls: $link");

    //example: https://bangumi.tv/ep/1471078?subjectID=1471078&selectedEp=2
    String? matchLink = pathRegExp.firstMatch(link)?.group(0);
    String? matchPath = matchLink?.split(RegExp('/')).last ?? "";

    final matchResult = RegExp(r'\d+').allMatches(matchPath);

    final int resID = matchResult.isEmpty ? 0 :
      int.tryParse(
        matchResult.first.group(0) ?? ""
      ) ?? 0
    ;

    final int? postReferID = matchResult.isEmpty ? null :
      int.tryParse(matchResult.last.group(0) ?? "") == resID ? 
      null : 
      int.tryParse(matchResult.last.group(0) ?? "")
    ;

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

            int subjectID = int.tryParse(appRouteUri.queryParameters['subjectID'] ?? "") ?? 0;
            num selectedEp = num.tryParse(appRouteUri.queryParameters['selectedEp'] ?? "") ?? 0;

            Navigator.pushNamed(
            context, Routes.subjectEp,
            arguments: {
              //暂定 随后会自动获取totalEp信息
              'epModel': EpModel(
                subjectID: subjectID,
                selectedEp: selectedEp,
                injectEpID: subjectID == 0 ? resID : 0,
              ),
              "referPostContentID": postReferID,
            }
          );


        }
        
      }

      else if(
        link.startsWith(BangumiWebUrls.subjectTopic(resID)) ||
        link.startsWith(BangumiWebUrls.relativeSubjectTopic(resID)) 
      ){
        if(context.mounted){

          debugPrint("topic link: $link");

          Navigator.pushNamed(
            context, 
            Routes.subjectTopic,
            arguments: {
              "topicModel":TopicModel(subjectID: appRouteUri.queryParameters['sourceID']),
              "topicInfo":TopicInfo(id: resID,contentTitle: appRouteUri.queryParameters['topicTitle'] ?? "topicID: $resID"),
              'sourceTitle': appRouteUri.queryParameters['sourceTitle'],
              "referPostContentID": postReferID,
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

          debugPrint("groupTopic link: $link");

          Navigator.pushNamed(
            context, 
            Routes.groupTopic,
            arguments: {
              "groupsModel":GroupsModel(subjectID: appRouteUri.queryParameters['sourceID']),
              "groupTopicInfo":
                  GroupTopicInfo(id: resID)
                  ..contentTitle = appRouteUri.queryParameters['groupTitle']
              ,
              'sourceTitle': appRouteUri.queryParameters['sourceTitle'],
              "referPostContentID": postReferID,
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
            "reviewModel":ReviewModel(subjectID: int.parse(appRouteUri.queryParameters['sourceID'] ?? "0")),
            "reviewInfo": ReviewInfo(id: resID),
            'sourceTitle': appRouteUri.queryParameters['sourceTitle'],
            "referPostContentID": postReferID,
          }
        );
        }
      }

      else if(
        link.startsWith(BangumiWebUrls.group(matchLink?.split(RegExp('/')).last)) ||
        link.startsWith(BangumiWebUrls.relativeGroup(matchLink?.split(RegExp('/')).last)) 
      ){

		  final groupNameRegexp = RegExp('group/([^&]+)');

        debugPrint(
          "groupName:${groupNameRegexp.firstMatch(link)?.group(1)}"
          "groupTitle:${link.split('groupTitle=').last}"
          "referPostContentID: $postReferID"
        );


        if(context.mounted){

          Navigator.pushNamed(
            context,
            Routes.groups,
            arguments: {
              "selectedGroupInfo": GroupInfo()
              ..groupName = groupNameRegexp.firstMatch(link)?.group(1)
              ..groupTitle = link.split('groupTitle=').last
            ,
            "referPostContentID": postReferID,
            }
          );
        }
      }

      else if(
        //特殊状况
        link.startsWith(BangumiAPIUrls.timelineReply(int.parse(appRouteUri.queryParameters['timelineID'] ?? '0')))
      ){

        /// 因为跳转的时候 一般会拥有 用户信息 那么传个userName什么的也没有问题

        if(context.mounted){

          //stupid way. but general...
          Navigator.pushNamed(
            context,
            Routes.timelineChat,
            arguments: {
              'timelineID':appRouteUri.queryParameters['timelineID'],
              'comment':appRouteUri.queryParameters['comment'],
              'createdAt':appRouteUri.queryParameters['createdAt'],
              'userName':appRouteUri.queryParameters['userName'],
              'onDeleteAction':(int resultID){

                if(resultID!=0){
                  showRequestSnackBar(
                    message: '删除成功',
                    requestStatus: true,
                  );
                }
              },

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

void appLoginMethodListener(BuildContext context,String link){
  final accountModel = context.read<AccountModel>();
  
  debugPrint("detected BangumiLogin: $link");

  if(link.startsWith(APPInformationRepository.bangumiOAuthCallbackUri.scheme)){
    final code = link.split("code=").last;
    accountModel.getAccessToken(
		code,
		fallbackAction: (message){
			showRequestSnackBar(message: message, requestStatus: false,backgroundColor: judgeCurrentThemeColor(context));
		}
	);
  }
}