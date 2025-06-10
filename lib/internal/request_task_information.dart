import 'dart:io';

import 'package:bangu_lite/internal/request_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

class RequestByteInformation{
  
  int? rangeStart;
  int? rangeEnd;
  int? contentLength;

  String? fileName = "pictureName";
  String? contentType;

  
  String? statusMessage;

  void printInformation() => debugPrint("contentLength:$contentLength fileName:$fileName contentType:$contentType");

}
  
int byteParse(String bytesRangeValue){
  // "bytes 0-7/36" => "0-7/36" => "36"
  return int.parse(bytesRangeValue.split(" ")[1].split("/")[1]);
}

Future<RequestByteInformation> loadByteInformation(String imageUrl) async {
  RequestByteInformation pictureRequestInformation = RequestByteInformation();

  await HttpApiClient.client.get(
    imageUrl,
    options: Options(
      headers: {'range':'bytes=0-1'},
    )).timeout(const Duration(seconds: 5)).then((response){

      if(response.data!=null){
          pictureRequestInformation
            ..fileName = response.headers.value("name")
            ..contentType = response.headers.value(HttpHeaders.contentTypeHeader)
            ..contentLength = byteParse(response.headers.value(HttpHeaders.contentRangeHeader) ?? "0")
            ..statusMessage = response.statusMessage
          ;

      }

    }
    ).catchError((error){
      switch (error.type) {
        case DioExceptionType.badResponse: {
          debugPrint('$imageUrl 图片不存在或拒绝访问'); 
          pictureRequestInformation.statusMessage = "图片不存在或拒绝访问";
          break;
        }
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout: {
          debugPrint('$imageUrl 超时');
          pictureRequestInformation.statusMessage = "请求超时";
          break;
        }
      }
    });

  return pictureRequestInformation;
}