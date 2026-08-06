import 'dart:async';

import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/const.dart';
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

const connectionTestUrlMap = {
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
  late final indexModel = context.read<IndexModel>();

  final List<ValueNotifier<String>> latencyResultNotifierList = List.generate(
    connectionTestUrlMap.length,
    (_) => ValueNotifier<String>(""),
    growable: false
  );

  @override
  void initState() {
    super.initState();
    httpProxyAddressEditingController.text = HttpApiClient.currentProxyAddress;

  }

  @override
  void dispose() {
    httpProxyAddressEditingController.dispose();
    latencyResultNotifierList.map((latencyNotifier) => latencyNotifier.dispose());

    super.dispose();
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

                  ListTile(
                    leading: const Icon(Icons.terminal),
                    title: const ScalableText('代理设置'),
                    subtitle: ScalableText('默认直连 保存后生效', style: TextStyle(color: Colors.grey, fontSize: AppFontSize.s14)),
                    trailing: SizedBox(
                      width: 50,
                      child: Switch(
                        value: indexModel.userConfig.isProxyMode ?? false,
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
                    ignoring: !(indexModel.userConfig.isProxyMode ?? false),
                    child: ValueListenableBuilder(
                      valueListenable: httpProxyAddressEditingController,
                      builder: (_, textContent, textFieldChild) {
                        return AnimatedContainer(
                          height: textContent.text.isEmpty ? 80 : 135,
                          padding: Padding6,
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: 
                            (indexModel.userConfig.isProxyMode ?? false) ? 
                            judgeCurrentThemeColor(context).withValues(alpha: 0.3) : 
                            Colors.grey.shade700
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
                                    value: indexModel.userConfig.isImgTagProxy ?? true,
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
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    child: ListTile(
                      leading: const Icon(Icons.wifi),
                      title: const ScalableText('网页与API连通性检查'),
                      subtitle: ScalableText('点击对应项目可以单独测试', style: TextStyle(color: Colors.grey, fontSize: AppFontSize.s14)),
                      trailing: TextButton(
                        onPressed: () {
                          Future.wait(
                            List.generate(connectionTestUrlMap.length, (index) {

                              latencyResultNotifierList[index].value = "loading";

                              return checkLatency(
                                targetUrl: connectionTestUrlMap.values.elementAt(index),
                                proxyAddress: (indexModel.userConfig.isProxyMode ?? false) ? httpProxyAddressEditingController.text : null
                              ).then((value) {
                                  debugPrint("[Network Latency] ${connectionTestUrlMap.values.elementAt(index)} $value ms");
                                  latencyResultNotifierList[index].value = "$value";
                                });
                            })
                          );
                        },
                        child: const Text("全部测试")
                      ),
                    )

                  ),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: judgeCurrentThemeColor(context).withValues(alpha: 0.15),
                    ),
                    padding: PaddingV6,
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      itemExtent: kToolbarHeight,
                      shrinkWrap: true,
                      children: List.generate(
                        connectionTestUrlMap.length, (index) {

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
                              connectionTestUrlMap.values.elementAt(index),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey, fontSize: AppFontSize.s12)
                            ),
                            onTap: () {

                              latencyResultNotifierList[index].value = "loading";

                              checkLatency(
                                targetUrl: connectionTestUrlMap.values.elementAt(index),
                                proxyAddress: judgeIsProxyMode(context) ? httpProxyAddressEditingController.text : null
                              ).then((value) {
                                  debugPrint("[Network Latency] ${connectionTestUrlMap.values.elementAt(index)} $value ms");
                                  latencyResultNotifierList[index].value = "$value";
                                });

                            },
                          );
                        }
                      )

                    ),
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

Future<int> checkLatency({String targetUrl = "", String? proxyAddress}) async {
  final stopwatch = Stopwatch()..start();

  try {

    final dio = Dio();

    dio.httpClientAdapter = HttpApiClient.configHTTPProxySetting(proxyAddress ?? "");

    await dio.head(
      targetUrl,
    ).timeout(const Duration(seconds: 5));
    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  } 

  on DioException catch (e) {
    debugPrint("[Network Latency] ${extractDioException(e)}");
    stopwatch.stop();
    return -1;
  }

  on TimeoutException {
    stopwatch.stop();
    return -1;
  }
}

