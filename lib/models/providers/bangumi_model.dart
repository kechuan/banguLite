
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/bangumi_details.dart';


class BangumiModel extends ChangeNotifier {
  BangumiModel();

  int _bangumiID = 0;

  int get bangumiID => _bangumiID;

  BangumiDetails? bangumiDetails;

  final Set<int> routesIDList = {}; //用于记录存放当前路由支上有多少个ID。

  Future<BangumiDetails?> loadDetails(int newID,{bool? refresh}) async {

    //BangumiDetails? bangumiDetails;

    if(newID!=bangumiID || refresh == true){
      _bangumiID = newID;

      final detailInformation = await HttpApiClient.client.get("${BangumiUrls.subject}/$bangumiID");

      if(detailInformation.data!=null){
        bangumiDetails = loadDetailsData(detailInformation);
      }

    }

    WidgetsBinding.instance.addPostFrameCallback((timestamp){
      notifyListeners();
    });

    return bangumiDetails;

  }


  @override
  void notifyListeners() {
    super.notifyListeners();
  }

}