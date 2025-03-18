

import 'dart:async';

import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/platforms/register_windows_applink.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/user_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AccountModel extends ChangeNotifier {

  AccountModel(){
    initModel();
  }

  LoginedUserDetails loginedUserDetails = getDefaultLoginedUserDetails();

  void initModel() async {
    loadUserDetail();
    verifySessionValidity(loginedUserDetails.accessToken).then((_) => notifyListeners());
  }

  void loadUserDetail(){
    loginedUserDetails = MyHive.loginUserDataBase.get('loginUserDetails') ?? getDefaultLoginedUserDetails();
  }

  void updateLoginInformation(LoginedUserDetails newLoginedUserDetails){
	loginedUserDetails = newLoginedUserDetails;
    MyHive.loginUserDataBase.put('loginUserDetails', newLoginedUserDetails);
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
					debugPrint("accessToken: Valid, ${DateTime.now().millisecondsSinceEpoch~/1000} / ${loginedUserDetails.expiredTime}");
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

  void postComment(){}
  void postTopic(){}

  //void starBangumi({int? starStatus}){
  //  HttpApiClient.client.post(
  //    BangumiAPIUrls.starBangumi,
  //    options: Options(
  //      headers: BangumiQuerys.starBangumiQuery(accessToken)
  //    ),
  //  ).then((response) {
  //    debugPrint(response.);
  //  });
  //}

}