import 'package:flutter/material.dart';

class ZeroHeightAppBar extends PreferredSize {
  ZeroHeightAppBar({
    Key? key,
  }) : super(
          key: key,
          child: AppBar(
            elevation: 0,
          ),
          preferredSize: const Size.fromHeight(0),
        );
}
