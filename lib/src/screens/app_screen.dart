import 'package:flutter/material.dart';
import 'package:tatlacas_flutter_core/src/widgets/zero_height_app_bar.dart';

class AppScreen extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;

  const AppScreen({
    Key? key,
    required this.body,
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? ZeroHeightAppBar(),
      backgroundColor: Theme.of(context).backgroundColor,
      body: body,
    );
  }
}
