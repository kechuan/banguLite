import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/components/color_palette.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

@FFRoute(name: 'settings')
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {

    const List<Widget> appearanceConfigList = [
      FontSizeTile(),
      ColorThemeTile(),
      ThemeModeTile(),
    ];

    const List<Widget> behaviourConfigList = [
      CommentImageLoadModeTile(),
      ClearCacheTile(),
      ConfigTile(),
      AboutTile(),
      TestTile()
    ];


    return Scaffold(
      appBar: AppBar(title: const ScalableText("设置")),

      body: EasyRefresh(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),


          child: Theme(
            data: Theme.of(context).copyWith(
              scrollbarTheme : const ScrollbarThemeData(
                thickness: WidgetStatePropertyAll(0.0)
              ),
            ),
            child: ListView(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: judgeCurrentThemeColor(context).withValues(alpha: 0.2)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    
                    children: [
                  
                      Padding(
                        padding: PaddingH16V12,
                        child: ScalableText("外观",style:TextStyle(color:Colors.grey.withValues(alpha: 0.8))),
                      ),
                  
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: appearanceConfigList.length,
                        itemBuilder: (context, index) {
                          return appearanceConfigList[index];
                        },
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        
                      ),
                    
                    
                    
                    ],
                  ),
                ),
            
                const Padding(padding: PaddingV16),
            
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: judgeCurrentThemeColor(context).withValues(alpha: 0.2)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    
                    children: [
                  
                      Padding(
                        padding: PaddingH16V12,
                        child: ScalableText("设置",style:TextStyle(color:Colors.grey.withValues(alpha: 0.8))),
                      ),
                  
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: behaviourConfigList.length,
                        itemBuilder: (context, index) {
                          return behaviourConfigList[index];
                        },
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        
                      ),
                    
                    
                    
                    ],
                  ),
                ),
              
              ],
            ),
          ),
        ),
      ),

      //body: EasyRefresh(
      //  child: ListView.separated(
      //  shrinkWrap: true,
      //  itemCount: configWidgetList.length,
      //  itemBuilder: (context, index) {
      //    return configWidgetList[index];
      //  },
      //  separatorBuilder: (context, index) => const Divider(height: 1),
          
      //  ),
      //),


    );
  }
}

class FontSizeTile extends ListTile {
  const FontSizeTile({super.key});

  @override
  Widget build(BuildContext context) {

    final indexModel = context.read<IndexModel>();

    return Selector<IndexModel,ScaleType>(
      selector: (_, indexModel) => indexModel.userConfig.fontScale!,
      builder: (_,fontScale,child){
        return ListTile(
          title: Row(
            spacing: 12,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ScalableText("文字大小",style: TextStyle(fontSize: AppFontSize.s16)),
    
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:  50*(ScaleType.values.length).toDouble(),
                    maxHeight: 60,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey.withValues(alpha: 0.2)
                    ),
                    child: DefaultTabController(
                      initialIndex: fontScale.index,
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
                        tabs: List.generate(5, (index) => Center(child: Text(ScaleType.values[index].sacleName)))
                      ),
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

class ColorThemeTile extends ListTile{
  const ColorThemeTile({super.key});

  @override
  Widget build(BuildContext context) {

    final indexModel = context.read<IndexModel>();

    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Selector<IndexModel,Color?>(
            selector: (_, indexModel) => judgeCurrentThemeColor(context),
            shouldRebuild: (previous, next) => previous!=next,
            builder: (_,currentColor,child) => ScalableText("主题色设置",style: TextStyle(color: judgeCurrentThemeColor(context).withValues(alpha: 0.8)))
          ),

          Flexible(
            child: SizedBox(
            width: 50*(BangumiThemeColor.values.length+1),
            height: 50,
            child: ListView.builder(
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: BangumiThemeColor.values.length+1,
              itemExtent: 50,
              itemBuilder: (_, index) {
    
                return Stack(
                  children: [

                    SizedBox(
                      width: 50,
                      height: 50,
                      child: Padding(
                        padding: PaddingH6,
                        child: UnVisibleResponse(
                          onTap: () {
                            if(index != BangumiThemeColor.values.length){
                              indexModel.updateThemeColor(BangumiThemeColor.values[index]);
                            }
                          
                            else{
                              //show 调色板
                              showModalBottomSheet(
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.sizeOf(context).width*5/6,
                                  maxHeight: 400
                                ),
                                context: context,
                                builder: (_){
                                  final Color color = indexModel.userConfig.customColor ?? indexModel.userConfig.currentThemeColor!.color;
                                  return HSLColorPicker(selectedColor:color);
                                }
                              ).then((newColor){
                                if(newColor!=null) indexModel.updateCustomColor(newColor);
                              });
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
                      ),
                    ),

                    Selector<IndexModel,BangumiThemeColor?>(
                      selector: (_,indexModel) => indexModel.userConfig.currentThemeColor,
                      shouldRebuild: (previous, next){
                        if(indexModel.userConfig.isSelectedCustomColor == true) return true;
                        return previous!=next;
                      },
                      builder: (_,themeColor,child) {
                        return IgnorePointer(
                          child: Center(
                            child: Builder(
                              builder: (_) {
                                if(index == BangumiThemeColor.values.length){
                                  return Offstage(
                                    offstage: !(indexModel.userConfig.isSelectedCustomColor == true),
                                    child: Icon(Icons.done,color: judgeCurrentThemeColor(context))
                                  );
                                }
                          
                                return Offstage(
                                  offstage: !(themeColor == BangumiThemeColor.values.elementAt(index) && indexModel.userConfig.isSelectedCustomColor == false),
                                  child: Icon(Icons.done,color: judgeCurrentThemeColor(context))
                                );
                              }
                            ),
                          ),
                        );
                      }
                    ),
                     
                    
                  ],
                );
              },
            ),
          )
        
          )


    
          ],
      ),
      subtitle: Selector<IndexModel,bool?>(
        selector: (_, indexModel) => indexModel.userConfig.isFollowThemeColor,
        shouldRebuild: (previous, next) => previous!=next,
        builder: (_,followStatus,child){
          return Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("番剧详细页是否跟随主题色"),
                Switch(
                  value: followStatus ?? false, 
                  onChanged: (value){
                    indexModel.updateFollowThemeColor(value);
                  }
                ),
              ],
            ),
          );
        }
      ),
    );
    
  }

}

class ThemeModeTile extends ListTile{
  const ThemeModeTile({super.key});

  @override
  Widget build(BuildContext context) {
    final indexModel = context.read<IndexModel>();

    return ListTile(
      title: Row(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ScalableText("明亮模式",style: TextStyle(fontSize: AppFontSize.s16)),
        
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 100*(ThemeMode.values.length).toDouble(),
                maxHeight: 60,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.withValues(alpha: 0.2)
                ),
                child: DefaultTabController(
                  initialIndex: indexModel.userConfig.themeMode!.index,
                  length: ThemeMode.values.length,
                  child: TabBar(
                    labelPadding: const EdgeInsets.all(0),
                    onTap: (value) {
                      switch(value){
                        case 0: indexModel.updateThemeMode(ThemeMode.system,config:true); break;
                        case 1: indexModel.updateThemeMode(ThemeMode.light,config:true); break;
                        case 2: indexModel.updateThemeMode(ThemeMode.dark,config:true); break;
                      }
                      
                    },
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: const [
                      Center(child: Text("系统")),
                      Center(child: Text("明亮")),
                      Center(child: Text("黑暗")),
                    ]
                  ),
                ),
              ),
            ),
          ),
      
        ],
      ),
        
    );
  }

}

class CommentImageLoadModeTile extends ListTile{
  const CommentImageLoadModeTile({super.key});

  @override
  Widget build(BuildContext context) {

    final indexModel = context.read<IndexModel>();

    return SizedBox(
      height: 80,
      child: Center(
        child: Selector<IndexModel,bool?>(
            selector: (_, indexModel) => indexModel.userConfig.isManuallyImageLoad,
            shouldRebuild: (previous, next) => previous!=next,
            builder: (_,manualStatus,child){
              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("评论区是否手动加载图片"),
                    Switch(
                      value: manualStatus ?? true, 
                      onChanged: (value) => indexModel.updateCommentImageLoadMode(value)
                    ),
                  ],
                ),
              );
            }
          ),
      ),
    );


    
      
    
  }

}

class ClearCacheTile extends ListTile{
  const ClearCacheTile({super.key});

  @override
  Widget build(BuildContext context) {

    ValueNotifier<bool> computingStatusNotifier = ValueNotifier<bool>(false);

    return Selector<IndexModel,int>(
      selector: (_, indexModel) => indexModel.cachedImageSize,
      builder: (_, cachedImageSize, child) {
        return SizedBox(
          height: 80,
          child: Center(
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
                  ScalableText("清除图像缓存",style: TextStyle(fontSize: AppFontSize.s16)),
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

            
            ),
          ),
        );
      }
    );
      
    
  }

}

class ConfigTile extends ListTile{
  const ConfigTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Center(
        child: ListTile(
          onTap: (){
            final indexModel = context.read<IndexModel>();
            showDialog(
              context: context,
              builder: (_){
                return AlertDialog(
                  title: const ScalableText("重置配置确认"),
                  content: const ScalableText("要恢复默认配置吗"),
                  actions:[
                    TextButton(
                      onPressed: ()=> Navigator.of(context).pop(),
                      child: const ScalableText("取消")
                    ),
                    TextButton(
                      onPressed: (){
                        indexModel.resetConfig();
                        Navigator.of(context).pop();
                      }, 
                      child: const ScalableText("确认")
                    )
                  ]
                );
              }
            );
          },
          title: ScalableText("重置设置",style: TextStyle(fontSize: AppFontSize.s16)),
        ),
      ),
    );
      
    
  }

}

class AboutTile extends ListTile{
  const AboutTile({super.key});

  @override
  Widget build(BuildContext context) {
    
    return SizedBox(
      height: 80,
      child: Center(
        child: ListTile(
          onTap: (){
            removeAsyncContextPush() => Navigator.pushNamed(context, Routes.about);
            precacheImage(
              const AssetImage('assets/icons/icon.png'),
              context
            ).then((_)=>removeAsyncContextPush());
            
          },
          title: ScalableText("关于",style: TextStyle(fontSize: AppFontSize.s16))
        ),
      ),
    );

    }

}

class TestTile extends ListTile{
  const TestTile({super.key});

  @override
  Widget build(BuildContext context) {
    
    return SizedBox(
      height: 80,
      child: Center(
        child: ListTile(
          trailing: IconButton(
            onPressed: (){
              
            }, 
            icon: const Icon(Icons.cookie)
          ),
          onTap: ()=> launchUrlString(BangumiWebUrls.webAuthPage()),
          title: ScalableText("登入",style: TextStyle(fontSize: AppFontSize.s16))
        ),
      ),
    );

    }

}
