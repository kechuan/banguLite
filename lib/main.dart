import 'dart:io';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/internal/platforms/register_windows_applink.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/utils/judge.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/models/providers/timeline_flow_model.dart';
import 'package:bangu_lite/models/providers/user_model.dart';
import 'package:bangu_lite/models/providers/webview_model.dart';
import 'package:bangu_lite/routes/bangu_lite_route.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

///感觉zone内容对于我这个项目还是太超标了 有错误还是老老实实扔在我的debug阶段吧

///[Claude] 新增 - 最近若干条运行期错误的内存缓冲
/// release 下 debugPrint 被置空(见下方), 线上任何异常原本不留任何痕迹, 用户报"卡住了"时无从定位.
/// 这里只在内存中保留最近 50 条, 不落盘、不上报; 后续若要加"导出日志"入口可直接读这个列表.
//class RuntimeErrorRecorder {
//  const RuntimeErrorRecorder._();

//  static const int maxRecordCount = 50;
//  static final List<String> records = [];

//  static void record(String scope, Object error, StackTrace? stack) {
//    if (records.length >= maxRecordCount) records.removeAt(0);
//    records.add('[$scope] $error\n$stack');

//    // debug 下仍然照常打印, 保持原有排查手感
//    debugPrint('[$scope] $error');
//  }
//}

void main() async {

  ///[Claude] 整体包进 runZonedGuarded, 捕获原本会静默逃逸的异步异常
  /// 注意 WidgetsFlutterBinding.ensureInitialized() 必须与 runApp 处在同一个 zone 内, 故一并移入.
  /// (error, stack) => RuntimeErrorRecorder.record('Zone', error, stack),
  //  (error, stack) => debugPrint('Zone: $error'),
  //);
  /// 拒绝采用

  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth})  {};
  }

  // path_provider 初始化需要
  WidgetsFlutterBinding.ensureInitialized();

  ///[Claude] 新增 - Widget 构建/布局/绘制期异常的统一入口
  //FlutterError.onError = (details) {
  //  RuntimeErrorRecorder.record('FlutterError', details.exception, details.stack);
  //  FlutterError.presentError(details);
  //};

  /////[Claude] 新增 - 平台层未捕获的异步异常(返回 true 表示已处理, 避免直接终止)
  //PlatformDispatcher.instance.onError = (error, stack) {
  //  RuntimeErrorRecorder.record('PlatformDispatcher', error, stack);
  //  return true;
  //};

  await listenAPPLink();

  await MyHive.init();

  //兼容性调整 只要不明确为false 即可采用 即使是空的也是默认DIRECT
  HttpApiClient.init(
    storageProxyAddress: 
    MyHive.appConfigDataBase.get('currentTheme')?.isProxyMode != false ? 
    MyHive.appConfigDataBase.get('currentTheme')?.currentProxyAddress ?? '' :
    ''
  );

  if (Platform.isAndroid) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,  // 使用 edgeToEdge 模式
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  runApp(const MainApp());





}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key
  });

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<IndexModel>(create: (_) => IndexModel()),
        ChangeNotifierProvider<TimelineFlowModel>(create: (_) => TimelineFlowModel()),
        ChangeNotifierProvider<AccountModel>(create: (_) => AccountModel()),
        ChangeNotifierProvider<UserModel>(create: (_) => UserModel()),
        ChangeNotifierProvider<WebViewModel>(create: (_) => WebViewModel()),
      ],

      child: Builder(
        builder: (context) {
          return Selector<IndexModel, (Color,ThemeMode?)>(
            selector: (_, indexModel) {
              if (indexModel.userConfig.isSelectedCustomColor == true) {
                return (
                  indexModel.userConfig.customColor!,
                  indexModel.userConfig.themeMode
                );
              }

              return (
                indexModel.userConfig.currentThemeColor!.color,
                indexModel.userConfig.themeMode
              );
            },

            builder: (_, currentRecord, child) {
              return MaterialApp(

                scaffoldMessengerKey: scaffoldMessengerKey,

                //debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: currentRecord.$1),
                  fontFamilyFallback: convertSystemFontFamily(),
                ),
                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  fontFamilyFallback: convertSystemFontFamily(),
                  //colorScheme: ColorScheme.fromSeed(seedColor: currentRecord.$1),

                  /// 比用 dividerColor: Colors.grey 好
                  expansionTileTheme: const ExpansionTileThemeData(
                    shape: Border.symmetric(
                      horizontal: BorderSide(color: Colors.grey),
                    ),
                  ),

                  scaffoldBackgroundColor: judgeDarkContentSurfaceColor(context),

                  colorScheme: ColorScheme.dark(
                    primary: currentRecord.$1,
                    onPrimary: Colors.white, //unSelected颜色
                    secondary: currentRecord.$1.withValues(alpha: 0.8), // Selected 底色颜色(Button 一类)
                    onSecondary: currentRecord.$1, //onSelected 的内部颜色(内部Widget/Text 一类)

                    outline: Colors.white,

                    //主要目的给 dividerColor 使用 
                    outlineVariant: Colors.grey
                  )
                ),
                themeMode: currentRecord.$2,

                initialRoute: Routes.index,
                navigatorObservers: [Lifecycle.lifecycleRouteObserver],
                onGenerateRoute: (RouteSettings settings) {

                  // 深链接auth访问时 跳过默认路由匹配，直接跳转到目标页面
                  if (
                  settings.name?.contains("bgm_login") == true ||
                    settings.name?.contains("turnstile") == true
                  ) {
                    return null;
                  }

                  return onGenerateRoute(
                    settings: settings,
                    getRouteSettings: getRouteSettings,
                  );
                }

              );
            }

          );
        }
      ),
    );
  }



}
