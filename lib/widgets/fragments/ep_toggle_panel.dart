import 'dart:math';

import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/eps_info.dart';
import 'package:bangu_lite/models/providers/ep_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EpTogglePanel extends StatelessWidget {
  const EpTogglePanel({
    super.key,
    required this.currentEp,
    required this.totalEps,

  });

  final int currentEp;
  final int totalEps;

  @override
  Widget build(BuildContext context) {

    final EpModel epModel = context.read<EpModel>();
    //final IndexModel indexModel = context.read<IndexModel>();
    
    //迟早变成 SliverAppbar
    return Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
    
              InkResponse(
                containedInkWell: true,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () => epModel.updateSelectedEp(max(1,currentEp-1)),
                child:  Row(
                  children: [
    
                    const Icon(Icons.arrow_back_ios,size: 18),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 6)),
    
                    Builder(
                      builder: (_){

                        //越过边境线 需求加载
                        if( currentEp != 1 && epModel.epsData[currentEp-1] == null){
    
                            return Row(
                              children: [
                                ScalableText("${convertEPInfoType(epModel.epsData[currentEp-1]?.type)} ${currentEp-1}}",style: const TextStyle(color: Colors.grey,fontFamily: "MiSansFont")),
    
                                const Padding(padding: PaddingH6),
    
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:  CircularProgressIndicator(strokeWidth: 3)
                                )
                              ],
                            );
                        }
    
    
                        //常规条件
                        return ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width/3),
                          child: ScalableText(
                            convertCollectionName(epModel.epsData[max(1,currentEp-1)]!, max(1,currentEp-1)),
                            style: TextStyle(
                              color: currentEp == 1 ? Colors.grey : judgeDarknessMode(context) ? Colors.white : Colors.black,
                              fontFamily: "MiSansFont"
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }
                    ),
    
                  ],
                ),
              ),
    
              InkResponse(
                containedInkWell: true,
                highlightColor: Colors.transparent,	
                hoverColor: Colors.transparent,
                onTap: (){
    
                  //debugPrint("${epModel.epsData[(currentEp+1)]}");
                  if(epModel.epsData[(currentEp+1)]?.epID == null) return;
                  epModel.updateSelectedEp(min(currentEp+1,totalEps));
                },
                child:  Row(
                  children: [
    
                    Builder(
                      builder: (_){
    
                        //越过边境线 需求加载
                        if( epModel.epsData[currentEp+1]?.epID == null && currentEp+1 <= totalEps){
                          return Row(
                            children: [
                              ScalableText("${convertEPInfoType(epModel.epsData[currentEp+1]?.type)}. ${currentEp+1}",style: const TextStyle(color: Colors.grey,fontFamily: "MiSansFont"),),
    
                              const Padding(padding: PaddingH6),
    
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child:  CircularProgressIndicator(strokeWidth: 3)
                              )
                            ],
                                          
                            );
                        }
    
    
                        //常规条件
                        return ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width/3) ,
                          child: ScalableText(
                            convertCollectionName(epModel.epsData[min(totalEps,currentEp+1)]!, min(totalEps,currentEp+1)),                            
                            style: TextStyle(color: currentEp == totalEps ? Colors.grey :judgeDarknessMode(context) ? Colors.white : Colors.black,fontFamily: "MiSansFont"),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }
                    ),
    
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 6)),
                    const Icon(Icons.arrow_forward_ios,size: 18),
                  ],
                ),
            ),
    
            ],
          ),
      );
  }
}