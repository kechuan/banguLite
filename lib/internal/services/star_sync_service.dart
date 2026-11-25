import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/subjects/bangumi_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 负责批量同步收藏番剧的最新评分与排名，将网络请求从纯数据模型 [BangumiDetails] 中剥离。
class StarSyncService {
  const StarSyncService._();

  static Future<Map<int, Map<String, num>>> fetchStarsRating(
    Iterable<int> starsIDList, {
    int batchSize = 5,
  }) async {
    final starIDs = starsIDList.toList();

    if (starIDs.isEmpty) return {};

    final Map<int, Map<String, num>> resultRating = {
      for (final bangumiID in starIDs)
        bangumiID: <String, num>{
          "score": 0.0,
          "rank": 0,
        },
    };

    try {
      // 分批并发，避免收藏过多时触发 Bangumi API 429 限流
      for (int offset = 0; offset < starIDs.length; offset += batchSize) {
        final end = (offset + batchSize).clamp(0, starIDs.length);
        final currentBatch = starIDs.sublist(offset, end);

        await Future.wait(
          currentBatch.map((bangumiID) async {
            final response = await HttpApiClient.client.get(
              "${BangumiAPIUrls.subject}/$bangumiID",
            );

            final details = loadDetailsData(response.data);

            resultRating[bangumiID]!["score"] = details.rating.score;
            resultRating[bangumiID]!["rank"] = details.rating.rank;
          }),
        );
      }

      return resultRating;
    }

    on DioException catch (e) {
      debugPrint("[StarSyncService] Error: ${e.message}");
      return {};
    }
  }
}
