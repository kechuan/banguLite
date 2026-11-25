
import 'dart:async';

import 'package:bangu_lite/catalogs/about_page.dart';
import 'package:bangu_lite/internal/bus_register_method.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/get.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/dialogs/new_update_dialog.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/views/index_landscape.dart';
import 'package:bangu_lite/widgets/views/index_portial.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

@FFRoute(name: '/index')

class BangumiIndexPage extends StatefulWidget{
  const BangumiIndexPage({super.key});
  @override
  State<BangumiIndexPage> createState() => _BangumiIndexPageState();
}

class _BangumiIndexPageState extends State<BangumiIndexPage>{

  final ValueNotifier<int> selectedPageIndexNotifier = ValueNotifier<int>(0);
  StreamSubscription<AppRouteEvent>? appRouteSubscription;
  StreamSubscription<String>? loginRouteSubscription;

  bool readyQuitFlag = false;
  bool isDrawerOpen = false;

  @override
  void initState() {
    super.initState();

    // 全局账号会话与路由事件在根壳页统一初始化，避免依赖具体 Tab 页生命周期
    context.read<AccountModel>().initModel(context);

    appRouteSubscription = bus.onAppRoute((event) {
      if (!mounted) return;
      appRouteMethodListener(context, event.link, data: event.data);
    });

    loginRouteSubscription = bus.onLoginRoute((link) {
      if (!mounted) return;
      appLoginMethodListener(context, link);
    });

    cleanInstalledPackageCache(APPInformationRepository.version);

    if (context.read<IndexModel>().userConfig.isUpdateAlert != false) {
      checkAppUpdate();
    }
  }

  Future<void> checkAppUpdate() async {
    final latestRelease = await pullLatestRelease();

    if (!mounted || latestRelease == null || latestRelease.hasErrors) return;

    if (APPInformationRepository.version == latestRelease.tagName) return;

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    showRequestSnackBar(
      message: "检测到新版本",
      trailingWidget: TextButton(
        onPressed: () {
          if (!mounted) return;
          showUpdateDialog(context, latestRelease);
        },
        child: const Text('去更新', style: TextStyle(color: Colors.black)),
      ),
      backgroundColor: getCurrentThemeColor(context),
    );
  }

  @override
  void dispose() {
    appRouteSubscription?.cancel();
    loginRouteSubscription?.cancel();
    selectedPageIndexNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return NotificationListener<DrawerStatusNotification>(
      onNotification: (isOpenNotification) {
        // 接收到里层的状态，更新本地变量
        isDrawerOpen = isOpenNotification.isOpen;
        return true; // 停止通知继续冒泡
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, __) async {

          //if(ModalRoute.of(context)?.isCurrent != true) return;
          debugPrint("drawer:${ModalRoute.of(context)?.isCurrent}");

          if (isDrawerOpen) return;

          if (!readyQuitFlag) {
            readyQuitFlag = true;

            Future.delayed(const Duration(seconds: 3)).then((_) => readyQuitFlag = false);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: getCurrentThemeColor(context),
                content: const ScalableText("再返回一次以退出", style: TextStyle(color: Colors.black)),
                duration: const Duration(seconds: 3),
              )
            );

          }

          else {
            await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }

        },
        child: OrientationBuilder(
          builder: (_, orientation) {
            return orientation == Orientation.portrait ?
            IndexPortial(
              selectedPageIndexNotifier: selectedPageIndexNotifier,
              onPop: invokeDrawerPopOut,
            ) :
            IndexLandscape(
              selectedPageIndexNotifier: selectedPageIndexNotifier
            );
          }
        ),
      ),
    );

  }

  void invokeDrawerPopOut(BuildContext innerContext) async {

    if (Scaffold.of(innerContext).isDrawerOpen) {
      Scaffold.of(innerContext).closeDrawer();
      return;
    }

  }

}
