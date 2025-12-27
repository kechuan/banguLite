
import 'dart:async';

import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/widgets/views/index_landscape.dart';
import 'package:bangu_lite/widgets/views/index_portial.dart';
import 'package:flutter/services.dart';

@FFRoute(name: '/index')

class BangumiIndexPage extends StatefulWidget{
  const BangumiIndexPage({super.key});
  @override
  State<BangumiIndexPage> createState() => _BangumiIndexPageState();
}

class _BangumiIndexPageState extends State<BangumiIndexPage>{

  
  final ValueNotifier<int> selectedPageIndexNotifier = ValueNotifier<int>(0);
  
  bool readyQuitFlag = false;
  bool isDrawerOpen = false;
  

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
      
          if(!readyQuitFlag){
            readyQuitFlag = true;
      
            Future.delayed(const Duration(seconds: 3)).then((_)=>readyQuitFlag = false);
            
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                backgroundColor:judgeCurrentThemeColor(context),
                content: const ScalableText("再返回一次以退出",style: TextStyle(color: Colors.black)),
                duration: const Duration(seconds: 3),
              )
            );
            
          }
      
          else{
            await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }
      
        },
        child: OrientationBuilder(
          builder: (_,orientation){
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
    
    if(Scaffold.of(innerContext).isDrawerOpen){
      Scaffold.of(innerContext).closeDrawer();
      return;
    }


  }

}
