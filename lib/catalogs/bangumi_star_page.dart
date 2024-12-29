import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_tile.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';

class BangumiStarPage extends StatefulWidget {
  const BangumiStarPage({super.key});

  @override
  State<BangumiStarPage> createState() => _BangumiStarPageState();
}

class _BangumiStarPageState extends State<BangumiStarPage> {

  @override
  void initState() {
    bus.on("star", (arg){
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(      
      appBar: AppBar(
        
        toolbarHeight: 60,
        title: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: ScalableText("订阅界面"),
        ),
        actions: [
          IconButton(
            onPressed: (){
              showDialog(
                context: context,
                builder: (context){
                  return AlertDialog(
                    title: const ScalableText("重置确认"),
                    content: const ScalableText("要清空所有的订阅信息吗?"),
                    actions:[
                      TextButton(
                        onPressed: (){

                          debugPrint("stars List: ${MyHive.starBangumisDataBase.keys}");

                          debugPrint("value List: ${MyHive.starBangumisDataBase.values}");

                         Navigator.of(context).pop();
                        }, child: const ScalableText("取消")
                      ),
                      TextButton(
                        onPressed: (){

                          setState(() {
                            MyHive.starBangumisDataBase.clear();
                          });
                          
                          Navigator.of(context).pop();
                        }, 
                        child: const ScalableText("确认")
                      )
                    ]
                  );
                }
              );
              

              //showDialog(
              //  context: context,
              //  builder: 
              //);
            },
            icon: const Icon(Icons.close)
          )
        ],
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 8),
        child: ListView.builder(
          itemCount: MyHive.starBangumisDataBase.keys.isEmpty ? 1 : MyHive.starBangumisDataBase.keys.length,
          itemBuilder: (_,index){
        
            if(MyHive.starBangumisDataBase.keys.isEmpty){
              return const Center(
                child: ScalableText("暂无订阅信息"),
              );
            }
        
            return BangumiListTile(
              imageSize: const Size(100, 150),
              bangumiTitle: MyHive.starBangumisDataBase.values.elementAt(index)["name"],
              imageUrl: MyHive.starBangumisDataBase.values.elementAt(index)["coverUrl"],
              trailing: ScalableText("score: ${MyHive.starBangumisDataBase.values.elementAt(index)["score"]}"),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  Routes.subjectDetail,
                  arguments: {"subjectID":MyHive.starBangumisDataBase.keys.elementAt(index)},
                );
              },
            );
            
          },
          
        ),
      ),
    );
  }
}