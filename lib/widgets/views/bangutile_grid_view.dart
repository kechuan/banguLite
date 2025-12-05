import 'package:bangu_lite/catalogs/subject/bangumi_detail_page.dart';
import 'package:bangu_lite/models/informations/subjects/bangumi_details.dart';
import 'package:bangu_lite/widgets/components/transition_container.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_tile.dart';
import 'package:flutter/material.dart';

class BanguTileGridView extends StatelessWidget {
  const BanguTileGridView({
    super.key,
    
    required this.bangumiLists,
    
  });

  
  final List<BangumiDetails> bangumiLists;

  @override
  Widget build(BuildContext context) {
    if(bangumiLists.isEmpty) return const SizedBox.shrink();

    int mainAxisShowCount = 3; //deafult
                                    
    if(MediaQuery.orientationOf(context) == Orientation.landscape){
      mainAxisShowCount = 4;
    }

    //小于 大约3格 空间时 显示2
    if(MediaQuery.sizeOf(context).width < (200*3) - (200/2) ){
      mainAxisShowCount = 2;
    }

    SliverGridDelegateWithFixedCrossAxisCount gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: mainAxisShowCount,
      mainAxisSpacing: 32,
      crossAxisSpacing: 16,
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),

        child: GridView.builder(
          physics: const ScrollPhysics(),
          shrinkWrap: true, 
          gridDelegate: gridDelegate,
            //Vertical view was given unbounded height 
        
            //此原因是因为 你即不给滚动视图限制空间 它内部也无法第一时间得知它自己多高所报的错误
            
            //解决方案两种 
            //第一种就是给整个滚动空间高度约束 也令它滚动 sizedBox height 500之类的
            //第二种就是给 shrinkWrap: true, 属性 让它自己计算它自己的高度 然后它自己给自己一个约束 这个道理和 intrinsicHeight是差不多的。。

            itemCount: bangumiLists.length,
            itemBuilder: (_,currentBangumiIndex){

              return TransitionContainer(
                builder: (_,openAction){
                  return BangumiGridTile(
                  imageUrl: bangumiLists[currentBangumiIndex].coverUrl,
                  bangumiTitle: bangumiLists[currentBangumiIndex].name,
                  onTap: () {
                      if(bangumiLists[currentBangumiIndex].name!=null){
                        openAction();
                      }
                    },
                );
                }, 
                next: BangumiDetailPage(
                  subjectID: bangumiLists[currentBangumiIndex].id ?? 0,
                  injectBangumiInfoDetail: bangumiLists[currentBangumiIndex],
                ),
              );
          }
        )

      
      ),
    );

  }
}