import 'dart:async';
import 'dart:io';

import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/utils/extract.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

class RequestByteInformation{

  String? contentLink;

  int? rangeStart;
  int? rangeEnd;
  int? contentLength;

  String? fileName = "pictureName";
  String? contentType;

  String? statusMessage;

  void printInformation() => debugPrint("contentLength:$contentLength fileName:$fileName contentType:$contentType");

}

int? contentRangeByteParse(String? bytesRangeValue) {
  // "bytes 0-7/36" => "0-7/36" => 36
  if (bytesRangeValue == null || !bytesRangeValue.contains('/')) return null;

  final totalSegment = bytesRangeValue.split('/').last.trim();
  return int.tryParse(totalSegment);
}

bool isValidImageResponse(Response response) {
  final contentType = response.headers.value(HttpHeaders.contentTypeHeader)?.toLowerCase() ?? '';

  if (contentType.isEmpty) return true;

  if (
    contentType.startsWith('image/') ||
    contentType.startsWith('application/octet-stream')
  ) {
    return true;
  }

  return false;
}

class ImageHeaderCheckResult {
  const ImageHeaderCheckResult({
    this.information,
    this.errorMessage,
    this.shouldTryRangeGet = false,
  });

  final RequestByteInformation? information;
  final String? errorMessage;
  final bool shouldTryRangeGet;
}

Future<ImageHeaderCheckResult> checkImageHeader(
  String targetUrl, {
  required Duration timeout,
  bool useRangeGet = false,
}) async {
  final headers = Map<String, dynamic>.from(HttpApiClient.browserHeader);

  if (useRangeGet) {
    headers[HttpHeaders.rangeHeader] = 'bytes=0-0';
  }

  try {
    final Response response = useRangeGet
      ? await HttpApiClient.client
        .get<ResponseBody>(
          targetUrl,
          options: Options(
            headers: headers,
            responseType: ResponseType.stream,
          ),
        )
        .timeout(timeout)
      : await HttpApiClient.client
        .head(
          targetUrl,
          options: Options(headers: headers),
        )
        .timeout(timeout);

    if (useRangeGet && response.data is ResponseBody) {
      await (response.data as ResponseBody).stream.listen(null).cancel();
    }

    if (!isValidImageResponse(response)) {
      debugPrint("[Image Check Non-Image] $targetUrl (${response.headers.value(HttpHeaders.contentTypeHeader)})");
      return ImageHeaderCheckResult(
        errorMessage: "链接返回内容不是图片",
        shouldTryRangeGet: !useRangeGet,
      );
    }

    debugPrint("[Image Check Succ] ${useRangeGet ? 'GET(Range)' : 'HEAD'} $targetUrl");

    return ImageHeaderCheckResult(
      information: extractPictureRequest(response, targetUrl),
    );
  }

  on DioException catch (e) {
    switch (e.type) {
      case DioExceptionType.badResponse: {
        debugPrint("[Image Check BadResponse] $targetUrl (${e.response?.statusCode})");
        return ImageHeaderCheckResult(
          errorMessage: "图片不存在或拒绝访问",
          shouldTryRangeGet: !useRangeGet,
        );
      }

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout: {
        debugPrint("[Image Check Timeout] $targetUrl");
        return const ImageHeaderCheckResult(
          errorMessage: "请求超时",
          shouldTryRangeGet: false,
        );
      }

      default: {
        debugPrint("[Image Check Error] $targetUrl ${e.message}");
        return const ImageHeaderCheckResult(
          errorMessage: "图片请求失败",
          shouldTryRangeGet: false,
        );
      }
    }
  }

  on TimeoutException {
    debugPrint("[Image Check Timeout] $targetUrl");
    return const ImageHeaderCheckResult(
      errorMessage: "请求超时",
      shouldTryRangeGet: false,
    );
  }

  catch (e) {
    debugPrint("[Image Check Unexpected] $targetUrl $e");
    return const ImageHeaderCheckResult(
      errorMessage: "图片请求失败",
      shouldTryRangeGet: false,
    );
  }
}

Future<RequestByteInformation> loadByteInformation(String imageUrl) async {
  String lastErrorMessage = "图片无法加载";

  final directHeadResult = await checkImageHeader(
    imageUrl,
    timeout: const Duration(seconds: 3),
  );

  if (directHeadResult.information != null) {
    return directHeadResult.information!;
  }

  if (directHeadResult.errorMessage != null) {
    lastErrorMessage = directHeadResult.errorMessage!;
  }

  if (directHeadResult.shouldTryRangeGet) {
    debugPrint("[Head Request Failed => Range GET] $imageUrl");

    final directRangeResult = await checkImageHeader(
      imageUrl,
      timeout: const Duration(seconds: 3),
      useRangeGet: true,
    );

    if (directRangeResult.information != null) {
      return directRangeResult.information!;
    }

    if (directRangeResult.errorMessage != null) {
      lastErrorMessage = directRangeResult.errorMessage!;
    }
  }

  final wsrvImageUrl = convertWsrvImageUri(imageUrl);
  debugPrint("[Direct Failed => wsrv.nl] $wsrvImageUrl");

  final wsrvResult = await checkImageHeader(
    wsrvImageUrl,
    timeout: const Duration(seconds: 4),
  );

  if (wsrvResult.information != null) {
    return wsrvResult.information!;
  }

  if (wsrvResult.errorMessage != null) {
    lastErrorMessage = wsrvResult.errorMessage!;
  }

  final wordPressImageUrl = convertProxyImageUri(imageUrl);
  debugPrint("[wsrv.nl Failed => WordPress] $wordPressImageUrl");

  final wordPressResult = await checkImageHeader(
    wordPressImageUrl,
    timeout: const Duration(seconds: 4),
  );

  if (wordPressResult.information != null) {
    return wordPressResult.information!;
  }

  if (wordPressResult.errorMessage != null) {
    lastErrorMessage = wordPressResult.errorMessage!;
  }

  return RequestByteInformation()..statusMessage = lastErrorMessage;
}
