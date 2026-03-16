import 'dart:async';

import 'package:bangu_lite/catalogs/subject/bangumi_ep_page.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/informations/surf/timeline_details.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

class UserModel extends ChangeNotifier{

  //userID: UserInformation
  static Map<String,UserDetails> userData = {};

  /// 被 [convertTimelineDescription] 植入的 [EpCommentDetails] 大部分信息会被转换成 [EpCommentPageDetails] 
  /// 以等待 context 读取引入 因为 [UserModel] 是全局Provider 
  //TimelineID: EPCommentDetails
  static Map<int,CommentDetails> timelineChatsData = {};

  Future<void> loadUserInfomation(
    String? userName,
    UserInformation? currentUserInformation
  ) async {

    Completer userInfomationCompleter = Completer();

    if(userName == null) return;
    if(userData.containsKey(userName)) return;

    //初始化占位
    userData.addAll({userName:UserDetails()});

    await Future.wait([
      HttpApiClient.client.get(BangumiAPIUrls.user(userName)),
      loadUserTimeline(userName)
    ]).then((responseList){

      if(responseList[0].data != null && responseList[1].data != null){

        final UserDetails currentUserDetail = loadUserDetails(
          responseList[0].data,
          currentUserInformation:currentUserInformation
        );

        debugPrint("basic user loaded");

        currentUserDetail.timelineActions = loadTimelineDetails(
          responseList[1].data,
          currentUserInformation:currentUserDetail.userInfomation

        );

        userData.addAll({
          userName:currentUserDetail
        });

        userInfomationCompleter.complete();

        notifyListeners();


      }

     
    });

   
    return userInfomationCompleter.future;

  }

  Future<Response> loadUserTimeline(
    String userName,
    {
      Map<String, dynamic>? queryParameters
    }
  ){
    return HttpApiClient.client.get(
      BangumiAPIUrls.userTimeline(userName),
      queryParameters: queryParameters ?? BangumiQuerys.timelineQuery()
    );
  }



}