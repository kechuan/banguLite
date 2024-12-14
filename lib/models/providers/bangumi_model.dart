
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/bangumi_details.dart';


class BangumiModel extends ChangeNotifier {
  BangumiModel();

  //int _bangumiID = 0;
  //int get bangumiID => _bangumiID;

  int? bangumiID = 0;

  BangumiDetails? bangumiDetails;

  Color? bangumiThemeColor;
  Color? imageColor;
  //Color? bangumiDarkThemeColor;

  Future<void> loadDetails(int? newID,{bool? refresh}) async {

    if(newID==null) return;

    if(newID!=bangumiID || refresh == true){
      bangumiID = newID;

      final detailInformation = await HttpApiClient.client.get("${BangumiAPIUrls.subject}/$bangumiID");

      if(detailInformation.data!=null){
        bangumiDetails = loadDetailsData(detailInformation);
      }

    }

    WidgetsBinding.instance.addPostFrameCallback((timestamp){
      notifyListeners();
    });


  }

  void getThemeColor(Color imageProviderColor,{bool? darkMode}){
    
    if(bangumiThemeColor!=null) return;

    Color resultColor = imageProviderColor;
    imageColor = imageProviderColor;


    if(darkMode==true){
      if(resultColor.computeLuminance()>0.5){
        HSLColor hslColor = HSLColor.fromColor(resultColor); //亮度过低 转换HSL色度
        double newLightness = (hslColor.lightness - 0.3).clamp(0.2, 0.5); // 确保不超过 1.0
        double newSaturation = (hslColor.saturation - 0.1).clamp(0.2, 0.4); //偏透明色
        HSLColor newHSLColor = hslColor.withLightness(newLightness).withSaturation(newSaturation);

        resultColor = newHSLColor.toColor();

        //bangumiDarkThemeColor = resultColor;

      }
    }

    else{
      if(resultColor.computeLuminance()<0.5){
        HSLColor hslColor = HSLColor.fromColor(resultColor); //亮度过低 转换HSL色度
        double newLightness = (hslColor.lightness + 0.3).clamp(0.8, 1.0); // 确保不超过 1.0

        double newSaturation = (hslColor.saturation - 0.1).clamp(0.2, 0.4); //偏透明色
        HSLColor newHSLColor = hslColor.withLightness(newLightness).withSaturation(newSaturation);

        resultColor = newHSLColor.toColor();

        

      }
    }

    bangumiThemeColor = resultColor;


    debugPrint("[detailPage] ID: $bangumiID, Color:$imageProviderColor => $resultColor, Lumi:${resultColor.computeLuminance()}");
    notifyListeners();


  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

}