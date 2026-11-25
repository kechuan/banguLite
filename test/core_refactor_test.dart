import 'dart:async';
import 'dart:typed_data';

import 'package:bangu_lite/catalogs/index/settings_page.dart';
import 'package:bangu_lite/catalogs/network_config_page.dart';
import 'package:bangu_lite/catalogs/subject/bangumi_general_content_page.dart';
import 'package:bangu_lite/hive/hive_registrar.g.dart';
import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/utils/get.dart';
import 'package:bangu_lite/models/informations/local/star_details.dart';
import 'package:bangu_lite/models/informations/subjects/bangumi_details.dart';
import 'package:bangu_lite/models/informations/subjects/topic_details.dart';
import 'package:bangu_lite/models/informations/subjects/topic_info.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/history_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/models/providers/topic_model.dart';
import 'package:bangu_lite/models/state/async_state.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:provider/provider.dart';

class TestIndexModel extends IndexModel {
  @override
  void initModel() {}

  @override
  void updateConfig() {
    notifyListeners();
  }
}


void main() {
  group('AsyncState', () {
    test('reports flags and preserves previousData across loading and error', () {
      const AsyncState<int> idle = AsyncIdle();
      expect(idle.isIdle, isTrue);
      expect(idle.dataOrNull, isNull);

      const AsyncState<int> loading = AsyncLoading(42);
      expect(loading.isLoading, isTrue);
      expect(loading.dataOrNull, 42);

      const AsyncState<int> loaded = AsyncData(99);
      expect(loaded.hasData, isTrue);
      expect(loaded.dataOrNull, 99);

      const AsyncState<int> failed = AsyncError('timeout', 42);
      expect(failed.hasError, isTrue);
      expect(failed.errorMessage, 'timeout');
      expect(failed.dataOrNull, 42);
    });
  });

  group('EventBus', () {
    test('buffers cold-start login route until first listener subscribes', () async {
      const link = 'bangulite://oauth/bgm_login?code=abc';
      bus.emitLoginRoute(link);

      final completer = Completer<String>();
      final sub = bus.onLoginRoute((received) {
        if (!completer.isCompleted) completer.complete(received);
      });

      expect(await completer.future, link);
      await sub.cancel();
    });

    test('dispatches typed AppRouteEvent with optional data', () async {
      final completer = Completer<AppRouteEvent>();
      final sub = bus.onAppRoute((event) {
        if (!completer.isCompleted) completer.complete(event);
      });

      bus.emitAppRoute('https://bgm.tv/subject/123', data: 123);
      final event = await completer.future;
      expect(event.link, 'https://bgm.tv/subject/123');
      expect(event.data, 123);

      await sub.cancel();
    });
  });

  group('getSeasonRange', () {
    test('maps currentTime=true correctly across all 12 months', () {
      expect(getSeasonRange(1, currentTime: true), SeasonType.winter);
      expect(getSeasonRange(3, currentTime: true), SeasonType.winter);
      expect(getSeasonRange(4, currentTime: true), SeasonType.spring);
      expect(getSeasonRange(6, currentTime: true), SeasonType.spring);
      expect(getSeasonRange(7, currentTime: true), SeasonType.summer);
      expect(getSeasonRange(9, currentTime: true), SeasonType.summer);
      expect(getSeasonRange(10, currentTime: true), SeasonType.autumn);
      expect(getSeasonRange(12, currentTime: true), SeasonType.autumn);
    });

    test('maps currentTime=false/null identically to previous behavior', () {
      expect(getSeasonRange(1), SeasonType.winter);
      expect(getSeasonRange(2), SeasonType.spring);
      expect(getSeasonRange(4), SeasonType.spring);
      expect(getSeasonRange(5), SeasonType.summer);
      expect(getSeasonRange(7), SeasonType.summer);
      expect(getSeasonRange(8), SeasonType.autumn);
      expect(getSeasonRange(10), SeasonType.autumn);
      expect(getSeasonRange(11), SeasonType.winter);
      expect(getSeasonRange(12), SeasonType.winter);
    });
  });

  group('HistoryModel pagination', () {
    test('splits small groups into pages without exceeding pageCount', () {
      final pages = buildHistoryPages([10, 15, 12, 8], pageCount: 30);
      expect(pages.length, 2);

      expect(pages[0].startGroupIndex, 0);
      expect(pages[0].endGroupIndex, 1);
      expect(pages[0].startItemIndex, 0);
      expect(pages[0].endItemIndex, 24);
      expect(pages[0].groupCount, 2);

      expect(pages[1].startGroupIndex, 2);
      expect(pages[1].endGroupIndex, 3);
      expect(pages[1].startItemIndex, 25);
      expect(pages[1].endItemIndex, 44);
      expect(pages[1].groupCount, 2);
    });

    test('isolates oversized group on its own page without skipping next group', () {
      final pages = buildHistoryPages([5, 35, 10], pageCount: 30);
      expect(pages.length, 3);

      expect(pages[0].startGroupIndex, 0);
      expect(pages[0].endGroupIndex, 0);
      expect(pages[0].startItemIndex, 0);
      expect(pages[0].endItemIndex, 4);

      expect(pages[1].startGroupIndex, 1);
      expect(pages[1].endGroupIndex, 1);
      expect(pages[1].startItemIndex, 5);
      expect(pages[1].endItemIndex, 39);

      expect(pages[2].startGroupIndex, 2);
      expect(pages[2].endGroupIndex, 2);
      expect(pages[2].startItemIndex, 40);
      expect(pages[2].endItemIndex, 49);
    });

    test('handles empty group list safely', () {
      expect(buildHistoryPages(const[]), isEmpty);
    });
  });

  group('Model equality and typed views', () {
    test('SurfTimelineDetails distinguishes same detailID across different types', () {
      final a = SurfTimelineDetails(detailID: 100)
        ..bangumiSurfTimelineType = BangumiSurfTimelineType.subject;
      final b = SurfTimelineDetails(detailID: 100)
        ..bangumiSurfTimelineType = BangumiSurfTimelineType.group;
      final c = SurfTimelineDetails(detailID: 100)
        ..bangumiSurfTimelineType = BangumiSurfTimelineType.subject;

      expect(a == b, isFalse);
      expect(a == c, isTrue);
      expect({a, b, c}.length, 2);
    });

    test('BangumiDetails exposes strongly typed rating Map and airInfo', () {
      final details = BangumiDetails()
        ..ratingList = {
        'total': 1234,
        'score': 8.4,
        'rank': 55,
        'count': {'1': 10, '2': 20, '10': 300},
      }
        ..informationList = {
        'air_date': '2026-04-01',
        'air_weekday': '星期三',
        'eps': 12,
        'alias': 'Original Title',
      };

      expect(details.rating.total, 1234);
      expect(details.rating.score, 8.4);
      expect(details.rating.rank, 55);
      expect(details.rating.count, {'1': 10, '2': 20, '10': 300});
      expect(details.airInfo.airDate, '2026-04-01');
      expect(details.airInfo.eps, 12);
      expect(details.airInfo.alias, 'Original Title');

      final starred = loadStarDetailsData(
        StarBangumiDetails()
          ..bangumiID = 1
          ..name = 'Test'
          ..score = 7.5
          ..rank = 100,
      );
      expect(starred.ratingList['count'], isA<Map>());
      expect(starred.rating.count, isEmpty);

      expect(convertRankList({}), isEmpty);
      expect(convertRankList({'10': 5, '1': 1}).keys.first, '1');
    });
  });

  group('Network request builders', () {
    test('timelineQuery includes until when provided and serializes mode name', () {
      final query = BangumiQuerys.timelineQuery(
        limit: 15,
        until: 999,
        mode: BangumiTimelineSortType.friends,
      );
      expect(query['limit'], 15);
      expect(query['until'], 999);
      expect(query['mode'], 'friends');

      final defaultQuery = BangumiQuerys.timelineQuery();
      expect(defaultQuery.containsKey('until'), isFalse);
      expect(defaultQuery['mode'], 'all');
    });

    test('subjectCommentData converts null comment to empty string instead of "null"', () {
      final data = BangumiDatas.subjectCommentData(content: null);
      expect(data['comment'], '');
    });
  });

  group('UI regression checks', () {
    setUpAll(() async {
      Hive.registerAdapters();
      MyHive.historySurfDataBase = await Hive.openBox<SurfTimelineDetails>(
        HiveBoxKey.historySurfDataBase,
        bytes: Uint8List(0),
      );
    });

    tearDownAll(() async {
      await MyHive.historySurfDataBase.close();
    });

    testWidgets('SettingsPage renders without ListTile hidden-background error', (tester) async {
      final indexModel = TestIndexModel();
      await tester.pumpWidget(
        ChangeNotifierProvider<IndexModel>.value(
          value: indexModel,
          child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.dark,
            home: const SettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('NetworkConfigPage renders without ListTile error and proxy switches react', (tester) async {
      HttpApiClient.currentProxyAddress = '127.0.0.1:7890';
      final indexModel = TestIndexModel();
      indexModel.userConfig.isProxyMode = false;
      indexModel.userConfig.isImgTagProxy = true;

      await tester.pumpWidget(
        ChangeNotifierProvider<IndexModel>.value(
          value: indexModel,
          child: const MaterialApp(
            home: NetworkConfigPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      final proxySwitchFinder = find.byType(Switch).first;
      expect(tester.widget<Switch>(proxySwitchFinder).value, isFalse);

      await tester.tap(proxySwitchFinder);
      await tester.pumpAndSettle();

      expect(indexModel.userConfig.isProxyMode, isTrue);
      expect(tester.widget<Switch>(proxySwitchFinder).value, isTrue);

      final imgProxySwitchFinder = find.byType(Switch).last;
      expect(tester.widget<Switch>(imgProxySwitchFinder).value, isTrue);

      await tester.tap(imgProxySwitchFinder);
      await tester.pumpAndSettle();

      expect(indexModel.userConfig.isImgTagProxy, isFalse);
      expect(tester.widget<Switch>(imgProxySwitchFinder).value, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('BangumiGeneralContentView renders cleanly in dark mode without select error', (tester) async {
      final indexModel = TestIndexModel();
      indexModel.userConfig.isPureDarkMode = false;
      final accountModel = AccountModel();
      final topicModel = TopicModel(subjectID: 1);
      final topicInfo = TopicInfo(id: 1001, contentTitle: 'Test Topic');
      topicModel.contentDetailData[1001] = TopicDetails(detailID: 1001)
        ..contentTitle = 'Test Topic'
        ..content = 'Body content'
        ..contentRepliedComment = [];

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<IndexModel>.value(value: indexModel),
            ChangeNotifierProvider<AccountModel>.value(value: accountModel),
          ],
          child: MaterialApp(
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.dark,
            home: BangumiGeneralContentView<TopicModel, TopicInfo, TopicDetails>(
              contentModel: topicModel,
              contentInfo: topicInfo,
              createEmptyDetailData: TopicDetails.empty,
              getWebUrl: (_) => 'https://bgm.tv/subject/topic/1001',
              postCommentType: PostCommentType.replyTopic,
              loadContent: (_, {bool isRefresh = false}) async {},
              themeColor: null,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      final scaffoldTheme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(scaffoldTheme.scaffoldBackgroundColor, const Color(0xFF2C2C2C));
    });

    testWidgets('BangumiGeneralContentView resolves fallback and custom themeColor in light mode', (tester) async {
      final indexModel = TestIndexModel();
      indexModel.userConfig.isFollowThemeColor = false;
      final accountModel = AccountModel();
      final topicModel = TopicModel(subjectID: 1);
      final topicInfo = TopicInfo(id: 1002, contentTitle: 'Light Topic');
      topicModel.contentDetailData[1002] = TopicDetails(detailID: 1002)
        ..contentTitle = 'Light Topic'
        ..content = 'Body content'
        ..contentRepliedComment = [];

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<IndexModel>.value(value: indexModel),
            ChangeNotifierProvider<AccountModel>.value(value: accountModel),
          ],
          child: MaterialApp(
            theme: ThemeData.light(),
            themeMode: ThemeMode.light,
            home: BangumiGeneralContentView<TopicModel, TopicInfo, TopicDetails>(
              contentModel: topicModel,
              contentInfo: topicInfo,
              createEmptyDetailData: TopicDetails.empty,
              getWebUrl: (_) => 'https://bgm.tv/subject/topic/1002',
              postCommentType: PostCommentType.replyTopic,
              loadContent: (_, {bool isRefresh = false}) async {},
              themeColor: Colors.teal,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      final scaffoldTheme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(
        scaffoldTheme.scaffoldBackgroundColor,
        convertFineTuneColor(Colors.teal, lumiScaleType: ScaleType.min),
      );
    });

    testWidgets('showRequestSnackBar wraps long error messages without RenderFlex overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: scaffoldMessengerKey,
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      );

      showRequestSnackBar(
        requestStatus: false,
        message: 'The request connection took longer than 0:00:05.000000 and it was aborted. ' * 4,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
