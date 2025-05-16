import 'package:bangu_lite/bangu_lite_routes.dart';
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

final pathRegExp = RegExp('^[^?]*');

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
    final int resID = int.tryParse(matchLink?.split(RegExp('/')).last ?? "") ?? 0;

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
              'epModel': EpModel(
                subjectID: int.parse(appRouteUri.queryParameters['subjectID']!),
                selectedEp: num.parse(appRouteUri.queryParameters['selectedEp']!)
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

          Navigator.pushNamed(
            context, 
            Routes.groupTopic,
            arguments: {
              "groupsModel":GroupsModel(subjectID: 'groups'),
              "groupTopicInfo":
                GroupTopicInfo(id: resID)
                 ..contentTitle = appRouteUri.queryParameters['groupTitle']
              ,
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

      else if(
        //特殊状况
        link.startsWith(BangumiAPIUrls.timelineReply(int.parse(appRouteUri.queryParameters['timelineID'] ?? '0')))
      ){

        if(context.mounted){

          //stupid way. but general...
          Navigator.pushNamed(
            context,
            Routes.timelineChat,
            arguments: {
              'timelineID':appRouteUri.queryParameters['timelineID'],
              'comment':appRouteUri.queryParameters['comment'],
              'onDeleteAction':(int resultID){

                if(resultID!=0){
                  showRequestSnackBar(
                    context,
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