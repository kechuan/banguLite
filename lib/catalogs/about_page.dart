import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/widgets/dialogs/new_update_dialog.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:url_launcher/url_launcher_string.dart';

@FFRoute(name: 'about')

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
  
    return EasyRefresh(
      child: Scaffold(
        appBar: AppBar(
          title: const ScalableText('关于'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

              Image.asset(
                'assets/icons/icon.png',
                height: 200,
                width: 200,
              ),
          
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Center(child: ScalableText('BanguLite, Lite to Surf Bangumi.',style: TextStyle(fontStyle: FontStyle.italic,color: Colors.blueGrey))),
              ),

              ListView(
                prototypeItem: const ListTile(title: Text("data")),
                shrinkWrap: true,
                children: [
              
                  const ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ScalableText('作者'),
                        ScalableText("kechuan",style:TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
              
                  const ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ScalableText('版本号'),
                        ScalableText(GithubRepository.version,style:TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
              
                  ListTile(
                    title: const ScalableText('检查更新'),
                    onTap: () async {

                      Release release = Release();

                      invokeAsyncToaster() => fadeToaster(context: context, message: "暂无更新");
                      invokeShowUpdateDialog() => showUpdateDialog(context,release);
                      

                      fadeToaster(context: context, message: "检查中...");

                      await pullLatestRelease().then((latestRelease){

                        if(latestRelease==null){ invokeAsyncToaster();}

                        else{
                          release = latestRelease;
                          invokeShowUpdateDialog();
                        }
                        
                      });

                      
                    },
                  ),
              
                  ListTile(
                    onTap: () => launchUrlString("https://github.com/kechuan/banguLite/issues"),
                    title: const ScalableText('意见反馈'),
                  ),
              
                ],
              ),
            ],
          ),
        ),
        
      ),
    );
  }
}

void showUpdateDialog(BuildContext context,Release latestRelease){
  showModalBottomSheet(
    context: context, 
    constraints: BoxConstraints(
      maxWidth: MediaQuery.sizeOf(context).width*5/6,
      maxHeight: MediaQuery.sizeOf(context).height*3/5+MediaQuery.paddingOf(context).bottom+20
    ),
    builder: (_)=> NewUpdateDialog(latestRelease:latestRelease)
  );
}