import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bangu_lite/catalogs/index/settings_page.dart';
import 'package:bangu_lite/catalogs/network_config_page.dart';
import 'package:bangu_lite/catalogs/subject/bangumi_general_content_page.dart';
import 'package:bangu_lite/hive/hive_registrar.g.dart';
import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/bangumi_mirror.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/request_task_information.dart';
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

class DirectHttpOverrides extends HttpOverrides {}


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

    test('toGithubMirrorUrl prefixes GitHub release API and asset URLs with gh-proxy.org', () {
      const apkUrl = 'https://github.com/kechuan/banguLite/releases/download/0.12.5/banguLite-0.12.5-arm64-v8a.apk';

      expect(
        APPInformationRepository.toGithubMirrorUrl(apkUrl),
        'https://gh-proxy.org/$apkUrl',
      );

      expect(
        APPInformationRepository.toGithubMirrorUrl('https://gh-proxy.org/$apkUrl'),
        'https://gh-proxy.org/$apkUrl',
      );

      expect(
        APPInformationRepository.toGithubMirrorUrl(APPInformationRepository.githubLatestReleaseApi),
        'https://gh-proxy.org/https://api.github.com/repos/kechuan/banguLite/releases/latest',
      );

      expect(APPInformationRepository.toGithubMirrorUrl('   '), '');
    });

    test('checkLatency warms up connection, skips redirects, and reuses connection pool', () async {
      await HttpOverrides.runWithHttpOverrides(() async {
        int headCount = 0;
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

        server.listen((request) async {
          if (request.method == 'HEAD') {
            headCount += 1;
          }

          request.response.statusCode = HttpStatus.found;
          request.response.headers.set(HttpHeaders.locationHeader, 'https://example.invalid/redirect');
          await request.response.close();
        });

        try {
          final targetUrl = 'http://${server.address.address}:${server.port}/ping';

          final firstLatency = await checkLatency(targetUrl: targetUrl);
          expect(firstLatency, greaterThanOrEqualTo(0));
          expect(headCount, 2);

          final secondLatency = await checkLatency(targetUrl: targetUrl);
          expect(secondLatency, greaterThanOrEqualTo(0));
          expect(headCount, 3);

          expect(await checkLatency(targetUrl: ''), -1);
        }

        finally {
          latencyTestClient?.close(force: true);
          latencyTestClient = null;
          warmedHostTimestamps.clear();
          await server.close(force: true);
        }
      }, DirectHttpOverrides());
    });

    test('external image proxy URLs preserve query and loadByteInformation falls back to Range GET', () async {
      const sampleUrl = 'https://pbs.twimg.com/media/demo?format=jpg&name=large';

      expect(
        convertProxyImageUri(sampleUrl),
        'https://i1.wp.com/pbs.twimg.com/media/demo?format=jpg&name=large',
      );

      expect(
        convertWsrvImageUri(sampleUrl),
        'https://wsrv.nl/?url=${Uri.encodeComponent(sampleUrl)}&n=-1',
      );

      expect(contentRangeByteParse('bytes 0-0/98765'), 98765);
      expect(contentRangeByteParse('bytes 0-0/*'), isNull);
      expect(contentRangeByteParse(null), isNull);

      await HttpOverrides.runWithHttpOverrides(() async {
        int headRequests = 0;
        int rangeGetRequests = 0;

        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

        server.listen((request) async {
          if (request.method == 'HEAD') {
            headRequests += 1;
            request.response.statusCode = HttpStatus.methodNotAllowed;
            await request.response.close();
            return;
          }

          if (request.method == 'GET' && request.headers.value(HttpHeaders.rangeHeader) == 'bytes=0-0') {
            rangeGetRequests += 1;
            request.response.statusCode = HttpStatus.partialContent;
            request.response.headers.set(HttpHeaders.contentTypeHeader, 'image/png');
            request.response.headers.set(HttpHeaders.contentRangeHeader, 'bytes 0-0/98765');
            request.response.headers.set(HttpHeaders.contentLengthHeader, '1');
            request.response.add([0x89]);
            await request.response.close();
            return;
          }

          request.response.statusCode = HttpStatus.badRequest;
          await request.response.close();
        });

        try {
          HttpApiClient.client.httpClientAdapter = HttpApiClient.configHTTPProxySetting('');

          final targetUrl = 'http://${server.address.address}:${server.port}/img';
          final result = await loadByteInformation(targetUrl);

          expect(headRequests, 1);
          expect(rangeGetRequests, 1);
          expect(result.contentLink, targetUrl);
          expect(result.contentLength, 98765);
          expect(result.contentType, 'image/png');
        }

        finally {
          await server.close(force: true);
        }
      }, DirectHttpOverrides());

      HttpApiClient.client.httpClientAdapter = HttpApiClient.configHTTPProxySetting('');
    });
  });

  group('Bangumi mirror host config', () {
    tearDown(() {
      BangumiHostConfig.applyConfig(isMirrorMode: false);
    });

    test('cleanMirrorDomain extracts clean root domain from URLs and subdomains', () {
      expect(BangumiMirrorOption.cleanMirrorDomain('https://bgm.lat/subject/1'), 'bgm.lat');
      expect(BangumiMirrorOption.cleanMirrorDomain('API.BGM.LAT'), 'bgm.lat');
      expect(BangumiMirrorOption.cleanMirrorDomain('next.example.org/p1'), 'example.org');
      expect(BangumiMirrorOption.cleanMirrorDomain('lain.mirror.test'), 'mirror.test');
      expect(BangumiMirrorOption.cleanMirrorDomain('  '), '');
    });

    test('parseWikiMirrors keeps both complete and incomplete mirrors with isApiComplete flag', () {
      final parsed = BangumiMirrorOption.parseWikiMirrors({
        'mirrors': [
          {
            'name': 'bgm.lat',
            'base': 'bgm.lat',
            'recommended': true,
            'note': 'full mirror',
            'services': [
              {'id': 'main', 'hosts': ['bgm.lat']},
              {'id': 'api', 'hosts': ['api.bgm.lat']},
              {'id': 'next', 'hosts': ['next.bgm.lat']},
              {'id': 'lain', 'hosts': ['lain.bgm.lat']},
            ],
          },
          {
            'name': 'fxbgm.tv',
            'base': 'fxbgm.tv',
            'note': '个人维护的 Bangumi 前端，不是完整镜像。',
            'services': [
              {'id': 'main', 'hosts': ['fxbgm.tv']},
            ],
          },
        ],
      });

      expect(parsed.length, 2);
      expect(parsed[0].baseDomain, 'bgm.lat');
      expect(parsed[0].apiHost, 'api.bgm.lat');
      expect(parsed[0].recommended, isTrue);
      expect(parsed[0].isApiComplete, isTrue);

      expect(parsed[1].baseDomain, 'fxbgm.tv');
      expect(parsed[1].isApiComplete, isFalse);
      expect(parsed[1].apiHost, isEmpty);

      expect(BangumiMirrorOption.parseWikiMirrors(null).first.baseDomain, 'bgm.lat');
    });

    test('applyConfig dynamically switches BangumiAPIUrls, BangumiWebUrls, images and routes', () {
      BangumiHostConfig.applyConfig(isMirrorMode: false);
      expect(BangumiAPIUrls.baseUrl, 'https://api.bgm.tv');
      expect(BangumiAPIUrls.newUrl, 'https://next.bgm.tv/p1');
      expect(BangumiAPIUrls.baseResourceUrl, 'https://lain.bgm.tv');
      expect(BangumiWebUrls.baseUrl, 'https://bangumi.tv');
      expect(BangumiWebUrls.relativeUrl, 'https://bgm.tv');

      BangumiHostConfig.applyConfig(isMirrorMode: true, mirrorMode: 'bgm.lat');
      expect(BangumiHostConfig.isUsingMirror, isTrue);
      expect(BangumiAPIUrls.baseUrl, 'https://api.bgm.lat');
      expect(BangumiAPIUrls.calendar, 'https://api.bgm.lat/calendar');
      expect(BangumiAPIUrls.newUrl, 'https://next.bgm.lat/p1');
      expect(BangumiAPIUrls.baseResourceUrl, 'https://lain.bgm.lat');
      expect(BangumiWebUrls.baseUrl, 'https://bgm.lat');
      expect(BangumiWebUrls.relativeUrl, 'https://bgm.lat');
      expect(BangumiWebUrls.oAuth, 'https://bgm.lat/oauth/authorize');
      expect(BangumiHostConfig.isBangumiApiHost('api.bgm.lat'), isTrue);
      expect(BangumiHostConfig.isBangumiApiHost('next.bgm.lat'), isTrue);
      expect(
        BangumiHostConfig.rewriteResourceUrl('https://lain.bgm.tv/pic/cover/l/demo.jpg'),
        'https://lain.bgm.lat/pic/cover/l/demo.jpg',
      );
      expect(
        BangumiHostConfig.convertToActiveWebLink('https://bangumi.tv/subject/123'),
        'https://bgm.lat/subject/123',
      );
      expect(
        convertBangumiNetworkGirlStickerPath(1),
        'https://lain.bgm.lat/img/smiles/musume/musume_01.gif',
      );

      BangumiHostConfig.applyConfig(
        isMirrorMode: true,
        mirrorMode: BangumiHostConfig.customMode,
        customDomain: 'https://api.my-bgm.example/v0',
      );
      expect(BangumiAPIUrls.baseUrl, 'https://api.my-bgm.example');
      expect(BangumiWebUrls.baseUrl, 'https://my-bgm.example');
      expect(BangumiAPIUrls.newUrl, 'https://next.my-bgm.example/p1');
      expect(BangumiAPIUrls.baseResourceUrl, 'https://lain.my-bgm.example');

      BangumiHostConfig.applyConfig(
        isMirrorMode: false,
        mirrorMode: BangumiHostConfig.customMode,
        customDomain: 'my-bgm.example',
      );
      expect(BangumiHostConfig.isUsingMirror, isFalse);
      expect(BangumiAPIUrls.baseUrl, 'https://api.bgm.tv');
      expect(
        BangumiHostConfig.convertToActiveWebLink('https://bgm.lat/subject/123'),
        'https://bangumi.tv/subject/123',
      );
      expect(
        BangumiHostConfig.rewriteResourceUrl('https://lain.bgm.lat/pic/cover/l/demo.jpg'),
        'https://lain.bgm.tv/pic/cover/l/demo.jpg',
      );
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

      final imgProxySwitchFinder = find.descendant(
        of: find.ancestor(
          of: find.text("使外链(img标签)图片加载也使用代理流量"),
          matching: find.byType(Row),
        ),
        matching: find.byType(Switch),
      );
      expect(tester.widget<Switch>(imgProxySwitchFinder).value, isTrue);

      await tester.tap(imgProxySwitchFinder);
      await tester.pumpAndSettle();

      expect(indexModel.userConfig.isImgTagProxy, isFalse);
      expect(tester.widget<Switch>(imgProxySwitchFinder).value, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('NetworkConfigPage supports mirror switch, custom input, and security dialog', (tester) async {
      addTearDown(() {
        BangumiHostConfig.applyConfig(isMirrorMode: false);
      });

      BangumiHostConfig.applyConfig(isMirrorMode: false);

      final indexModel = TestIndexModel();

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
      expect(find.text('镜像站设置'), findsOneWidget);
      expect(find.text('fxbgm.tv'), findsOneWidget);
      expect(find.text('api不完整'), findsOneWidget);
      expect(find.text('非完整api镜像支持'), findsOneWidget);
      expect(find.text('应用'), findsNothing);
      expect(find.byType(CheckboxListTile), findsNWidgets(2));
      final incompleteTile = find.ancestor(
        of: find.text('fxbgm.tv'),
        matching: find.byType(ListTile),
      );
      final incompleteCheckbox = tester.widget<Checkbox>(
        find.descendant(of: incompleteTile, matching: find.byType(Checkbox)),
      );
      expect(incompleteCheckbox.value, isFalse);
      expect(incompleteCheckbox.onChanged, isNull);
      expect(find.text('https://api.bgm.tv'), findsOneWidget);

      final mirrorSwitchFinder = find.descendant(
        of: find.ancestor(
          of: find.text('镜像站设置'),
          matching: find.byType(ListTile),
        ),
        matching: find.byType(Switch),
      );
      expect(tester.widget<Switch>(mirrorSwitchFinder).value, isFalse);

      await tester.ensureVisible(mirrorSwitchFinder);
      await tester.tap(mirrorSwitchFinder);
      await tester.pumpAndSettle();

      expect(indexModel.userConfig.isMirrorMode, isTrue);
      expect(indexModel.userConfig.bangumiMirrorMode, 'bgm.lat');
      expect(BangumiAPIUrls.baseUrl, 'https://api.bgm.lat');
      expect(find.text('https://api.bgm.lat'), findsOneWidget);

      final customTextField = find.byWidgetPredicate(
        (widget) =>
          widget is TextField &&
          widget.decoration?.hintText == '输入镜像根域名，如 bgm.lat',
      );

      await tester.ensureVisible(customTextField);
      await tester.pumpAndSettle();
      await tester.enterText(customTextField, 'https://custom-bgm.test/v0');
      await tester.pumpAndSettle();

      final customTileTitle = find.text('自定义镜像域名');
      await tester.ensureVisible(customTileTitle);
      await tester.pumpAndSettle();
      await tester.tap(customTileTitle);
      await tester.pumpAndSettle();

      expect(indexModel.userConfig.bangumiMirrorMode, BangumiHostConfig.customMode);
      expect(indexModel.userConfig.customMirrorDomain, 'custom-bgm.test');
      expect(BangumiAPIUrls.baseUrl, 'https://api.custom-bgm.test');
      expect(find.text('https://api.custom-bgm.test'), findsOneWidget);

      await tester.ensureVisible(mirrorSwitchFinder);
      await tester.tap(mirrorSwitchFinder);
      await tester.pumpAndSettle();

      expect(indexModel.userConfig.isMirrorMode, isFalse);
      expect(indexModel.userConfig.customMirrorDomain, 'custom-bgm.test');
      expect(BangumiAPIUrls.baseUrl, 'https://api.bgm.tv');
      expect(find.text('https://api.bgm.tv'), findsOneWidget);

      final helpIcon = find.byIcon(Icons.help_outline);
      await tester.ensureVisible(helpIcon);
      await tester.tap(helpIcon);
      await tester.pumpAndSettle();

      expect(find.text('安全提醒'), findsOneWidget);
      final dialogTitleText = tester.widget<Text>(find.text('安全提醒'));
      expect(dialogTitleText.style?.fontWeight, FontWeight.bold);
      expect(find.text('只有官方域名才算安全：bangumi.tv、bgm.tv、chii.in。'), findsOneWidget);
      expect(find.text('其他域名，包括 bgm.lat，登不登录取决于你是否信任这个站。'), findsOneWidget);
      expect(find.text('镜像站可以获得你在该站的全部信息，包括账号和密码。'), findsOneWidget);

      await tester.tap(find.text('我知道了'));
      await tester.pumpAndSettle();

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
