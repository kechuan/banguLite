import 'dart:async';

import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/timeline_details.dart';
import 'package:bangu_lite/models/user_details.dart';
import 'package:flutter/widgets.dart';

//唉 真的不想写这玩意
class UserModel extends ChangeNotifier{

  //userID: UserInformation
  Map<String,UserDetails> userData = {};

  Future<void> loadUserInfomation(String? userName,UserInformation? currentUserInformation) async {

    Completer userInfomationCompleter = Completer();

    if(userName == null) return;
    if(userData.containsKey(userName)) return;

    //初始化占位
    userData.addAll({userName:UserDetails()});

    await Future.wait([
      HttpApiClient.client.get(BangumiAPIUrls.user(userName)),
      HttpApiClient.client.get(
        BangumiAPIUrls.userTimeline(userName),
        queryParameters: BangumiQuerys.timelineQuery
      )
    ]).then((responseList){

      if(responseList[0].data != null && responseList[1].data != null){

        final UserDetails currentUserDetail = loadUserDetails(
          responseList[0].data,
          currentUserInformation:currentUserInformation
        );

        debugPrint("basic user loaded");

        currentUserDetail.timelineActions = loadTimelineDetails(
          responseList[1].data,
        );

        userData.addAll({
          userName:currentUserDetail
        });

        debugPrint("currentUserDetail timelineActions: ${currentUserDetail.timelineActions}");

        userInfomationCompleter.complete();

        notifyListeners();


      }

     
    });

   
    return userInfomationCompleter.future;

  }
}