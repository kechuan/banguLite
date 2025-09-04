import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';

const String largePadding =  """
  你说的对 但是BangumiLite是一个我用于练手的项目, 你将扮演一个刚从GetX思维迁移过来的人。
  品尽由于 Provider依赖的inheritedWidget 所导致的多重rebuild问题
  导致你不得不在FutureLoader的处理上返回状态 而不是结果。
  直到后面才认知这个行为叫 SideEffect 附带效应 的故事
""";

const String mediumnPadding =  """
  你说的对 但是BanguLite实际上也并没有能让我逃脱的项目.
  我收获了实践的知识,但空虚感与恐惧却与日俱增.
  我并不清楚也不敢面对未来的事物.
""";

const String smallPadding =  """
  正经人谁写日记啊? 你写日记吗? 
  我不写 你写日记吗? 
  我也不写
""";

class SkeletonListTileTemplate extends StatelessWidget {
  const SkeletonListTileTemplate({
    super.key,
    this.scaleType = ScaleType.max

  });

  final ScaleType? scaleType;

  @override
  Widget build(BuildContext context) {

    String paddingScale = largePadding;

    switch(scaleType){
      case ScaleType.max: paddingScale = largePadding; break;
      case ScaleType.medium: paddingScale = mediumnPadding; break;
      case ScaleType.min: paddingScale = smallPadding; break;
      default: paddingScale = largePadding; break;
    }

    return  ListTile(
      title: const ScalableText("骨架似乎无法识别修饰类的改变。只能使用现有的Widget"),
      subtitle:  Padding(
        padding: const EdgeInsets.only(top:16),
        child: ScalableText(paddingScale),
      ),
      leading: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Icon(
          Icons.circle,
          size: 48,
        ),
      )
    );
  }
}