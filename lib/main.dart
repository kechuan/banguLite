import 'dart:io';


import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/internal/platforms/register_windows_applink.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/timeline_flow_model.dart';
import 'package:bangu_lite/models/providers/user_model.dart';
import 'package:bangu_lite/models/providers/webview_model.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
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

  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // path_provider 初始化需要
  WidgetsFlutterBinding.ensureInitialized();
  await listenAPPLink();

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
          return Selector<IndexModel,(Color,ThemeMode?)>(
            selector: (_, indexModel){
              if(indexModel.userConfig.isSelectedCustomColor == true){
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
            
            builder: (_, currentRecord, child){
              return MaterialApp(
				
                scaffoldMessengerKey: scaffoldMessengerKey,
				
                //debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: currentRecord.$1),
                  fontFamilyFallback:convertSystemFontFamily(),
                ),
                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  fontFamilyFallback:convertSystemFontFamily(),
                  //colorScheme: ColorScheme.fromSeed(seedColor: currentRecord.$1),

				  /// 比用 dividerColor: Colors.grey 好
				  expansionTileTheme: ExpansionTileThemeData(
					shape: Border.symmetric(
						horizontal: BorderSide(color:Colors.grey),
					),
				  ),
				  

				  scaffoldBackgroundColor: judgeDarkContentSurfaceColor(context),
				  
                  colorScheme: ColorScheme.dark(
                    primary: currentRecord.$1,
                    onPrimary: Colors.white, //unSelected颜色
                    secondary: currentRecord.$1.withValues(alpha: 0.8), // Selected 底色颜色(Button 一类)
                    onSecondary:currentRecord.$1, //onSelected 的内部颜色(内部Widget/Text 一类)

                    outline: Colors.white,

					//主要目的给 dividerColor 使用 
					outlineVariant: Colors.grey
                  )
                ),
                themeMode: currentRecord.$2,
                  
                initialRoute: Routes.index,
                navigatorObservers: [Lifecycle.lifecycleRouteObserver],
                onGenerateRoute: (RouteSettings settings)  {

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
