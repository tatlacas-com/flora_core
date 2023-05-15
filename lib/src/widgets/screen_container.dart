import 'package:flutter/material.dart';
import 'package:tatlacas_flutter_core/src/widgets/zero_height_app_bar.dart';

class ScreenContainer extends StatelessWidget {

  const ScreenContainer({
    super.key,
    required this.body,
    this.appBar,
  });
  final Widget body;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? ZeroHeightAppBar(),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: body,
    );
  }
}
