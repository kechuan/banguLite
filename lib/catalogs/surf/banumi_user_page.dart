import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@FFRoute(name: 'userPage')
class BanumiUserPage extends StatelessWidget {
  const BanumiUserPage({
    super.key,

  });

  @override
  Widget build(BuildContext context) {

    final accountModel = context.read<AccountModel>();

    accountModel;

    return Scaffold(
      appBar: AppBar(),
      body: const SizedBox.shrink(),
    );
  }
}