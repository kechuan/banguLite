import 'package:bangu_lite/delegates/search_delegates.dart';
import 'package:flutter/material.dart';

class BuildTags extends StatelessWidget {
  const BuildTags({
    super.key,
    required this.tagsList
  });

  final Map tagsList;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (_){
        if(tagsList.isNotEmpty){
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(tagsList.length, (index){
                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(width: 0.5,color: const Color.fromARGB(255, 219, 190, 213))
                  ),
                  child: TextButton(
                    child: Text(
                      "${tagsList.keys.elementAt(index)} ${tagsList.values.elementAt(index)}",
                      style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),
                    ),
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: CustomSearchDelegate(),
                        query: tagsList.keys.elementAt(index)
                      );
                    },
                    
                  )
                );
              }),
          );
        }
    
        return const Text("暂无Tags信息");
      }
    );
  }
}
