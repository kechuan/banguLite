import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/models/providers/user_model.dart';
import 'package:bangu_lite/models/timeline_details.dart';
import 'package:bangu_lite/models/user_details.dart';
import 'package:bangu_lite/widgets/dialogs/general_transition_dialog.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class UserInformationDialog extends StatelessWidget {
  const UserInformationDialog({
    super.key,
    this.userInformation
  });

  final UserInformation? userInformation;

  @override
  Widget build(BuildContext context) {
    final accountModel = context.read<AccountModel>();
    final userModel = context.read<UserModel>();

    return Dialog(
		backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha:0.9), 
		child: ConstrainedBox(
    		  constraints: BoxConstraints(
    			maxHeight: MediaQuery.sizeOf(context).height/2 > 200 ? MediaQuery.sizeOf(context).height/2 : 200,
    			maxWidth: MediaQuery.sizeOf(context).width/1.5 > 300 ? MediaQuery.sizeOf(context).width/1.5 : 300,
    			minHeight: 200,
    			minWidth: 300
    		  ),
    		  
    		  child: Column(
    			spacing: 6,
    			children: [
    		  
    			  Padding(
    				padding: Padding12,
    				child: SizedBox(
    				  height: 60,
    				  child: Row(
    					spacing: 6,
    					crossAxisAlignment: CrossAxisAlignment.center,
    					
    					children: [
    						  
    					  SizedBox(
    						height: 50,
    						width: 50,
    						child: CachedImageLoader(imageUrl: userInformation?.avatarUrl)
    					  ),
    						  
    					  //可压缩信息 Expanded
    					  Expanded(
    						child: UnVisibleResponse(
    						  onTap: () {
    						  Clipboard.setData(ClipboardData(text: '${userInformation?.userName}'));
    						  fadeToaster(context: context,message: "已复制用户ID");
    						  },
    						  child: ScalableText(
    						  userInformation?.nickName ?? userInformation?.userName ?? "no data",
    						    style: const TextStyle(color: Colors.blue),
    						    maxLines: 2,
    						    overflow: TextOverflow.ellipsis,
    						    textAlign: TextAlign.center,
    						  ),
    						),
    					  ),
    
    					  Column(
    						children: [
    
    						  TextButton(
    							onPressed: (){},
    							child: const ScalableText(
    							  "TA的主页",
    							  style: TextStyle(decoration: TextDecoration.underline),
    							)
    						  ),
    
    						  Row(
    							  spacing: 12,
    							  mainAxisAlignment: MainAxisAlignment.end,
    							  children: [
    				  
    								UnVisibleResponse(
    								  onTap: (){
    									if(accountModel.loginedUserInformations.accessToken == null) return;
    								  },
    								  child: Icon(
    									Icons.email_outlined,
    									color: accountModel.loginedUserInformations.accessToken == null ? Colors.grey : null,
    								  )
    								  
    								),
    				  
    								UnVisibleResponse(
    								  onTap: (){
    									if(accountModel.loginedUserInformations.accessToken == null) return;
    									showTransitionAlertDialog(
    									  context,
    									  title: "发送好友请求",
    									  content: "确定对用户 ${userInformation?.nickName ?? userInformation?.userName} 发送好友请求吗?",
    									  confirmAction: () async {
    				  
                          invokeAsyncToaster(String message) => fadeToaster(context: context, message: message);

                          accountModel.userRelationAction(
                            userInformation?.userName,
                            fallbackAction: (errorMessage) => invokeAsyncToaster(errorMessage),
                          ).then((status){
                            if(status){
                              invokeAsyncToaster("发送请求成功");
                            }
                            
                          });
    				  
    									  },
    				  
    									);
    								  },
    								  child: Icon(
    								  
    									MdiIcons.accountPlusOutline,
    									color: accountModel.loginedUserInformations.accessToken == null ? Colors.grey : null,
    								  )
    								),
    				  
    								UnVisibleResponse(
    								  onTap: (){
    									if(accountModel.loginedUserInformations.accessToken == null) return;
    									showTransitionAlertDialog(
    									  context,
    									  title: "拉黑用户",
    									  content: "确定拉入用户 ${userInformation?.nickName ?? userInformation?.userName} 进黑名单吗?",
    									  confirmAction: () async {
    				  
    										invokeAsyncToaster(String message)=> fadeToaster(context: context, message: message);

                        accountModel.userRelationAction(
                          userInformation?.userName,
                          relationType: UserRelationsActionType.block,
                          fallbackAction: (errorMessage) => invokeAsyncToaster(errorMessage),
                        ).then((_){
                          invokeAsyncToaster("拉黑成功");
                        });

    									  },
    				  
    									);
    								  },
    								  child: Icon(
    									Icons.no_accounts_outlined,
    									color: accountModel.loginedUserInformations.accessToken == null ? Colors.grey : null,
    								  )
    								)
    							  ],
    							)
    						  
    						],
    					  ),
    
    
    					  
    					],
    				  ),
    				),
    			  ),
    
    			  Expanded(
    				  child: EasyRefresh(
    					child: FutureBuilder(
    					  future: userModel.loadUserInfomation(userInformation?.userName, userInformation),
    					  builder: (_,snapshot) {
    					
    						final timelineActions = userModel.userData[userInformation?.userName]?.timelineActions;
    					
    						switch(snapshot.connectionState){
    						  case ConnectionState.done:{
    							return LayoutBuilder(
    							  builder: (_,constraint) {
    								return Column(
										spacing: 6,
    									children: [
    										Row(
    											mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    											children: [
    										
    											ScalableText(
    												"${covertPastDifferentTime(timelineActions?[0].timelineCreatedAt)} 来过",
    												style: const TextStyle(fontSize: 14,color: Colors.grey),
    											),
    										
    										
    											Builder(
    												builder: (_) {
    														
														DateTime joinTime = DateTime.fromMillisecondsSinceEpoch((userInformation?.joinedAtTimeStamp ?? 0)*1000);
																
														return ScalableText(
															"加入时间: ${joinTime.year}-${convertDigitNumString(joinTime.month)}-${convertDigitNumString(joinTime.day)}",
															style: const TextStyle(fontSize: 14,color: Colors.grey),
														);
    												}
    											),
    												
    										
    											],
    										),

											// 收藏数据
    										Builder(
    										  builder: (_) {
												final statListData = convertSubjectStat(userModel.userData[userInformation?.userName]?.subjectStat);
    										    return Wrap(
													spacing: 6,
													runSpacing: 12,
													children: List.generate(
														StarType.values.length-1,
														(index){
															return ScalableText(
																"${StarType.values[index].starTypeName} ${statListData[index]}",
																style: const TextStyle(color: Colors.grey,fontSize: 14),

															);
														},
														
													),
												);
    										  }
    										),
    										
    									
    										const Padding(
    											padding: PaddingH16V6,
    											child: Align(
    												alignment: Alignment.centerLeft,
    												child: ScalableText("最近动态",style: TextStyle(fontSize: 16))
    										)),
    										
    										Expanded(
    											child: Padding(
    											padding: PaddingH12+Padding16,
    											child: ListView.separated(
    												itemCount: timelineActions?.length ?? 0,
    												separatorBuilder: (_, index) => const Padding(padding: PaddingV6),
    												itemBuilder: (_, index) {
    											
    												return Wrap(
														spacing: 6,
    													children: [
															ScalableText(
																covertPastDifferentTime(timelineActions![index].timelineCreatedAt),
																style: const TextStyle(color: Colors.blueGrey,fontSize: 14),
															),

															BBCodeText(
																data: convertTimelineDescription(timelineActions[index]),
																stylesheet: BBStylesheet(
																	tags: allEffectTag,
																	defaultText: TextStyle(
																		fontFamily: 'MiSansFont',
																		fontSize: AppFontSize.s16,
																		//奇怪 这里必须特地指定属性。。但是其他的地方却不需要 我感觉是 Dialog作用域 + TextStyle 带来的问题
																		color: judgeDarknessMode(context) ? Colors.white : Colors.black,
																	)
																)
															),
    													],
    												);
    											
    												},
    												shrinkWrap: true,
    												
    											
    											),
    											),
    										),
    									  
    									  
    									],
    								  );
    							  }
    							);
    							
    						  }
    					
    						  default: return const Center(child: CircularProgressIndicator());
    						}
    					
    						}
    					),
    				  ),
    				),
    		  
    			  
    
    			],
    		  ),
    		),
    );
  
  }
}

void showUserInfomationDialog(BuildContext context,UserInformation? userInformation){
  showGeneralDialog(
    barrierDismissible: true,
    barrierLabel: "'!barrierDismissible || barrierLabel != null' is not true",
    context: context,
    transitionBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation,child: child),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_,inAnimation,outAnimation){

      return UserInformationDialog(userInformation: userInformation);
      
    }
  );
}