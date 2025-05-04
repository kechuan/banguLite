import 'dart:io';

import 'package:bangu_lite/catalogs/index/bangumi_index_page.dart';
import 'package:bangu_lite/catalogs/surf/bangumi_login_auth_page.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/internal/platforms/register_windows_applink.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/timeline_flow_model.dart';
import 'package:bangu_lite/models/providers/user_model.dart';
import 'package:bangu_lite/models/providers/webview_model.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/routes/bangu_lite_route.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {

  String? listenLink;

  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // path_provider 初始化需要
  WidgetsFlutterBinding.ensureInitialized();
  listenLink = await listenAPPLink();

  HttpApiClient.init();
  await MyHive.init();

  if(Platform.isAndroid){
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

  runApp(MainApp(initialLink: listenLink));

}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
    this.initialLink,
  });

  final String? initialLink;

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
          return Selector<IndexModel,Color>(
            selector: (_, indexModel){
              if(indexModel.userConfig.isSelectedCustomColor == true){
                return indexModel.userConfig.customColor!;
              }

              return indexModel.userConfig.currentThemeColor!.color;
            },
            shouldRebuild: (previous, next) => previous!=next,
            builder: (_, currentColor, child){
              return MaterialApp(
                //debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: currentColor),
                  //fontFamilyFallback: convertSystemFontFamily(),
                  fontFamilyFallback:convertSystemFontFamily()
                  
                ),
                darkTheme: ThemeData( 
                  brightness: Brightness.dark,
                  //fontFamilyFallback: convertSystemFontFamily(),
                  fontFamilyFallback:convertSystemFontFamily(),
                  
                  colorScheme: ColorScheme.dark(
                    primary: currentColor,
                    onPrimary: Colors.white, //unSelected颜色
                    secondary: Colors.white,
                    onSecondary:currentColor, //onSelected 的颜色
                    surface: Colors.black,
                    outline: Colors.white,
                  )
                ),
                themeMode: context.watch<IndexModel>().userConfig.themeMode,
                  
                initialRoute: Routes.index,
                //navigatorObservers: [],
                navigatorObservers: [Lifecycle.lifecycleRouteObserver],
                onGenerateRoute: (RouteSettings settings) {
                  return onGenerateRoute(
                    settings: settings,
                    getRouteSettings: getRouteSettings,
                  );
                },
                onGenerateInitialRoutes: (String initialRoute) {
                  
                  if (initialLink != null && initialLink!.isNotEmpty) {
                    // 深链接存在，跳过默认路由匹配，直接跳转到目标页面
                    return [
                      MaterialPageRoute(
                        settings: const RouteSettings(name: Routes.loginAuth),
                        builder: (context) => const BangumiAuthPage(key: Key('loginAuth')),
                      ),
                    ];
                  }

                  // 没有深链接，进入正常首页
                  return [
                    MaterialPageRoute(
                      settings: const RouteSettings(name: Routes.index),
                      builder: (context) => const BangumiIndexPage(key: Key('index')),
                    ),
                  ];
                },
              );
            }
            

            
            
            
          );
        }
      ),
    );
  }

  

}
