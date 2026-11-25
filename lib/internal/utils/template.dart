import 'dart:async';

import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/bangumi_define/response_status_code.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

Future<T> generalRequest<T>(
  String requestUrl, {
  Map<String, dynamic>? queryParameters,
  Map<String, dynamic>? data,
  Options? options,
  UserContentActionType? userContentActionType,
  required FutureOr<T> Function(Response response) onSuccess,
  required FutureOr<T> Function(String errorMessage) onError,
}) async {
  try {
    final Response<dynamic> response = switch (userContentActionType) {
      null => await HttpApiClient.client.get(
        requestUrl,
        queryParameters: queryParameters,
        options: options ?? BangumiAPIUrls.bangumiAccessOption(),
      ),

      UserContentActionType.post => await HttpApiClient.client.post(
        requestUrl,
        queryParameters: queryParameters,
        data: data,
        options: options ?? BangumiAPIUrls.bangumiAccessOption(),
      ),

      UserContentActionType.delete => await HttpApiClient.client.delete(
        requestUrl,
        queryParameters: queryParameters,
        data: data,
        options: options ?? BangumiAPIUrls.bangumiAccessOption(),
      ),

      UserContentActionType.edit => await HttpApiClient.client.put(
        requestUrl,
        queryParameters: queryParameters,
        data: data,
        options: options ?? BangumiAPIUrls.bangumiAccessOption(),
      ),
    };

    final statusCode = response.statusCode;

    if (statusCode != null && statusCode >= 200 && statusCode < 300) {
      return await onSuccess(response);
    }

    return await onError('$statusCode ${response.statusMessage}');
  }

  on DioException catch (e) {
    debugPrint('[generalRequest - $requestUrl]: request error: $e');

    if (e.response?.statusCode == BangumiResponseStatusCode.unauthorized.code) {
      return await onError('${e.response?.statusCode} 登录会话已过期 请重新登录');
    }

    return await onError('${e.response?.statusCode} ${extractDioException(e)}');
  }

  catch (e) {
    debugPrint('[generalRequest - $requestUrl]: unexpected error: $e');
    return await onError('请求处理异常: $e');
  }
}

//尽可能的从 DioException 中拉取有用的信息
String extractDioException(DioException e) {

  final responseData = e.response?.data;

  if (responseData is Map && responseData["message"] != null) {
    return responseData["message"].toString();
  }

  return e.response?.statusMessage ?? e.message ?? e.type.name;
}
