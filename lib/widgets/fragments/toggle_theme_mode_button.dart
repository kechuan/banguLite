import 'dart:math';

import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ToggleThemeModeButton extends StatelessWidget {
  const ToggleThemeModeButton({
    super.key,
    this.isDetailText,
    this.onThen
  });

  final void Function()? onThen;
  final bool? isDetailText;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      containedInkWell: true,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: (){

        final indexModel = context.read<IndexModel>();

        if(indexModel.userConfig.themeMode == ThemeMode.dark || judgeDarknessMode(context)){
          indexModel.updateThemeMode(ThemeMode.light);
        }
        else{
          indexModel.updateThemeMode(ThemeMode.dark);
        }

        if(onThen != null) onThen!();
          
      },
      child: Selector<IndexModel,ThemeMode>(
        selector: (_, indexModel) => indexModel.userConfig.themeMode!,
        shouldRebuild: (previous, next) => previous!=next,
        builder: (_, currentTheme, child){

          if(isDetailText == true){
            return ListTile(
              leading: Icon(
                judgeDarknessMode(context) ? 
                Icons.dark_mode_outlined :
                Icons.wb_sunny_outlined,
                size: min(30,MediaQuery.sizeOf(context).width/15)
              ),
              title: const Text("切换主题模式"),
            );
          }

          else{
            return Icon(
              judgeDarknessMode(context) ? 
              Icons.dark_mode_outlined :
              Icons.wb_sunny_outlined,
              size: min(30,MediaQuery.sizeOf(context).width/15)
            );
          }

        },
      ),
    );
  }
}