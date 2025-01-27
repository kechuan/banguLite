import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:flutter/material.dart';
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