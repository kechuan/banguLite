import 'dart:async';

import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/surf/timeline_details.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

class UserModel extends ChangeNotifier{

  //userID: UserInformation
  static Map<String,UserDetails> userData = {};

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
      queryParameters: queryParameters ?? BangumiQuerys.timelineQuery
    );
  }



}