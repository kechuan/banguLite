
import 'dart:async';

import 'package:bangu_lite/internal/const.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/bangumi_details.dart';


class BangumiModel extends ChangeNotifier {
  BangumiModel({
    required this.subjectID
  });

  int subjectID = 0;

  BangumiDetails? bangumiDetails;

  Color? bangumiThemeColor;
  Color? imageColor;

  Future<void> loadDetails({bool? refresh}) async {

    if(subjectID==0) return;

    if(bangumiDetails != null && refresh != true) return;

    final detailInformation = await HttpApiClient.client.get("${BangumiAPIUrls.subject}/$subjectID");

    if(detailInformation.data!=null){
      bangumiDetails = loadDetailsData(detailInformation.data,detailFlag:true);
    }

    WidgetsBinding.instance.addPostFrameCallback((timestamp){
      notifyListeners();
    });
  }

  void getThemeColor(Color imageProviderColor,{bool? darkMode}){

    bangumiThemeColor = null;
    
    if(!BangumiThemeColor.values.any((currentTheme) => currentTheme.color == imageProviderColor)){
      imageColor ??= imageProviderColor;
    }
    
    Color resultColor = imageProviderColor;

    if(darkMode==true){
      if(resultColor.computeLuminance()>0.5){
        HSLColor hslColor = HSLColor.fromColor(resultColor); //亮度过低 转换HSL色度
        double newLightness = (hslColor.lightness - 0.3).clamp(0.2, 0.5); // 确保不超过 1.0
        double newSaturation = (hslColor.saturation - 0.1).clamp(0.2, 0.4); //偏透明色
        HSLColor newHSLColor = hslColor.withLightness(newLightness).withSaturation(newSaturation);

        resultColor = newHSLColor.toColor();

      }
    }

    else{
      if(resultColor.computeLuminance()<0.5){
        HSLColor hslColor = HSLColor.fromColor(resultColor);
        double newLightness = (hslColor.lightness + 0.3).clamp(0.8, 1.0);

        double newSaturation = (hslColor.saturation - 0.1).clamp(0.2, 0.4);
        HSLColor newHSLColor = hslColor.withLightness(newLightness).withSaturation(newSaturation);

        resultColor = newHSLColor.toColor();

      }
    }

    bangumiThemeColor = resultColor;

    debugPrint("[detailPage] ID: $subjectID, Color:$imageProviderColor => $resultColor, Lumi:${resultColor.computeLuminance()}");
    notifyListeners();


  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

}