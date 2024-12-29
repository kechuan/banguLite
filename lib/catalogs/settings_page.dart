import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


@FFRoute(name: 'settings')
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const ScalableText("设置")),
      body: EasyRefresh(
        child: ListView(
        itemExtent: 50,
          children: const [
            FontSizeTile(),
            Divider(height: 1),
            ColorThemeTile()
          ],
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
        title: ScalableText("文字大小",style: TextStyle(fontSize: AppFontSize.s16)),
        trailing: SizedBox(
          height: 80,
          width: 50*(ScaleType.values.length+0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey.withValues(alpha: 0.2)
            ),
            child: DefaultTabController(
              initialIndex: indexModel.currentScale.index,
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
                //indicator: ,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [
                  SizedBox(width:30,child:Center(child: Text("小"))),
                  SizedBox(width:30,child:Center(child: Text("偏小"))),
                  SizedBox(width:30,child:Center(child: Text("中"))),
                  SizedBox(width:30,child:Center(child: Text("偏大"))),
                  SizedBox(width:30,child:Center(child: Text("大"))),
                ]
              ),
            ),
          ),
        )
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
          title: ScalableText("主题色设置",style: TextStyle(color: indexModel.currentThemeColor.color.withValues(alpha: 0.8))),
          trailing: SizedBox(
            width: 50*(BangumiThemeColor.values.length+1),
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
                          const LinearGradient(
                          begin:Alignment.centerLeft,
                          end:Alignment.centerRight,
                          colors: Colors.primaries
                        ) : null,
                        color: index != BangumiThemeColor.values.length ? BangumiThemeColor.values[index].color.withValues(alpha: 0.8) : null
                      ),
                      
                    ),
                  ),
                );
              },
            ),
          ),
          subtitle: Text("test"),
        );
      }
    );
    
  }

}