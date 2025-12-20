
import 'dart:async';

import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/subjects/bangumi_details.dart';


class BangumiModel extends ChangeNotifier {
  BangumiModel({
    required this.subjectID,
    this.bangumiDetails
  });

  int subjectID = 0;

  BangumiDetails? bangumiDetails;

  Color? bangumiThemeColor;
  Color? imageColor;

  Completer? getDetailsCompleter;

  Future<void> loadDetails({bool? isRefresh}) async {

    if(subjectID==0) return;
    if(bangumiDetails?.summary?.isNotEmpty == true && isRefresh != true) return;
    if(getDetailsCompleter!=null) return getDetailsCompleter!.future;
    
    Completer loadCompleter = Completer();
    getDetailsCompleter = loadCompleter;

    final detailInformation = await HttpApiClient.client.get("${BangumiAPIUrls.subject}/$subjectID");

    if(detailInformation.data!=null){
      bangumiDetails = loadDetailsData(detailInformation.data,detailFlag:true);
    }

    WidgetsBinding.instance.addPostFrameCallback((timestamp){
      loadCompleter.complete();
      notifyListeners();
    });

    return loadCompleter.future;
  }

  void getThemeColor(Color imageProviderColor,{bool? darkMode}){

    if(!AppThemeColor.values.any((currentTheme) => currentTheme.color == imageProviderColor)){
      imageColor ??= imageProviderColor;
    }

    bangumiThemeColor = convertFineTuneColor(imageProviderColor,darkMode: darkMode);

    debugPrint("[detailPage] ID: $subjectID, Color:$imageProviderColor => $bangumiThemeColor, Lumi:${bangumiThemeColor?.computeLuminance()}");
    notifyListeners();

  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

}