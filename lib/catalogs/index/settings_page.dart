import 'dart:io';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/catalogs/test_page.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/components/color_palette.dart';
import 'package:bangu_lite/widgets/components/transition_container.dart';
import 'package:bangu_lite/widgets/dialogs/inital_image_storage_dialog.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:docman/docman.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/foundation.dart';
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
	    ImageStorageManageTile(),
      ClearCacheTile(),
      ConfigTile(),
      AboutTile(),
      if(kDebugMode) TestTile()
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
                        child: ScalableText("功能设置",style:TextStyle(color:Colors.grey.withValues(alpha: 0.8))),
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

                const Padding(padding: PaddingV16),

              ],
            ),
          ),
        ),
      ),

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
                        tabs: List.generate(ScaleType.values.length, (index) => Center(child: Text(ScaleType.values[index].sacleName)))
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
            width: 50*(AppThemeColor.values.length+1),
            height: 50,
            child: ListView.builder(
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: AppThemeColor.values.length+1,
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
                            if(index != AppThemeColor.values.length){
                              indexModel.updateThemeColor(AppThemeColor.values[index]);
                            }
                          
                            else{
                              //show 调色板
                              showModalBottomSheet(
                                isScrollControlled: true,
                                enableDrag: false,
                                backgroundColor: Colors.transparent,
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.sizeOf(context).width*5/6,
                                  maxHeight: 450
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
                              gradient: index == AppThemeColor.values.length ? 
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
                              color: index != AppThemeColor.values.length ? AppThemeColor.values[index].color.withValues(alpha: 0.8) : null
                            ),
                            
                          ),
                        ),
                      ),
                    ),

                    Selector<IndexModel,AppThemeColor?>(
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
                                if(index == AppThemeColor.values.length){
                                  return Offstage(
                                    offstage: !(indexModel.userConfig.isSelectedCustomColor == true),
                                    child: Icon(Icons.done,color: judgeCurrentThemeColor(context))
                                  );
                                }
                          
                                return Offstage(
                                  offstage: !(themeColor == AppThemeColor.values.elementAt(index) && indexModel.userConfig.isSelectedCustomColor == false),
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
                    const ScalableText("评论区是否手动加载图片"),
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

                computingStatusNotifier.value = true;
                context.read<IndexModel>().updateCachedSize().then((_)=>computingStatusNotifier.value = false);
                
              },
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ScalableText("清除图像缓存",style: TextStyle(fontSize: AppFontSize.s16)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {

                          computingStatusNotifier.value = true;
            
                          final indexModel = context.read<IndexModel>();

                          if(MyHive.cachedImageDir.existsSync()){
                            await MyHive.cachedImageDir.delete(recursive: true).then((_){
                              indexModel.updateCachedSize().then(
                                (_)=>computingStatusNotifier.value = false
                              );
                            });
                          }
                          
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

class ImageStorageManageTile extends ListTile{
  const ImageStorageManageTile({super.key});

  

	@override
	Widget build(BuildContext context) {

		final ValueNotifier<int> updateStorageNotifier = ValueNotifier(0);

		Future<String> imageStoragePath = getImageStoragePath();
		
		return Center(
			child: ListTile(
				title: Row(
					mainAxisAlignment: MainAxisAlignment.spaceBetween,
					children: [
						ScalableText("手动保存的图片位置",style: TextStyle(fontSize: AppFontSize.s16)),

            Row(
              spacing: 12,
              children: [

                TextButton(
                  onPressed: () {
                
                    if(Platform.isAndroid){
                      initalImageStorageDialog(context).then((result){
                        if(result != null){
                          imageStoragePath = getImageStoragePath();
                          updateStorageNotifier.value += 1;
                        }
                      });
                    }
                
                    else{

                      launchUrlString(
                        MyHive.downloadImageDir!.path,
                        mode: LaunchMode.externalApplication,
                      );

                    }
                
                    
                
                  }, 
                  child: ScalableText(Platform.isAndroid ? "设置" : "打开目录")
                ),

              

              ],


            )
					
          ],
				),
				subtitle: Padding(
          padding: PaddingV12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.6)
            ),
            child: Padding(
              padding: Padding6,
              child: ValueListenableBuilder(
                valueListenable: updateStorageNotifier,
                builder: (_, __, ___) {
                return FutureBuilder(
                  future: imageStoragePath,
                  builder: (_, snapshot) {
                
                    String resultText = "";
                
                    switch(snapshot.connectionState) {
          
                      case ConnectionState.waiting:{
                        resultText = "正在检查...";
                      }
                        
                      case ConnectionState.done:{
                        resultText = snapshot.data ?? "";
                      }
                
                      default:{} 
                    }
                
                
                    return ScalableText("存储目录: $resultText");
                  }
                );
                }
              ),
            )
          ),
        ),
					
			),
		);

	}

	Future<String> getImageStoragePath() async { 

		String resultPath = "";

		if(Platform.isAndroid){

			final androidPermissionsList = await DocMan.perms.list();

			androidPermissionsList.sort((a,b)=> b.time.compareTo(a.time));
			resultPath = androidPermissionsList.first.uri;
		}

		else{
			resultPath = "${MyHive.downloadImageDir?.path}";
		}

		return resultPath;
	}

}


class TestTile extends ListTile{
  const TestTile({super.key});

  @override
  Widget build(BuildContext context) {
    return TransitionContainer(
      builder: (_, openAction){
        return SizedBox(
          height: 80,
          child: Center(
            child: ListTile(
              onTap: (){
                openAction();
                //  //Navigator.pushNamed(context, Routes.test);
        
                //  //showSeasonDialog(context);
                //  //showStarSubjectDialog(context);
          
                //  //downloadSticker(isOldType: false);
          
                //  //bus.emit('AppRoute','${BangumiAPIUrls.timelineReply(52089780)}?timelineID=52089780&comment=我难道喜欢看厕纸？');
                
                //  //debugPrint("callAndroidFunction");
          
                //  //await DocMan.perms.list().then((result){
                //  //  debugPrint("list: $result");
                //  //});
          
                //  //DocMan.perms.releaseAll();
          
                //  //await callAndroidFunction();
              },
              title: ScalableText("测试触发工具",style: TextStyle(fontSize: AppFontSize.s16))
            ),
          ),
        );
      },
      next: const TestPage()
    );

    }

}


void saveImageFile(DocumentFile? targetWriteDocument,DocumentFile? selectedDocFile) async {

	if( selectedDocFile == null || targetWriteDocument == null) return;

	debugPrint("目标目录 URI: ${targetWriteDocument.uri}");
	debugPrint("目标目录是否存在 (exists()): ${targetWriteDocument.exists}");
	debugPrint("目标目录是否为目录 (isDirectory()): ${targetWriteDocument.isDirectory}");

	if(targetWriteDocument.isDirectory && targetWriteDocument.canCreate){
		targetWriteDocument.createFile(
			name: selectedDocFile.name,
			bytes: await selectedDocFile.read()
		);
		debugPrint("${selectedDocFile.name} created!");
	}
	

}