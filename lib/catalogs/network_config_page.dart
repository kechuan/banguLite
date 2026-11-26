import 'dart:async';

import 'package:bangu_lite/internal/bangumi_mirror.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/get.dart';
import 'package:bangu_lite/internal/utils/judge.dart';
import 'package:bangu_lite/internal/utils/template.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

Map<String, String> buildConnectionTestUrlMap() => {
  '网页主站测试': BangumiWebUrls.baseUrl,
  'API v0 测试': BangumiAPIUrls.baseUrl,
  'API next 测试': BangumiAPIUrls.newUrl,
  'OAuth登录测试': BangumiWebUrls.oAuth,
  'turnstile回帖验证测试': "${BangumiWebUrls.nextUrl}/p1/turnstile?redirect_uri=bangulite://turnstile/callback",
  'bgm内置图片源测试': '${BangumiAPIUrls.baseResourceUrl}/img/smiles/blake/blake_01.gif',

  // 不规范实现的图片源 只有path 靠浏览器自动推断返回内容 结果也没有head请求 导致直接请求失败
  // 遇到这种类型拉取写恐怕还得要独立完整的get请求 但那样估计又重起来了 只能说还得是wordpress这些转发请求好
  //'Debug':"https://i1.wp.com/note.072158.xyz/img"
  //'Debug':"https://note.072158.xyz/img"
};

@FFRoute(name: 'networkConfig')
class NetworkConfigPage extends StatefulWidget {
  const NetworkConfigPage({super.key});

  @override
  State<NetworkConfigPage> createState() => _NetworkConfigPageState();
}

class _NetworkConfigPageState extends State<NetworkConfigPage> {

  final httpProxyAddressEditingController = TextEditingController();
  final customMirrorEditingController = TextEditingController();
  late final indexModel = context.read<IndexModel>();

  final ValueNotifier<List<BangumiMirrorOption>> wikiMirrorsNotifier = ValueNotifier(
    List<BangumiMirrorOption>.from(BangumiMirrorOption.defaultMirrors),
  );

  final ValueNotifier<bool> isLoadingMirrorsNotifier = ValueNotifier(false);

  final List<ValueNotifier<String>> latencyResultNotifierList = List.generate(
    buildConnectionTestUrlMap().length,
    (_) => ValueNotifier<String>(""),
    growable: false
  );

  @override
  void initState() {
    super.initState();
    httpProxyAddressEditingController.text = HttpApiClient.currentProxyAddress;
    customMirrorEditingController.text = indexModel.userConfig.customMirrorDomain ?? '';
    refreshWikiMirrors();
  }

  @override
  void dispose() {
    httpProxyAddressEditingController.dispose();
    customMirrorEditingController.dispose();
    wikiMirrorsNotifier.dispose();
    isLoadingMirrorsNotifier.dispose();

    for (final latencyNotifier in latencyResultNotifierList) {
      latencyNotifier.dispose();
    }

    super.dispose();
  }

  void clearLatencyResults() {
    for (final latencyNotifier in latencyResultNotifierList) {
      latencyNotifier.value = "";
    }
  }

  Future<void> refreshWikiMirrors() async {
    if (isLoadingMirrorsNotifier.value) return;

    isLoadingMirrorsNotifier.value = true;

    final fetchedMirrors = await BangumiMirrorOption.fetchWikiMirrors();

    if (!mounted) return;

    wikiMirrorsNotifier.value = fetchedMirrors;
    isLoadingMirrorsNotifier.value = false;

    final isMirrorEnabled = indexModel.userConfig.isMirrorMode ?? false;
    final savedMode = indexModel.userConfig.bangumiMirrorMode ?? '';

    if (isMirrorEnabled && savedMode.isNotEmpty && savedMode != BangumiHostConfig.customMode) {
      BangumiHostConfig.applyConfig(
        isMirrorMode: true,
        mirrorMode: savedMode,
        customDomain: indexModel.userConfig.customMirrorDomain,
        availableMirrors: fetchedMirrors,
      );
    }
  }

  void toggleMirrorMode(bool enabled) {
    clearLatencyResults();

    indexModel.updateMirrorMode(
      enabled,
      availableMirrors: wikiMirrorsNotifier.value,
    );
  }

  void selectMirrorMode(
    String mirrorMode, {
      List<BangumiMirrorOption> availableMirrors = const[],
    }) {
    clearLatencyResults();

    indexModel.updateBangumiMirror(
      mirrorMode: mirrorMode,
      availableMirrors: availableMirrors,
    );
  }

  void applyCustomMirror() {
    final cleanedDomain = BangumiMirrorOption.cleanMirrorDomain(
      customMirrorEditingController.text,
    );

    customMirrorEditingController.text = cleanedDomain;

    clearLatencyResults();

    indexModel.updateBangumiMirror(
      mirrorMode: BangumiHostConfig.customMode,
      customDomain: cleanedDomain,
    );
  }

  void showMirrorSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.security_outlined),
          title: const ScalableText(
            '安全提醒',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                ScalableText('只有官方域名才算安全：bangumi.tv、bgm.tv、chii.in。'),

                ScalableText('其他域名，包括 bgm.lat，登不登录取决于你是否信任这个站。'),

                ScalableText('镜像站可以获得你在该站的全部信息，包括账号和密码。'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const ScalableText('我知道了'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    debugPrint("[NetworkConfigPage] Rebuild");

    return Scaffold(
      appBar: AppBar(
        title: const ScalableText('网络配置与检测'),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 20),
        child: EasyRefresh(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: Padding16,
              child: Column(
                children: [

                  Selector<IndexModel, (bool, bool)>(
                    selector: (_, model) => (
                      model.userConfig.isProxyMode ?? false,
                      model.userConfig.isImgTagProxy ?? true,
                    ),
                    builder: (_, proxyConfig, textFieldChild) {
                      final (isProxyMode, isImgTagProxy) = proxyConfig;

                      return Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.terminal),
                            title: const ScalableText('代理设置'),
                            subtitle: ScalableText('默认直连 保存后生效', style: TextStyle(color: Colors.grey, fontSize: AppFontSize.s14)),
                            trailing: SizedBox(
                              width: 50,
                              child: Switch(
                                value: isProxyMode,
                                onChanged: (value) {
                                  //确保输入框跟随保存内容
                                  httpProxyAddressEditingController.text = HttpApiClient.currentProxyAddress;
                                  indexModel.updateProxyMode(value);

                                  if (value) {
                                    HttpApiClient.client.httpClientAdapter = HttpApiClient.configHTTPProxySetting(HttpApiClient.currentProxyAddress);
                                  }

                                  else {
                                    HttpApiClient.client.httpClientAdapter = HttpApiClient.configHTTPProxySetting("");
                                  }
                                }
                              )
                            ),
                          ),

                          IgnorePointer(
                            ignoring: !isProxyMode,
                            child: ValueListenableBuilder(
                              valueListenable: httpProxyAddressEditingController,
                              builder: (_, textContent, __) {
                                return AnimatedContainer(
                                  height: textContent.text.isEmpty ? 80 : 135,
                                  padding: Padding6,
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color:
                                    isProxyMode ?
                                    getCurrentThemeColor(context).withValues(alpha: 0.3) :
                                    (judgeDarknessMode(context) ? Colors.grey.shade700 : Colors.grey)
                                  ),

                                  child: Column(
                                    spacing: 6,
                                    children: [

                                      Expanded(child: textFieldChild!),

                                      textContent.text.isEmpty ?
                                      const SizedBox.shrink() :
                                      Row(
                                        spacing: 12,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          const Text("使外链(img标签)图片加载也使用代理流量"),
                                          Switch(
                                            value: isImgTagProxy,
                                            onChanged: (value) {
                                              indexModel.updateImageTagProxyMode(value);
                                            }
                                          )
                                        ],
                                      ),

                                    ],
                                  )
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 12,

                      children: [
                        const SizedBox.shrink(),

                        Flexible(
                          child: SizedBox(
                            height: 50,
                            child: ScrollConfiguration(
                              //隔离EasyRefresh所带来的滚动影响 只给TextField传递 scrollPhysics 是不能完全抵消这种影响的
                              behavior: ScrollConfiguration.of(context).copyWith(physics: const ClampingScrollPhysics()),
                              child: TextField(
                                controller: httpProxyAddressEditingController,
                                decoration: const InputDecoration(
                                  hintText: '格式 [IP]:[(HTTP)Port]',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(),

                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(RegExp(r'\\|\/|http|socks')),
                                ],
                              ),
                            ),
                          ),
                        ),

                        TextButton(
                          onPressed: () async {
                            HttpApiClient.currentProxyAddress = httpProxyAddressEditingController.text;
                            HttpApiClient.client.httpClientAdapter = HttpApiClient.configHTTPProxySetting(httpProxyAddressEditingController.text);
                            context.read<IndexModel>().updateCurrentProxyAddress(HttpApiClient.currentProxyAddress);
                          },
                          child: const ScalableText('保存'),
                        ),
                      ],
                    ),
                  ),

                  Selector<IndexModel, (bool, String, String)>(
                    selector: (_, model) => (
                      model.userConfig.isMirrorMode ?? false,
                      model.userConfig.bangumiMirrorMode ?? '',
                      model.userConfig.customMirrorDomain ?? '',
                    ),
                    builder: (_, mirrorConfig, __) {
                      final (isMirrorMode, currentMirrorMode, currentCustomDomain) = mirrorConfig;

                      return Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: Column(
                          children: [

                            ListTile(
                              leading: const Icon(Icons.dns_outlined),
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Flexible(
                                    child: ScalableText(
                                      '镜像站设置',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  const SizedBox(width: 4),

                                  IconButton(
                                    tooltip: '安全提醒',
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    icon: const Icon(Icons.help_outline, size: 20),
                                    onPressed: () => showMirrorSecurityDialog(context),
                                  ),
                                ],
                              ),
                              subtitle: ScalableText(
                                '默认使用官方域名 开启后切换镜像站',
                                style: TextStyle(color: Colors.grey, fontSize: AppFontSize.s14),
                              ),
                              trailing: SizedBox(
                                width: 50,
                                child: Switch(
                                  value: isMirrorMode,
                                  onChanged: toggleMirrorMode,
                                ),
                              ),
                            ),

                            IgnorePointer(
                              ignoring: !isMirrorMode,
                              child: ValueListenableBuilder<List<BangumiMirrorOption>>(
                                valueListenable: wikiMirrorsNotifier,
                                builder: (_, wikiMirrors, ___) {
                                  final displayMirrors = List<BangumiMirrorOption>.from(wikiMirrors);

                                  final completeMirrors = displayMirrors.where((item) => item.isApiComplete);
                                  final fallbackCompleteDomain = completeMirrors.isNotEmpty
                                    ? completeMirrors.first.baseDomain
                                    : BangumiMirrorOption.defaultMirrors.first.baseDomain;

                                  final selectedMirrorMode = currentMirrorMode.isNotEmpty
                                    ? currentMirrorMode
                                    : fallbackCompleteDomain;

                                  final hasSavedInList = displayMirrors.any(
                                    (item) => item.baseDomain == selectedMirrorMode,
                                  );

                                  if (
                                  selectedMirrorMode.isNotEmpty &&
                                    selectedMirrorMode != BangumiHostConfig.customMode &&
                                    !hasSavedInList
                                  ) {
                                    displayMirrors.add(BangumiMirrorOption.fromDomain(selectedMirrorMode));
                                  }

                                  final subtitleHintColor = isMirrorMode
                                    ? Colors.grey
                                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65);

                                  final disabledTextColor =
                                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45);

                                  return Material(
                                    borderRadius: BorderRadius.circular(12),
                                    clipBehavior: Clip.antiAlias,
                                    animationDuration: const Duration(milliseconds: 300),
                                    color:
                                    isMirrorMode
                                      ? getCurrentThemeColor(context).withValues(alpha: 0.3)
                                      : (judgeDarknessMode(context) ? Colors.grey.shade700 : Colors.grey),
                                    child: Padding(
                                      padding: PaddingV6,
                                      child: Column(
                                        children: [

                                          Padding(
                                            padding: const EdgeInsets.only(left: 16, right: 8),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                ScalableText(
                                                  'bangumi.wiki 可用镜像',
                                                  style: TextStyle(color: subtitleHintColor, fontSize: AppFontSize.s12),
                                                ),

                                                ValueListenableBuilder<bool>(
                                                  valueListenable: isLoadingMirrorsNotifier,
                                                  builder: (_, isLoading, ____) {
                                                    if (isLoading) {
                                                      return const Padding(
                                                        padding: EdgeInsets.all(8),
                                                        child: SizedBox(
                                                          height: 16,
                                                          width: 16,
                                                          child: CircularProgressIndicator(strokeWidth: 2),
                                                        ),
                                                      );
                                                    }

                                                    return TextButton.icon(
                                                      onPressed: refreshWikiMirrors,
                                                      icon: const Icon(Icons.refresh, size: 16),
                                                      label: const ScalableText('刷新列表'),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),

                                          for (final mirror in displayMirrors)
                                            if (mirror.isApiComplete)
                                            CheckboxListTile(
                                              controlAffinity: ListTileControlAffinity.leading,
                                              value: selectedMirrorMode == mirror.baseDomain,
                                              title: Row(
                                                spacing: 8,
                                                children: [
                                                  Flexible(
                                                    child: ScalableText(
                                                      mirror.name,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),

                                                  if (mirror.recommended)
                                                  DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(6),
                                                      color: getCurrentThemeColor(context).withValues(alpha: 0.25),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      child: ScalableText(
                                                        '推荐',
                                                        style: TextStyle(fontSize: AppFontSize.s12),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              subtitle: ScalableText(
                                                '${mirror.mainHost} / ${mirror.apiHost} / ${mirror.nextHost}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(color: subtitleHintColor, fontSize: AppFontSize.s12),
                                              ),
                                              onChanged: (_) => selectMirrorMode(
                                                mirror.baseDomain,
                                                availableMirrors: displayMirrors,
                                              ),
                                            )
                                            else
                                            ListTile(
                                              enabled: false,
                                              leading: const Checkbox(
                                                value: false,
                                                onChanged: null,
                                              ),
                                              title: Row(
                                                spacing: 8,
                                                children: [
                                                  Flexible(
                                                    child: ScalableText(
                                                      mirror.name,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(color: disabledTextColor),
                                                    ),
                                                  ),

                                                  DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(6),
                                                      color: Colors.red.withValues(alpha: 0.18),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      child: ScalableText(
                                                        'api不完整',
                                                        style: TextStyle(
                                                          color: judgeDarknessMode(context) ? Colors.red.shade300 : Colors.red,
                                                          fontSize: AppFontSize.s12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              subtitle: ScalableText(
                                                '非完整api镜像支持',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(color: disabledTextColor, fontSize: AppFontSize.s12),
                                              ),
                                            ),

                                          CheckboxListTile(
                                            controlAffinity: ListTileControlAffinity.leading,
                                            value: selectedMirrorMode == BangumiHostConfig.customMode,
                                            title: const ScalableText('自定义镜像域名'),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(top: 8, bottom: 4),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 6,
                                                children: [
                                                  SizedBox(
                                                    height: 44,
                                                    child: ScrollConfiguration(
                                                      behavior: ScrollConfiguration.of(context).copyWith(
                                                        physics: const ClampingScrollPhysics(),
                                                      ),
                                                      child: TextField(
                                                        controller: customMirrorEditingController,
                                                        onChanged: (value) {
                                                          if (isMirrorMode && selectedMirrorMode == BangumiHostConfig.customMode) {
                                                            clearLatencyResults();
                                                            indexModel.updateBangumiMirror(
                                                              mirrorMode: BangumiHostConfig.customMode,
                                                              customDomain: value,
                                                            );
                                                          }
                                                        },
                                                        onSubmitted: (_) => applyCustomMirror(),
                                                        decoration: const InputDecoration(
                                                          isDense: true,
                                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                          hintText: '输入镜像根域名，如 bgm.lat',
                                                          hintStyle: TextStyle(color: Colors.grey),
                                                          border: OutlineInputBorder(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  if (isMirrorMode && selectedMirrorMode == BangumiHostConfig.customMode)
                                                  ScalableText(
                                                    currentCustomDomain.isNotEmpty
                                                      ? '当前生效: $currentCustomDomain / api.$currentCustomDomain / next.$currentCustomDomain'
                                                      : '请输入镜像根域名（未填写时暂用官方源）',
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(color: subtitleHintColor, fontSize: AppFontSize.s12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            onChanged: (_) => applyCustomMirror(),
                                          ),

                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                          ],
                        ),
                      );
                    },
                  ),

                  Selector<IndexModel, (bool, String, String)>(
                    selector: (_, model) => (
                      model.userConfig.isMirrorMode ?? false,
                      model.userConfig.bangumiMirrorMode ?? '',
                      model.userConfig.customMirrorDomain ?? '',
                    ),
                    builder: (_, __, ___) {
                      final connectionTestUrlMap = buildConnectionTestUrlMap();

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 25),
                            child: ListTile(
                              leading: const Icon(Icons.wifi),
                              title: const ScalableText('网页与API连通性检查'),
                              subtitle: ScalableText('点击对应项目可以单独测试', style: TextStyle(color: Colors.grey, fontSize: AppFontSize.s14)),
                              trailing: TextButton(
                                onPressed: () {
                                  final proxyAddress = (indexModel.userConfig.isProxyMode ?? false)
                                    ? httpProxyAddressEditingController.text
                                    : null;

                                  final Map<String, List<int>> hostIndexGroups = {};

                                  for (int index = 0; index < connectionTestUrlMap.length; index++) {
                                    latencyResultNotifierList[index].value = "loading";

                                    final targetUrl = connectionTestUrlMap.values.elementAt(index);
                                    final hostKey = Uri.tryParse(targetUrl)?.host ?? "$index";

                                    hostIndexGroups.putIfAbsent(hostKey, () => []).add(index);
                                  }

                                  Future.wait(
                                    hostIndexGroups.values.map((indexGroup) async {
                                      for (final index in indexGroup) {
                                        final targetUrl = connectionTestUrlMap.values.elementAt(index);

                                        final value = await checkLatency(
                                          targetUrl: targetUrl,
                                          proxyAddress: proxyAddress,
                                        );

                                        debugPrint("[Network Latency] $targetUrl $value ms");

                                        if (!mounted) return;
                                        latencyResultNotifierList[index].value = "$value";
                                      }
                                    }),
                                  );
                                },
                                child: const Text("全部测试")
                              ),
                            )

                          ),

                          Material(
                            borderRadius: BorderRadius.circular(12),
                            clipBehavior: Clip.antiAlias,
                            color: getCurrentThemeColor(context).withValues(alpha: 0.15),
                            child: Padding(
                              padding: PaddingV6,
                              child: ListView(
                                physics: const NeverScrollableScrollPhysics(),
                                itemExtent: kToolbarHeight,
                                shrinkWrap: true,
                                children: List.generate(
                                  connectionTestUrlMap.length, (index) {
                                    final targetUrl = connectionTestUrlMap.values.elementAt(index);

                                    return ListTile(
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          ScalableText(connectionTestUrlMap.keys.elementAt(index)),
                                          ValueListenableBuilder(
                                            valueListenable: latencyResultNotifierList[index],
                                            builder: (_, resultText, child) {
                                              switch (resultText) {
                                                case "":
                                                  return const SizedBox.shrink();
                                                case "loading":
                                                  return const SizedBox(
                                                    height: 25,
                                                    width: 25,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 3,
                                                    ),
                                                  );
                                                default:
                                                  return Builder(builder: (_) {

                                                    int latency = int.tryParse(resultText) ?? 0;
                                                    Color currentLatencyLevel = Colors.green;

                                                    if (latency > 500) {
                                                      currentLatencyLevel = Colors.orange;
                                                    }

                                                    if (latency == -1 || latency >= 2000) {
                                                      currentLatencyLevel = Colors.red;
                                                    }

                                                    return ScalableText(
                                                      latency == -1 ? "TimeOut" : "$latency ms",
                                                      style: TextStyle(color: currentLatencyLevel, fontSize: AppFontSize.s12)
                                                    );

                                                  });
                                              }
                                            }
                                          )

                                        ],
                                      ),
                                      subtitle: ScalableText(
                                        targetUrl,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.grey, fontSize: AppFontSize.s12)
                                      ),
                                      onTap: () {

                                        latencyResultNotifierList[index].value = "loading";

                                        checkLatency(
                                          targetUrl: targetUrl,
                                          proxyAddress: judgeIsProxyMode(context) ? httpProxyAddressEditingController.text : null
                                        ).then((value) {
                                            debugPrint("[Network Latency] $targetUrl $value ms");
                                            if (!mounted) return;
                                            latencyResultNotifierList[index].value = "$value";
                                          });

                                      },
                                    );
                                  }
                                )

                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

    );
  }
}

Dio? latencyTestClient;
String? latencyClientProxyAddress;

final Map<String, DateTime> warmedHostTimestamps = {};
final Map<String, Future<void>> pendingWarmupTasks = {};

const Duration latencyWarmupValidDuration = Duration(seconds: 25);

Dio getLatencyTestClient(String proxyAddress) {
  if (latencyTestClient != null && latencyClientProxyAddress == proxyAddress) {
    return latencyTestClient!;
  }

  latencyTestClient?.close(force: true);
  warmedHostTimestamps.clear();
  pendingWarmupTasks.clear();

  final newClient = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      followRedirects: false,
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  newClient.httpClientAdapter = HttpApiClient.configHTTPProxySetting(proxyAddress);

  latencyTestClient = newClient;
  latencyClientProxyAddress = proxyAddress;

  return newClient;
}

Future<void> ensureLatencyConnectionWarmed({
  required Dio dio,
  required String targetUrl,
  required String hostKey,
  required Options requestOptions,
}) async {
  final lastWarmedAt = warmedHostTimestamps[hostKey];

  if (
  lastWarmedAt != null &&
    DateTime.now().difference(lastWarmedAt) < latencyWarmupValidDuration
  ) {
    return;
  }

  final existingTask = pendingWarmupTasks[hostKey];

  if (existingTask != null) {
    await existingTask;
    return;
  }

  final warmupFuture = dio
    .head(targetUrl, options: requestOptions)
    .timeout(const Duration(seconds: 5))
    .then((_) {
      warmedHostTimestamps[hostKey] = DateTime.now();
    });

  pendingWarmupTasks[hostKey] = warmupFuture;

  try {
    await warmupFuture;
  }

  finally {
    pendingWarmupTasks.remove(hostKey);
  }
}

Future<int> checkLatency({String targetUrl = "", String? proxyAddress}) async {

  final stopwatch = Stopwatch();
  final activeProxy = (proxyAddress ?? "").trim();
  final parsedUri = Uri.tryParse(targetUrl);

  if (parsedUri == null || parsedUri.host.isEmpty) return -1;

  final hostKey = "$activeProxy|${parsedUri.scheme}://${parsedUri.host}:${parsedUri.port}";

  final requestOptions = Options(
    followRedirects: false,
    validateStatus: (status) => status != null && status < 500,
  );

  try {
    final dio = getLatencyTestClient(activeProxy);

    await ensureLatencyConnectionWarmed(
      dio: dio,
      targetUrl: targetUrl,
      hostKey: hostKey,
      requestOptions: requestOptions,
    );

    stopwatch.start();

    await dio
      .head(targetUrl, options: requestOptions)
      .timeout(const Duration(seconds: 5));

    stopwatch.stop();
    warmedHostTimestamps[hostKey] = DateTime.now();

    return stopwatch.elapsedMilliseconds;
  }

  on DioException catch (e) {
    debugPrint("[Network Latency] ${extractDioException(e)}");
    warmedHostTimestamps.remove(hostKey);
    stopwatch.stop();
    return -1;
  }

  on TimeoutException {
    warmedHostTimestamps.remove(hostKey);
    stopwatch.stop();
    return -1;
  }
}

