import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/bangumi_details.dart';

Future<List<BangumiDetails>> searchHandler(String query) async {

  Response<dynamic> responseData = await HttpApiClient.client.get(
    '${BangumiAPIUrls.search}/$query',
    queryParameters: BangumiQuerys.searchQuery..["max_results"] = 10
  );

  List<BangumiDetails> searchResult = [];

  if(responseData.data != null){

    Map<String,dynamic> searchData = responseData.data;

    List<dynamic> bangumiList = searchData["list"];

    for(Map currentBangumi in bangumiList){
      BangumiDetails bangumiDetail = BangumiDetails();

      bangumiDetail.name = currentBangumi["name_cn"].isEmpty ? currentBangumi["name"] : currentBangumi["name_cn"];
      bangumiDetail.id = currentBangumi["id"];
      bangumiDetail.coverUrl = currentBangumi["images"]["medium"];

      searchResult.add(bangumiDetail);
    }

  }

  return searchResult;

}

Future<List<BangumiDetails>> sortSearchHandler(
  String keyword,
  {
    List<String>? airDateRange,
    List<String>? rankRange,
    List<String>? ratingRange,

    int? searchOffset,
    List<String>? tagsList,
    
    String? sortType,
  }
  ) async {

  Response<dynamic> responseData = await HttpApiClient.client.post(
    BangumiAPIUrls.bangumiSubjectSort,
    queryParameters: BangumiQuerys.sortQuery..['offset'] = searchOffset ?? 0,

    //data: BangumiDatas.sortData

    data: BangumiDatas.sortData
      ..['keyword'] = keyword
      ..['sort'] = sortType ?? ""
      ..['filter'] = {
        "type": [2],
        "tag": [...?tagsList],
        "nsfw": false,
        "rank" : rankRange != null ? [rankRange.first,rankRange.last] : [],
        "air_date" : airDateRange != null ? [airDateRange.first,airDateRange.last] : [],
        "rating" : ratingRange != null ? [ratingRange.first,ratingRange.last] : [],

      }

  );

  List<BangumiDetails> searchResult = [];

  if(responseData.data != null){

    Map<String,dynamic> searchData = responseData.data;

    List<dynamic> bangumiList = searchData["data"];

    debugPrint(responseData.data.toString());

    for(Map currentBangumi in bangumiList){
      BangumiDetails bangumiDetail = BangumiDetails();

      bangumiDetail.name = currentBangumi["name_cn"].isEmpty ? currentBangumi["name"] : currentBangumi["name_cn"];
      bangumiDetail.id = currentBangumi["id"];
      bangumiDetail.coverUrl = currentBangumi["image"];

      bangumiDetail.ratingList = {
        "total": currentBangumi["total"] ?? 0,
        "score": currentBangumi["score"] ?? 0,
        "rank": currentBangumi["rank"] ?? 0, //返回的是一个数值0
      };

      searchResult.add(bangumiDetail);
    }

  }

  debugPrint("keyword: $keyword, sort parse done");

  return searchResult;

}
