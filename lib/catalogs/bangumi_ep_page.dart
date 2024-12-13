
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/eps_info.dart';
import 'package:bangu_lite/models/providers/ep_model.dart';
import 'package:bangu_lite/widgets/components/ep_comments.dart';
import 'package:bangu_lite/widgets/fragments/ep_toggle_panel.dart';
import 'package:bangu_lite/widgets/fragments/skeleton_listtile_template.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher_string.dart';


@FFRoute(name: '/subjectEp')

class BangumiEpPage extends StatefulWidget {
  const BangumiEpPage({
    super.key,
    required this.epModel,
    required this.totalEps
  });

  final EpModel epModel;
  final int totalEps;

  @override
  State<BangumiEpPage> createState() => _BangumiEpPageState();
}

class _BangumiEpPageState extends State<BangumiEpPage> {

  Future<void>? epsInformationFuture;

  @override
  Widget build(BuildContext context) {

    //return ChangeNotifierProvider(
	return ChangeNotifierProvider.value(
		value: widget.epModel,
		builder: (context,child){

			final epModel = widget.epModel;

			//final ScrollController scrollController = ScrollController();

			epsInformationFuture ??= epModel.getEpsInformation(offset: epModel.selectedEp~/100 );

			return EasyRefresh.builder(
			//  footer: const MaterialFooter(),
				header: const MaterialHeader(),

				childBuilder: (_,physics) {
					return Scaffold(
						appBar: AppBar(
							title: Selector<EpModel,int>(
								selector: (_, epModel) => epModel.selectedEp,
								shouldRebuild: (previous, next) => previous!=next,
								builder: (_,selectedEp,__) => Text("第$selectedEp集 ${epModel.epsData[selectedEp]!.nameCN} ")
							),
							actions: [

								IconButton(
									onPressed: () async {
										if(await canLaunchUrlString(BangumiWebUrls.ep(epModel.epsData[epModel.selectedEp]!.epID!))){
										await launchUrlString(BangumiWebUrls.ep(epModel.epsData[epModel.selectedEp]!.epID!));
										}
									},
									icon: Transform.rotate(
										angle: -45,
										child: const Icon(Icons.link),
									)
								),


							],
						),
						body:  Selector<EpModel,Map<int,EpsInfo>>(
							selector: (_, epModel) => epModel.epsData,
							shouldRebuild: (previous, next) => previous.length != next.length,
							builder: (_,epsData,child) {
	
								return Selector<EpModel,int>(
									selector: (_, epModel) => epModel.selectedEp,
									shouldRebuild: (previous, next) => previous != next,
									builder: (_,selectedEp,child){
	
										return CustomScrollView(
											physics:physics,
											slivers: [
	
												SliverList(
													delegate: SliverChildListDelegate(
														[
															EpInfo(epsInfo: epsData,selectedEp: selectedEp),

															//迟早变成 SliverAppbar

															 FutureBuilder(
																future: epsInformationFuture,
																builder: (_,snapshot){
																	return EpTogglePanel(currentEp: selectedEp,totalEps: widget.totalEps);
																}
															),

													
														]
													)
												),
	
												child!


	
											],	
										);
										
									},
									
									child: const EpCommentDetails()

								);
	
	
							}
						)
					
						
						
						
					);
				}
				
				


			);
		},
	  );
    
  }
}

class EpInfo extends StatelessWidget {
  
  const EpInfo({
    super.key,
    required this.epsInfo,
    required this.selectedEp,
  });

  final Map<int,EpsInfo> epsInfo;
  final int selectedEp;


  @override
  Widget build(BuildContext context) {

    if(epsInfo.isEmpty){
      return const Skeletonizer(
        child: SkeletonListTileTemplate()
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        ListTile(
          title: Row(
            children: [
              Text("${epsInfo[selectedEp]!.nameCN ?? epsInfo[selectedEp]!.name}"),
              const Padding(padding: PaddingH6),
              Text("${epsInfo[selectedEp]!.airDate}",style: const TextStyle(fontSize: 14,color: Colors.grey)),
            ],
          ),
          
        ),

        ListTile(
          title:  SelectableText("${epsInfo[selectedEp]!.description}"),
        ),

       
      ],
    );
  }
}

class EpCommentDetails extends StatelessWidget {
	const EpCommentDetails({
		super.key,
	});


	@override
	Widget build(BuildContext context) {

		return Selector<EpModel,List?>(
			selector: (_, epModel) => epModel.epCommentData[epModel.selectedEp],
			shouldRebuild: (previous, next)=> previous!=next,
			
			builder: (_,currentEpCommentData,child){
				
				return FutureBuilder(
					future: context.read<EpModel>().loadEp(),
					builder: (_,snapshot) {

						final epModel = context.read<EpModel>();
						int currentEp = epModel.selectedEp;
				
						debugPrint("currentEp:$currentEp");

						bool isCommentLoading = epModel.epCommentData[currentEp] == null || epModel.epCommentData[currentEp]!.isEmpty;

						return Skeletonizer.sliver(
							enabled: isCommentLoading,
							child: SliverList.separated(
								itemCount: isCommentLoading ? 3 : epModel.epCommentData[currentEp]!.length+1,
								itemBuilder: (_,epCommentIndex){
									//Loading...
									if(isCommentLoading){
										return const SkeletonListTileTemplate();
									}

									if(epCommentIndex == 0){
										int commentCount = 0;

										if(epModel.epCommentData[epModel.selectedEp]![0].userId != 0){
											commentCount = epModel.epCommentData[epModel.selectedEp]!.length;
										}

										return Padding(
											padding: const EdgeInsets.all(16),
											child: Row(
												children: [
													const Text("吐槽箱",style: TextStyle(fontSize: 24)),
																		
													const Padding(padding: PaddingH6),
																		
													Text("$commentCount",style: const TextStyle(color: Colors.grey)),

                          //BBCode测试
                          //BBCodeText(
                          //  //data: "[img=36]这是一个测试[/img] [color=#FF0000]这是另一个测试[/color]", 
                          //  //data: "[img]https://p.sda1.dev/19/c25b1394330e0a0da6f140ececce3015/1dec650d1b1ee1a139ea09f81246d53d.png[/img]",
                          //  data: "[img]https://i.yusa.me/RwiYjbYD7yGL.webp[/img]",
                            
                          //  stylesheet: BBStylesheet(
                          //    tags: [
                          //      SizeTag(),
                          //      ColorTag(),
                          //      LateLoadImgTag()
                          //    ]
                          //  ),
                          //)

												],
											),
										);
									}
								
									//无评论的显示状态
									if(epModel.epCommentData[currentEp]![0].userId == 0){
										return const Center(
											child: Padding(
												padding: EdgeInsets.only(top:64),
												child: Text("该集数暂无人评论...",style: TextStyle(fontSize: 16)),
											),
										);
									}
									
								
									return EpCommentView(epCommentData: epModel.epCommentData[currentEp]![epCommentIndex-1]);
								},
								separatorBuilder: (_,__,) => const Divider(height: 1), 
							),
						);

					}
				);
			}
		);
	}
}

