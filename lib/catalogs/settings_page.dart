import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';


@FFRoute(name: 'settings')
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {

    const List<Widget> configWidgetList = [
      FontSizeTile(),
      ColorThemeTile(),
      ClearCacheTile(),
      ConfigTile(),
    ];

    return Scaffold(
      appBar: AppBar(title: const ScalableText("设置")),

      body: EasyRefresh(
        child: ListView.separated(
        shrinkWrap: true,
        itemCount: configWidgetList.length,
        itemBuilder: (context, index) {
          return configWidgetList[index];
        },
        separatorBuilder: (context, index) => const Divider(height: 1),
          
        ),
      ),
    );
  }
}

class FontSizeTile extends StatelessWidget {
  const FontSizeTile({super.key});

  @override
  Widget build(BuildContext context) {


    return Consumer<IndexModel>(
          builder: (_,indexModel,child){
            return ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ScalableText("文字大小",style: TextStyle(fontSize: AppFontSize.s16)),
        
                  SizedBox(
                    height: 60,
                    width: 50*(ScaleType.values.length+0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey.withValues(alpha: 0.2)
                      ),
                      child: DefaultTabController(
                        initialIndex: indexModel.userConfig.fontScale!.index,
                        length: ScaleType.values.length,
                        child: TabBar(
                          labelPadding: const EdgeInsets.all(0),
                          onTap: (value) {
                            switch(value){
                              case 0: indexModel.updateFontSize(ScaleType.min); break;
                              case 1: indexModel.updateFontSize(ScaleType.less); break;
                              case 2: indexModel.updateFontSize(ScaleType.medium); break;
                              case 3: indexModel.updateFontSize(ScaleType.more); break;
                              case 4: indexModel.updateFontSize(ScaleType.max); break;
                            }
                            
                          },
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.label,
                          tabs: const [
                            Center(child: Text("小")),
                            Center(child: Text("偏小")),
                            Center(child: Text("中")),
                            Center(child: Text("偏大")),
                            Center(child: Text("大")),
                          ]
                        ),
                      ),
                    ),
                  ),
             
                ],
              ),
        
            );
          }
        );

    
    
  }
}

class ColorThemeTile extends StatelessWidget{
  const ColorThemeTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IndexModel>(
      builder: (_,indexModel,child){
        return ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ScalableText("主题色设置",style: TextStyle(color: indexModel.userConfig.currentThemeColor!.color.withValues(alpha: 0.8))),

              SizedBox(
                width: 50*(BangumiThemeColor.values.length+1),
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: BangumiThemeColor.values.length+1,
                  
                  itemExtent: 50,
                  itemBuilder: (_, index) {

                    return Padding(
                      padding: PaddingH6,
                      child: UnVisibleResponse(
                        onTap: () {
                          if(index != BangumiThemeColor.values.length){
                            indexModel.updateThemeColor(BangumiThemeColor.values[index]);
                          }

                          else{
                            //show 调色板
                          }
                          
                        },
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: index == BangumiThemeColor.values.length ? 
                              LinearGradient(
                              begin:Alignment.bottomCenter,
                              end:Alignment.topCenter,
                              stops:const [0.2,0.4,0.5,1],
                              colors: [
                                Colors.red.withValues(alpha: 0.6),
                                Colors.green.withValues(alpha: 0.6),
                                Colors.blue.withValues(alpha: 0.6),
                                Colors.yellow.withValues(alpha: 0.6),
                              ]
                            ) : null,
                            color: index != BangumiThemeColor.values.length ? BangumiThemeColor.values[index].color.withValues(alpha: 0.8) : null
                          ),
                          
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("番剧详细页是否跟随主题色"),
                Switch(
                  value: indexModel.userConfig.detailfollowThemeColor!, 
                  onChanged: (value){
                    indexModel.updateFollowThemeColor(value);
                  }
                ),
              ],
            ),
          ),
        );
      }
    );
    
  }

}

class ClearCacheTile extends StatelessWidget{
  const ClearCacheTile({super.key});

  @override
  Widget build(BuildContext context) {

    ValueNotifier<bool> computingStatusNotifier = ValueNotifier<bool>(false);

    return Selector<IndexModel,int>(
      selector: (_, indexModel) => indexModel.cachedImageSize,
      builder: (_, cachedImageSize, child) {
        return SizedBox(
          height: 80,
          child: ListTile(
            onTap: () async {
              //Dialog: DefaultCacheManager().emptyCache();
              computingStatusNotifier.value = true;

              final indexModel = context.read<IndexModel>();

              await MyHive.cachedImageDir.delete(recursive: true).then((_){
                indexModel.updateCachedSize().then(
                  (_)=>computingStatusNotifier.value = false
                );
                        
              });
            },
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(alignment: Alignment.centerLeft,child: ScalableText("清除缓存",style: TextStyle(fontSize: AppFontSize.s16))),
                Row(
                  children: [
                    IconButton(
                      onPressed: (){
                        context.read<IndexModel>().updateCachedSize().then((_)=>computingStatusNotifier.value = false);
                        computingStatusNotifier.value = true;
                      },
                      icon: const Icon(Icons.refresh)
                    ),
                    ValueListenableBuilder(
                      valueListenable: computingStatusNotifier,
                      builder: (_,computingStatus,child) {
                        return computingStatus ? const ScalableText("Computing...") : ScalableText(convertTypeSize(cachedImageSize));
                      }
                    ),
                  ],
                ),
              ],
            ),
            //trailing: 
          
          ),
        );
      }
    );
      
    
  }

}

class ConfigTile extends StatelessWidget{
  const ConfigTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IndexModel>(
      builder: (_, indexModel, child) {
        return SizedBox(
          height: 80,
          child: ListTile(
            onTap: () {
              MyHive.appConfigDataBase.clear();
            },
            title: Align(alignment: Alignment.centerLeft,child: ScalableText("重置设置",style: TextStyle(fontSize: AppFontSize.s16))),

            trailing: SizedBox(
              width: 200,
              child: Row(
                children: [
                  
                  TextButton(
                    onPressed: (){
                      //MyHive.appConfigDataBase.put("currentTheme", indexModel.userConfig);
                      MyHive.appConfigDataBase.put("currentTheme", indexModel.userConfig);
                      //debugPrint("config:${indexModel.userConfig}");
                    }, 
                    child: const ScalableText("保存配置")
                  ),
              
                  TextButton(
                    onPressed: (){
                      debugPrint("${MyHive.appConfigDataBase.values}");
                    }, 
                    child: const ScalableText("读取配置")
                  ),
              
                ],
              ),
            ),

           
          
          ),
        );
      }
    );
      
    
  }

}