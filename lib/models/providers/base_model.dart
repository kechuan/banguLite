import 'dart:async';
import 'dart:io';

import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/template.dart';
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
    I extends ContentInfo,
    D extends ContentDetails?
  > extends ChangeNotifier {

  BaseModel({
    required this.subjectID,
  });

  /// group 将 groupName 作为属性 一己之力将 int 属性更改为 dynamic
  final dynamic subjectID;

  // 内容列表数据 装载着id 用于加载内部数据
  final List<I> contentListData = [];

  // 单个内容的内部数据 id:Details
  final Map<dynamic, D> contentDetailData = {};

  Future<bool> loadSubjectContentList({
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
          if (response.statusCode == HttpStatus.ok) {
            subContentListResponseDataCallback(response);
            completer.complete(true);
          }

          else {
            completer.complete(false);
          }

        });
    }

    on DioException catch(e){
      fallbackAction?.call('内容加载错误: ${extractDioException(e)}');
      return false;
    }

    ///[Claude]: 新增兜底 catch, 防子类解析抛异常导致悬挂
    /// 兜底: convertResponseToList / createEmptyInfoList 等子类实现若抛出(字段类型不符),
    catch(e){
      debugPrint("[loadSubjectContentList] unexpected error: $e");
      fallbackAction?.call('内容解析错误');
      return false;
    }

    return completer.future;
  }

  void subContentListResponseDataCallback(Response subContentListResponseData) {

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

    //空地址跳过
    if (getContentDetailUrl(contentID) == null) return false;
    //已有(占位)数据时跳过
    if (contentDetailData[contentID] != null) {
      if (!isRefresh) {
        debugPrint("content: $contentID already loaded or in processing");
        return false;
      }

    }

    Completer<bool> contentDetailCompleter = Completer();

    //占位符
    contentDetailData[contentID] = createEmptyDetails() as D;

    try {
      await HttpApiClient.client
        .get(
          getContentDetailUrl(contentID)!,
          queryParameters: queryParameters,
          options: BangumiAPIUrls.bangumiAccessOption(),
        ).timeout(
          Duration(seconds: isRefresh == true ? 30 : 10),
          //DEBUG Duration(microseconds: isRefresh == true ? 30 : 10),
          onTimeout: () {
            throw DioException(
              requestOptions: RequestOptions(),
              error: TimeoutException("[Timeout] 加载时间超过10s, 请检查网络通畅状况,或可尝试重新加载"),
            );
          },
        ).then((response) {
          if (response.data != null) {
            contentDetailData[contentID] = convertResponseToDetail(response.data) as D;
            debugPrint("$contentID load content done");
            contentDetailCompleter.complete(true);
            notifyListeners();
          }

          else {

            //错误发生时初始化对应数据
            contentDetailData.remove(contentID);
            contentDetailCompleter.complete(false);
          }

        });
    }

    on DioException catch (e) {
      debugPrint("[GeneralContentReceive] ${e.toString()}");

      //错误发生时初始化对应数据 报错信息不再由Completer处理 交由消息处理
      contentDetailData.remove(contentID);
      fallbackAction?.call('code: ${e.response?.statusCode} ${extractDioException(e)}');
      contentDetailCompleter.complete(false);
    }

    catch (e) {
      debugPrint("[GeneralContentReceive] unexpected error: $e");
      contentDetailData.remove(contentID);
      fallbackAction?.call('内容解析错误');
      if (!contentDetailCompleter.isCompleted) contentDetailCompleter.complete(false);
    }

    return contentDetailCompleter.future;
  }

  // 抽象方法：获取API URL
  String getContentListUrl(dynamic subjectID);

  // 抽象方法：获取详情API URL
  String? getContentDetailUrl(int contentID) => null;

  // 抽象方法：转换响应数据为列表数据
  List<I> convertResponseToList(Response subContentListResponseData);

  D? convertResponseToDetail(Map<String, dynamic> contentResponseData) => null;

  //空数据填充
  List<I> createEmptyInfoList();
  D? createEmptyDetails() => null;


}

