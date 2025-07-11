import 'dart:async';

import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/subjects/base_details.dart';
import 'package:bangu_lite/models/informations/subjects/base_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// 抽象的内容模型基类
/// [I] => Info / 入口
/// [D] => Detail / 详情
/// 有些数据 并不存在后续的内容 因此 [D] 允许为 nullable
abstract class BaseModel
<
  I extends BaseInfo,
  D extends BaseDetails?
> extends ChangeNotifier {

  BaseModel({
    required this.subjectID,
  });

  final dynamic subjectID;
  final List<I> contentListData = [];

  /// group 将 groupName 作为属性 一己之力将 int 属性更改为 dynamic
  final Map<dynamic, D> contentDetailData = {};

  Future<bool> loadSubjectSubContentList({
    Map<String, dynamic> queryParameters = const {},
    bool isReloaded = false,
    Function(String)? fallbackAction
  }) async {

    Completer<bool> completer = Completer();

    if (subjectID == 0) return false;

    if (isReloaded) {
      contentListData.clear();
      contentDetailData.clear();
    }

    if (contentListData.isNotEmpty && queryParameters.isEmpty) {
      debugPrint("contentList is already loaded");
      return false;
    }

    try{
      await HttpApiClient.client.get(
        getContentListUrl(subjectID),
        queryParameters: queryParameters,
        options: BangumiAPIUrls.bangumiAccessOption(),
      ).then((response) {
        if(response.statusCode == 200){
          subContentListResponseDataCallback(response);
          completer.complete(true);
        }

        else{
          completer.complete(false);
        }
        
      });


    }

    on DioException catch(e){
      fallbackAction?.call('${e.response?.statusCode} ${e.response?.statusMessage}');
      return false;
    }

    return completer.future;
  }

  void subContentListResponseDataCallback(Response subContentListResponseData){

    if (subContentListResponseData.data != null) {
      if ((subContentListResponseData.data["total"] ?? 0) == 0) {
        contentListData.addAll(createEmptyInfoList());
      } 
      
      else {

        contentListData.addAll(convertResponseToList(subContentListResponseData));
      }
      notifyListeners();
    }
  }
    
  // 抽象方法：加载特定内容详情
  Future<bool> loadContentDetail(
    int contentID,
    {
      Map<String, dynamic>? queryParameters,
      bool isRefresh = false,
      Function(String)? fallbackAction
    }
  ) async {

    Completer<bool> contentDetailCompleter = Completer();
 
    if(getContentDetailUrl(contentID) == null) return false;

    if (contentDetailData[contentID] != null) {
      if(!isRefresh){
        debugPrint("content: $contentID already loaded or in processing");
        return false;
      }
      
    }

    //占位符
    contentDetailData[contentID] = createEmptyDetails() as D;

    try {
      await HttpApiClient.client
      .get(
        getContentDetailUrl(contentID)!,
        queryParameters: queryParameters,
        options: BangumiAPIUrls.bangumiAccessOption(),
      ).timeout(
        Duration(seconds: isRefresh == true ? 15 : 5),
        onTimeout:() {
          throw DioException(
            requestOptions:RequestOptions(),
            error: TimeoutException("[Timeout] 加载时间超过5s, 请检查网络通畅状况,或可尝试重新加载(15s宽限)"),
          );
        },
      ).then((response) {
        if (response.data != null) {
          contentDetailData[contentID] = convertResponseToDetail(response.data) as D;
          debugPrint("$contentID load content done");
          contentDetailCompleter.complete(true);
          notifyListeners();
        }
      });
    } 
    
    on DioException catch (e) {
      debugPrint("[GeneralContentReceive] ${e.toString()}");
      
      fallbackAction?.call('code: ${e.response?.statusCode} ${e.error}');
      contentDetailCompleter.completeError(e.error!);
    }

    return contentDetailCompleter.future;
  }

  // 抽象方法：获取API URL
  String getContentListUrl(dynamic subjectID);
  
  // 抽象方法：获取详情API URL
  String? getContentDetailUrl(int contentID) => null;

  // 抽象方法：转换响应数据为列表数据
  List<I> convertResponseToList(Response subContentListResponseData);

  D? convertResponseToDetail(Map<String,dynamic> contentResponseData) => null;

  //空数据填充 I为空表示 D为占位符表示
  List<I> createEmptyInfoList();
  D? createEmptyDetails() => null;


}

