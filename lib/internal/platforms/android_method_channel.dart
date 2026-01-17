import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String banguLiteChannel = "io.flutter.bangulite/channel";

dynamic callAndroidFunction() async {
  final result = await const MethodChannel(banguLiteChannel).invokeMethod("test");
  
  debugPrint("callAndroidFunction:$result");

  return result;
  
}