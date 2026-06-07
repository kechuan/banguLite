import 'dart:io';

import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TimelineFlowModel extends ChangeNotifier {
  TimelineFlowModel();

  final Set<SurfTimelineDetails> timelinesData = {};
  final Set<SurfTimelineDetails> trendTimelinesData = {};

  Future<bool>? requestTimelineFuture;
  Future<bool>? requestTrendTopicTimelineFuture;

  ///相当于监视器 用于替代 Completer锁(防止忘记需要手动置null 才能刷新)
  Future<bool> requestSelectedTimeLineType(
    BangumiSurfTimelineType timelineType, {
      List<Map<String, dynamic>>? queryParameters,
      Function(String message)? fallbackAction,
    }) {
    if (requestTimelineFuture != null) return requestTimelineFuture!;

    late final Future<bool> requestFuture;
    requestFuture = loadSelectedTimeLineType(
      timelineType,
      queryParameters: queryParameters,
      fallbackAction: fallbackAction,
    ).whenComplete(() {
        if (identical(requestTimelineFuture, requestFuture)) {
          requestTimelineFuture = null;
        }
      });

    requestTimelineFuture = requestFuture;
    return requestFuture;
  }

  Future<bool> loadSelectedTimeLineType(
    BangumiSurfTimelineType timelineType, {
      List<Map<String, dynamic>>? queryParameters,
      Function(String message)? fallbackAction,
    }) async {
    if (queryParameters == null) {
      if (timelineType == BangumiSurfTimelineType.all) {
        timelinesData.clear();
      } else {
        timelinesData.removeWhere(
          (currentTimeline) =>
          currentTimeline.bangumiSurfTimelineType == timelineType,
        );
      }
    }

    late Future<List<Response<dynamic>>> Function() timelineFuture;

    switch (timelineType) {
      case BangumiSurfTimelineType.all:
        timelineFuture = () => Future.wait([
          HttpApiClient.client.get(
            BangumiAPIUrls.latestSubjectTopics(),
            queryParameters:
            queryParameters?.elementAtOrNull(0) ?? BangumiQuerys.topicsQuery,
          ),
          HttpApiClient.client.get(
            BangumiAPIUrls.latestGroupTopics(),
            options: BangumiAPIUrls.bangumiAccessOption(),
            queryParameters:
            queryParameters?.elementAtOrNull(1) ?? BangumiQuerys.groupsTopicsQuery(),
          ),
          HttpApiClient.client.get(
            BangumiAPIUrls.timeline(),
            options: BangumiAPIUrls.bangumiAccessOption(),
            queryParameters:
            queryParameters?.elementAtOrNull(2) ?? BangumiQuerys.timelineQuery(),
          ),
        ]);

      case BangumiSurfTimelineType.subject:
        timelineFuture = () async {
          final response = await HttpApiClient.client.get(
            BangumiAPIUrls.latestSubjectTopics(),
            queryParameters:
            queryParameters?.elementAtOrNull(0) ?? BangumiQuerys.topicsQuery,
          );
          return [response];
        };

      case BangumiSurfTimelineType.group:
        timelineFuture = () async {
          final response = await HttpApiClient.client.get(
            BangumiAPIUrls.latestGroupTopics(),
            queryParameters:
            queryParameters?.elementAtOrNull(0) ?? BangumiQuerys.groupsTopicsQuery(),
            options: BangumiAPIUrls.bangumiAccessOption(),
          );
          return [response];
        };

      case BangumiSurfTimelineType.timeline:
        timelineFuture = () async {
          final response = await HttpApiClient.client.get(
            BangumiAPIUrls.timeline(),
            options: BangumiAPIUrls.bangumiAccessOption(),
            queryParameters:
            queryParameters?.elementAtOrNull(0) ?? BangumiQuerys.timelineQuery(),
          );
          return [response];
        };
    }

    try {
      final responseList = await timelineFuture();
      bool hasEmptyResponse = false;

      for (int responseIndex = 0;
      responseIndex < responseList.length;
      responseIndex++) {
        final response = responseList[responseIndex];

        if (response.statusCode != HttpStatus.ok) {
          return false;
        }

        if (response.data.isEmpty) {
          fallbackAction?.call(
            'request ${response.requestOptions.path} failed '
            '${response.statusCode} ${extractResponseMessage(response.data)}',
          );
          hasEmptyResponse = true;
          continue;
        }

        final extractResponseData =
          response.requestOptions.path.contains(BangumiAPIUrls.timeline())
            ? response.data
            : response.data['data'];

        timelinesData.addAll(
          loadSurfTimelineDetails(
            extractResponseData,
            bangumiSurfTimelineType: timelineType == BangumiSurfTimelineType.all
              ? BangumiSurfTimelineType.values[responseIndex + 1]
              : timelineType,
          ),
        );
      }

      if (hasEmptyResponse) {
        return false;
      }

      notifyListeners();
      return true;
    } on DioException catch (e) {
      fallbackAction?.call(
        'request timeline content failed ${e.type}',
      );
      return false;
    }
  }

  Future<bool> requestTrendTopicTimeline({
    Map<String, dynamic>? queryParameters,
    Function(String message)? fallbackAction,
  }) {
    if (requestTrendTopicTimelineFuture != null) {
      return requestTrendTopicTimelineFuture!;
    }

    late final Future<bool> requestFuture;
    requestFuture = loadTrendTopicTimeline(
      queryParameters: queryParameters,
      fallbackAction: fallbackAction,
    ).whenComplete(() {
        if (identical(requestTrendTopicTimelineFuture, requestFuture)) {
          requestTrendTopicTimelineFuture = null;
        }
      });

    requestTrendTopicTimelineFuture = requestFuture;
    return requestFuture;
  }

  Future<bool> loadTrendTopicTimeline({
    Map<String, dynamic>? queryParameters,
    Function(String message)? fallbackAction,
  }) async {
    try {
      final response = await HttpApiClient.client.get(
        BangumiAPIUrls.trendTopics(),
        queryParameters: queryParameters ?? BangumiQuerys.trendTopicQuery,
      );

      if (response.statusCode != HttpStatus.ok) {
        return false;
      }

      if (queryParameters == null) trendTimelinesData.clear();

      trendTimelinesData.addAll(
        loadSurfTimelineDetails(
          response.data['data'],
          bangumiSurfTimelineType: BangumiSurfTimelineType.subject,
        ),
      );

      return true;
    } on DioException catch (e) {
      debugPrint(
        '[TrendTopics] ${e.response?.statusCode} '
        'error:${extractResponseMessage(e.response?.data)}',
      );
      fallbackAction?.call(
        '${e.type} ${extractResponseMessage(e.response?.data)}',
      );
      return false;
    }
  }

  String extractResponseMessage(dynamic data) {
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return data?.toString() ?? '';
  }
}
