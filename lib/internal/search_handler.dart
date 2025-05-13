import 'dart:async';

import 'package:bangu_lite/internal/convert.dart';
import 'package:dio/dio.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/subjects/bangumi_details.dart';

//@Deprecated
Future<List<BangumiDetails>> searchHandler(String query) async {

  Response<dynamic> responseData = await HttpApiClient.client.get(    
    '${BangumiAPIUrls.search}/${Uri.encodeComponent(query)}',
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

Future<Response> sortSearchHandler(
  {
    String? keyword,
    List<String>? airDateRange,
    List<String>? rankRange,
    List<String>? ratingRange,

    int? searchOffset,
    int? searchLimit,
    List<String>? tagsList,
    List<int>? subjectType,
    
    String? sortType,
  }
  ) async {

  return await HttpApiClient.client.post(
    BangumiAPIUrls.bangumiSubjectSort,
    queryParameters: BangumiQuerys.sortQuery
      ..['offset'] = searchOffset ?? BangumiQuerys.sortQuery["offset"]!
      ..['limit'] = searchLimit ?? BangumiQuerys.sortQuery["limit"]!,

    //data: BangumiDatas.sortData

    data: BangumiDatas.sortData
      ..['keyword'] = keyword ?? BangumiDatas.sortData["keyword"]
      ..['sort'] = sortType ?? BangumiDatas.sortData["sort"]
      ..['filter'] = {
        "type": subjectType ?? BangumiDatas.sortData["filter"]["type"],
        "tag": [...?tagsList],
        "nsfw": false,
        "rank" : rankRange != null ? [rankRange.first,rankRange.last] : [],
        "air_date" : airDateRange != null ? [airDateRange.first,airDateRange.last] : [],
        "rating" : ratingRange != null ? [ratingRange.first,ratingRange.last] : [],
      }

  );

}

Future<List<BangumiDetails>> bangumiTimeRangeSearch({required int totalBangumiLength, required List<String> airDateRange}) async {

  final List<BangumiDetails> searchResultList = [];

  Completer<List<BangumiDetails>> searchCompleter = Completer();
  int completeFlag = convertSegement(totalBangumiLength, 20);


  await Future.wait(
    List.generate(
      convertSegement(totalBangumiLength, 20),
      (index){
        return sortSearchHandler(
          airDateRange: airDateRange,
          searchLimit: 20,
          searchOffset: index*20
        ).then((response){
          if(response.data!=null) searchResultList.addAll(loadSearchData(response.data,animateFliter: true));
          completeFlag-=1;
          if(completeFlag == 0) searchCompleter.complete(searchResultList);
          //存在最后一个加载完之后直接抛出List的风险 因此使用completer

        });
      }
    )
  );

  //return searchResultList;
  return searchCompleter.future;

}

