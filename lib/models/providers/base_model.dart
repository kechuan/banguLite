import 'dart:async';
import 'dart:io';

import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/template.dart';
import 'package:bangu_lite/models/informations/subjects/base_details.dart';
import 'package:bangu_lite/models/informations/subjects/base_info.dart';
import 'package:bangu_lite/models/state/async_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// 抽象的内容模型基类
/// [K] => 所属主题的标识类型（通常为 int subjectID，小组场景为 String? groupName）
/// [I] => Info / 入口
/// [D] => Detail / 详情
/// 有些数据 并不存在后续的内容 因此 [D] 允许为 nullable
/// 
/// [BaseModel] 大致针对 generalContentPage 的各种获取对应 数据Info/Detail 的一个接口
abstract class BaseModel<
    K,
    I extends ContentInfo,
    D extends ContentDetails?
  > extends ChangeNotifier {

  BaseModel({
    required this.subjectID,
  });

  ///为什么是泛型 因为凭借Group请求名称而非id的一己之力 从int转变为了dynamic/template
  final K subjectID;

  final List<I> contentListData = [];

  /// 从单个[I.id]内容所对应的D
  final Map<int, D> contentDetailData = {};

  /// 显式列表加载状态，方便新老页面逐步脱离哨兵判断
  AsyncState<List<I>> infoListState = const AsyncIdle();

  /// 显式详情加载状态（按 contentID 索引）
  final Map<int, AsyncState<D>> detailStates = {};

  AsyncState<D> detailStateOf(int contentID) => detailStates[contentID] ?? const AsyncIdle();

  bool isDetailLoading(int? contentID) {
    if (contentID == null) return true;

    final state = detailStates[contentID];
    if (state != null) return state.isLoading;

    final detail = contentDetailData[contentID];
    return detail == null || detail.detailID == 0;
  }

  Future<bool> loadSubjectContentList({
    Map<String, dynamic> queryParameters = const {},
    bool isReloaded = false,
    Function(String)? fallbackAction
  }) async {

    if (subjectID == 0 || subjectID == null) return false;

    if (isReloaded) {
      contentListData.clear();
      contentDetailData.clear();
      detailStates.clear();
    }

    if (contentListData.isNotEmpty && queryParameters.isEmpty) {
      debugPrint("contentList is already loaded");
      return false;
    }

    infoListState = AsyncLoading(
      contentListData.isEmpty ? null : List<I>.unmodifiable(contentListData),
    );

    try {
      final response = await HttpApiClient.client.get(
        getContentListUrl(subjectID),
        queryParameters: queryParameters,
        options: BangumiAPIUrls.bangumiAccessOption(),
      );

      if (response.statusCode == HttpStatus.ok) {
        subContentListResponseDataCallback(response);
        infoListState = AsyncData(List<I>.unmodifiable(contentListData));
        return true;
      }

      infoListState = AsyncError('HTTP ${response.statusCode}', infoListState.dataOrNull);
      return false;
    }

    on DioException catch(e){
      final message = '内容加载错误: ${extractDioException(e)}';
      infoListState = AsyncError(message, infoListState.dataOrNull);
      fallbackAction?.call(message);
      return false;
    }

    ///[Claude]: 新增兜底 catch, 防子类解析抛异常导致悬挂
    /// 兜底: convertResponseToList / createEmptyInfoList 等子类实现若抛出(字段类型不符),
    catch(e){
      debugPrint("[loadSubjectContentList] unexpected error: $e");
      infoListState = AsyncError('内容解析错误', infoListState.dataOrNull);
      fallbackAction?.call('内容解析错误');
      return false;
    }
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

    final detailUrl = getContentDetailUrl(contentID);
    if (detailUrl == null) return false;

    final previousDetail = contentDetailData[contentID];
    //已有(占位)数据时跳过
    if ((previousDetail != null || detailStateOf(contentID).isLoading) && !isRefresh) {
      debugPrint("content: $contentID already loaded or in processing");
      return false;
    }

    detailStates[contentID] = AsyncLoading<D>(previousDetail);

    //首次加载时写入占位符，刷新时保留旧数据防止闪烁和失败丢数据
    if (!isRefresh) {
      contentDetailData[contentID] = createEmptyDetails() as D;
    }

    final int timeoutSeconds = isRefresh ? 30 : 10;

    try {
      final response = await HttpApiClient.client
        .get(
          detailUrl,
          queryParameters: queryParameters,
          options: BangumiAPIUrls.bangumiAccessOption(),
        ).timeout(
          Duration(seconds: timeoutSeconds),
          onTimeout: () {
            throw DioException(
              requestOptions: RequestOptions(path: detailUrl),
              error: TimeoutException("[Timeout] 加载时间超过${timeoutSeconds}s, 请检查网络通畅状况,或可尝试重新加载"),
            );
          },
        );

      if (response.data != null) {
        final parsed = convertResponseToDetail(response.data) as D;

        contentDetailData[contentID] = parsed;
        detailStates[contentID] = AsyncData<D>(parsed);
        debugPrint("$contentID load content done");

        notifyListeners();
        return true;
      }

      //错误发生时恢复旧数据或移除占位
      if (previousDetail != null) {
        contentDetailData[contentID] = previousDetail;
      } 

      else {
        contentDetailData.remove(contentID);
      }

      detailStates[contentID] = AsyncError<D>('空响应数据', previousDetail);

      return false;
    }

    on DioException catch (e) {
      debugPrint("[GeneralContentReceive] ${e.toString()}");

      if (previousDetail != null) {
        contentDetailData[contentID] = previousDetail;
      } 

      else {
        contentDetailData.remove(contentID);
      }

      final message = 'code: ${e.response?.statusCode} ${extractDioException(e)}';
      detailStates[contentID] = AsyncError<D>(message, previousDetail);
      fallbackAction?.call(message);

      return false;
    }

    catch (e) {
      debugPrint("[GeneralContentReceive] unexpected error: $e");

      if (previousDetail != null) {
        contentDetailData[contentID] = previousDetail;
      }

      else {
        contentDetailData.remove(contentID);
      }

      detailStates[contentID] = AsyncError<D>('内容解析错误', previousDetail);
      fallbackAction?.call('内容解析错误');

      return false;
    }
  }

  // 抽象方法：获取API URL
  String getContentListUrl(K subjectID);

  // 抽象方法：获取详情API URL
  String? getContentDetailUrl(int contentID) => null;

  // 抽象方法：转换响应数据为列表数据
  List<I> convertResponseToList(Response subContentListResponseData);

  D? convertResponseToDetail(Map<String, dynamic> contentResponseData) => null;

  //空数据填充
  List<I> createEmptyInfoList();
  D? createEmptyDetails() => null;


}

