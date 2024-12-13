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
          itemCount: MyHive.starBangumisDataBase.keys.isEmpty ? 1 : MyHive.starBangumisDataBase.keys.length,
          itemBuilder: (_,index){
        
            if(MyHive.starBangumisDataBase.keys.isEmpty){
              return const Center(
                child: Text("暂无订阅信息"),
              );
            }
        
            return BangumiListTile(
              imageSize: const Size(100, 150),
              bangumiTitle: MyHive.starBangumisDataBase.values.elementAt(index)["name"],
              imageUrl: MyHive.starBangumisDataBase.values.elementAt(index)["coverUri"],
              trailing: Text("score: ${MyHive.starBangumisDataBase.values.elementAt(index)["score"]}"),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  Routes.subjectDetail,
                  arguments: {"bangumiID":MyHive.starBangumisDataBase.keys.elementAt(index)},
                );
              },
            );
            
          },
          
        ),
      ),
    );
  }
}