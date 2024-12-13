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

  void printInformation() => debugPrint("contentLength:$contentLength fileName:$fileName contentType:$contentType");

}
  
int byteParse(String bytesRangeValue){
  // "bytes 0-7/36" => "0-7/36" => "36"
  return int.parse(bytesRangeValue.split(" ")[1].split("/")[1]);
}

Future<RequestByteInformation> loadByteInformation(String imageUri) async {
  RequestByteInformation pictureRequestInformation = RequestByteInformation();

  await HttpApiClient.client
    .get(
      imageUri,
      options: Options(
        headers: {'range':'bytes=0-1'},
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      )
    ).then((response){

      if(response.data!=null){
          pictureRequestInformation
            ..fileName = response.headers.value("name")
            ..contentType = response.headers.value(HttpHeaders.contentTypeHeader)
            ..contentLength = byteParse(response.headers.value(HttpHeaders.contentRangeHeader) ?? "0");
        
        pictureRequestInformation.printInformation();
      }

    }
    ).catchError((error){
      switch (error.type) {
        case DioExceptionType.badResponse: {debugPrint('$imageUri 不存在'); break;}
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          debugPrint('$imageUri 超时');
          break;
      }
    });

  return pictureRequestInformation;
}