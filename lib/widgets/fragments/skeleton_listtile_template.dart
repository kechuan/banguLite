import 'package:flutter/material.dart';

class SkeletonListtileTemplate extends StatelessWidget {
  const SkeletonListtileTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      title: Text("骨架似乎无法识别修饰类的改变。只能使用现有的Widget"),
      subtitle:  Padding(
        padding: EdgeInsets.only(top:16),
        child: Text(
          """
            你说的对 但是BangumiLite是一个我用于练手的项目, 你将扮演一个刚从GetX思维迁移过来的人。
            品尽由于 Provider依赖的inheritedWidget 所导致的多重rebuild问题
            导致你不得不在FutureLoader的处理上返回状态 而不是结果。
            直到后面才认知这个行为叫 SideEffect 附带效应 的故事
          """
        ),
      ),
      leading: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Icon(
          Icons.circle,
          size: 48,
        ),
      )
    );
  }
}