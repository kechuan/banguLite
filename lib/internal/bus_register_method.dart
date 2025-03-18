import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/user_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

void appRouteMethod(BuildContext context,String link){

  if(
    link.startsWith(BangumiWebUrls.baseUrl) || 
    link.startsWith(BangumiWebUrls.relativeUrl)
  ){

    debugPrint("detected BangumiWebUrls: $link");

    List<String> splitLink = link.split("https://").last.split(RegExp('/'));

    final int resID = int.tryParse(splitLink.last) ?? 0;
    if(resID == 0) return;

    //String appRoute = ""; 
    //如果后面需要匹配多个词条。。也许会用到呢。。
    //虽然我现在 topic/comment 之类的几乎全依赖在detailPage 但。。说不定其他页面会需要
    //比如说 可以单独拧出来的东西的 comment/topic 跳转?

    if(
      //splitLink.length != 3 ||
      link != BangumiWebUrls.subject(resID) && link != BangumiWebUrls.relativeSubject(resID)
    ){
      launchUrlString(link);
    }

    else{
      if(context.mounted) Navigator.pushNamed(context, Routes.subjectDetail,arguments: {"subjectID":resID});
    }
  }

  else{
    launchUrlString(link);
  }

        
}

void apploginMethod(BuildContext context,String link){

  debugPrint("detected BangumiLogin: $link");

  if(
    link.startsWith(APPInformationRepository.bangumiAuthCallbackUri.scheme)
  ){

    final accountModel = context.read<AccountModel>();
    final code = link.split("code=").last;

    try{
        HttpApiClient.client.post(
          BangumiWebUrls.oAuthToken,
          data: BangumiQuerys.getAccessTokenQuery(code),
        ).then((response) async {
          if(response.statusCode == 200){

            if(response.data != null){

              debugPrint("response:$response");

              await accountModel.verifySessionValidity(response.data["access_token"])
                .then((isValid){
                  if(isValid){
                    accountModel.updateLoginInformation(
                      LoginedUserDetails()
                        ..accessToken = response.data["access_token"]
                        ..expiredTime = DateTime.now().millisecondsSinceEpoch~/1000 + (response.data["expires_in"] as int)
                        ..refreshToken = response.data["refresh_token"]
                    );
                  }
                });

            }

          }

        });

    }

    on DioException catch(e){
      debugPrint("[Login error] ${e.response?.statusCode}:${e.message}");
    }




  }
}