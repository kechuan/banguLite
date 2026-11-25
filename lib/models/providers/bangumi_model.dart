
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:dio/dio.dart';
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

  Future<void>? loadingDetailsFuture;

  Future<void> loadDetails({bool? isRefresh}) {
    if (subjectID == 0) return Future.value();

    if (bangumiDetails?.summary?.isNotEmpty == true && isRefresh != true) {
      return Future.value();
    }

    if (loadingDetailsFuture != null) return loadingDetailsFuture!;

    late final Future<void> requestFuture;

    requestFuture = requestDetails().whenComplete(() {
      if (identical(loadingDetailsFuture, requestFuture)) {
        loadingDetailsFuture = null;
      }
    });

    loadingDetailsFuture = requestFuture;
    return requestFuture;
  }

  Future<void> requestDetails() async {
    try {
      final detailInformation = await HttpApiClient.client.get("${BangumiAPIUrls.subject}/$subjectID");

      if (detailInformation.data != null) {
        bangumiDetails = loadDetailsData(detailInformation.data, detailFlag: true);
        notifyListeners();
      }
    }

    on DioException catch (e) {
      debugPrint("[BangumiModel] loadDetails error: $e");
    }
  }

  void getThemeColor(Color imageProviderColor,{bool? darkMode}){

    if(!AppThemeColor.values.any((currentTheme) => currentTheme.color == imageProviderColor)){
      imageColor ??= imageProviderColor;
    }

    bangumiThemeColor = convertFineTuneColor(imageProviderColor,darkMode: darkMode);

    debugPrint("[detailPage] ID: $subjectID, Color:$imageProviderColor => $bangumiThemeColor, Lumi:${bangumiThemeColor?.computeLuminance()}");
    notifyListeners();

  }

}