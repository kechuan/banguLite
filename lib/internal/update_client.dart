import 'dart:async';

import 'package:bangu_lite/internal/convert.dart';
import 'package:flutter/material.dart';

class UpdateClient {

  UpdateClient._();
  static UpdateClient updateClient = UpdateClient._();
  factory UpdateClient.getInstance() => updateClient;

  Timer? speedTimer;
  int totalSize = 0;
  double recordProgress = 0;
  String speedValue = "0.00MB";

  final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0);
 

  void startDownload(){
    speedTimer = Timer.periodic(
      const Duration(milliseconds: 500), 
      (_){
        speedValue = convertTypeSize(((progressNotifier.value - recordProgress)*totalSize).toInt());
        recordProgress = progressNotifier.value;
      }
    );
  }

  void finishDownload(){
    speedTimer?.cancel();
    totalSize = 0;
    recordProgress = 0;
    speedValue = "0.00MB";
    progressNotifier.value = 0;

  }

}