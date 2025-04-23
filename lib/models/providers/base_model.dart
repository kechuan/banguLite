import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/base_details.dart';
import 'package:bangu_lite/models/base_info.dart';
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
  final Map<int, D> contentDetailData = {};

  Future<void> loadSubjectSubContentList({
    Map<String, dynamic> queryParameters = const {},
    bool isReloaded = false
  }) async {

    if (subjectID == 0) return;

    if (isReloaded) {
      contentListData.clear();
      contentDetailData.clear();
    }

    if (contentListData.isNotEmpty && queryParameters.isEmpty) {
      debugPrint("contentList is already loaded");
      return;
    }

    try {
      await HttpApiClient.client.get(
        getContentListUrl(subjectID),
        queryParameters: queryParameters
      ).then((response) {
        subContentListResponseDataCallback(response);
      });

    } on DioException catch (e) {
      debugPrint("Request Error: ${e.toString()}");
    }
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
  Future<dynamic> loadContentDetail(int contentID,{Map<String, dynamic>? queryParameters}) async {

    if(getContentDetailUrl(contentID) == null) return;

    if (contentDetailData[contentID] != null) {
      debugPrint("content: $contentID already loaded or in processing");
      return;
    }


    //占位符
    contentDetailData[contentID] = createEmptyDetails() as D;

    try {
      await HttpApiClient.client.get(
        getContentDetailUrl(contentID)!,
        queryParameters: queryParameters
      ).then((response) {
        if (response.data != null) {
          contentDetailData[contentID] = convertResponseToDetail(response.data) as D;
          debugPrint("$contentID load content done");
          notifyListeners();
        }
      });
    } on DioException catch (e) {
      debugPrint("Request Error: ${e.toString()}");
    }
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

