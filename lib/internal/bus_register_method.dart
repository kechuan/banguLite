import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/ep_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

void appRouteMethodListener(BuildContext context,String link){

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
      link == BangumiWebUrls.subject(resID) ||
      link == BangumiWebUrls.relativeSubject(resID)
    ){
      if(context.mounted) Navigator.pushNamed(context, Routes.subjectDetail,arguments: {"subjectID":resID});
    }

    //TODO 长路漫漫
    //else if(
    //  link == BangumiWebUrls.ep(resID) ||
    //  link == BangumiWebUrls.relativeEp(resID)
    //){
    //  if(context.mounted){
    //    //EpModel(subjectID: widget.subjectID,selectedEp: 1)

    //    Navigator.pushNamed(
    //      context, Routes.subjectEp,
    //      arguments: {
    //        'totalEps': 1,
    //        "epModel": EpModel(subjectID: 0,selectedEp: 0),
    //        'episodesID':resID,
    //      }
    //    );

    //    //Navigator.pushNamed(
    //    //  context, Routes.subjectEp,
    //    //  arguments: {
    //    //    "epID":resID,
    //    //    "bangumiThemeColor": judgeCurrentThemeColor(context)
    //    //  }
    //    //);  

    //  }
      
    //}

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

  if(link.startsWith(APPInformationRepository.bangumiAuthCallbackUri.scheme)){
    final code = link.split("code=").last;
    accountModel.getAccessToken(code);
  }
}