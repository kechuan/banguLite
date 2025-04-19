import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFRoute(name: '/Groups')
class BangumiGroupsPage extends StatelessWidget {
  const BangumiGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('小组列表'),
      ),

    );
  }
}