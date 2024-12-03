

import 'dart:math';

import 'package:bangu_lite/models/providers/ep_model.dart';
import 'package:bangu_lite/widgets/components/ep_comments.dart';
import 'package:bangu_lite/widgets/fragments/skeleton_listtile_template.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';


@FFRoute(name: '/subjectEp')

class BangumiEpPage extends StatefulWidget {
  const BangumiEpPage({
    super.key,
    required this.subjectID,
    this.epIndex
    //required this.epsInformation
  });

  final int subjectID;
  final int? epIndex;

  //final Map<String,dynamic> epsInformation;

  @override
  State<BangumiEpPage> createState() => _BangumiEpPageState();
}

class _BangumiEpPageState extends State<BangumiEpPage> {

  @override
  Widget build(BuildContext context) {


    return ChangeNotifierProvider(
      create: (_) => EpModel(subjectID: widget.subjectID,selectedEp: widget.epIndex ?? 1),
      builder: (context,child){

        final epModel = context.read<EpModel>();

        return EasyRefresh(
          footer: const MaterialFooter(),
          header: const MaterialHeader(),
          onRefresh: () => epModel.loadEps(),
          onLoad: () => debugPrint("下拉加载"),
          child: Scaffold(
            appBar: AppBar(
              title: Text("Ep.${widget.epIndex} current EpName(CN)"),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            
              children: [
            
                const EpInfo(),
            
                //做成悬浮样式 监听scrollNotification
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  
                      InkResponse(
                        onTap: () => epModel.updateSelectedEp(max(1,epModel.selectedEp-1)),
                        child:  Row(
                          children: [
                            const Icon(Icons.arrow_back_ios,size: 18),
                            const Padding(padding: EdgeInsets.symmetric(horizontal: 6)),
                            Text(
                              "上一话 Ep. ${max(1,epModel.selectedEp-1)} Name",
                              style: TextStyle(color: epModel.selectedEp == 1 ? Colors.grey : null),
                            ),
                          ],
                        ),
                      ),
                  
                      InkResponse(
                        onTap: () => epModel.updateSelectedEp(min(epModel.epsData.length,epModel.selectedEp+1)),
                        child:  Row(
                          children: [
                            Text(
                              "下一话 Ep. ${min(epModel.epsData.length,epModel.selectedEp-1)} Name",
                              style: TextStyle(color: epModel.selectedEp == epModel.epsData.length ? Colors.grey : null),
                            ),
            
                            const Padding(padding: EdgeInsets.symmetric(horizontal: 6)),
                            const Icon(Icons.arrow_forward_ios,size: 18),
                          ],
                        ),
                      ),
                  
                    ],
                  ),
                ),
            
                //吐槽箱 (count)
                Expanded(
                  child: EpCommentDetails(),
                )
            
              ],
            ),
          ),
        );
      },
    );
  }
}

class EpInfo extends StatelessWidget {
  
  const EpInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text("current Eps"),
          subtitle: Text("current Ep status"),
        ),


        ListTile(
          title:  SelectableText(
            "desc"
          ),
        ),

       
      ],
    );
  }
}

class EpCommentDetails extends StatefulWidget {
  const EpCommentDetails({super.key});

  @override
  State<EpCommentDetails> createState() => _EpCommentDetailsState();
}

class _EpCommentDetailsState extends State<EpCommentDetails> {

  @override
  void initState() {
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
    
        const Padding(
          padding:  EdgeInsets.all(16),
          child: Row(
            
            children: [
                Text("吐槽箱",style: TextStyle(fontSize: 24)),

                Padding(padding: EdgeInsetsDirectional.symmetric(horizontal: 6)),

                Text("33",style: TextStyle(color: Colors.grey))
            ],
          ),
        ),

          Expanded(
            child: Selector<EpModel,int?>(
              selector: (_, epModel) => epModel.selectedEp,
              shouldRebuild: (previous, next) => previous!=next,
              builder: (_,currentEp,child){

                final epModel = context.read<EpModel>();

                debugPrint("currentEp:$currentEp");

                //策略转变 不再分页 而是下拉加载

                return FutureBuilder(
                  future: Future.delayed(Duration.zero),
                  builder: (_,snapshot) {

                    //snapshot充当rebuild

                    return Skeletonizer(
                      enabled: epModel.epCommentData[currentEp] == null,
                      child: AnimatedList.separated(
                        initialItemCount: epModel.epCommentData[currentEp] != null ? epModel.epCommentData[currentEp]!.length : 1,
                        itemBuilder: (_,epCommentIndex,animation){
                    
                          //Loading...
                          if(epModel.epCommentData[currentEp] == null) return const SkeletonListtileTemplate();
                    
                          //无评论的显示状态
                          if(epModel.epCommentData[currentEp]!.isEmpty) return const Center(child: Text("该集数暂无人评论..."));

                          return EpCommentView(
                            epCommentData: epModel.epCommentData[currentEp]![epCommentIndex],
                          );

                    
                        }, 
                        separatorBuilder: (_,__,___) => const Divider(height: 1), 
                        removedSeparatorBuilder: (_,__,___) => const SizedBox.shrink()
                      ),
                    );
                  }
                );

                 
              },
            ),
          ),
              
        
      ],
    );
  }
}