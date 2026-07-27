import 'dart:async';

import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/bangumi_define/response_status_code.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

Future<dynamic> generalRequest(
  String requestUrl,
  {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    Options? options,
    UserContentActionType? userContentActionType,

    /// 依赖注入环节

    /// CompleteAction
    Function(Response response, Completer<dynamic> completer)? generalCompleteLoadAction,

    /// FailedAction
    Function(String response, Completer<dynamic> completer)? generalFallbackAction,

  }

) async {
  Completer<dynamic> generalCompleter = Completer<dynamic>();

  late Future<Response<dynamic>> Function() contentFuture;

  switch (userContentActionType) {

    case null:{
      contentFuture = () => HttpApiClient.client.get(
        requestUrl,
        data: queryParameters,
        options: options ?? BangumiAPIUrls.bangumiAccessOption(),
      );
    }

    case UserContentActionType.post:{
      contentFuture = () => HttpApiClient.client.post(
        requestUrl,
        queryParameters: queryParameters,
        data: data,
        options: options ?? BangumiAPIUrls.bangumiAccessOption(),
      );
    }

    case UserContentActionType.delete:{
      contentFuture = () => HttpApiClient.client.delete(
        requestUrl,
        data: queryParameters,
        options: options ?? BangumiAPIUrls.bangumiAccessOption(),
      );
    }

    case UserContentActionType.edit:{
      contentFuture = () => HttpApiClient.client.put(
        requestUrl,
        data: queryParameters,
        options: options ?? BangumiAPIUrls.bangumiAccessOption(),
      );
    }

  }

  /// 由外部控制 completer 的返回数据 与 时机
  try{
    //try 无法处理 异步的错误
    await contentFuture().then((response) {

      final statusCode = response.statusCode;

      if (statusCode != null && statusCode >= 200 && statusCode < 300) {
        //若一切正常 此处应视作 .complete 并结束这段 completer.future
        generalCompleteLoadAction?.call(response, generalCompleter);
      }

      else {
        generalFallbackAction?.call('$statusCode ${response.statusMessage}', generalCompleter);
      }

    });

  }

  on DioException catch (e){
    debugPrint('[generalRequest - $requestUrl]: request error: $e');

    if (e.response?.statusCode == BangumiResponseStatusCode.unauthorized.code) {
      generalFallbackAction?.call('${e.response?.statusCode} 登录会话已过期 请重新登录', generalCompleter);
    }

    else {
      generalFallbackAction?.call('${e.response?.statusCode} ${extractDioException(e)}', generalCompleter);
    }

  }

  catch (e){
    debugPrint('[generalRequest - $requestUrl]: unexpected error: $e');
    generalFallbackAction?.call('请求处理异常: $e', generalCompleter);
  }

  return generalCompleter.future;
}

//尽可能的从 DioException 中拉取有用的信息
String extractDioException(DioException e) {

  final responseData = e.response?.data;

  if (responseData is Map && responseData["message"] != null) {
    return responseData["message"].toString();
  }

  return e.response?.statusMessage ?? e.message ?? e.type.name;
}
