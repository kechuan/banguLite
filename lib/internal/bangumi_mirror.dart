import 'package:bangu_lite/internal/request_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 单个 Bangumi 镜像站信息（对应 bangumi.wiki/api/v1/mirrors 结构）
class BangumiMirrorOption {
  const BangumiMirrorOption({
    required this.name,
    required this.baseDomain,
    required this.mainHost,
    required this.apiHost,
    required this.nextHost,
    required this.lainHost,
    this.note = '',
    this.recommended = false,
    this.isApiComplete = true,
  });

  final String name;
  final String baseDomain;
  final String mainHost;
  final String apiHost;
  final String nextHost;
  final String lainHost;
  final String note;
  final bool recommended;
  final bool isApiComplete;

  factory BangumiMirrorOption.fromDomain(
    String rawDomain, {
    String? name,
    String note = '',
    bool recommended = false,
  }) {
    final cleanDomain = cleanMirrorDomain(rawDomain);

    return BangumiMirrorOption(
      name: name ?? cleanDomain,
      baseDomain: cleanDomain,
      mainHost: cleanDomain,
      apiHost: 'api.$cleanDomain',
      nextHost: 'next.$cleanDomain',
      lainHost: 'lain.$cleanDomain',
      note: note,
      recommended: recommended,
    );
  }

  /// 内置预设（来自 bangumi.wiki，离线或首次打开时立即可用）
  static const List<BangumiMirrorOption> defaultMirrors = [
    BangumiMirrorOption(
      name: 'bgm.lat',
      baseDomain: 'bgm.lat',
      mainHost: 'bgm.lat',
      apiHost: 'api.bgm.lat',
      nextHost: 'next.bgm.lat',
      lainHost: 'lain.bgm.lat',
      note: 'bangumi.wiki 维护的完整镜像，非官方域名。',
      recommended: true,
    ),
    BangumiMirrorOption(
      name: 'fxbgm.tv',
      baseDomain: 'fxbgm.tv',
      mainHost: 'fxbgm.tv',
      apiHost: '',
      nextHost: '',
      lainHost: '',
      note: '个人维护的 Bangumi 前端，不是完整镜像。',
      recommended: false,
      isApiComplete: false,
    ),
  ];

  static const String wikiMirrorsApiUrl = 'https://bangumi.wiki/api/v1/mirrors';

  /// 清理用户输入的镜像域名，支持直接输入 bgm.lat / https://bgm.lat/ / api.bgm.lat
  static String cleanMirrorDomain(String rawInput) {
    String result = rawInput.trim().toLowerCase();

    if (result.isEmpty) return '';

    if (result.contains('://')) {
      result = Uri.tryParse(result)?.host ?? result;
    }

    final slashIndex = result.indexOf('/');
    if (slashIndex != -1) {
      result = result.substring(0, slashIndex);
    }

    for (final prefix in ['www.', 'api.', 'next.', 'lain.']) {
      if (result.startsWith(prefix) && result.length > prefix.length) {
        result = result.substring(prefix.length);
        break;
      }
    }

    return result.trim();
  }

  /// 从 bangumi.wiki API 解析镜像列表（保留非完整镜像并标记 isApiComplete）
  static List<BangumiMirrorOption> parseWikiMirrors(dynamic responseData) {
    if (responseData is! Map) return List<BangumiMirrorOption>.from(defaultMirrors);

    final rawMirrors = responseData['mirrors'];
    if (rawMirrors is! List) return List<BangumiMirrorOption>.from(defaultMirrors);

    final List<BangumiMirrorOption> resultList = [];

    for (final item in rawMirrors) {
      if (item is! Map) continue;

      final services = item['services'];
      if (services is! List) continue;

      String? mainHost;
      String? apiHost;
      String? nextHost;
      String? lainHost;

      for (final service in services) {
        if (service is! Map) continue;

        final serviceID = service['id']?.toString();
        final hosts = service['hosts'];
        if (hosts is! List || hosts.isEmpty) continue;

        final firstHost = hosts.first.toString().trim();
        if (firstHost.isEmpty) continue;

        switch (serviceID) {
          case 'main':
            mainHost = firstHost;
          case 'api':
            apiHost = firstHost;
          case 'next':
            nextHost = firstHost;
          case 'lain':
            lainHost = firstHost;
        }
      }

      if (mainHost == null) continue;

      final baseDomain = cleanMirrorDomain(item['base']?.toString() ?? mainHost);
      if (baseDomain.isEmpty) continue;

      final isApiComplete = apiHost != null && nextHost != null && lainHost != null;

      resultList.add(
        BangumiMirrorOption(
          name: item['name']?.toString() ?? baseDomain,
          baseDomain: baseDomain,
          mainHost: mainHost,
          apiHost: apiHost ?? '',
          nextHost: nextHost ?? '',
          lainHost: lainHost ?? '',
          note: item['note']?.toString() ?? '',
          recommended: item['recommended'] == true,
          isApiComplete: isApiComplete,
        ),
      );
    }

    if (resultList.isEmpty || !resultList.any((item) => item.isApiComplete)) {
      return List<BangumiMirrorOption>.from(defaultMirrors);
    }

    return resultList;
  }

  /// 拉取 bangumi.wiki 最新可用完整镜像列表，失败时回退到内置预设
  static Future<List<BangumiMirrorOption>> fetchWikiMirrors() async {
    try {
      final response = await HttpApiClient.client
        .get(wikiMirrorsApiUrl)
        .timeout(const Duration(seconds: 6));

      return parseWikiMirrors(response.data);
    }

    on DioException catch (e) {
      debugPrint('[BangumiMirror] fetchWikiMirrors error: ${e.message}');
      return List<BangumiMirrorOption>.from(defaultMirrors);
    }

    catch (e) {
      debugPrint('[BangumiMirror] fetchWikiMirrors unexpected error: $e');
      return List<BangumiMirrorOption>.from(defaultMirrors);
    }
  }
}

/// 统一管理当前激活的 Bangumi 官方/镜像站域名，兼容所有 BangumiAPIUrls 与 BangumiWebUrls 引用。
class BangumiHostConfig {
  const BangumiHostConfig._();

  static const String officialMode = '';
  static const String customMode = 'custom';

  static const String officialWebBaseUrl = 'https://bangumi.tv';
  static const String officialRelativeUrl = 'https://bgm.tv';
  static const String officialChiiUrl = 'https://chii.in';
  static const String officialApiBaseUrl = 'https://api.bgm.tv';
  static const String officialNextUrl = 'https://next.bgm.tv';
  static const String officialResourceUrl = 'https://lain.bgm.tv';

  static bool isMirrorEnabled = false;
  static String activeMirrorMode = officialMode;
  static String activeCustomDomain = '';
  static BangumiMirrorOption? activeMirror;

  static bool get isUsingMirror => activeMirror != null;

  static String get apiBaseUrl =>
    activeMirror != null ? 'https://${activeMirror!.apiHost}' : officialApiBaseUrl;

  static String get nextBaseUrl =>
    activeMirror != null ? 'https://${activeMirror!.nextHost}' : officialNextUrl;

  static String get resourceBaseUrl =>
    activeMirror != null ? 'https://${activeMirror!.lainHost}' : officialResourceUrl;

  static String get webBaseUrl =>
    activeMirror != null ? 'https://${activeMirror!.mainHost}' : officialWebBaseUrl;

  static String get webRelativeUrl =>
    activeMirror != null ? 'https://${activeMirror!.mainHost}' : officialRelativeUrl;

  static void applyConfig({
    bool? isMirrorMode,
    String? mirrorMode,
    String? customDomain,
    List<BangumiMirrorOption> availableMirrors = const [],
  }) {
    final enabled = isMirrorMode ?? false;
    final mode = (mirrorMode ?? officialMode).trim();
    final cleanedCustom = BangumiMirrorOption.cleanMirrorDomain(customDomain ?? '');

    isMirrorEnabled = enabled;
    activeMirrorMode = mode;
    activeCustomDomain = cleanedCustom;

    if (!enabled) {
      activeMirror = null;
    }

    else if (mode == customMode) {
      activeMirror = cleanedCustom.isNotEmpty
        ? BangumiMirrorOption.fromDomain(cleanedCustom)
        : null;
    }

    else {
      final targetMode = mode.isNotEmpty
        ? mode
        : BangumiMirrorOption.defaultMirrors.first.baseDomain;

      BangumiMirrorOption? matched;

      for (final item in [...availableMirrors, ...BangumiMirrorOption.defaultMirrors]) {
        if (!item.isApiComplete) continue;

        if (item.baseDomain == targetMode || item.name == targetMode) {
          matched = item;
          break;
        }
      }

      final fallbackDomain = BangumiMirrorOption.cleanMirrorDomain(targetMode);
      activeMirror = matched ?? (fallbackDomain.isNotEmpty ? BangumiMirrorOption.fromDomain(fallbackDomain) : null);
    }

    HttpApiClient.clientOption.baseUrl = BangumiAPIUrls.baseUrl;
    HttpApiClient.client.options.baseUrl = BangumiAPIUrls.baseUrl;
  }

  /// 判断请求 host 是否属于官方或当前镜像站的 Bangumi API 域名
  static bool isBangumiApiHost(String host) {
    if (host == 'api.bgm.tv' || host == 'next.bgm.tv') return true;

    if (activeMirror != null) {
      return host == activeMirror!.apiHost || host == activeMirror!.nextHost;
    }

    return false;
  }

  /// 判断图片链接是否属于 Bangumi 官方或镜像图床
  static bool isBangumiResourceUrl(String url) {
    final host = Uri.tryParse(url)?.host.toLowerCase();

    if (host == null || host.isEmpty) return false;

    if (host == 'lain.bgm.tv') return true;

    if (activeMirror != null && host == activeMirror!.lainHost) return true;

    return false;
  }

  /// 将旧缓存或官方返回的 lain 图床链接切换到当前激活的官方/镜像图床域名
  static String rewriteResourceUrl(String url) {
    if (url.isEmpty) return url;

    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return url;

    final host = uri.host.toLowerCase();
    final isKnownLainHost = host == 'lain.bgm.tv' ||
      host == 'lain.bgm.lat' ||
      (activeMirror != null && host == activeMirror!.lainHost);

    if (!isKnownLainHost) return url;

    final targetUri = Uri.parse(resourceBaseUrl);
    if (host == targetUri.host && uri.scheme == targetUri.scheme) return url;

    return uri.replace(scheme: targetUri.scheme, host: targetUri.host).toString();
  }

  /// 兼容站内链接解析：无论当前是否启用镜像站，官方域名与镜像域名都能被路由识别
  static String convertToActiveWebLink(String link) {
    final uri = Uri.tryParse(link);
    if (uri == null || uri.host.isEmpty) return link;

    final host = uri.host.toLowerCase();

    if (
      host == 'bangumi.tv' ||
      host == 'bgm.tv' ||
      host == 'chii.in' ||
      host == 'bgm.lat' ||
      (activeMirror != null && host == activeMirror!.mainHost)
    ) {
      final targetUri = Uri.parse(webBaseUrl);
      return uri.replace(scheme: targetUri.scheme, host: targetUri.host).toString();
    }

    if (
      host == 'next.bgm.tv' ||
      host == 'next.bgm.lat' ||
      (activeMirror != null && host == activeMirror!.nextHost)
    ) {
      final targetUri = Uri.parse(nextBaseUrl);
      return uri.replace(scheme: targetUri.scheme, host: targetUri.host).toString();
    }

    return link;
  }
}
