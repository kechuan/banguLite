import 'dart:async';

import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
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
    Function(Response response,Completer<dynamic> completer)? generalCompleteLoadAction,

    /// FailedAction
    Function(String response,Completer<dynamic> completer)? generalFallbackAction,

  }

) async {
  Completer<dynamic> generalCompleter = Completer<dynamic>();

  late Future<Response<dynamic>> Function() contentFuture;

  switch(userContentActionType) {

    case null:{
      contentFuture = () => HttpApiClient.client.get(
        requestUrl,
        data: queryParameters,
        options: options ?? BangumiAPIUrls.bangumiAccessOption,
      );
    }
    
    case UserContentActionType.post:{
      contentFuture = () => HttpApiClient.client.post(
        requestUrl,
        queryParameters: queryParameters,
        data: data,
        options: options ?? BangumiAPIUrls.bangumiAccessOption,
      );
    }

    case UserContentActionType.delete:{
      contentFuture = () => HttpApiClient.client.delete(
        requestUrl,
        data: queryParameters,
        options: options ?? BangumiAPIUrls.bangumiAccessOption,
      );
    }

    case UserContentActionType.edit:{
      contentFuture = () => HttpApiClient.client.put(
        requestUrl,
        data: queryParameters,
        options: options ?? BangumiAPIUrls.bangumiAccessOption,
      );
    }

  }

  /// 由外部控制 completer 的返回数据 与 时机
  try{
    contentFuture().then((response){
      if(response.statusCode == 200){
        generalCompleteLoadAction?.call(response,generalCompleter);
      }
    });

  }

  on DioException catch (e){
    debugPrint('[generalRequest - ${userContentActionType?.name}]: request error: $e');
    generalFallbackAction?.call('${e.response?.statusCode} ${e.response?.data["message"]}',generalCompleter);
  }

  
  return generalCompleter.future;
}
