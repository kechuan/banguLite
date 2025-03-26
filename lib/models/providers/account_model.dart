

import 'dart:async';

import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/user_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AccountModel extends ChangeNotifier {

  AccountModel(){
    initModel();
  }

  LoginedUserInformations loginedUserInformations = getDefaultLoginedUserInformations();

  void initModel(){
    loadUserDetail();
    verifySessionValidity(loginedUserInformations.accessToken).then((status){
      if(status){
        updateAccessToken(loginedUserInformations.refreshToken);
      }
      
      notifyListeners();

    });
  }

  bool isLogined() => loginedUserInformations.accessToken!=null;

  void loadUserDetail(){
    loginedUserInformations = MyHive.loginUserDataBase.get('loginUserInformations') ?? getDefaultLoginedUserInformations();
  }

  void updateLoginInformation(LoginedUserInformations loginedUserInformations){
    MyHive.loginUserDataBase.put('loginUserInformations', loginedUserInformations);
	  notifyListeners();
  }

  Future<bool> verifySessionValidity(String? accessToken) async {

    Completer<bool> verifyCompleter = Completer();

    if(accessToken==null){
      debugPrint("账号未登录");
      verifyCompleter.complete(false);
    }

    else{
      try{
        await HttpApiClient.client.get(
          BangumiAPIUrls.me,
          options: Options(
            headers: BangumiQuerys.bearerTokenAccessQuery(accessToken),
          ),
      
        ).then((response) {
          if(response.statusCode == 200){
            debugPrint("accessToken: Valid, ${DateTime.now().millisecondsSinceEpoch~/1000} / ${loginedUserInformations.expiredTime}");
            loginedUserInformations.userInformations = loadUserInformations(response.data);
            verifyCompleter.complete(true);
          }
        });
		}

		on DioException catch(e){
			debugPrint(" ${e.response?.statusCode} verifySessionValidity:${e.message}");
			verifyCompleter.complete(false);
		}

    }

    return verifyCompleter.future;
  }

  Future<void> getAccessToken(String code) async{
    try{
      await HttpApiClient.client.post(
        BangumiWebUrls.oAuthToken,
        data: BangumiQuerys.getAccessTokenQuery(code),
      ).then((response) async {
        if(response.statusCode == 200){
          debugPrint("accessToken: Valid, ${DateTime.now().millisecondsSinceEpoch~/1000} / ${loginedUserInformations.expiredTime}");

          
          await verifySessionValidity(response.data["access_token"]).then((isValid){
            if(isValid){
              loginedUserInformations
                ..accessToken = response.data["access_token"]
                ..expiredTime = DateTime.now().millisecondsSinceEpoch~/1000 + (response.data["expires_in"] as int)
                ..refreshToken = response.data["refresh_token"]
              ;

              updateLoginInformation(loginedUserInformations);
                
            }
          });

          

        }
      });
    }

    on DioException catch(e){
      debugPrint(" ${e.response?.statusCode} error:${e.message}");
    }
  }

  Future<void> updateAccessToken(String? refreshToken) async{
    if(refreshToken==null) return;

    try{
      await HttpApiClient.client.post(
        BangumiWebUrls.oAuthToken,
        data: BangumiQuerys.refreshTokenQuery(refreshToken),
      ).then((response) {
        if(response.statusCode == 200){
          debugPrint("update succ, ${loginedUserInformations.expiredTime} => ${DateTime.now().millisecondsSinceEpoch~/1000 + (response.data["expires_in"])}");

          loginedUserInformations
            ..accessToken = response.data["access_token"]
            ..expiredTime = DateTime.now().millisecondsSinceEpoch~/1000 + (response.data["expires_in"] as int)
            ..refreshToken = response.data["refresh_token"]
          ;
          updateLoginInformation(loginedUserInformations);
          
        }

        else{
          debugPrint("update fail. token may already expired");
          launchUrlString(BangumiWebUrls.webAuthPage());
        }
      });
    }

    on DioException catch(e){
      debugPrint(" ${e.response?.statusCode} error:${e.message}");
    }
  }

  //账户相关操作
  Future<bool> userAction(
    String? username,
    {
      UserRelationsActionType relationType = UserRelationsActionType.add,
      Function(String)? fallbackAction,
    }
  ) async {

    Completer<bool> userActionCompleter = Completer();

    if(username==null) return false;

    try{
      switch(relationType){
          case UserRelationsActionType.add: await HttpApiClient.client.put(BangumiAPIUrls.addFriend(username)); break;
          case UserRelationsActionType.remove: await HttpApiClient.client.delete(BangumiAPIUrls.removeFriend(username)); break;
          case UserRelationsActionType.block: await HttpApiClient.client.put(BangumiAPIUrls.addBlockList(username)); break;
          case UserRelationsActionType.removeBlock: await HttpApiClient.client.delete(BangumiAPIUrls.removeBlockList(username)); break;
      }

      userActionCompleter.complete(true);
    }

    on DioException catch(e){
      debugPrint("${e.response?.statusCode} error:${e.message}");
      userActionCompleter.complete(false);
      if(fallbackAction!=null){
        fallbackAction('${e.message}')!;
      }

    }

    return userActionCompleter.future;

  }

    
  

  Future<void> postComment() async {}
  Future<void> postTopic() async {}

}