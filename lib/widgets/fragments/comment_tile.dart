import 'package:flutter/material.dart';
import 'package:flutter_bangumi/internal/convert.dart';
import 'package:flutter_bangumi/models/comment_details.dart';
import 'package:flutter_bangumi/widgets/fragments/cached_image_loader.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.commentData
  });

  final CommentDetails commentData;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          children: [
        
          commentData.avatarUri!=null ? 
                
            SizedBox(
              height: 50,
              width: 50,
              child: CachedImageLoader(imageUrl: commentData.avatarUri!)
            ) : 
                
            const FlutterLogo(),
        
            Text(commentData.nickName ?? "nameID",style: const TextStyle(color: Colors.blue)),
          ],
        ),
      ),

      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(commentData.comment ?? "comment"),
          Row(
            children: [
  
              Builder(builder: (_){
                DateTime commentStamp = DateTime.fromMillisecondsSinceEpoch(commentData.commentTimeStamp!*1000);
                return Text(
                  "${commentStamp.year}-${convertDigitNumString(commentStamp.month)}-${convertDigitNumString(commentStamp.day)} ${convertDigitNumString(commentStamp.hour)}:${convertDigitNumString(commentStamp.minute)}"
                );
              }),
                
              const Spacer(),  
  
              Row(
                children: [
                  const Icon(Icons.arrow_upward_outlined),
                  Text('(${commentData.rate})')
                ],
              )
            ],
          )
        ],
      ),
    );
                            
  }
}