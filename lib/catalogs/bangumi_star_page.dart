import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_tile.dart';
import 'package:flutter/material.dart';

class BangumiStarPage extends StatefulWidget {
  const BangumiStarPage({super.key});

  @override
  State<BangumiStarPage> createState() => _BangumiStarPageState();
}

class _BangumiStarPageState extends State<BangumiStarPage> {

  Map<int,Map?> hiveStarMap = {};

  @override
  void initState() {

    for(int currentStarIndex = 0; currentStarIndex<MyHive.starBangumisDataBase.keys.length; currentStarIndex++){
      hiveStarMap.addAll({
        MyHive.starBangumisDataBase.keyAt(currentStarIndex):(MyHive.starBangumisDataBase.values.elementAt(currentStarIndex))
      });
    }

    bus.on("star",(arg){

      debugPrint("star Staus change: update");

      hiveStarMap.clear();

      for(int currentStarIndex = 0; currentStarIndex<MyHive.starBangumisDataBase.keys.length; currentStarIndex++){
        hiveStarMap.addAll({
          MyHive.starBangumisDataBase.keyAt(currentStarIndex):(MyHive.starBangumisDataBase.values.elementAt(currentStarIndex))
        });
      }

      setState(() {
        
      });

    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        toolbarHeight: 60,
        title: const Padding(
          padding: EdgeInsets.only(top: 40,left: 20),
          child: Text("订阅界面"),
        ),
        actions: [
          IconButton(
            onPressed: (){
              showDialog(
                context: context,
                builder: (context){
                  return AlertDialog(
                    title: const Text("重置确认"),
                    content: const Text("要清空所有的订阅信息吗?"),
                    actions:[
                      TextButton(
                        onPressed: (){

                          debugPrint("stars List: ${MyHive.starBangumisDataBase.keys}");

                          debugPrint("value List: ${MyHive.starBangumisDataBase.values}");

                         Navigator.of(context).pop();
                        }, child: const Text("取消")
                      ),
                      TextButton(
                        onPressed: (){

                          MyHive.starBangumisDataBase.clear().then(
                            (value){

                            }
                          );
                          Navigator.of(context).pop();
                        }, 
                        child: const Text("确认")
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
            icon: const Icon(Icons.refresh)
          )
        ],
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 8),
        child: ListView.builder(
          itemCount: hiveStarMap.isEmpty ? 1 : hiveStarMap.length,
          itemBuilder: (_,index){
        
            if(hiveStarMap.isEmpty){
              return const Center(
                child: Text("暂无订阅信息"),
              );
            }
        
            return BangumiListTile(
              imageSize: const Size(100, 150),
              bangumiTitle: hiveStarMap.values.elementAt(index)?["name"],
              imageUrl: hiveStarMap.values.elementAt(index)?["coverUri"],
              trailing: Text("score: ${hiveStarMap.values.elementAt(index)?["score"]}"),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  Routes.subjectDetail,
                  arguments: {"bangumiID":hiveStarMap.keys.elementAt(index)},
                );
              },
            );
            
          },
          
        ),
      ),
    );
  }
}