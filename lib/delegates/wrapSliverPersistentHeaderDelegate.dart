import 'package:flutter/material.dart';

class WrapSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  WrapSliverPersistentHeaderDelegate({
    required this.maxExtent,
    required this.minExtent,
    required this.onBuild,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return onBuild(context, shrinkOffset, overlapsContent);
  }

  @override
  final double maxExtent;
  @override
  final double minExtent;

  final Widget Function(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) onBuild;


  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate.maxExtent != maxExtent ||
    oldDelegate.minExtent != minExtent;
    
  }
}