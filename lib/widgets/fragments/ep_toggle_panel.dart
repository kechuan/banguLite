import 'dart:math';

import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/models/providers/ep_model.dart';
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
    
    //迟早变成 SliverAppbar
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 16),
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
                        //终末


                        //越过边境线 需求加载
                        if( currentEp != 1 && epModel.epsData[currentEp-1] == null){

                          	return Row(
								children: [
									Text("Ep. ${currentEp-1}}",style: const TextStyle(color: Colors.grey),),

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
						  child: Text(
							"Ep. ${max(1,currentEp-1)} ${epModel.epsData[max(1,currentEp-1)]!.nameCN ?? epModel.epsData[max(1,currentEp-1)]!.name}",
							style: TextStyle(color: currentEp == 1 ? Colors.grey : null),
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

                  if(currentEp+1 != totalEps){
                    if(epModel.epsData[(currentEp+1)]?.epID == null){
                    //  epsInformationFuture = epModel.getEpsInformation(offset: currentEp~/100 );
                      //epsInformationFuture = epModel.updateSelectedEp(min(currentEp+1,totalEps));
                   
                      
                    }
                  }
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
                              Text("Ep. ${currentEp+1}",style: const TextStyle(color: Colors.grey),),

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
                          child: Text(
                            "Ep. ${min(totalEps,currentEp+1)} ${epModel.epsData[min(totalEps,currentEp+1)]?.nameCN ?? epModel.epsData[min(totalEps,currentEp+1)]?.name ?? "loading"}",
                            style: TextStyle(color: currentEp == totalEps ? Colors.grey : null),
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